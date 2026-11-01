import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class _LogoShape {
  _LogoShape(this.path, this.matrix, this.strokeWidth, this.metrics);

  /// Path in its own coordinate space; [matrix] maps it into the SVG space so
  /// strokes get squashed by non-uniform transforms exactly like in the SVG.
  final Path path;
  final Float64List matrix;
  final double strokeWidth;
  final List<PathMetric> metrics;
}

class _LogoData {
  _LogoData(this.shapes, this.bounds);

  final List<_LogoShape> shapes;
  final Rect bounds;
}

/// The Noxira wordmark that draws itself stroke by stroke and then fills in.
///
/// Mirrors the timing of the original SVG animation: every path draws its
/// outline over [_strokeMs] (staggered by [_staggerMs] per path), after which
/// all paths fade from transparent to white over [_fillMs].
class AnimatedLogo extends StatelessWidget {
  const AnimatedLogo({
    super.key,
    required this.animation,
    this.width,
    this.asset = splashAsset,
    this.ghost = 0,
    this.minStrokePx = 0,
  });

  static const String splashAsset =
      'assets/images/logo/noxiramusic_wordmark_plus_outline.svg';
  static const String wordmarkAsset =
      'assets/images/logo/noxiramusic_wordmark.svg';

  static const double _strokeMs = 1000;
  static const double _staggerMs = 20;
  static const double _fillDelayMs = 900;
  static const double _fillMs = 600;

  /// Controller value 0 → 1 maps onto this timeline.
  static double totalMs(int shapeCount) => math.max(
      _strokeMs + (shapeCount - 1) * _staggerMs, _fillDelayMs + _fillMs);

  static const Duration duration = Duration(milliseconds: 1500);

  static final Map<String, _LogoData> _cache = {};
  static final Map<String, Future<_LogoData>> _loading = {};

  final Animation<double> animation;
  final double? width;
  final String asset;

  /// Opacity (0..1) of the complete outline drawn underneath, so a partly
  /// drawn wordmark reads as progress towards something.
  final double ghost;

  /// Keeps the outline at least this many logical pixels thick, for small
  /// sizes where the SVG's hairline strokes would vanish.
  final double minStrokePx;

  static Future<void> preload([String asset = splashAsset]) => _load(asset);

  static Future<_LogoData> _load(String asset) {
    return _loading[asset] ??= rootBundle.loadString(asset).then((svg) {
      final data = _parse(svg);
      _cache[asset] = data;
      return data;
    });
  }

  static _LogoData _parse(String svg) {
    final doc = XmlDocument.parse(svg);
    final shapes = <_LogoShape>[];

    void walk(XmlElement element, Matrix4 parent) {
      final local = _parseTransform(element.getAttribute('transform'));
      final matrix = parent.multiplied(local);

      if (element.name.local == 'path') {
        final d = element.getAttribute('d');
        if (d != null && d.isNotEmpty) {
          final style = element.getAttribute('style') ?? '';
          final strokeWidth = _styleValue(style, 'stroke-width');
          final path = parseSvgPathData(d)..fillType = PathFillType.evenOdd;
          shapes.add(_LogoShape(
            path,
            Float64List.fromList(matrix.storage),
            strokeWidth ?? 0,
            path.computeMetrics().toList(),
          ));
        }
      }

      for (final child in element.childElements) {
        walk(child, matrix);
      }
    }

    walk(doc.rootElement, Matrix4.identity());

    Rect boundsOf(_LogoShape s) => s.path.transform(s.matrix).getBounds();
    var bounds = boundsOf(shapes.first);
    for (final s in shapes.skip(1)) {
      bounds = bounds.expandToInclude(boundsOf(s));
    }
    return _LogoData(shapes, bounds);
  }

