import 'dart:async';

import 'package:flutter/material.dart';

// Ported from musicfy's TouchFeedback.kt and RevealOnAppear.kt.

const Color kHighlightColor = Color(0x1FFFFFFF);
const Curve kRevealEasing = Cubic(0.2, 0, 0, 1);
const Duration kRevealDuration = Duration(milliseconds: 520);
const double kRevealSlide = 20;

/// Completes once the page's open transition has finished, so heavy loading
/// doesn't compete with the animation for frames. Safe to call from `initState`.
Future<void> whenRouteSettled(BuildContext context) async {
  // A route's animation reads "completed" until its first frame.
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) return;
  final animation = ModalRoute.of(context)?.animation;
  if (animation == null || animation.isCompleted || animation.isDismissed) {
    return;
  }
  final done = Completer<void>();
  void onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
      animation.removeStatusListener(onStatus);
      if (!done.isCompleted) done.complete();
    }
  }

  animation.addStatusListener(onStatus);
  return done.future.timeout(
    const Duration(milliseconds: 1500),
    onTimeout: () => animation.removeStatusListener(onStatus),
  );
}

/// A soft rounded box that fades in behind a pressed row or card instead of a
/// square ripple. [spillX]/[spillY] let it extend past the bounds.
class RoundedHighlight extends StatefulWidget {
  const RoundedHighlight({
    super.key,
    required this.child,
    this.cornerRadius = 12,
    this.spillX = 0,
    this.spillY = 0,
    this.color = kHighlightColor,
  });

  final Widget child;
  final double cornerRadius;
  final double spillX;
  final double spillY;
  final Color color;

  @override
  State<RoundedHighlight> createState() => _RoundedHighlightState();
}

class _RoundedHighlightState extends State<RoundedHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  int _pressed = 0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down() {
    _pressed++;
    _c.animateTo(1, duration: const Duration(milliseconds: 90));
  }

  Future<void> _up() async {
    _pressed = (_pressed - 1).clamp(0, 1 << 30);
    if (_pressed != 0) return;
    // a quick tap lets go before the box has shown at all, so flash it first
    if (_c.value < 1) {
      await _c.animateTo(1, duration: const Duration(milliseconds: 70));
    }
    if (mounted && _pressed == 0) {
      _c.animateTo(0, duration: const Duration(milliseconds: 340));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _down(),
      onPointerUp: (_) => _up(),
      onPointerCancel: (_) => _up(),
      child: CustomPaint(
        painter: _HighlightPainter(
          _c,
          widget.cornerRadius,
          widget.spillX,
          widget.spillY,
          widget.color,
        ),
        child: widget.child,
      ),
    );
  }
}

class _HighlightPainter extends CustomPainter {
  _HighlightPainter(this.t, this.radius, this.spillX, this.spillY, this.color)
      : super(repaint: t);

  final Animation<double> t;
  final double radius;
  final double spillX;
  final double spillY;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = t.value;
    if (s <= 0) return;
    final rect = Rect.fromLTWH(
      -spillX,
      -spillY,
      size.width + spillX * 2,
      size.height + spillY * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = color.withValues(alpha: color.a * s),
    );
  }

  @override
  bool shouldRepaint(_HighlightPainter old) =>
      old.radius != radius ||
      old.spillX != spillX ||
      old.spillY != spillY ||
      old.color != color;
}

/// Keys that already played their reveal, so scrolling a row back in or coming
/// back to a screen doesn't animate it twice.
class RevealSeen {
  RevealSeen._();

  static final Set<String> _seen = <String>{};
  static DateTime _burstStartedAt = DateTime.fromMillisecondsSinceEpoch(0);
  static int _burstCount = 0;

  /// Reveals that start together go one after another.
  static Duration _nextBurstDelay() {
    final now = DateTime.now();
    if (now.difference(_burstStartedAt) > const Duration(milliseconds: 120)) {
      _burstStartedAt = now;
      _burstCount = 0;
    }
    final step = _burstCount < 6 ? _burstCount : 6;
    _burstCount++;
    return Duration(milliseconds: step * 60);
  }
}

/// Fades and slides its child up the first time it shows for [revealKey].
/// With [waitForRoute] it holds back until the page transition has settled.
class RevealOnAppear extends StatefulWidget {
  const RevealOnAppear({
    super.key,
    required this.revealKey,
    required this.child,
    this.delay = Duration.zero,
    this.cascade = true,
    this.waitForRoute = true,
  });

  final String revealKey;
  final Widget child;
  final Duration delay;
  final bool cascade;
  final bool waitForRoute;

  @override
  State<RevealOnAppear> createState() => _RevealOnAppearState();
}

class _RevealOnAppearState extends State<RevealOnAppear>
    with SingleTickerProviderStateMixin {
  late final bool _alreadySeen;
  late final AnimationController _c;
  late final Animation<double> _p;
  Animation<double>? _route;

  @override
  void initState() {
    super.initState();
    // Created up front: a controller first built inside dispose() would look up
    // an ancestor on a deactivated element and throw.
    _alreadySeen = RevealSeen._seen.contains(widget.revealKey);
    _c = AnimationController(vsync: this, duration: kRevealDuration);
    _p = CurvedAnimation(parent: _c, curve: kRevealEasing);
  }

  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_alreadySeen || _checked) return;
    _checked = true;
    final route =
        widget.waitForRoute ? ModalRoute.of(context)?.animation : null;
    if (route == null) {
      _start();
      return;
    }
    // A route's animation reads "completed" until its first frame, so the
    // real state is only known after this one.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (route.isCompleted) {
        _start();
      } else {
        _route = route..addStatusListener(_onRouteStatus);
      }
    });
  }

  bool _started = false;

  void _onRouteStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) _start();
  }

  Future<void> _start() async {
    if (_started) return;
    _started = true;
    _route?.removeStatusListener(_onRouteStatus);
    // marked up front: a fast fling that disposes the row mid-animation
    // shouldn't replay it later
    RevealSeen._seen.add(widget.revealKey);
    final wait = widget.delay +
        (widget.cascade ? RevealSeen._nextBurstDelay() : Duration.zero);
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    if (mounted) _c.forward();
  }

  @override
  void dispose() {
    _route?.removeStatusListener(_onRouteStatus);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_alreadySeen) return widget.child;
    return AnimatedBuilder(
      animation: _p,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _p.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _p.value) * kRevealSlide),
          child: child,
        ),
      ),
    );
  }
}
