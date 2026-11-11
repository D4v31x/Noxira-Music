/// One word (or syllable) of a line sung at a known time. [text] keeps its
/// trailing space, so the words of a line concatenate to the line's text.
class LyricWord {
  const LyricWord({required this.start, required this.end, required this.text});

  final Duration start;
  final Duration end;
  final String text;
}

class TimedLyric {
  final Duration time;
  final String text;

  /// Word-by-word timing, when the lyrics source provides it.
  final List<LyricWord>? words;

  TimedLyric({required this.time, required this.text, this.words});

  /// Builds a timestamp from the groups of an LRC tag such as `[01:23.45]`.
  /// [fraction] is the 2 or 3 digit part after the separator (centi/milliseconds).
  static Duration parseTimestamp(String minutes, String seconds,
      [String? fraction]) {
    var ms = 0;
    if (fraction != null && fraction.isNotEmpty) {
      ms = int.parse(fraction.padRight(3, '0').substring(0, 3));
    }
    return Duration(
      minutes: int.parse(minutes),
      seconds: int.parse(seconds),
      milliseconds: ms,
    );
  }
}

final RegExp _lineTag = RegExp(r'\[(\d{2}):(\d{2})[\.:](\d{2,3})\]');
final RegExp _wordTag = RegExp(r'<(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?>');

/// Parses LRC text, including enhanced LRC where a line carries word timings:
/// `[00:01.00]<00:01.00>Hello <00:01.40>world<00:02.00>`. The last tag, with no
/// text after it, marks when the final word ends.
List<TimedLyric> parseLrc(String content) {
  final lyrics = <TimedLyric>[];

  for (final line in content.split('\n')) {
    if (line.trim().isEmpty) continue;

    final lineTags = _lineTag.allMatches(line).toList();
    if (lineTags.isEmpty) continue;

    final raw = line.substring(line.lastIndexOf(']') + 1);
    final words = _parseWords(raw);
    final text = (words == null
            ? raw.replaceAll(_wordTag, '')
            : words.map((w) => w.text).join())
        .trim();
    if (text.isEmpty) continue;

    for (var i = 0; i < lineTags.length; i++) {
      final m = lineTags[i];
      lyrics.add(TimedLyric(
        time: TimedLyric.parseTimestamp(m.group(1)!, m.group(2)!, m.group(3)),
        text: text,
        // Word times are absolute, so they only fit the first occurrence of
        // a repeated line.
        words: i == 0 && words != null ? _trimWords(words) : null,
      ));
    }
  }

  lyrics.sort((a, b) => a.time.compareTo(b.time));
  _closeOpenWordEnds(lyrics);
  return lyrics;
}

List<LyricWord>? _parseWords(String raw) {
  final tags = _wordTag.allMatches(raw).toList();
  if (tags.isEmpty) return null;

  // Text before the first tag belongs to no timed word.
  final words = <LyricWord>[];
  for (var i = 0; i < tags.length; i++) {
    final start = _tagTime(tags[i]);
    final segmentEnd = i + 1 < tags.length ? tags[i + 1].start : raw.length;
    final segment = raw.substring(tags[i].end, segmentEnd);
    final end = i + 1 < tags.length ? _tagTime(tags[i + 1]) : start;

    if (segment.trim().isEmpty) {
      // A whitespace-only segment is spacing; a bare tag at the very end only
      // closes the previous word.
      if (words.isNotEmpty && segment.isNotEmpty) {
        final prev = words.removeLast();
        words.add(LyricWord(
            start: prev.start, end: prev.end, text: '${prev.text}$segment'));
      }
      if (words.isNotEmpty && i == tags.length - 1) {
        final prev = words.removeLast();
        words.add(LyricWord(start: prev.start, end: start, text: prev.text));
      }
      continue;
    }
    words.add(LyricWord(start: start, end: end, text: segment));
  }
  return words.isEmpty ? null : words;
}

Duration _tagTime(RegExpMatch m) =>
    TimedLyric.parseTimestamp(m.group(1)!, m.group(2)!, m.group(3));

List<LyricWord> _trimWords(List<LyricWord> words) {
  final last = words.last;
  return [
    ...words.sublist(0, words.length - 1),
    LyricWord(start: last.start, end: last.end, text: last.text.trimRight()),
  ];
}

/// The last word of a line without an end marker ends where the next line
/// starts (or shortly after it began, for the final line).
void _closeOpenWordEnds(List<TimedLyric> lyrics) {
  for (var i = 0; i < lyrics.length; i++) {
    final words = lyrics[i].words;
    if (words == null || words.isEmpty) continue;
    final last = words.last;
    if (last.end > last.start) continue;
    final next = i + 1 < lyrics.length ? lyrics[i + 1].time : null;
    final end = next != null && next > last.start
        ? next
        : last.start + const Duration(milliseconds: 600);
    words[words.length - 1] =
        LyricWord(start: last.start, end: end, text: last.text);
  }
}
