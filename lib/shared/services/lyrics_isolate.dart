import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/timed_lyrics.dart';

/// Isolate helper for parsing lyrics to avoid UI thread blocking
class LyricsIsolate {
  /// Parse LRC content in an isolate for better performance
  static Future<List<TimedLyric>> parseLrcInIsolate(String lrcContent) async {
    // On web, we can't use isolates, so parse directly
    if (kIsWeb) {
      return _parseLrc(lrcContent);
    }

    // Use compute for better performance on native platforms
    return compute(_parseLrc, lrcContent);
  }

  /// Parse LRC content - can be run in isolate or main thread
  static List<TimedLyric> _parseLrc(String lrcContent) {
    final normalized = utf8
        .decode(utf8.encode(lrcContent), allowMalformed: true)
        .replaceAll(RegExp(r'[\uFFFD]'), '');
    return parseLrc(normalized);
  }

  /// Generate suggestions for song metadata in isolate
  static Future<Map<String, dynamic>> generateSuggestionsInIsolate(
    Map<String, dynamic> data,
  ) async {
    if (kIsWeb) {
      return _generateSuggestions(data);
    }

    return compute(_generateSuggestions, data);
  }

  static Map<String, dynamic> _generateSuggestions(Map<String, dynamic> data) {
    // Placeholder for smart suggestions computation
    // This would contain the expensive computation logic
    // that should not run on the UI thread
    return {
      'suggestions': [],
      'computedAt': DateTime.now().toIso8601String(),
    };
  }
}
