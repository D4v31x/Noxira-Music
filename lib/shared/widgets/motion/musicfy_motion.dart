import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../adaptive_blur.dart';

// Motion language ported from realidkroo/musicfy (Compose):
// press3D, artwork hero into the opened page, cover fade-in and the receding
// page stack.

const double kContainerOpenDamping = 0.88;
const double kContainerOpenStiffness = 150;
const Duration kContainerOpenDuration = Duration(milliseconds: 480);
const Duration kContainerCloseDuration = Duration(milliseconds: 420);
const Curve kContainerCloseCurve = Cubic(0.4, 0, 0.1, 1);
const double kRecedeScale = 0.92;
const double kRecedeAlpha = 0.45;

/// Underdamped spring step response, normalised so t in 0..1 spans [duration].
class SpringCurve extends Curve {
  const SpringCurve({
    this.damping = kContainerOpenDamping,
    this.stiffness = kContainerOpenStiffness,
    this.duration = kContainerOpenDuration,
  });

  final double damping;
  final double stiffness;
  final Duration duration;

  @override
  double transformInternal(double t) {
    if (t >= 1) return 1;
    final seconds = t * duration.inMilliseconds / 1000.0;
    final w = math.sqrt(stiffness);
    final wd = w * math.sqrt(1 - damping * damping);
    final decay = math.exp(-damping * w * seconds);
    return 1 -
        decay *
            (math.cos(wd * seconds) +
                (damping * w / wd) * math.sin(wd * seconds));
  }
}

const SpringCurve _openSpring = SpringCurve();

/// Bottom corners of the detail screens' header, which the artwork lands in.
const BorderRadius kDetailHeaderRadius =
    BorderRadius.vertical(bottom: Radius.circular(24));

/// The last tapped card: lets the next pushed page know it was opened from a
/// card and which artwork should fly into it.
class TapOrigin {
  TapOrigin._();

  static String? _heroTag;
  static bool _set = false;
  static DateTime _at = DateTime.fromMillisecondsSinceEpoch(0);

  static void record(String? heroTag) {
    _set = true;
    _heroTag = heroTag;
    _at = DateTime.now();
  }

  static void clear() => _set = false;

  static void touch() => _at = DateTime.now();

  static ({String? heroTag})? take() {
    final hadOrigin = _set;
    final tag = _heroTag;
    _set = false;
    _heroTag = null;
    if (!hadOrigin) return null;
    if (DateTime.now().difference(_at) > const Duration(milliseconds: 900)) {
      return null;
    }
    return (heroTag: tag);
  }
}

/// Pages opened from a card; the page below recedes only while one is open.
int _activeCardPages = 0;
final Expando<({String? heroTag})> _routeOrigins = Expando();
final Expando<bool> _routeResolved = Expando();

/// Hero tag of the artwork that flew into this page, if it was opened from a card.
String? artworkHeroTagFor(BuildContext context) {
  final route = ModalRoute.of(context);
  if (route == null) return null;
  return _routeOrigins[route]?.heroTag;
}

class _PressSlot {
  String? heroTag;
}

class _PressScope extends InheritedWidget {
  const _PressScope({required this.slot, required super.child});

  final _PressSlot slot;

  @override
  bool updateShouldNotify(_PressScope old) => false;
}

/// Pressed tilt + scale for tappable cards. A page opened from the card
/// flies the card's [ArtworkHero] into its header.
class Press3D extends StatefulWidget {
  const Press3D({
    super.key,
    required this.child,
    this.maxTilt = 7,
    this.pressedScale = 0.97,
    this.cornerRadius = 15,
    this.opensPage = true,
    this.enabled = true,
  });

  final Widget child;
  final double maxTilt;
  final double pressedScale;
  final double cornerRadius;

  /// False for taps that don't push a page (e.g. a song that just plays).
  final bool opensPage;
  final bool enabled;

  @override
  State<Press3D> createState() => _Press3DState();
}

