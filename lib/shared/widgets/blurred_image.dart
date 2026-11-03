import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'adaptive_blur.dart';

/// An image blurred once into a small bitmap and then drawn as a plain
/// texture, instead of re-running a full-screen blur filter on every frame.
///
/// [sigma] is in logical pixels, as for `ImageFilter.blur`. Until the bitmap
/// is ready, [fallback] (the live blur) is shown.
class BlurredImage extends StatefulWidget {
  const BlurredImage({
    super.key,
    required this.provider,
    required this.sigma,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  final ImageProvider provider;
  final double sigma;
  final BoxFit fit;
  final Widget fallback;

  /// Renders the blurred bitmap ahead of time for a [BlurredImage] spanning
  /// [extent] logical pixels on its longest side, so it is ready on first build.
  static Future<void> precache(ImageProvider provider,
      {required double sigma, required double extent}) {
    final bitmapSigma = (sigma * _BlurCache.side / extent).clamp(0.5, 64.0);
    return _BlurCache.load(_Key(provider, (bitmapSigma * 2).round() / 2));
  }

  @override
  State<BlurredImage> createState() => _BlurredImageState();
}

class _BlurredImageState extends State<BlurredImage> {
  _Key? _requested;
  bool _shownReady = false;
  int _generation = 0;

  @override
  Widget build(BuildContext context) {
    // Low-end: no blur at all — a small, dimmed, unfiltered image instead.
    if (isBlurDisabled(context)) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: ResizeImage(widget.provider, width: 160),
            fit: widget.fit,
            gaplessPlayback: true,
          ),
          const ColoredBox(color: Color(0x8C000000)),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = constraints.biggest.longestSide;
        if (!extent.isFinite || extent <= 0) return widget.fallback;
        // The same blur, expressed in the small bitmap's pixels.
        final bitmapSigma =
            (widget.sigma * _BlurCache.side / extent).clamp(0.5, 64.0);
        final key = _Key(widget.provider, (bitmapSigma * 2).round() / 2);
        final ready = _BlurCache.peek(key);
        if (ready == null && _requested != key) {
          _requested = key;
          unawaited(_BlurCache.load(key).then((_) {
            if (mounted && _requested == key) setState(() {});
          }));
        }
        // A fresh key per change, so a fading-out child never shares a key with its replacement.
        if (_shownReady != (ready != null)) {
          _shownReady = ready != null;
          _generation++;
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: KeyedSubtree(
            key: ValueKey(_generation),
            child: ready != null
                ? RawImage(
                    image: ready,
                    fit: widget.fit,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : widget.fallback,
          ),
        );
      },
    );
  }
}

class _Key {
  const _Key(this.provider, this.sigma);

  final ImageProvider provider;
  final double sigma;

  @override
  bool operator ==(Object other) =>
      other is _Key && other.provider == provider && other.sigma == sigma;

  @override
  int get hashCode => Object.hash(provider, sigma);
}

class _BlurCache {
  static const int side = 256;
  static const int _capacity = 8;

  // Evicted images are left to the GC: a widget may still be drawing one.
  static final LinkedHashMap<_Key, ui.Image> _images = LinkedHashMap();
  static final Map<_Key, Future<void>> _pending = {};

  static ui.Image? peek(_Key key) {
    final image = _images.remove(key);
    if (image != null) _images[key] = image;
    return image;
  }

  static Future<void> load(_Key key) {
    return _pending[key] ??= _render(key).whenComplete(() {
      _pending.remove(key);
    });
  }

  static Future<void> _render(_Key key) async {
    try {
      final source = await _decode(key.provider);
      if (source == null) return;
      final w = source.width.toDouble();
      final h = source.height.toDouble();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, w, h));
      final paint = ui.Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: key.sigma,
          sigmaY: key.sigma,
          tileMode: ui.TileMode.clamp,
        );
      canvas.saveLayer(ui.Rect.fromLTWH(0, 0, w, h), paint);
      canvas.drawImage(source, ui.Offset.zero, ui.Paint());
      canvas.restore();
      final blurred =
          await recorder.endRecording().toImage(source.width, source.height);
      source.dispose();
      _images[key] = blurred;
      while (_images.length > _capacity) {
        _images.remove(_images.keys.first);
      }
    } catch (_) {
      // The live blur stays in place.
    }
  }

  static Future<ui.Image?> _decode(ImageProvider provider) {
    final completer = Completer<ui.Image?>();
    final stream =
        ResizeImage(provider, width: side).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(info.image.clone());
      },
      onError: (_, __) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}
