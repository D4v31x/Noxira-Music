import 'package:aurora_music_v01/features/onboarding/widgets/onboarding_glass.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/providers/theme_provider.dart';
import 'package:aurora_music_v01/shared/services/device_performance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => taps++),
        child: Text('taps $taps'),
      );
}

void main() {
  late PerformanceModeProvider perf;

  Future<void> open(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    perf = PerformanceModeProvider();
    await perf.setPerformanceMode(PerformanceLevel.high);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: perf,
      child: const MaterialApp(
        home: Scaffold(body: GlassSurface(child: _Counter())),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
  }

  bool backdropOn(WidgetTester tester) =>
      tester.widget<BackdropFilter>(find.byType(BackdropFilter)).enabled;

  testWidgets('glass turns solid gradually and stops blurring once solid',
      (tester) async {
    await open(tester);
    expect(backdropOn(tester), isTrue);

    await perf.setPerformanceMode(PerformanceLevel.low);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // Part-way through: still blurring, so it is not an instant swap.
    expect(backdropOn(tester), isTrue);

    await tester.pump(const Duration(milliseconds: 600));
    expect(backdropOn(tester), isFalse);

    await perf.setPerformanceMode(PerformanceLevel.high);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(backdropOn(tester), isTrue);
  });

  testWidgets('what is inside keeps its state across the change',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('taps 0'));
    await tester.pump();
    expect(find.text('taps 1'), findsOneWidget);

    await perf.setPerformanceMode(PerformanceLevel.low);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('taps 1'), findsOneWidget);

    await perf.setPerformanceMode(PerformanceLevel.high);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('taps 1'), findsOneWidget);
  });

  /// The colour actually drawn at the middle of the surface.
  Future<Color> centrePixel(WidgetTester tester, GlobalKey key) async {
    late Color colour;
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = (await image.toByteData())!;
      final x = image.width ~/ 2;
      final y = image.height ~/ 2;
      final i = (y * image.width + x) * 4;
      colour = Color.fromARGB(
          255, data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2));
    });
    return colour;
  }

  testWidgets('the solid surface is really drawn, not just the border',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    perf = PerformanceModeProvider();
    await perf.setPerformanceMode(PerformanceLevel.low);
    final key = GlobalKey();
    const backdrop = Color(0xFF2A4A7A);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: perf,
      child: MaterialApp(
        theme: ThemeProvider.accentSolidTheme(ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B5CF6),
            brightness: Brightness.dark,
          ),
        )),
        home: RepaintBoundary(
          key: key,
          child: const ColoredBox(
            color: backdrop,
            child: Center(
              child: GlassSurface(
                child: SizedBox(width: 300, height: 200),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 800));

    final solid = await centrePixel(tester, key);
    // The accent-tinted solid fill, not the blue backdrop behind it.
    final fill = Theme.of(tester.element(find.byType(GlassSurface)))
        .colorScheme
        .surfaceContainerHigh;
    expect((solid.r - fill.r).abs(), lessThan(0.02));
    expect((solid.g - fill.g).abs(), lessThan(0.02));
    expect((solid.b - fill.b).abs(), lessThan(0.02));

    // And it fades back to see-through glass, then to solid again.
    await perf.setPerformanceMode(PerformanceLevel.high);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    final glass = await centrePixel(tester, key);
    expect(glass.b, greaterThan(0.35));

    await perf.setPerformanceMode(PerformanceLevel.low);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    final again = await centrePixel(tester, key);
    expect((again.b - fill.b).abs(), lessThan(0.02));
  });
}
