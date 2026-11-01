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
/// frame instead of an animation.
class OnboardingBackground extends StatefulWidget {
  const OnboardingBackground({super.key, required this.child});

  final Widget child;

  @override
  State<OnboardingBackground> createState() => _OnboardingBackgroundState();
}

class _OnboardingBackgroundState extends State<OnboardingBackground>
    with SingleTickerProviderStateMixin {
  static const _loopSeconds = 15.5;
  static const _fallbackColor = Color(0xFF15171A);

  static Future<ui.FragmentProgram>? _program;

  late final Ticker _ticker;
  final _frame = ValueNotifier<_Frame>(const _Frame(0));
  ui.FragmentShader? _shader;
  Duration _lastPaint = Duration.zero;
  Duration _minInterval = const Duration(milliseconds: 33);

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

    if (animate && !_ticker.isActive) {
      _ticker.start();
    } else if (!animate && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    if (elapsed - _lastPaint < _minInterval) return;
    _lastPaint = elapsed;
    final seconds = elapsed.inMicroseconds / 1e6;
    _frame.value = _Frame(
      (seconds % _loopSeconds) / _loopSeconds * 2 * math.pi,
    );
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