class _Press3DState extends State<Press3D> with SingleTickerProviderStateMixin {
  static final SpringDescription _spring =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 420, ratio: 1);

  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  final _PressSlot _slot = _PressSlot();
  Offset _normalized = Offset.zero;
  Offset? _down;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _press.animateWith(
      SpringSimulation(_spring, _press.value, target, _press.velocity),
    );
  }

  void _onDown(PointerDownEvent e) {
    final size = context.size;
    if (size == null || size.isEmpty) return;
    _down = e.position;
    _normalized = Offset(
      (e.localPosition.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
      (e.localPosition.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
    );
    _animateTo(1);
    if (widget.opensPage) TapOrigin.record(_slot.heroTag);
  }

  void _onMove(PointerMoveEvent e) {
    final down = _down;
    if (down == null) return;
    if ((e.position - down).distance > kTouchSlop) {
      _down = null;
      _animateTo(0);
      if (widget.opensPage) TapOrigin.clear();
    }
  }

  void _onUp(PointerEvent e) {
    if (_down == null) return;
    _down = null;
    _animateTo(0);
    if (widget.opensPage && e is PointerUpEvent) TapOrigin.touch();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    // The Transform must always be present: swapping it in and out remounts the
    // child mid-press and drops the tap.
    return Listener(
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onUp,
      child: _PressScope(
        slot: _slot,
        child: AnimatedBuilder(
          animation: _press,
          child: widget.child,
          builder: (context, child) {
            final t = _press.value;
            final s = 1 - (1 - widget.pressedScale) * t;
            final m = Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateX(-_normalized.dy * widget.maxTilt * t * math.pi / 180)
              ..rotateY(_normalized.dx * widget.maxTilt * t * math.pi / 180)
              ..scaleByDouble(s, s, 1, 1);
            return Transform(
              transform: m,
              alignment: Alignment.center,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

Widget _artworkShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
  BorderRadius sourceRadius,
  BorderRadius targetRadius,
) {
  final from = (fromHeroContext.widget as Hero).child;
  final to = (toHeroContext.widget as Hero).child;
  final isPush = direction == HeroFlightDirection.push;
  final source = isPush ? from : to;
  final target = isPush ? to : from;
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final t = animation.value.clamp(0.0, 1.0);
      // Blur builds up as the artwork grows, matching the header backdrop's sigma of 30.
      final sigma = 30 * Curves.easeIn.transform(t);
      final blend = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
      return ClipRRect(
        borderRadius: BorderRadius.lerp(sourceRadius, targetRadius, t)!,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - blend,
              child: AdaptiveImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: sigma,
                  sigmaY: sigma,
                  tileMode: TileMode.clamp,
                ),
                child: source,
              ),
            ),
            Opacity(opacity: blend, child: target),
          ],
        ),
      );
    },
  );
}

/// The artwork on a card. Flies into the page the card opens (see
/// [ArtworkHeroTarget]); inert outside a [Press3D].
class ArtworkHero extends StatefulWidget {
  const ArtworkHero({super.key, required this.child, this.radius = 12});

  final Widget child;
  final double radius;

  @override
  State<ArtworkHero> createState() => _ArtworkHeroState();
}

/// What each flying artwork looks like on its card, so the opened page can keep
/// showing it until its own artwork has loaded.
final Map<String, Widget> _heroSources = {};

int _heroTagCounter = 0;

class _ArtworkHeroState extends State<ArtworkHero> {
  // identityHashCode can collide; a counter is guaranteed unique.
  late final String _tag = 'aurora_art_${_heroTagCounter++}';

  @override
  void dispose() {
    _heroSources.remove(_tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slot = context.getInheritedWidgetOfExactType<_PressScope>()?.slot;
    if (slot == null) return widget.child;
    slot.heroTag = _tag;
    _heroSources[_tag] = widget.child;
    return Hero(
      tag: _tag,
      flightShuttleBuilder: (c, a, d, from, to) => _artworkShuttle(
        c,
        a,
        d,
        from,
        to,
        BorderRadius.circular(widget.radius),
        kDetailHeaderRadius,
      ),
      child: widget.child,
    );
  }
}

/// The header backdrop of an opened page; receives the card's artwork.
///
/// While [ready] is false (the page's own artwork is still loading) it keeps
/// showing the card's artwork, blurred like the finished backdrop, so the
/// flight never ends on a placeholder.
class ArtworkHeroTarget extends StatelessWidget {
  const ArtworkHeroTarget({
    super.key,
    required this.child,
    this.radius = 12,
    this.ready = true,
  });

  final Widget child;
  final double radius;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final tag = artworkHeroTagFor(context);
    if (tag == null) return child;
    final source = _heroSources[tag];
    final showSource = !ready && source != null;
    return Hero(
      tag: tag,
      flightShuttleBuilder: (c, a, d, from, to) => _artworkShuttle(
        c,
        a,
        d,
        from,
        to,
        BorderRadius.circular(radius),
        kDetailHeaderRadius,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          children: [...previous, if (current != null) current],
        ),
        child: showSource
            ? KeyedSubtree(
                key: const ValueKey('card-artwork'),
                child: _BlurredSource(source),
              )
            : KeyedSubtree(key: const ValueKey('page-artwork'), child: child),
      ),
    );
  }
}

class _BlurredSource extends StatelessWidget {
  const _BlurredSource(this.source);

  final Widget source;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AdaptiveImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 30,
              sigmaY: 30,
              tileMode: TileMode.clamp,
            ),
            child: SizedBox.expand(child: source),
          ),
          ColoredBox(color: Colors.black.withValues(alpha: 0.15)),
        ],
      ),
    );
  }
}

