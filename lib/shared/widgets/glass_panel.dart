import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'adaptive_blur.dart';
import 'glass_fill.dart';

/// Frosted-glass container used for cards, banners and tiles, in the same
/// look as the onboarding glass (sheen plus a light edge).
///
/// Leave [blur] off wherever the app's already-blurred background sits behind
/// it; turn it on only over unblurred content (dialogs, sheets).
///
/// Set [blur] to false for repeated items (grids, lists): the translucent
/// fill, gradient and border still read as glass, without a live backdrop
/// blur per item. With [blur] on, low-end devices automatically get a solid
/// surface instead (see [AdaptiveBackdropFilter]).
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding,
    this.tint,
    this.borderColor,
    this.blur = true,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;

  /// Colour mixed into the glass, e.g. an accent for a banner.
  final Color? tint;
  final Color? borderColor;
  final bool blur;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final tint = this.tint;

    Widget content = child;
    if (padding != null) content = Padding(padding: padding!, child: content);
    if (onTap != null || onLongPress != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: content,
        ),
      );
    }

    Widget surface = CustomPaint(
      foregroundPainter: GlassEdgePainter(radius: radius, alpha: 1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                tint?.withValues(alpha: 0.22) ?? Colors.transparent,
                Colors.white.withValues(alpha: 0.17),
              ),
              Color.alphaBlend(
                tint?.withValues(alpha: 0.08) ?? Colors.transparent,
                Colors.white.withValues(alpha: 0.05),
              ),
            ],
          ),
        ),
        child: content,
      ),
    );

    if (blur) {
      surface = AdaptiveBackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: surface,
      );
    }

    return ClipRRect(borderRadius: borderRadius, child: surface);
  }
}