  static double? _styleValue(String style, String key) {
    final match = RegExp('$key:\\s*([0-9.]+)').firstMatch(style);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  static Matrix4 _parseTransform(String? value) {
    if (value == null) return Matrix4.identity();
    final match = RegExp(r'matrix\(([^)]*)\)').firstMatch(value);
    if (match == null) return Matrix4.identity();
    final v = match
        .group(1)!
        .split(RegExp(r'[\s,]+'))
        .where((s) => s.isNotEmpty)
        .map(double.parse)
        .toList();
    if (v.length != 6) return Matrix4.identity();
    return Matrix4(
      v[0], v[1], 0, 0, //
      v[2], v[3], 0, 0, //
      0, 0, 1, 0, //
      v[4], v[5], 0, 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _cache[asset];
    if (data == null) return const SizedBox.shrink();

    final bounds = data.bounds;
    final w = width ?? MediaQuery.sizeOf(context).width * 0.6;
    final h = w * bounds.height / bounds.width;

    return RepaintBoundary(
      child: CustomPaint(
        size: Size(w, h),
        painter: _AnimatedLogoPainter(data, animation, ghost, minStrokePx),
      ),
    );
  }
}

class _AnimatedLogoPainter extends CustomPainter {
  _AnimatedLogoPainter(this.data, this.animation, this.ghost, this.minStrokePx)
      : super(repaint: animation);

  final _LogoData data;
  final Animation<double> animation;
  final double ghost;
  final double minStrokePx;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = data.bounds;
    final scale = size.width / bounds.width;
    final t = animation.value * AnimatedLogo.totalMs(data.shapes.length);

    canvas.save();
    canvas.scale(scale);
    canvas.translate(-bounds.left, -bounds.top);

    final fillT = Curves.ease.transform(
        ((t - AnimatedLogo._fillDelayMs) / AnimatedLogo._fillMs).clamp(0, 1));

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = Colors.white.withValues(alpha: fillT);
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..color = Colors.white;

    final ghostPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..color = Colors.white.withValues(alpha: ghost);

    for (var i = 0; i < data.shapes.length; i++) {
      final shape = data.shapes[i];
      final p = Curves.ease.transform(
          ((t - i * AnimatedLogo._staggerMs) / AnimatedLogo._strokeMs)
              .clamp(0, 1));

      canvas.save();
      canvas.transform(shape.matrix);

      // Stroke width in local units; widened if it would fall under the
      // minimum on screen.
      var localStroke = shape.strokeWidth;
      if (minStrokePx > 0) {
        final onScreen = scale *
            math.sqrt(shape.matrix[0].abs() * shape.matrix[5].abs() + 1e-9);
        localStroke = math.max(localStroke, minStrokePx / onScreen);
      }

      if (ghost > 0) {
        ghostPaint.strokeWidth = localStroke;
        canvas.drawPath(shape.path, ghostPaint);
      }

      if (fillT > 0) canvas.drawPath(shape.path, fillPaint);

      if (p > 0) {
        strokePaint.strokeWidth = localStroke;
        if (p >= 1) {
          canvas.drawPath(shape.path, strokePaint);
        } else {
          final drawn = Path()..fillType = PathFillType.evenOdd;
          for (final m in shape.metrics) {
            drawn.addPath(m.extractPath(0, m.length * p), Offset.zero);
          }
          canvas.drawPath(drawn, strokePaint);
        }
      }

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_AnimatedLogoPainter old) =>
      old.data != data || old.ghost != ghost || old.minStrokePx != minStrokePx;
}

/// The finished Noxira wordmark (no animation), e.g. for app bars.
class NoxiraWordmark extends StatelessWidget {
  const NoxiraWordmark({
    super.key,
    required this.width,
    this.asset = AnimatedLogo.wordmarkAsset,
  });

  final double width;

  /// [AnimatedLogo.wordmarkAsset] or [AnimatedLogo.splashAsset] (with icon).
  final String asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: AnimatedLogo.preload(asset),
      builder: (context, _) => AnimatedLogo(
        animation: kAlwaysCompleteAnimation,
        asset: asset,
        width: width,
      ),
    );
  }
}
