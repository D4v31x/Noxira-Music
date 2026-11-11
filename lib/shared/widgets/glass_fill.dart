import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/performance_mode_provider.dart';

/// Light edge that is brighter at the top-left; the signature of the glass.
class GlassEdgePainter extends CustomPainter {
  const GlassEdgePainter({
    required this.radius,
    required this.alpha,
    this.boost = 0,
  });

  final double radius;
  final double alpha;
  final double boost;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(radius)).deflate(0.6);
    final strong = 0.5 + 0.25 * boost;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: strong * alpha),
          Colors.white.withValues(alpha: 0.10 * alpha),
          Colors.white.withValues(alpha: 0.04 * alpha),
          Colors.white.withValues(alpha: 0.22 * alpha),
        ],
        stops: const [0, 0.38, 0.7, 1],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GlassEdgePainter old) =>
      old.alpha != alpha || old.boost != boost || old.radius != radius;
}

/// The onboarding glass (faint sheen and light edge) without its own blur.
///
/// Use it on top of the app's blurred background, which already provides the
/// frosted look: blurring again per card is costly and adds nothing. Where
/// nothing blurred sits behind (onboarding, overlays) use `GlassSurface`.
///
/// Light themes and low-end devices keep a plain themed surface.
class GlassFill extends StatelessWidget {
  const GlassFill({
    super.key,
    required this.child,
    this.radius = 16,
    this.width,
    this.padding,
    this.selected = false,
  });

  final Widget child;
  final double radius;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lowEnd = Provider.of<PerformanceModeProvider>(context).isLowEndDevice;
    final r = BorderRadius.circular(radius);

    Widget content = child;
    if (padding != null) content = Padding(padding: padding!, child: content);

    if (lowEnd || theme.brightness != Brightness.dark) {
      return Container(
        width: width,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: r,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: content,
      );
    }

    final sel = selected ? 1.0 : 0.0;
    return SizedBox(
      width: width,
      child: CustomPaint(
        foregroundPainter:
            GlassEdgePainter(radius: radius, alpha: 1, boost: sel),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.17 + 0.07 * sel),
                Colors.white.withValues(alpha: 0.05 + 0.05 * sel),
              ],
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}