/// Cover that fades in once decoded instead of popping in. Use as the
/// `frameBuilder` of [Image].
Widget coverFadeFrameBuilder(
  BuildContext context,
  Widget child,
  int? frame,
  bool wasSynchronouslyLoaded,
) {
  if (wasSynchronouslyLoaded) return child;
  return AnimatedOpacity(
    opacity: frame == null ? 0 : 1,
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeInOutCubic,
    child: child,
  );
}

/// Page transition: pages fade in (the card's artwork flies in as a Hero), the
/// page below recedes. Only opacity changes on the incoming page so hero
/// geometry stays exact.
class MusicfyPageTransitionsBuilder extends PageTransitionsBuilder {
  const MusicfyPageTransitionsBuilder();

  /// Low-end devices get a short plain cross-fade instead of the full motion.
  static bool simple = false;

  @override
  Duration get transitionDuration =>
      simple ? const Duration(milliseconds: 180) : kContainerOpenDuration;

  @override
  Duration get reverseTransitionDuration =>
      simple ? const Duration(milliseconds: 150) : kContainerCloseDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (simple) {
      TapOrigin.clear();
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    }
    if (_routeResolved[route] != true) {
      _routeResolved[route] = true;
      final origin = route.isFirst ? null : TapOrigin.take();
      _routeOrigins[route] = origin;
      if (origin != null) {
        _activeCardPages++;
        void listener(AnimationStatus s) {
          if (s == AnimationStatus.dismissed) {
            _activeCardPages = math.max(0, _activeCardPages - 1);
            animation.removeStatusListener(listener);
          }
        }

        animation.addStatusListener(listener);
      }
    }

    return _Recede(
      secondaryAnimation: secondaryAnimation,
      child: _FadeEnter(animation: animation, child: child),
    );
  }
}

double _progress(Animation<double> a) {
  if (a.status == AnimationStatus.reverse) {
    return 1 - kContainerCloseCurve.transform(1 - a.value);
  }
  return _openSpring.transform(a.value);
}

class _FadeEnter extends StatelessWidget {
  const _FadeEnter({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      // Own layer, so the fade composites a cached page instead of repainting it.
      child: RepaintBoundary(child: child),
      builder: (context, child) {
        final raw = animation.value;
        // fade in over the first ~280ms; out between 120ms and 320ms of the close
        final opacity = animation.status == AnimationStatus.reverse
            ? ((raw - 0.429) / 0.357).clamp(0.0, 1.0)
            : (raw / 0.467).clamp(0.0, 1.0);
        return Opacity(opacity: opacity, child: child);
      },
    );
  }
}

class _Recede extends StatelessWidget {
  const _Recede({required this.secondaryAnimation, required this.child});

  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Same widget structure at rest and while receding, or the page below is
    // remounted and loses its state.
    return AnimatedBuilder(
      animation: secondaryAnimation,
      // Own layer, so scaling/fading composites a cached page instead of repainting it.
      child: RepaintBoundary(child: child),
      builder: (context, child) {
        final p = _activeCardPages == 0
            ? 0.0
            : _progress(secondaryAnimation).clamp(0.0, 1.0);
        return Opacity(
          opacity: 1 - (1 - kRecedeAlpha) * p,
          child: Transform.scale(
            scale: 1 - (1 - kRecedeScale) * p,
            child: child,
          ),
        );
      },
    );
  }
}

/// Springy press-down scale for buttons. Uses raw pointer events, so the
/// child's own tap handling and splash are untouched.
class SpringPress extends StatefulWidget {
  const SpringPress({
    super.key,
    required this.child,
    this.pressedScale = 0.86,
    this.damping = 0.54,
    this.stiffness = 720,
  });

  final Widget child;
  final double pressedScale;
  final double damping;
  final double stiffness;

  @override
  State<SpringPress> createState() => _SpringPressState();
}

class _SpringPressState extends State<SpringPress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController.unbounded(vsync: this, value: 1);

  void _to(double target) {
    final spring = SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: widget.stiffness,
      ratio: widget.damping,
    );
    _c.animateWith(SpringSimulation(spring, _c.value, target, _c.velocity));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _to(widget.pressedScale),
      onPointerUp: (_) => _to(1),
      onPointerCancel: (_) => _to(1),
      child: ScaleTransition(scale: _c, child: widget.child),
    );
  }
}

/// Cross-fades from a placeholder to the cover once its [token] (the loaded
/// image) changes, instead of popping in.
class CoverFade extends StatelessWidget {
  const CoverFade({super.key, required this.token, required this.child});

  final Object? token;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.fastOutSlowIn,
      // The default loose Stack lets the cover keep its card size inside a
      // flying hero; passthrough keeps the incoming constraints.
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [...previous, if (current != null) current],
      ),
      child: KeyedSubtree(key: ValueKey(token), child: child),
    );
  }
}

/// 0 up to [from], 1 from [to] on, an s-curve in between.
double smoothstep(double from, double to, double x) {
  final t = ((x - from) / (to - from)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}
