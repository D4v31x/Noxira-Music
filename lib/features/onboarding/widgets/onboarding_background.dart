import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/performance_mode_provider.dart';

/// Pixelated, posterised, grainy flow of colour shown behind onboarding.
///
/// Rendered by a tiny fragment shader (all geometry is evaluated per coarse
/// cell, so it is cheap) inside its own repaint boundary, and throttled to a
/// low frame rate. Low-end devices and "reduce motion" get a single still
/// frame instead of an animation. Switching between the two eases the motion
/// down or back up from where it was, rather than freezing or restarting.
class OnboardingBackground extends StatefulWidget {
  const OnboardingBackground({super.key, required this.child});

  final Widget child;

  @override
  State<OnboardingBackground> createState() => _OnboardingBackgroundState();
}

class _OnboardingBackgroundState extends State<OnboardingBackground>
    with SingleTickerProviderStateMixin {
  static const _fallbackColor = Color(0xFF15171A);

  static Future<ui.FragmentProgram>? _program;

  late final Ticker _ticker;
  final _frame = ValueNotifier<_Frame>(const _Frame(0));
  ui.FragmentShader? _shader;
  final _clock = FlowClock();
  Duration _minInterval = const Duration(milliseconds: 33);
  bool _first = true;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    (_program ??= ui.FragmentProgram.fromAsset('shaders/onboarding_flow.frag'))
        .then((program) {
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    }).catchError((_) {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final perf = context.watch<PerformanceModeProvider>();
    final animate =
        !perf.isLowEndDevice && !MediaQuery.disableAnimationsOf(context);
    _minInterval = Duration(
      milliseconds: perf.shouldEnableAnimatedGradients ? 33 : 66,
    );

    _clock.target = animate ? 1 : 0;
    if (_first) {
      // The very first frame already moves at full speed.
      _first = false;
      _clock.speed = _clock.target;
    }
    if (!_ticker.isActive && !_clock.settledStill) {
      _clock.restart();
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    if (_clock.tick(elapsed, _minInterval)) {
      _frame.value = _Frame(_clock.phase);
    }
    if (_clock.settledStill) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    return Stack(
      children: [
        Positioned.fill(
          child: shader == null
              ? const ColoredBox(color: _fallbackColor)
              : RepaintBoundary(
                  child: CustomPaint(
                    painter: _FlowPainter(shader, _frame),
                  ),
                ),
        ),
        widget.child,
      ],
    );
  }
}

/// The timing of the flow: how far it has run, how fast it runs right now and
/// when a frame is due. Kept apart from the widget so it can be tested.
class FlowClock {
  FlowClock({this.loopSeconds = 15.5});

  final double loopSeconds;

  /// Seconds of flow so far. Kept across stops and starts so the picture
  /// carries on from where it was.
  double flowSeconds = 0;

  /// Playback speed, eased towards [target] (1 = moving, 0 = still).
  double speed = 0;
  double target = 0;

  Duration _lastElapsed = Duration.zero;
  Duration _lastPaint = Duration.zero;

  static const easeSeconds = 0.35;

  bool get settledStill => target == 0 && speed == 0;

  /// 0..2π position in the loop.
  double get phase => (flowSeconds % loopSeconds) / loopSeconds * 2 * math.pi;

  /// A restarted ticker counts from zero again, so the old time stamps are
  /// forgotten; otherwise nothing is painted until its clock caught up with
  /// them, which looked like the background hanging after it was switched back
  /// on.
  void restart() {
    _lastElapsed = Duration.zero;
    _lastPaint = Duration.zero;
  }

  /// Advances to [elapsed] (the ticker's time) and says whether to paint now.
  bool tick(Duration elapsed, Duration minInterval) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt > 0) {
      speed += (target - speed) * (1 - math.exp(-dt / easeSeconds));
      if ((target - speed).abs() < 0.005) speed = target;
      flowSeconds += dt * speed;
    }
    if (settledStill || elapsed - _lastPaint >= minInterval) {
      _lastPaint = elapsed;
      return true;
    }
    return false;
  }
}

class _Frame {
  const _Frame(this.phase);

  final double phase;
}

class _FlowPainter extends CustomPainter {
  _FlowPainter(this.shader, this.frame) : super(repaint: frame);

  final ui.FragmentShader shader;
  final ValueNotifier<_Frame> frame;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame.value;
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, f.phase);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_FlowPainter old) => old.shader != shader;
}
