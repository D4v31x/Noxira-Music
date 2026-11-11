/// Extra visualiser styles. Every painter draws from the analyzer's smoothed
/// 0..1 bar levels (see SpectrumAnalyzer) and repaints only when
/// [paintGeneration] changes.
library;

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../utils/visualizer_colors.dart';

const double _kTopReserve = 110.0;
const double _kBottomReserve = 200.0;

/// Spectrum area shared by the bottom-anchored styles.
({double bottom, double height}) _spectrumArea(Size size, double bottomInset) {
  final bottom = size.height - _kBottomReserve - bottomInset;
  return (
    bottom: bottom,
    height: (bottom - _kTopReserve).clamp(50.0, double.infinity),
  );
}

/// Dot Matrix — an LED-style grid: each column lights dots up to its level.
class DotMatrixPainter extends CustomPainter {
  const DotMatrixPainter({
    required this.levels,
    required this.color,
    required this.bottomInset,
    required this.paintGeneration,
  });

  final List<double> levels;
  final Color color;
  final double bottomInset;
  final int paintGeneration;

  @override
  void paint(Canvas canvas, Size size) {
    // Two analyzer bars per column keeps the grid readable.
    final columns = max(1, levels.length ~/ 2);
    const hPad = 24.0;
    final area = _spectrumArea(size, bottomInset);

    final pitch = (size.width - hPad * 2) / columns;
    final dot = pitch * 0.62;
    final rows = max(4, (area.height / pitch).floor());

    final lit = Paint();
    final unlit = Paint()..color = color.withValues(alpha: 0.09);
    final highlight = VisualizerColors.highlight(color);
    final backing = Paint()..color = VisualizerColors.markBackground;

    for (var c = 0; c < columns; c++) {
      final a = levels[(c * 2).clamp(0, levels.length - 1)];
      final b = levels[(c * 2 + 1).clamp(0, levels.length - 1)];
      final level = (a + b) / 2;
      final litRows = (level * rows).round();
      final x = hPad + pitch * c + pitch / 2;

      for (var r = 0; r < rows; r++) {
        final y = area.bottom - pitch * r - pitch / 2;
        if (r < litRows) {
          // Brighter towards the top of the column.
          final t = r / rows;
          lit.color = Color.lerp(
            color.withValues(alpha: VisualizerColors.minimumOpacity),
            highlight.withValues(alpha: 0.95),
            t * t,
          )!;
          canvas.drawCircle(Offset(x, y), dot / 2, backing);
          canvas.drawCircle(Offset(x, y), dot / 2, lit);
        } else {
          canvas.drawCircle(Offset(x, y), dot / 2, unlit);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DotMatrixPainter old) =>
      old.paintGeneration != paintGeneration || old.color != color;
}

/// Peak Bars — slim gradient bars with a cap that hangs at each recent peak
/// and slowly falls.
class PeakBarsPainter extends CustomPainter {
  const PeakBarsPainter({
    required this.levels,
    required this.peaks,
    required this.color,
    required this.bottomInset,
    required this.paintGeneration,
  });

  final List<double> levels;
  final List<double> peaks;
  final Color color;
  final double bottomInset;
  final int paintGeneration;

  @override
  void paint(Canvas canvas, Size size) {
    final count = levels.length;
    const hPad = 20.0;
    const gapFactor = 0.55;
    final area = _spectrumArea(size, bottomInset);

    final barWidth =
        (size.width - hPad * 2) / (count + (count - 1) * gapFactor);
    final gap = barWidth * gapFactor;
    final highlight = VisualizerColors.highlight(color);

    final bars = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, area.bottom - area.height),
        Offset(0, area.bottom),
        [
          highlight.withValues(alpha: 0.95),
          color.withValues(alpha: VisualizerColors.minimumOpacity),
        ],
      );
    final caps = Paint()..color = highlight.withValues(alpha: 0.9);
    final backing = Paint()..color = VisualizerColors.markBackground;
    final radius = Radius.circular(barWidth / 2);

    for (var i = 0; i < count; i++) {
      final x = hPad + i * (barWidth + gap);
      final h = (levels[i] * area.height).clamp(2.0, area.height);
      final bar = RRect.fromLTRBAndCorners(
          x, area.bottom - h, x + barWidth, area.bottom,
          topLeft: radius, topRight: radius);
      canvas.drawRRect(bar, backing);
      canvas.drawRRect(bar, bars);

      final peakY =
          area.bottom - (peaks[i] * area.height).clamp(2.0, area.height) - 7;
      final cap =
          RRect.fromLTRBR(x, peakY - 3, x + barWidth, peakY + 1, radius);
      canvas.drawRRect(cap, backing);
      canvas.drawRRect(cap, caps);
    }
  }

  @override
  bool shouldRepaint(PeakBarsPainter old) =>
      old.paintGeneration != paintGeneration || old.color != color;
}

/// Circular Wave — one smooth, mirrored loop around the centre whose radius
/// follows the spectrum.
class CircularWavePainter extends CustomPainter {
  const CircularWavePainter({
    required this.levels,
    required this.bass,
    required this.color,
    required this.glow,
    required this.paintGeneration,
  });

  final List<double> levels;
  final double bass;
  final Color color;
  final bool glow;
  final int paintGeneration;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final shortest = min(size.width, size.height);
    final baseR = shortest * 0.2 + bass * 16;
    final maxLen = shortest * 0.24;

