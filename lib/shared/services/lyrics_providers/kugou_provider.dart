/// KuGou lyrics (https://www.kugou.com). Ported from musicfy's KuGou provider.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'lyrics_provider.dart';

class KuGouProvider extends LyricsProvider {
  const KuGouProvider();

  @override
  String get id => 'kugou';

  @override
  String get name => 'KuGou';

  static const int _pageSize = 8;
  static const int _durationToleranceSeconds = 8;
  static const Duration _timeout = Duration(seconds: 8);

  @override
  Future<String?> fetchLrc(LyricsQuery query, http.Client client) async {
    try {
      final duration = query.durationSeconds;
      final keywords = {
        _keyword(query),
        '${_normalizeTitle(query.title)} ${_normalizeArtist(query.artist)}',
      };

      for (final keyword in keywords) {
        final songs = await _getJson(
          client,
          Uri.parse('https://mobileservice.kugou.com/api/v3/search/song')
              .replace(
            queryParameters: {
              'version': '9108',
              'plat': '0',
              'pagesize': '$_pageSize',
              'showtype': '0',
              'keyword': keyword,
            },
          ),
        );
        final infos = (songs?['data']?['info'] as List?) ?? const [];

        for (final info in infos) {
          // Only the song we asked for: KuGou's first hit is often another one.
          if (!tracksMatch(query.title, query.artist,
              '${info['songname'] ?? ''}', '${info['singername'] ?? ''}')) {
            continue;
          }
          final songDuration = info['duration'] as int? ?? 0;
          if (duration != null &&
              (songDuration - duration).abs() > _durationToleranceSeconds) {
            continue;
          }
          final candidate = await _firstCandidate(
            client,
            {'hash': info['hash'] as String},
            query,
          );
          final lrc =
              candidate == null ? null : await _download(client, candidate);
          if (lrc != null) return lrc;
        }
      }

      final candidate = await _firstCandidate(
        client,
        {
          'keyword': _keyword(query),
          if (duration != null) 'duration': '${duration * 1000}',
        },
        query,
        requireMetadata: true,
      );
      return candidate == null ? null : await _download(client, candidate);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getJson(http.Client client, Uri uri) async {
    final response = await client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) return null;
    final decoded = json.decode(utf8.decode(response.bodyBytes));
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<Map<String, dynamic>?> _firstCandidate(
    http.Client client,
    Map<String, String> params,
    LyricsQuery query, {
    bool requireMetadata = false,
  }) async {
    final data = await _getJson(
      client,
      Uri.parse('https://lyrics.kugou.com/search').replace(queryParameters: {
        'ver': '1',
        'man': 'yes',
        'client': 'pc',
        ...params,
      }),
    );
    final candidates = (data?['candidates'] as List?) ?? const [];
    for (final c in candidates) {
      if (c is! Map<String, dynamic>) continue;
      final song = c['song'];
      final singer = c['singer'];
      if (song is String && singer is String) {
        if (tracksMatch(query.title, query.artist, song, singer)) return c;
      } else if (!requireMetadata) {
        return c;
      }
    }
    return null;
  }

  Future<String?> _download(
      http.Client client, Map<String, dynamic> candidate) async {
    final data = await _getJson(
      client,
      Uri.parse('https://lyrics.kugou.com/download').replace(queryParameters: {
        'fmt': 'lrc',
        'charset': 'utf8',
        'client': 'pc',
        'ver': '1',
        'id': '${candidate['id']}',
        'accesskey': '${candidate['accesskey']}',
      }),
    );
    final content = data?['content'] as String?;
    if (content == null) return null;
    final lrc = normalize(utf8.decode(base64.decode(content)));
    return lrc.isEmpty ? null : lrc;
  }

  static String _keyword(LyricsQuery q) {
    final title = _normalizeTitle(q.title);
    final artist = _normalizeArtist(q.artist);
    final album = q.album;
    return '$title - $artist${album == null || album.isEmpty ? '' : ' $album'}';
  }

  static String _normalizeTitle(String title) => title
      .replaceAll(RegExp(r'\(.*\)'), '')
      .replaceAll(RegExp(r'（.*）'), '')
      .replaceAll(RegExp(r'「.*」'), '')
      .replaceAll(RegExp(r'『.*』'), '')
      .replaceAll(RegExp(r'<.*>'), '')
      .replaceAll(RegExp(r'《.*》'), '')
      .replaceAll(RegExp(r'〈.*〉'), '')
      .replaceAll(RegExp(r'＜.*＞'), '')
      .trim();

  static String _normalizeArtist(String artist) => artist
      .replaceAll(', ', '、')
      .replaceAll(' & ', '、')
      .replaceAll('.', '')
      .replaceAll('和', '、')
      .replaceAll(RegExp(r'\(.*\)'), '')
      .replaceAll(RegExp(r'（.*）'), '')
      .trim();

  static final RegExp _timed = RegExp(r'^\[\d\d:\d\d\.\d{2,3}\].*');

  /// Credit lines such as `[00:01.00]作词 : name`.
  static final RegExp _credit = RegExp(r'^\[[^\]]*\].+[:：].+');

  /// Keeps timed lines only and trims the credit block KuGou puts before
  /// (after an optional "Title - Artist" line) and after the lyrics.
  static String normalize(String lrc) {
    final lines = const LineSplitter()
        .convert(lrc)
        .map((l) => l.trim())
        .where(_timed.hasMatch)
        .toList();

    var start = 0;
    if (lines.length > 1 &&
        !_credit.hasMatch(lines[0]) &&
        _credit.hasMatch(lines[1])) {
      start = 1;
    }
    while (start < lines.length && _credit.hasMatch(lines[start])) {
      start++;
    }
    var end = lines.length;
    while (end > start && _credit.hasMatch(lines[end - 1])) {
      end--;
    }
    return lines.sublist(start, end).join('\n');
  }
}
