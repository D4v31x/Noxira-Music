import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Like animation ported from musicfy's LikeBurst: a heart arcs up to the middle
// of the screen, thumps with a burst, floats, then dives into the like button.

const double _heartWidth = 104;
const double _heartAspect = 76 / 88;
const double _particleWidth = 14;
const int _particleCount = 8;
const int _maxFlights = 4;

const double _travelMs = 460;
const double _thumpMs = 110;
const double _floatMs = 640;
const double _homeMs = 540;
const double _bounceMs = 600;

const double _thumpAt = _travelMs;
const double _floatAt = _thumpAt + _thumpMs;
const double _homeAt = _floatAt + _floatMs;
const double _landAt = _homeAt + _homeMs;
const double _totalMs = _landAt + _bounceMs;

const Curve _travelEasing = Cubic(0.3, 1.22, 0.5, 1);
const Curve _popEasing = Cubic(0.34, 1.56, 0.64, 1);
const Curve _homeEasing = Cubic(0.5, -0.18, 0.7, 1);
const Curve _linearOutSlowIn = Cubic(0, 0, 0.2, 1);

/// Entry point for the like heart animation.
class LikeBurst {
  LikeBurst._();

  /// Scale of the like button while a heart lands on it.
  static final ValueNotifier<double> landing = ValueNotifier<double>(1);

  static GlobalKey? _targetKey;
  static final List<OverlayEntry> _entries = [];

  /// Flies a heart. With no [origin] it leaves the like button itself.
  static void play(
    BuildContext context, {
    Offset? origin,
    Color color = Colors.red,
    double glyphWidth = 30,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final from = origin ?? _targetCenter();
    if (from == null) return;

    if (_entries.length >= _maxFlights) {
      final old = _entries.removeAt(0);
      if (old.mounted) old.remove();
    }
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _HeartFlight(
        origin: from,
        fromButton: origin == null,
        color: color,
        glyphWidth: glyphWidth,
        seed: math.Random().nextInt(1 << 30),
        onDone: () {
          _entries.remove(entry);
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _entries.add(entry);
    overlay.insert(entry);
  }

  static Offset? _targetCenter() {
    final box = _targetKey?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

/// Marks the like button: hearts leave from and land on it, and it bounces.
class LikeBurstTarget extends StatefulWidget {
  const LikeBurstTarget({super.key, required this.child});

  final Widget child;

  @override
  State<LikeBurstTarget> createState() => _LikeBurstTargetState();
}

class _LikeBurstTargetState extends State<LikeBurstTarget> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    LikeBurst._targetKey = _key;
  }

  @override
  void dispose() {
    if (LikeBurst._targetKey == _key) LikeBurst._targetKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: LikeBurst.landing,
      child: KeyedSubtree(key: _key, child: widget.child),
      builder: (context, scale, child) =>
          scale == 1 ? child! : Transform.scale(scale: scale, child: child),
    );
  }
}

class _Particle {
  const _Particle(
      this.dx, this.dy, this.reach, this.scale, this.spin, this.color);
  final double dx, dy, reach, scale, spin;
  final Color color;
}

class _HeartFlight extends StatefulWidget {
  const _HeartFlight({
    required this.origin,
    required this.fromButton,
    required this.color,
    required this.glyphWidth,
    required this.seed,
    required this.onDone,
  });

  final Offset origin;
  final bool fromButton;
  final Color color;
  final double glyphWidth;
  final int seed;
  final VoidCallback onDone;

  @override
  State<_HeartFlight> createState() => _HeartFlightState();
}

class _HeartFlightState extends State<_HeartFlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _totalMs.round()),
  );
  late final math.Random _random = math.Random(widget.seed);
  late final double _side = _random.nextBool() ? 1 : -1;
  late final List<_Particle> _particles = _buildParticles();
  bool _thumped = false;
  bool _landed = false;

  List<_Particle> _buildParticles() {
    final palette = [
      widget.color,
      Color.lerp(widget.color, Colors.white, 0.45)!,
      Colors.white,
    ];
    return List.generate(_particleCount, (i) {
      final angle =
          i * 2 * math.pi / _particleCount + (_random.nextDouble() - 0.5) * 0.5;
      return _Particle(
        math.cos(angle),
        math.sin(angle),
        44.0 + _random.nextInt(36),
        0.6 + _random.nextDouble() * 0.5,
        (_random.nextDouble() - 0.5) * 70,
        palette[i % palette.length],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (!widget.fromButton) HapticFeedback.lightImpact();
    _c.addListener(_onTick);
    _c.forward().whenComplete(widget.onDone);
  }

  void _onTick() {
    final ms = _c.value * _totalMs;
    if (!_thumped && ms >= _thumpAt) {
      _thumped = true;
      HapticFeedback.mediumImpact();
    }
    if (!_landed && ms >= _landAt) {
      _landed = true;
      HapticFeedback.selectionClick();
    }
    if (ms >= _landAt) {
      final t = ms - _landAt;
      LikeBurst.landing.value = t < 90
          ? 1 + 0.3 * _linearOutSlowIn.transform(t / 90)
          : 1 + 0.3 * _springDisplacement((t - 90) / 1000, 0.35, 520);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    LikeBurst.landing.value = 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = context.findRenderObject();
    final rootOffset = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero)
        : Offset.zero;
    final glyphScale = widget.glyphWidth / _heartWidth;
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _FlightPainter(
              ms: _c.value * _totalMs,
              origin: widget.origin - rootOffset,
              target: (LikeBurst._targetCenter() ?? widget.origin) - rootOffset,
              side: _side,
              fromButton: widget.fromButton,
              glyphScale: glyphScale,
              color: widget.color,
              particles: _particles,
            ),
          ),
        ),
      ),
    );
  }
}

