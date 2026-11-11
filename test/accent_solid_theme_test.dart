import 'package:aurora_music_v01/shared/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

double _distance(Color a, Color b) =>
    (a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('low-end solids move toward the accent colour', () {
    for (final seed in const [Color(0xFF00C853), Color(0xFFFF4081)]) {
      final base = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      );
      final tinted = ThemeProvider.accentSolidTheme(base);
      final accent = base.colorScheme.primaryContainer;

      for (final pair in [
        (base.colorScheme.surface, tinted.colorScheme.surface),
        (
          base.colorScheme.surfaceContainerHigh,
          tinted.colorScheme.surfaceContainerHigh
        ),
      ]) {
        expect(
            _distance(pair.$2, accent), lessThan(_distance(pair.$1, accent)));
      }
      expect(tinted.scaffoldBackgroundColor, tinted.colorScheme.surface);
      expect(tinted.colorScheme.primary, base.colorScheme.primary);
    }
  });

  test('the tinted theme is only used when asked for and is cached', () async {
    final provider = ThemeProvider();
    await Future<void>.delayed(Duration.zero);

    final normal = provider.darkThemeFor(accentSolids: false);
    final solid = provider.darkThemeFor(accentSolids: true);

    expect(identical(normal, provider.darkTheme), isTrue);
    expect(solid.colorScheme.surface, isNot(normal.colorScheme.surface));
    expect(identical(solid, provider.darkThemeFor(accentSolids: true)), isTrue);

    await provider.setPreset(4);
    final next = provider.darkThemeFor(accentSolids: true);
    expect(identical(next, solid), isFalse);
    expect(next.colorScheme.surface, isNot(solid.colorScheme.surface));
  });
}
