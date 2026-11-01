import 'package:flutter/material.dart';

/// Text whose changing characters roll up like an odometer (musicfy's
/// OdometerText). Unchanged characters stay still.
class OdometerText extends StatelessWidget {
  const OdometerText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final tabular = style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < text.length; i++)
          _Digit(
            // Index from the right so "9:59" -> "10:00" keeps columns aligned.
            key: ValueKey(text.length - i),
            char: text[i],
            style: tabular,
          ),
      ],
    );
  }
}

class _Digit extends StatelessWidget {
  const _Digit({super.key, required this.char, required this.style});

  final String char;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey(char);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween(
                  begin: Offset(0, incoming ? 0.9 : -0.9),
                  end: Offset.zero,
                ),
              ),
              child: child,
            ),
          );
        },
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.center,
          children: [...previous, if (current != null) current],
        ),
        child: Text(char, key: ValueKey(char), style: style),
      ),
    );
  }
}