/// Damped-spring displacement from 1 towards 0 after [seconds].
double _springDisplacement(double seconds, double damping, double stiffness) {
  final w = math.sqrt(stiffness);
  final wd = w * math.sqrt(1 - damping * damping);
  return math.exp(-damping * w * seconds) *
      (math.cos(wd * seconds) + damping * w / wd * math.sin(wd * seconds));
}

double _seg(double ms, double start, double dur,
    [Curve curve = Curves.linear]) {
  return curve.transform(((ms - start) / dur).clamp(0.0, 1.0));
}

Offset _quad(Offset a, Offset c, Offset b, double t) {
  final u = 1 - t;
  return Offset(
    u * u * a.dx + 2 * u * t * c.dx + t * t * b.dx,
    u * u * a.dy + 2 * u * t * c.dy + t * t * b.dy,
  );
}

Path _heart(double w) {
  final h = w * _heartAspect;
  return Path()
    ..moveTo(0, h * 0.46)
    ..cubicTo(-w * 0.6, -h * 0.02, -w * 0.4, -h * 0.5, 0, -h * 0.2)
    ..cubicTo(w * 0.4, -h * 0.5, w * 0.6, -h * 0.02, 0, h * 0.46)
    ..close();
}

class _FlightPainter extends CustomPainter {
  _FlightPainter({
    required this.ms,
    required this.origin,
    required this.target,
    required this.side,
    required this.fromButton,
    required this.glyphScale,
    required this.color,
    required this.particles,
  });

