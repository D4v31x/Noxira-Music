import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Smoky blurred mesh used behind the splash screen.
///
/// The soft colour bands are painted once into a tiny offscreen image (where
/// the heavy blur is almost free) and then simply scaled up, instead of
/// running a full-screen gaussian blur on the GPU every frame.
class SplashBackdrop extends StatefulWidget {
  const SplashBackdrop({super.key});

  @override
  State<SplashBackdrop> createState() => _SplashBackdropState();
}

class _SplashBackdropState extends State<SplashBackdrop> {
  static const _downscale = 8.0;
  static const _base = Color(0xFF151515);

  ui.Image? _image;
  Size? _renderedFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    if (_renderedFor == size) return;
    _renderedFor = size;
    _render(size);
  }

  Future<void> _render(Size size) async {
    final w = (size.width / _downscale).ceil();
    final h = (size.height / _downscale).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(w / size.width, h / size.height);
    _paintMesh(canvas, size);
    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    picture.dispose();

    if (!mounted || _renderedFor != size) {
      image.dispose();
      return;
    }
    setState(() {
      _image?.dispose();
      _image = image;
    });
  }

  static void _paintMesh(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final full = Offset.zero & size;

    canvas.drawRect(full, Paint()..color = _base);

    canvas.saveLayer(
      full,
      Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 95, sigmaY: 95),
    );

    void oval(double w, double h, Color color,
        {double? top,
        double? left,
        double? right,
        double? bottom,
        double alpha = 0.95}) {
      final x = left ?? (width - w - (right ?? 0));
      final y = top ?? (height - h - (bottom ?? 0));
      final rect = Rect.fromLTWH(x, y, w, h);
      final shader = RadialGradient(
        colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
      ).createShader(rect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(h)),
        Paint()..shader = shader,
      );
    }

    oval(width * 1.15, height * 0.42, const Color(0xFFECECEA),
        top: -height * 0.14, right: -width * 0.22);
    oval(width * 1.05, height * 0.36, const Color(0xFFFF254C),
        top: height * 0.30, left: -width * 0.32);
    oval(width * 1.05, height * 0.34, const Color(0xFFFF355C),
        top: height * 0.27, right: -width * 0.18, alpha: 0.90);
    oval(width * 1.10, height * 0.48, const Color(0xFF171717),
        top: height * 0.18, left: width * 0.18, alpha: 1.0);
    oval(width * 0.95, height * 0.28, const Color(0xFF9B9B96),
        bottom: height * 0.12, left: -width * 0.10, alpha: 0.72);
    oval(width * 1.05, height * 0.42, const Color(0xFFE3E3E0),
        bottom: -height * 0.15, left: -width * 0.28, alpha: 0.84);
    oval(width * 1.18, height * 0.45, const Color(0xFF101010),
        bottom: -height * 0.12, right: -width * 0.16, alpha: 1.0);

    canvas.restore();

    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.24),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(full),
    );
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return RepaintBoundary(
      child: image == null
          ? const ColoredBox(color: _base)
          : RawImage(image: image, fit: BoxFit.fill),
    );
  }
}
