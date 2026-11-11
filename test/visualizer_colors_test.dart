import 'dart:ui' as ui;

import 'package:aurora_music_v01/features/player/utils/visualizer_colors.dart';
import 'package:aurora_music_v01/features/player/widgets/visualizer_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final first = a.computeLuminance() + 0.05;
  final second = b.computeLuminance() + 0.05;
  return first > second ? first / second : second / first;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('backed primary marks contrast independently of the artwork', () {
    const artwork = [
      Colors.black,
      Colors.white,
      Color(0xFF666666),
      Color(0xFF101A3A),
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.cyan,
      Color(0xFFFF00FF),
    ];
    for (final preferred in artwork) {
      final foreground = VisualizerColors.ensureContrast(preferred);
      for (final background in artwork) {
        final scrimmed = Color.alphaBlend(
          Colors.black.withValues(alpha: VisualizerColors.backgroundOpacity),
          background,
        );
        final backing =
            Color.alphaBlend(VisualizerColors.markBackground, scrimmed);
        for (final opacity in [
          VisualizerColors.minimumOpacity,
          0.88,
          0.9,
          0.92,
          0.95,
          1.0,
        ]) {
          final rendered = Color.alphaBlend(
            foreground.withValues(alpha: opacity),
            backing,
          );
          expect(_contrast(rendered, backing),
              greaterThanOrEqualTo(VisualizerColors.minimumContrast));
        }
      }
    }
  });

  test('readable artwork colors and the no-artwork white stay unchanged', () {
    for (final color in [Colors.white, const Color(0xFFFFEECC)]) {
      expect(VisualizerColors.ensureContrast(color), color);
    }
    expect(VisualizerColors.ensureContrast(Colors.transparent).a, 1);
  });

  test('blue artwork chooses its vivid accent, not a neutral palette slot', () {
    const blue = Color(0xFF0979E4);
    final selected = VisualizerColors.fromArtwork([
      const Color(0xFF10131C),
      const Color(0xFF777777),
      const Color(0xFFBBBBBB),
      blue,
    ]);
    final hsl = HSLColor.fromColor(selected);
    final original = HSLColor.fromColor(blue);
    // HSLColor.toColor quantizes to 8-bit channels.
    expect(hsl.hue, closeTo(original.hue, 1));
    expect(hsl.saturation, closeTo(original.saturation, 0.03));
    expect(hsl.saturation, greaterThan(0.8));
    expect(hsl.lightness, lessThan(0.65),
        reason: 'visibility must not turn a vivid blue into a pale pastel');
  });

  test('a red accent stands apart from a muted blue-gray dominant cover', () {
    const red = Color(0xFF98243A);
    final selected = VisualizerColors.fromArtwork([
      const Color(0xFF192A32),
      const Color(0xFF688D9F),
      const Color(0xFFA8BBC3),
      red,
    ]);
    final hsl = HSLColor.fromColor(selected);
    expect(hsl.hue, closeTo(HSLColor.fromColor(red).hue, 2));
    expect(hsl.saturation, greaterThan(0.6));
    expect(hsl.lightness, lessThan(0.65));
  });

  test('palette order does not turn a colorful accent into a gray one', () {
    const dominant = Color(0xFF201410);
    const accent = Color(0xFFEA7019);
    const gray = Color(0xFFAAAAAA);
    expect(
      VisualizerColors.fromArtwork([dominant, accent, gray]),
      VisualizerColors.fromArtwork([dominant, gray, accent]),
    );
  });

  test('contrast adjustments and highlights preserve artwork hues', () {
    for (final color in [
      const Color(0xFFB82222),
      const Color(0xFFB87812),
      const Color(0xFF159949),
      const Color(0xFF1264C1),
      const Color(0xFFB32481),
    ]) {
      final original = HSLColor.fromColor(color);
      final foreground = VisualizerColors.ensureContrast(color);
      for (final tone in [foreground, VisualizerColors.highlight(foreground)]) {
        final hsl = HSLColor.fromColor(tone);
        // The highlight passes through two 8-bit HSL conversions.
        expect(hsl.hue, closeTo(original.hue, 2));
        expect(hsl.saturation, closeTo(original.saturation, 0.03));
      }
    }
  });

  test('missing or monochrome artwork does not invent an accent', () {
    expect(VisualizerColors.fromArtwork([]), Colors.white);
    expect(VisualizerColors.fromArtwork([Colors.transparent]), Colors.white);
    final color = VisualizerColors.fromArtwork([
      Colors.black,
      const Color(0xFF777777),
      Colors.white,
    ]);
    expect(HSLColor.fromColor(color).saturation, 0);
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(768, 1024),
  ]) {
    for (final dots in [false, true]) {
      test('rasterised ${dots ? 'dots' : 'bar bases'} contrast at $size',
          () async {
        final color = VisualizerColors.fromArtwork([
          const Color(0xFF101A3A),
          const Color(0xFF0979E4),
          const Color(0xFFBBBBBB),
        ]);
        final levels = List.filled(64, dots ? 0.5 : 0.03);
        final painter = dots
            ? DotMatrixPainter(
                levels: levels,
                color: color,
                bottomInset: 0,
                paintGeneration: 1,
              )
            : PeakBarsPainter(
                levels: levels,
                peaks: levels,
                color: color,
                bottomInset: 0,
                paintGeneration: 1,
              );
        const scale = 2.0;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder)..scale(scale);
        final background = VisualizerColors.brightestBackground;
        canvas.drawRect(Offset.zero & size, Paint()..color = background);
        painter.paint(canvas, size);
        final picture = recorder.endRecording();
        final image = await picture.toImage(
          (size.width * scale).round(),
          (size.height * scale).round(),
        );
        picture.dispose();
        final pixels = (await image.toByteData())!;
        final pitch = (size.width - 48) / 32;
        final barWidth = (size.width - 40) / (64 + 63 * 0.55);
        final x = ((dots ? 24 + pitch / 2 : 20 + barWidth / 2) * scale).floor();
        final y =
            ((size.height - 200 - (dots ? pitch / 2 : 3)) * scale).floor();
        final offset = (y * image.width + x) * 4;
        final rendered = Color.fromARGB(
          pixels.getUint8(offset + 3),
          pixels.getUint8(offset),
          pixels.getUint8(offset + 1),
          pixels.getUint8(offset + 2),
        );
        {
          final borderX = dots ? 24 + pitch / 2 - pitch * 0.62 / 2 - 0.5 : 19.5;
          final borderOffset =
              (y * image.width + (borderX * scale).floor()) * 4;
          final border = Color.fromARGB(
            pixels.getUint8(borderOffset + 3),
            pixels.getUint8(borderOffset),
            pixels.getUint8(borderOffset + 1),
            pixels.getUint8(borderOffset + 2),
          );
          expect(border, background,
              reason: 'underpainting must not form an exterior black outline');
        }
        image.dispose();
        expect(_contrast(rendered, VisualizerColors.markBackground),
            greaterThanOrEqualTo(VisualizerColors.minimumContrast));
        expect(rendered.b, greaterThan(rendered.r * 1.1));
      });
    }
  }
}
