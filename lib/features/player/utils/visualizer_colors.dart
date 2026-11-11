import 'package:flutter/material.dart';

/// Contrast shared by the artwork scrim and every visualiser's primary marks.
abstract final class VisualizerColors {
  static const double backgroundOpacity = 0.60;
  static const double minimumOpacity = 0.75;
  static const double minimumContrast = 3.0;

  /// Interior underpaint only; its geometry must not extend into an outline.
  static const Color markBackground = Color(0xFF080A0F);

  /// Even white artwork cannot render brighter than this beneath the scrim.
  static final Color brightestBackground = Color.alphaBlend(
    Colors.black.withValues(alpha: backgroundOpacity),
    Colors.white,
  );

  /// Picks a distinctive chromatic swatch instead of assuming a fixed palette
  /// position is the accent. Neutral artwork keeps a neutral foreground.
  static Color fromArtwork(List<Color> palette, {Color? dominantColor}) {
    if (palette.isEmpty || palette.every((color) => color.a == 0)) {
      return Colors.white;
    }
    final dominantColorValue = dominantColor ?? palette.first;
    final background = Color.alphaBlend(
      Colors.black.withValues(alpha: backgroundOpacity),
      dominantColorValue.withValues(alpha: 1),
    );
    final dominant = HSLColor.fromColor(dominantColorValue);
    final dominantChroma =
        dominant.saturation * (1 - (2 * dominant.lightness - 1).abs());
    Color? accent;
    var bestAccent = -1.0;
    var neutral = palette.first;
    var bestContrast = -1.0;
    for (final swatch in palette) {
      if (swatch.a == 0) continue;
      final color = swatch.withValues(alpha: 1);
      final hsl = HSLColor.fromColor(color);
      final chroma = hsl.saturation * (1 - (2 * hsl.lightness - 1).abs());
      final rendered = Color.alphaBlend(
        color.withValues(alpha: minimumOpacity),
        background,
      );
      final a = rendered.computeLuminance() + 0.05;
      final b = background.computeLuminance() + 0.05;
      final contrast = a > b ? a / b : b / a;
      if (contrast > bestContrast) {
        neutral = color;
        bestContrast = contrast;
      }
      final hueDifference = (hsl.hue - dominant.hue).abs();
      final hueDistance =
          hueDifference > 180 ? 360 - hueDifference : hueDifference;
      final score =
          chroma * hsl.saturation * (1 + dominantChroma * hueDistance / 180);
      if (chroma >= 0.1 && score > bestAccent) {
        accent = color;
        bestAccent = score;
      }
    }
    return ensureContrast(accent ?? neutral);
  }

  /// Brightens an artwork color without mixing away its hue or saturation.
  static Color ensureContrast(Color preferred) {
    final opaque = preferred.withValues(alpha: 1);
    final backgroundLuminance = markBackground.computeLuminance();
    bool visible(Color color) {
      final rendered = Color.alphaBlend(
        color.withValues(alpha: minimumOpacity),
        markBackground,
      );
      // Leave room for 8-bit rasterisation rounding.
      return (rendered.computeLuminance() + 0.05) /
              (backgroundLuminance + 0.05) >=
          minimumContrast + 0.1;
    }

    if (visible(opaque)) return opaque;
    final hsl = HSLColor.fromColor(opaque);
    var low = hsl.lightness;
    var high = 1.0;
    for (var i = 0; i < 16; i++) {
      final lightness = (low + high) / 2;
      if (visible(hsl.withLightness(lightness).toColor())) {
        high = lightness;
      } else {
        low = lightness;
      }
    }
    return hsl.withLightness(high).toColor();
  }

  /// A brighter tone of the selected accent, not an unrelated white endpoint.
  static Color highlight(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness(hsl.lightness + (1 - hsl.lightness) * 0.25)
        .toColor();
  }
}
