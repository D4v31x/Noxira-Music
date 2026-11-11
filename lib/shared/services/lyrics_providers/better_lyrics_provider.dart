/// Better Lyrics (https://lyrics-api.boidu.dev), served as TTML.
/// Ported from musicfy's BetterLyrics provider; converted to line-level LRC.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'lyrics_provider.dart';

class BetterLyricsProvider extends LyricsProvider {
  const BetterLyricsProvider();

  @override
  String get id => 'better_lyrics';

  @override
  String get name => 'Better Lyrics';

  @override
  Future<String?> fetchLrc(LyricsQuery query, http.Client client) async {
    try {
      final uri = Uri.parse('https://lyrics-api.boidu.dev/getLyrics').replace(
        queryParameters: {
          's': query.title,
          'a': query.artist,
          if (query.durationSeconds != null && query.durationSeconds! > 0)
            'd': '${query.durationSeconds}',
          if (query.album != null && query.album!.isNotEmpty)
            'al': query.album!,
        },
      );
      final response =
          await client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final body = json.decode(utf8.decode(response.bodyBytes));
      final ttml = body is Map ? body['ttml'] as String? : null;
      return ttml == null ? null : ttmlToLrc(ttml);
    } catch (_) {
      return null;
    }
  }

  /// Converts TTML paragraphs to LRC lines. Paragraphs whose spans carry their
  /// own `begin` times become enhanced-LRC lines with word timing. Background
  /// vocals (`ttm:role="x-bg"`) are left out so they do not duplicate the main
  /// line.
  static String? ttmlToLrc(String ttml) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(ttml);
    } catch (_) {
      return null;
    }

    final lines = <String>[];
    for (final p in doc.findAllElements('p')) {
      final begin = p.getAttribute('begin');
      if (begin == null) continue;
      final ms = parseTime(begin);
      if (ms == null) continue;

      final timed = _timedWords(p);
      if (timed != null) {
        lines.add('${lrcTag(ms)}$timed');
        continue;
      }

      final text = _text(p).replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty) continue;
      lines.add('${lrcTag(ms)}$text');
    }
    return lines.isEmpty ? null : lines.join('\n');
  }

  /// `<t>word <t>word<end>` for a paragraph whose spans are individually timed,
  /// or null when they aren't.
  static String? _timedWords(XmlElement p) {
    final starts = <int>[];
    final texts = <String>[];
    var lastEnd = -1;

    for (final child in p.children) {
      if (child is XmlText) {
        if (child.value.trim().isNotEmpty) return null; // untimed text
        if (texts.isNotEmpty && child.value.isNotEmpty) {
          texts[texts.length - 1] = '${texts.last.trimRight()} ';
        }
        continue;
      }
      if (child is! XmlElement || _role(child) == 'x-bg') continue;

      final begin = child.getAttribute('begin');
      final startMs = begin == null ? null : parseTime(begin);
      if (startMs == null || (starts.isNotEmpty && startMs < starts.last)) {
        return null;
      }
      final text = _text(child).replaceAll(RegExp(r'\s+'), ' ');
      if (text.trim().isEmpty) {
        if (texts.isNotEmpty) {
          texts[texts.length - 1] = '${texts.last.trimRight()} ';
        }
        continue;
      }
      starts.add(startMs);
      texts.add(texts.isEmpty ? text.trimLeft() : text);
      final end = child.getAttribute('end');
      lastEnd = end == null ? -1 : (parseTime(end) ?? -1);
    }

    if (starts.isEmpty) return null;
    final buffer = StringBuffer();
    for (var i = 0; i < starts.length; i++) {
      buffer
        ..write(lrcWordTag(starts[i]))
        ..write(i == starts.length - 1 ? texts[i].trimRight() : texts[i]);
    }
    if (lastEnd > starts.last) buffer.write(lrcWordTag(lastEnd));
    return buffer.toString();
  }

  static String? _role(XmlElement e) => e.attributes
      .where((a) => a.name.local == 'role')
      .map((a) => a.value)
      .firstOrNull;

  static String _text(XmlNode node) {
    final buffer = StringBuffer();
    for (final child in node.children) {
      if (child is XmlText) {
        buffer.write(child.value);
      } else if (child is XmlElement) {
        final role = child.attributes
            .where((a) => a.name.local == 'role')
            .map((a) => a.value)
            .firstOrNull;
        if (role == 'x-bg') continue;
        buffer.write(_text(child));
      }
    }
    return buffer.toString();
  }

  /// Parses `1:23.456`, `00:01:23.456`, `83.4s` and `83.4` into milliseconds.
  static int? parseTime(String value) {
    var v = value.trim();
    if (v.endsWith('s')) v = v.substring(0, v.length - 1);
    final parts = v.split(':');
    final nums = parts.map(double.tryParse).toList();
    if (nums.any((n) => n == null)) return null;
    var seconds = 0.0;
    for (final n in nums) {
      seconds = seconds * 60 + n!;
    }
    return (seconds * 1000).round();
  }
}
