import 'dart:typed_data';

import 'package:aurora_music_v01/features/player/utils/visualizer_colors.dart';
import 'package:aurora_music_v01/shared/services/background_manager_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('small red artwork details survive extraction and beat muted blue-gray',
      () async {
    const width = 64;
    const height = 64;
    const red = Color(0xFF9E1836);
    final pixels = Uint8List(width * height * 4);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final color = x >= 48 && x < 52 && y >= 8 && y < 56
            ? red
            : x >= 16 && x < 48 && y >= 8 && y < 56
                ? const Color(0xFF88A3AD)
                : const Color(0xFF243B43);
        final offset = (y * width + x) * 4;
        pixels[offset] = (color.r * 255).round();
        pixels[offset + 1] = (color.g * 255).round();
        pixels[offset + 2] = (color.b * 255).round();
        pixels[offset + 3] = 255;
      }
    }

    final extracted = await computeArtworkPalette(
      (pixels: pixels, width: width, height: height),
    );
    expect(extracted.background, hasLength(6));
    final selected = VisualizerColors.fromArtwork(
      extracted.accents.map(Color.new).toList(),
      dominantColor: Color(extracted.background.first),
    );
    final hsl = HSLColor.fromColor(selected);
    expect(hsl.hue, closeTo(HSLColor.fromColor(red).hue, 5));
    expect(hsl.saturation, greaterThan(0.6));
    expect(hsl.lightness, lessThan(0.65));
  });
}
