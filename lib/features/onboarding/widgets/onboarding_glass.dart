import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/performance_mode_provider.dart';
import '../../../shared/widgets/glass_fill.dart';
import 'onboarding_kit.dart';

/// Glass and motion for the onboarding.
///
/// Real glass needs a live backdrop, and a backdrop blur only sees what is
/// painted underneath it in the same layer. A fade (an `Opacity` layer) around
/// a glass surface would hide that backdrop, so nothing here fades a glass
/// surface with a layer: [GlassSurface] animates its own blur, tint and edge
/// instead. On low-end devices the glass is a plain solid surface.

bool onboardingReduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

bool onboardingLowEnd(BuildContext context) {
  try {
    return Provider.of<PerformanceModeProvider>(context, listen: false)
        .isLowEndDevice;
  } catch (_) {
    return false;
  }
}

/// Whether glass is drawn as a solid surface (low-end devices). Rebuilds the
/// caller when the performance level changes.
bool isGlassSolid(BuildContext context) {
  try {
    return Provider.of<PerformanceModeProvider>(context).isLowEndDevice;
  } catch (_) {
    return false;
  }
}

/// Carries how present the current page still is (1 = fully, 0 = gone) while
/// it leaves, so entrances and glass can fade out without an opacity layer.
class OnboardingExit extends InheritedNotifier<ValueNotifier<double>> {
  const OnboardingExit({
    super.key,
    required ValueNotifier<double> presence,
    required super.child,
  }) : super(notifier: presence);

  static ValueNotifier<double>? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<OnboardingExit>()?.notifier;
}

/// Fades (and lifts) its child out while the page leaves. For things that are
/// not glass and not [Reveal]ed, such as the main button and the footnote.
class ExitFade extends StatelessWidget {
  const ExitFade({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final presence = OnboardingExit.of(context);
    if (presence == null) return child;
    return AnimatedBuilder(
      animation: presence,
      child: child,
      builder: (context, child) => Opacity(
        opacity: presence.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, -(1 - presence.value) * 16),
          child: child,
        ),
      ),
    );
  }
}

/// Staggered entrance shared by [Reveal] and [GlassSurface]: starts [order]
/// steps after the page appeared.
class _Entrance {
  _Entrance(TickerProvider vsync, this.order)
      : controller = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 600),
        ) {
    fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    rise = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
  }

  final int order;
  final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<double> rise;
  ValueNotifier<double>? exit;
  Timer? _delay;

  void start(BuildContext context) {
    exit = OnboardingExit.of(context);
    if (onboardingReduceMotion(context)) {
      controller.value = 1;
      return;
    }
    final low = onboardingLowEnd(context);
    if (low) controller.duration = const Duration(milliseconds: 240);
    final step = low ? 30 : 75;
    _delay = Timer(Duration(milliseconds: 90 + order * step), () {
      if (controller.isDismissed) unawaited(controller.forward());
    });
  }

  /// 0..1: entrance progress times how present the page still is.
  double get alpha => fade.value * (exit?.value ?? 1);

  /// While the page leaves, its parts drift up a little as they fade.
  double get lift => -(1 - (exit?.value ?? 1)) * 16;

  Listenable get listenable =>
      exit == null ? controller : Listenable.merge([controller, exit!]);

  void dispose() {
    _delay?.cancel();
    controller.dispose();
  }
}

/// Fades and lifts text-like content in, [order] steps after the page
/// appeared. Do not put glass inside it: give the glass its own `order`.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.order = 0});

  final Widget child;
  final int order;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final _Entrance _e = _Entrance(this, widget.order);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _e.start(context);
  }

  @override
  void dispose() {
    _e.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _e.listenable,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _e.alpha.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - _e.rise.value) * 18 + _e.lift),
          child: child,
        ),
      ),
    );
  }
}

