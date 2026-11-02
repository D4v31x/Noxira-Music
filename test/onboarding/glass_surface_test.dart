import 'package:aurora_music_v01/features/onboarding/widgets/onboarding_glass.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/services/device_performance_service.dart';
import 'package:flutter/material.dart';
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
}
