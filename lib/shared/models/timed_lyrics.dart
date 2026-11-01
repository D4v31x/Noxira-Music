class TimedLyric {
  final Duration time;
  final String text;

  TimedLyric({required this.time, required this.text});

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
