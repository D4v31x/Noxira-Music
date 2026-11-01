/// YouLyPlus (LyricsPlus community servers). Ported from musicfy's provider.
///
/// The servers are interchangeable mirrors, so all are asked at once and the
/// first one that returns synced lyrics wins.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'lyrics_provider.dart';

class YouLyPlusProvider extends LyricsProvider {
  const YouLyPlusProvider();

  @override
  String get id => 'youlyplus';

  @override
  String get name => 'YouLyPlus';

  static const List<String> _servers = [
    'https://lyricsplus.prjktla.my.id',
    'https://lyricsplus.atomix.one',
    'https://lyricsplus.binimum.org',
    'https://lyricsplus.prjktla.workers.dev',
    'https://lyricsplus-seven.vercel.app',
    'https://lyrics-plus-backend.vercel.app',
  ];

  static String? _lastWorking;

  @override
  Future<String?> fetchLrc(LyricsQuery query, http.Client client) {
    final last = _lastWorking;
    final servers = [
      if (last != null) last,
      ..._servers.where((s) => s != last),
    ];

    final result = Completer<String?>();
    var pending = servers.length;

    void finish(String? lrc, String server) {
      if (result.isCompleted) return;
      if (lrc != null) {
        _lastWorking = server;
        result.complete(lrc);
      } else if (--pending == 0) {
        result.complete(null);
      }
    }

    for (final server in servers) {
      _fetch(client, server, query).then((lrc) => finish(lrc, server));
    }
    return result.future;
  }

  Future<String?> _fetch(
      http.Client client, String server, LyricsQuery query) async {
    try {
      final uri = Uri.parse('$server/v2/lyrics/get').replace(
        queryParameters: {
          'title': query.title,
          'artist': query.artist,
          'duration': '${query.durationSeconds ?? 0}',
          if (query.album != null && query.album!.isNotEmpty)
            'album': query.album!,
        },
      );
      final response =
          await client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = json.decode(utf8.decode(response.bodyBytes));
      if (body is! Map<String, dynamic>) return null;
      final meta = body['metadata'];
      if (meta is Map) {
        final title = meta['title'];
        final artist = meta['artist'];
        if (title is String &&
            artist is String &&
            !tracksMatch(query.title, query.artist, title, artist)) {
          return null;
        }
      }
      return toLrc(body);
    } catch (_) {
      return null;
    }
  }

  /// Prefers the server's own LRC, otherwise builds line-level LRC from the
  /// per-line list. Background vocal lines are skipped.
  static String? toLrc(Map<String, dynamic> body) {
    final synced = body['syncedLyrics'];
    if (synced is String && synced.trim().isNotEmpty) return synced;

    final items = body['lyrics'];
    if (items is! List) return null;

    final lines = <String>[];
    for (final item in items) {
      if (item is! Map) continue;
      final time = item['time'];
      if (time is! num) continue;

      final syllabus = item['syllabus'];
      var text = (item['text'] as String?) ?? '';
      if (syllabus is List && syllabus.isNotEmpty) {
        if (syllabus.every((s) => s is Map && s['isBackground'] == true)) {
          continue;
        }
        final joined = syllabus.map((s) => (s as Map)['text'] ?? '').join();
        if (joined.trim().isNotEmpty) text = joined;
      }
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty) continue;
      lines.add('${lrcTag(time.round())}$text');
    }
    return lines.isEmpty ? null : lines.join('\n');
  }
}
