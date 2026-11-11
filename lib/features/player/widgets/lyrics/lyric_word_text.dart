import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

import '../../../../shared/models/timed_lyrics.dart';

/// A lyric line whose words light up as they are sung (word-by-word timing).
///
/// Words already sung are fully lit, the word being sung fills in over its
/// duration, and the rest wait dimmed. Rebuilds with [clock] (once per frame
/// while playing), so only use it for the active line.
class LyricWordText extends StatelessWidget {
  const LyricWordText({
    super.key,
    required this.words,
    required this.clock,
    required this.style,
  });

  final List<LyricWord> words;
  final ValueListenable<int> clock;
  final TextStyle style;

  static const double _dimmed = 0.38;

  @override
  Widget build(BuildContext context) {
    final base = style.color ?? Colors.white;
    return ValueListenableBuilder<int>(
      valueListenable: clock,
      builder: (context, ms, _) {
        return Text.rich(
          TextSpan(
            children: [
              for (final word in words)
                TextSpan(
                  text: word.text,
                  style: style.copyWith(
                    color: base.withValues(alpha: _alpha(word, ms)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static double _alpha(LyricWord word, int ms) {
    final start = word.start.inMilliseconds;
    final end = word.end.inMilliseconds;
    if (ms >= end) return 1.0;
    if (ms <= start || end <= start) return _dimmed;
    final progress = Curves.easeOut.transform((ms - start) / (end - start));
    return _dimmed + (1 - _dimmed) * progress;
  }
}
