/// Timing helpers for synced lyrics.
///
/// LRC only carries the start of each line, so how long a line is actually
/// sung (and therefore when an instrumental gap begins) is estimated.
library;

import '../../../../shared/models/timed_lyrics.dart';

/// Gaps shorter than this are plain breathing room, not an interlude.
const int kMinInterludeGapMs = 4000;

/// Gaps up to this length are assumed to be filled by the line that precedes
/// them, so the whole gap is used for that line's progress sweep.
const int _kContinuousGapMs = 6000;

/// A gap between two sung lines that gets the animated three dots.
class LyricsInterlude {
  const LyricsInterlude({
    required this.afterLine,
    required this.startMs,
    required this.endMs,
  });

  /// Index of the line before the gap, or -1 for an intro before line 0.
  final int afterLine;
  final int startMs;
  final int endMs;
}

/// A row of the lyrics list: either a sung line or an interlude.
class LyricsRow {
  const LyricsRow.line(this.lineIndex) : interlude = null;
  const LyricsRow.interlude(LyricsInterlude this.interlude) : lineIndex = -1;

  final int lineIndex;
  final LyricsInterlude? interlude;

  bool get isInterlude => interlude != null;
}

class LyricsTiming {
  LyricsTiming._();

  /// Estimated time in ms during which line [i] is being sung.
  static int sungMs(List<TimedLyric> lyrics, int i) {
    final chars = lyrics[i].text.length;
    final byLength = (chars * 90).clamp(2000, 12000);
    if (i + 1 >= lyrics.length) return byLength;

    final gap = (lyrics[i + 1].time - lyrics[i].time).inMilliseconds;
    final available = (gap * 0.95).round();
    if (gap <= _kContinuousGapMs) return available.clamp(300, 1 << 30);
    return available < byLength ? available : byLength;
  }

  static List<LyricsInterlude> interludes(List<TimedLyric> lyrics) {
    final result = <LyricsInterlude>[];
    if (lyrics.isEmpty) return result;

    if (lyrics.first.time.inMilliseconds >= kMinInterludeGapMs) {
      result.add(LyricsInterlude(
        afterLine: -1,
        startMs: 0,
        endMs: lyrics.first.time.inMilliseconds,
      ));
    }
    for (var i = 0; i + 1 < lyrics.length; i++) {
      final start = lyrics[i].time.inMilliseconds + sungMs(lyrics, i);
      final end = lyrics[i + 1].time.inMilliseconds;
      if (end - start >= kMinInterludeGapMs) {
        result.add(LyricsInterlude(afterLine: i, startMs: start, endMs: end));
      }
    }
    return result;
  }

  /// Lines interleaved with their interludes, in display order.
  static List<LyricsRow> buildRows(List<TimedLyric> lyrics) {
    final byAfter = {for (final g in interludes(lyrics)) g.afterLine: g};
    final rows = <LyricsRow>[];
    if (byAfter[-1] != null) rows.add(LyricsRow.interlude(byAfter[-1]!));
    for (var i = 0; i < lyrics.length; i++) {
      rows.add(LyricsRow.line(i));
      final gap = byAfter[i];
      if (gap != null) rows.add(LyricsRow.interlude(gap));
    }
    return rows;
  }
}