/// A pane of frosted glass: blurred backdrop, a faint sheen, and a light edge
/// that is brighter at the top-left. Solid on low-end devices.
///
/// With [blur] off it skips the backdrop blur and only keeps the sheen and
/// edge, for panes that sit on a background that is already blurred.
///
/// With an [order] it rises in with the rest of the page (its blur, tint and
/// edge fade up together); without one it is simply there.
class GlassSurface extends StatefulWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 24,
    this.selected = false,
    this.order,
    this.blur = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool selected;
  final int? order;
  final bool blur;

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface>
    with SingleTickerProviderStateMixin {
  late final _Entrance _e = _Entrance(this, widget.order ?? 0);
  bool _started = false;

  /// Keeps the content's state when the surface changes between glass and
  /// solid, so switching the interface style never restarts what is inside.
  final GlobalKey _contentKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.order == null) {
      _e.controller.value = 1;
      _e.exit = OnboardingExit.of(context);
    } else {
      _e.start(context);
    }
  }

  @override
  void dispose() {
    _e.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solid = isGlassSolid(context);
    final reduce = onboardingReduceMotion(context);
    return AnimatedBuilder(
      animation: _e.listenable,
      builder: (context, _) {
        final a = _e.alpha.clamp(0.0, 1.0);
        final rise = widget.order == null ? 1.0 : _e.rise.value;
        // 0 = frosted glass, 1 = solid. Changing the interface style eases
        // between the two instead of swapping the surface.
        final surface = TweenAnimationBuilder<double>(
          tween: Tween(end: solid ? 1.0 : 0.0),
          duration: reduce ? Duration.zero : const Duration(milliseconds: 520),
          curve: Curves.easeInOutCubic,
          builder: (context, solidness, _) => TweenAnimationBuilder<double>(
            tween: Tween(end: widget.selected ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            builder: (context, sel, _) => _surface(a, sel, solidness),
          ),
        );
        return Transform.translate(
          offset: Offset(0, (1 - rise) * 22 + _e.lift),
          child: Transform.scale(scale: 0.975 + 0.025 * rise, child: surface),
        );
      },
    );
  }

  Widget _content(double a) => KeyedSubtree(
        key: _contentKey,
        child: Opacity(
          opacity: a,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      );

  /// One structure for both looks: the blur, the sheen and the edge fade out
  /// as [solidness] rises while the solid fill and its border fade in.
  Widget _surface(double a, double sel, double solidness) {
    final r = BorderRadius.circular(widget.radius);
    final glass = a * (1 - solidness);
    final scheme = Theme.of(context).colorScheme;
    final solidFill = Color.lerp(
        scheme.surfaceContainerHigh, scheme.surfaceContainerHighest, sel)!;
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        // No backdrop work at all once it is fully solid.
        enabled: widget.blur && solidness < 1,
        filter: ui.ImageFilter.blur(
          sigmaX: 0.01 + 22 * glass,
          sigmaY: 0.01 + 22 * glass,
        ),
        child: CustomPaint(
          foregroundPainter: GlassEdgePainter(
            radius: widget.radius,
            alpha: glass,
            boost: sel,
          ),
          // Fill and sheen are separate layers: a gradient in the same
          // decoration would paint over the fill (it is transparent once the
          // surface is solid, and the fill would vanish).
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              color: solidFill.withValues(alpha: a * solidness),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: (0.08 + 0.12 * sel) * a * solidness,
                ),
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: (0.17 + 0.07 * sel) * glass),
                    Colors.white.withValues(alpha: (0.05 + 0.05 * sel) * glass),
                  ],
                ),
              ),
              child: _content(a),
            ),
          ),
        ),
      ),
    );
  }
}

/// The glass panel used for groups and single items.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
    this.radius = 28,
    this.order,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final int? order;
  final bool selected;

  @override
  Widget build(BuildContext context) => GlassSurface(
        radius: radius,
        padding: padding,
        order: order,
        selected: selected,
        child: child,
      );
}

/// A row of glass: leading, title with body text and a trailing widget.
/// [selected] gives it the lifted look; it dips slightly while pressed.
class GlassRow extends StatefulWidget {
  const GlassRow({
    super.key,
    this.leading,
    required this.title,
    this.body,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.order,
  });

  final Widget? leading;
  final String title;
  final String? body;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final int? order;

  @override
  State<GlassRow> createState() => _GlassRowState();
}

class _GlassRowState extends State<GlassRow> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: tappable ? (_) => setState(() => _down = true) : null,
      onTapCancel: tappable ? () => setState(() => _down = false) : null,
      onTapUp: tappable ? (_) => setState(() => _down = false) : null,
      child: AnimatedScale(
        scale: _down ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GlassSurface(
          order: widget.order,
          selected: widget.selected,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: tappable
                  ? () {
                      unawaited(HapticFeedback.selectionClick());
                      widget.onTap!();
                    }
                  : null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      SizedBox(width: 28, child: Center(child: widget.leading)),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: OnboardingText.rowTitle),
                          if (widget.body != null) ...[
                            const SizedBox(height: 4),
                            Text(widget.body!, style: OnboardingText.rowBody),
                          ],
                        ],
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 12),
                      widget.trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