  final double ms;
  final Offset origin;
  final Offset target;
  final double side;
  final bool fromButton;
  final double glyphScale;
  final Color color;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.44);

    final travel = _seg(ms, 0, _travelMs, _travelEasing);
    final control = Offset(
      (origin.dx + center.dx) / 2 + side * 48,
      math.min(origin.dy, center.dy) - 110,
    );
    final inPos = _quad(origin, control, center, travel);

    final f = _seg(ms, _floatAt, _floatMs);
    Offset bobAt(double f) => Offset(
          math.sin(f * 2 * math.pi * 1.25) * 7 * side,
          -math.sin(f * 2 * math.pi) * 9 - f * 16,
        );
    final floatPos = center + bobAt(f);
    final floatEnd = center + bobAt(1);

    final h = _seg(ms, _homeAt, _homeMs, _homeEasing);
    final homeControl = Offset(
      floatEnd.dx + (target.dx - floatEnd.dx) * 0.25,
      floatEnd.dy - 90,
    );
    final Offset pos;
    if (ms >= _homeAt) {
      pos = _quad(floatEnd, homeControl, target, h);
    } else if (ms >= _floatAt) {
      pos = floatPos;
    } else {
      pos = inPos;
    }

    final wobble = math.sin(f * 2 * math.pi * 1.5) * 8;
    final double rotationDeg;
    if (ms >= _homeAt) {
      rotationDeg = wobble * (1 - h) +
          math.sin(h * math.pi) * 16 * (target.dx - floatEnd.dx).sign;
    } else if (ms >= _floatAt) {
      rotationDeg = wobble;
    } else {
      rotationDeg = -22 * side * (1 - travel.clamp(0.0, 1.0));
    }

    final pop = _seg(ms, 0, _travelMs, _popEasing);
    var scale = fromButton ? glyphScale + (1 - glyphScale) * pop : pop;
    if (ms >= _thumpAt) {
      final t = ms - _thumpAt;
      scale = t < _thumpMs
          ? 1 + 0.32 * _linearOutSlowIn.transform(t / _thumpMs)
          : 1 + 0.32 * _springDisplacement((t - _thumpMs) / 1000, 0.3, 360);
    }

    final redUp = _seg(ms, _thumpAt, _thumpMs, Curves.fastOutSlowIn);
    final redDown = _seg(ms, _thumpAt + 160, 520, Curves.fastOutSlowIn);
    final red = redUp * (1 - redDown);

    final homeShrink = 1 + (glyphScale - 1) * h * h;
    final s = scale * homeShrink;
    final squash = math.max(0.0, scale - 1);
    final sx = s * (1 + squash * 0.28);
    final sy = s * (1 - squash * 0.14);
    final alpha = 1 - ((h - 0.84) / 0.16).clamp(0.0, 1.0);

    _paintBurst(canvas, center, _seg(ms, _thumpAt, 620, _linearOutSlowIn));

    if (alpha <= 0 || s <= 0) return;
    final shadowAt = pos + Offset(0, 8 * s);
    canvas.drawCircle(
      shadowAt,
      _heartWidth * 0.75 * s,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.black.withValues(alpha: 0.22 * alpha),
          Colors.transparent,
        ]).createShader(
            Rect.fromCircle(center: shadowAt, radius: _heartWidth * 0.75 * s)),
    );
    if (red > 0.01) {
      final r = _heartWidth * 0.95 * s;
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            color.withValues(alpha: 0.45 * red * alpha),
            Colors.transparent,
          ]).createShader(Rect.fromCircle(center: pos, radius: r)),
      );
    }

    canvas
      ..save()
      ..translate(pos.dx, pos.dy)
      ..rotate(rotationDeg * math.pi / 180)
      ..scale(sx, sy)
      ..drawPath(
        _heart(_heartWidth),
        Paint()
          ..color =
              Color.lerp(Colors.white, color, red)!.withValues(alpha: alpha),
      )
      ..restore();
  }

  void _paintBurst(Canvas canvas, Offset center, double progress) {
    if (progress <= 0 || progress >= 1) return;
    final out = 1 - math.pow(1 - progress, 3).toDouble();
    final fade = 1 - progress;

    canvas.drawCircle(
      center,
      _heartWidth * 0.5 * (0.7 + 1.2 * out),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 + (0.5 - 5) * progress
        ..color = Color.lerp(color, Colors.white, progress * 0.6)!
            .withValues(alpha: 0.7 * fade),
    );

    const start = _heartWidth * 0.32;
    for (final p in particles) {
      final distance = start + p.reach * out;
      final at = center + Offset(p.dx * distance, p.dy * distance);
      final s = p.scale * (1 - progress * 0.5);
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(p.spin * progress * math.pi / 180)
        ..scale(s)
        ..drawPath(
          _heart(_particleWidth),
          Paint()..color = p.color.withValues(alpha: fade),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_FlightPainter old) => old.ms != ms;
}
