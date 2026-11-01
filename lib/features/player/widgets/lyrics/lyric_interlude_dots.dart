/// Three dots that count down an instrumental gap between two sung lines.
///
/// The row grows in when the gap starts (lines below make room), the dots pop
/// in with a small bounce, bob while they wait and light up one by one with a
/// soft glow, then all swell together just before the next line arrives.
///
/// Design and motion adapted from musicfy (https://github.com/realidkroo/musicfy, GPL-3.0).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'lyrics_clock.dart';
import 'lyrics_constants.dart';

const int _kDotCount = 3;
const double kLyricsInterludeHeight = 56;
const double _kDotSize = 12;
const double _kDotGap = 7;
const double _kRestAlpha = 0.3;
const double _kRestScale = 0.8;
const double _kLitScale = 1.1;
const double _kGlowRadiusFactor = 2.8;
const double _kGlowPeakAlpha = 0.55;
const double _kGlowFadeMs = 900;
const double _kBobPeriodMs = 2600;
const double _kBobHeight = 1.8;
const double _kBobPhaseStep = 0.9;
const double _kDotFadeFraction = 0.55;
const double _kFinaleFraction = 0.88;

/// Shared with the list's recentering scroll so collapse and scroll are one motion.
const Duration kLyricsRecenterDuration = Duration(milliseconds: 950);
const Curve kLyricsRecenterCurve = Cubic(0.42, 0, 0.16, 1);

class LyricInterludeDots extends StatefulWidget {
  const LyricInterludeDots({
    super.key,
    required this.startMs,
    required this.endMs,
    required this.clock,
    required this.accentColor,
    required this.visible,
  });

  final int startMs;
  final int endMs;
  final LyricsClock clock;
  final Color accentColor;

  /// Whether this gap is the one currently playing. The row stays in the list
  /// at zero height when hidden.
  final bool visible;

  @override
  State<LyricInterludeDots> createState() => _LyricInterludeDotsState();
}

class _LyricInterludeDotsState extends State<LyricInterludeDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    reverseDuration: kLyricsRecenterDuration,
    value: widget.visible ? 1 : 0,
  );

  @override
  void didUpdateWidget(LyricInterludeDots old) {
    super.didUpdateWidget(old);
    if (widget.visible != old.visible) {
      if (widget.visible) {
        _grow.forward();
      } else {
        _grow.reverse();
      }
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _grow,
      builder: (context, _) {
        final t = _grow.value;
        final height = _grow.status == AnimationStatus.reverse
            ? 1 - kLyricsRecenterCurve.transform(1 - t)
            : Curves.easeOutCubic.transform(t);
        final factor = height.clamp(0.0, 1.0);
        return ClipRect(
          child: Align(
            heightFactor: factor,
            child: Opacity(
              opacity: factor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: kLyricsHorizontalPadding),
                child: SizedBox(
                  height: kLyricsInterludeHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(
                          _kDotCount * _kDotSize + (_kDotCount - 1) * _kDotGap,
                          kLyricsInterludeHeight,
                        ),
                        painter: _DotsPainter(
                          clock: widget.clock,
                          grow: _grow,
                          startMs: widget.startMs,
                          endMs: widget.endMs,
                          glow: _asGlow(widget.accentColor),
                          active: widget.visible,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Light emitted by the artwork colour is lightened, never darkened, so dark
/// artwork does not produce a near-black glow.
Color _asGlow(Color c) {
  double lift(double v) => v + (0.85 - v).clamp(0.0, 1.0) * 0.65;
  return Color.from(
      alpha: 1, red: lift(c.r), green: lift(c.g), blue: lift(c.b));
}

double _smoothstep(double x) {
  final t = x.clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({
    required this.clock,
    required this.grow,
    required this.startMs,
    required this.endMs,
    required this.glow,
    required this.active,
  }) : super(repaint: Listenable.merge([clock, grow]));

  final LyricsClock clock;
  final Animation<double> grow;
  final int startMs;
  final int endMs;
  final Color glow;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final span = math.max(1, endMs - startMs);
    final nowMs = clock.value;
    final progress = active ? ((nowMs - startMs) / span).clamp(0.0, 1.0) : 1.0;
    final finale =
        _smoothstep((progress - _kFinaleFraction) / (1 - _kFinaleFraction));

    for (var i = 0; i < _kDotCount; i++) {
      final sliceStart = i / _kDotCount;
      final fill =
          _smoothstep((progress - sliceStart) * _kDotCount / _kDotFadeFraction);

      final litAt = sliceStart + _kDotFadeFraction / _kDotCount;
      final glowAmount = progress < litAt
          ? fill
          : math.exp(-((progress - litAt) * span) / _kGlowFadeMs);
      final glowNow = math.max(glowAmount, math.sin(math.pi * finale) * 0.7);

      // Each dot pops in slightly after the previous one.
      final pop = Curves.easeOutBack
          .transform(((grow.value * 1.4) - i * 0.1).clamp(0.0, 1.0));
      final popAlpha = pop.clamp(0.0, 1.0);

      final scale =
          (_kRestScale + (_kLitScale - _kRestScale) * fill + 0.14 * finale) *
              pop;
      final alpha =
          (_kRestAlpha + (1 - _kRestAlpha) * math.max(fill, finale)) * popAlpha;

      final phase = nowMs / _kBobPeriodMs * 2 * math.pi - i * _kBobPhaseStep;
      final bob = math.sin(phase) * _kBobHeight;

      final center = Offset(
        _kDotSize / 2 + i * (_kDotSize + _kDotGap),
        size.height / 2 + bob,
      );
      final radius = _kDotSize / 2 * scale;

      if (glowNow > 0.01) {
        const glowRadius = _kDotSize / 2 * _kGlowRadiusFactor;
        final a = _kGlowPeakAlpha * glowNow * popAlpha;
        canvas.drawCircle(
          center,
          glowRadius,
          Paint()
            ..shader = RadialGradient(colors: [
              glow.withValues(alpha: a),
              glow.withValues(alpha: 0),
            ]).createShader(
                Rect.fromCircle(center: center, radius: glowRadius)),
        );
      }
      canvas.drawCircle(
        center,
        math.max(0, radius),
        Paint()..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.startMs != startMs ||
      old.endMs != endMs ||
      old.glow != glow ||
      old.active != active;
}
