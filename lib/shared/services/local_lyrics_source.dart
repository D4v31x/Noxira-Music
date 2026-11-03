import 'dart:io';

import 'package:haudiotagger/haudiotagger.dart';
import 'package:flutter/foundation.dart';

import '../models/timed_lyrics.dart';
import 'lyrics_service.dart';

/// Synced lyrics that ship with the audio file itself: a `.lrc` file next to
/// it, or an LRC body stored in the file's lyrics tag. Both work offline.
class LocalLyricsSource {
  LocalLyricsSource._();

  static Future<List<TimedLyric>?> find(String? audioPath) async {
    if (audioPath == null || audioPath.isEmpty) return null;

    final sidecar = await _fromSidecar(audioPath);
    if (sidecar != null) return sidecar;
    return _fromTag(audioPath);
  }

  static Future<List<TimedLyric>?> _fromSidecar(String audioPath) async {
    final dot = audioPath.lastIndexOf('.');
    final base = dot > audioPath.lastIndexOf('/') && dot > 0
        ? audioPath.substring(0, dot)
        : audioPath;
    for (final ext in const ['.lrc', '.LRC']) {
      try {
        final file = File('$base$ext');
        if (await file.exists()) {
          final parsed = _parse(await file.readAsString());
          if (parsed != null) return parsed;
        }
      } catch (e) {
        debugPrint('Local lyrics: sidecar read failed: $e');
      }
    }
    return null;
  }

  static Future<List<TimedLyric>?> _fromTag(String audioPath) async {
    try {
      final tag = await Haudiotagger.read(audioPath);
      final lyrics = tag?.lyrics;
      return lyrics == null ? null : _parse(lyrics);
    } catch (e) {
      debugPrint('Local lyrics: tag read failed: $e');
      return null;
    }
  }

  /// Only text with LRC timestamps is usable; plain lyrics have no timing.
  static List<TimedLyric>? _parse(String content) {
    final parsed = TimedLyricsService().parseLrcContent(content);
    return parsed.isEmpty ? null : parsed;
  }
}
