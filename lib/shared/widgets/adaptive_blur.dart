import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/performance_mode_provider.dart';

/// Whether blur effects must be replaced by solid fills (low-end devices).
///
/// Rebuilds the caller when the performance level changes.
bool isBlurDisabled(BuildContext context) =>
    context.select<PerformanceModeProvider, bool>((p) => p.isLowEndDevice);

/// Drop-in [BackdropFilter] that, on low-end devices, skips the live blur
/// entirely and puts a (nearly) solid surface behind [child] instead.
class AdaptiveBackdropFilter extends StatelessWidget {
  const AdaptiveBackdropFilter({
    super.key,
    required this.filter,
    this.child,
    this.enabled = true,
    this.backing,
  });

  final ui.ImageFilter filter;
  final Widget? child;
  final bool enabled;

  /// Colour used instead of the blur on low-end devices. Defaults to the
  /// theme surface colour.
  final Color? backing;

  @override
  Widget build(BuildContext context) {
    if (isBlurDisabled(context)) {
      return ColoredBox(
        color: backing ??
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        child: child,
      );
    }
    return BackdropFilter(filter: filter, enabled: enabled, child: child);
  }
}

/// Drop-in [ImageFiltered] that renders [child] unfiltered on low-end devices.
class AdaptiveImageFiltered extends StatelessWidget {
  const AdaptiveImageFiltered({
    super.key,
    required this.imageFilter,
    this.enabled = true,
    this.child,
  });

  final ui.ImageFilter imageFilter;
  final bool enabled;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (isBlurDisabled(context)) return child ?? const SizedBox.shrink();
    return ImageFiltered(
      imageFilter: imageFilter,
      enabled: enabled,
      child: child,
    );
  }
}