    // Mirrored left/right so the shape is symmetric.
    final count = levels.length * 2;
    final points = <Offset>[];
    for (var i = 0; i < count; i++) {
      final level = levels[i < levels.length ? i : count - 1 - i];
      final angle = i / count * 2 * pi - pi / 2;
      final r = baseR + level * maxLen;
      points.add(center + Offset(cos(angle), sin(angle)) * r);
    }

    // Closed Catmull-Rom spline through the points.
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < count; i++) {
      final p0 = points[(i - 1 + count) % count];
      final p1 = points[i];
      final p2 = points[(i + 1) % count];
      final p3 = points[(i + 2) % count];
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.radial(center, baseR + maxLen, [
          color.withValues(alpha: 0.05),
          color.withValues(alpha: 0.35),
        ]),
    );
    if (glow) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = VisualizerColors.markBackground
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    // Quiet inner ring that breathes with the bass.
    canvas.drawCircle(
      center,
      baseR * 0.82,
      Paint()
        ..color = color.withValues(alpha: 0.10 + bass * 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(CircularWavePainter old) =>
      old.paintGeneration != paintGeneration || old.color != color;
}

/// Aurora Waves — three layered, softly filled waves, each reading the
/// spectrum from a different offset so they drift apart like curtains.
class AuroraWavesPainter extends CustomPainter {
  const AuroraWavesPainter({
    required this.levels,
    required this.color,
    required this.bottomInset,
    required this.paintGeneration,
  });

  final List<double> levels;
  final Color color;
  final double bottomInset;
  final int paintGeneration;

  @override
  void paint(Canvas canvas, Size size) {
    final area = _spectrumArea(size, bottomInset);
    final layers = <({double shift, double scale, Color color})>[
      (shift: 0.0, scale: 1.0, color: VisualizerColors.highlight(color)),
      (shift: 0.0, scale: 0.78, color: color),
      (shift: 0.0, scale: 0.55, color: color),
    ];
    final count = levels.length;

    for (var l = 0; l < layers.length; l++) {
      final layer = layers[l];
      // Each layer reads the spectrum a few bins over (mirrored at the ends).
      final offset = l * 5;
      double sample(int i) {
        var idx = i + offset;
        if (idx >= count) idx = 2 * (count - 1) - idx;
        return levels[idx.clamp(0, count - 1)];
      }

      final step = size.width / (count - 1);
      final path = Path()..moveTo(0, area.bottom);
      var prevX = 0.0;
      var prevY = area.bottom - sample(0) * area.height * layer.scale;
      path.lineTo(prevX, prevY);
      for (var i = 1; i < count; i++) {
        final x = i * step;
        final y = area.bottom - sample(i) * area.height * layer.scale;
        final cx = (prevX + x) / 2;
        path.cubicTo(cx, prevY, cx, y, x, y);
        prevX = x;
        prevY = y;
      }
      path
        ..lineTo(size.width, area.bottom)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, area.bottom - area.height * layer.scale),
            Offset(0, area.bottom),
            [
              layer.color.withValues(alpha: 0.55),
              layer.color.withValues(alpha: 0.02),
            ],
          ),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = VisualizerColors.markBackground
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color =
              layer.color.withValues(alpha: VisualizerColors.minimumOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(AuroraWavesPainter old) =>
      old.paintGeneration != paintGeneration || old.color != color;
}

/// Pulse Rings — concentric rings that swell with the bass, wrapped by a
/// ring of dots that ride the spectrum.
class PulseRingsPainter extends CustomPainter {
  const PulseRingsPainter({
    required this.levels,
    required this.bass,
    required this.overall,
    required this.color,
    required this.glow,
    required this.paintGeneration,
  });

  final List<double> levels;
  final double bass;
  final double overall;
  final Color color;
  final bool glow;
  final int paintGeneration;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final shortest = min(size.width, size.height);

    // Soft core that brightens with the overall level.
    canvas.drawCircle(
      center,
      shortest * 0.16 + bass * 24,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          shortest * 0.16 + bass * 24,
          [
            color.withValues(alpha: 0.25 + overall * 0.5),
            color.withValues(alpha: 0.0),
          ],
        ),
    );

    const rings = 4;
    final backingStroke = Paint()
      ..color = VisualizerColors.markBackground
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < rings; i++) {
      final t = i / (rings - 1);
      final radius = shortest * (0.10 + 0.06 * i) + bass * (30 - i * 6);
      final paint = Paint()
        ..color = color.withValues(
            alpha: 0.95 - t * (0.95 - VisualizerColors.minimumOpacity))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 + bass * 3 * (1 - t);
      if (glow && i == 0) {
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = color.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
      backingStroke.strokeWidth = paint.strokeWidth;
      canvas.drawCircle(center, radius, backingStroke);
      canvas.drawCircle(center, radius, paint);
    }

    // Dots on the outer ring, pushed out by their frequency band.
    final dots = levels.length;
    final outer = shortest * 0.345;
    final dotPaint = Paint();
    final highlight = VisualizerColors.highlight(color);
    final backingDot = Paint()..color = VisualizerColors.markBackground;
    for (var i = 0; i < dots; i++) {
      final level = levels[i];
      final angle = i / dots * 2 * pi - pi / 2;
      final r = outer + level * shortest * 0.115;
      dotPaint.color = Color.lerp(color, highlight, level)!.withValues(
        alpha: VisualizerColors.minimumOpacity +
            level * (1 - VisualizerColors.minimumOpacity),
      );
      final position = center + Offset(cos(angle), sin(angle)) * r;
      final radius = 2.2 + level * 3.2;
      canvas.drawCircle(position, radius, backingDot);
      canvas.drawCircle(position, radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(PulseRingsPainter old) =>
      old.paintGeneration != paintGeneration || old.color != color;
}
