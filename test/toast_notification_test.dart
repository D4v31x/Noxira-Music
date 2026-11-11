import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/widgets/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  late BuildContext context;
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => PerformanceModeProvider(),
      child: MaterialApp(
        home: Builder(builder: (value) {
          context = value;
          return const Scaffold();
        }),
      ),
    ));
  }

  testWidgets('back-to-back shows before mounting never duplicate a GlobalKey',
      (tester) async {
    await open(tester);
    ToastNotification.show(context, 'First');
    ToastNotification.show(context, 'Second');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    ToastNotification.hide();
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('a retiring toast cannot remove its replacement', (tester) async {
    await open(tester);
    ToastNotification.show(context, 'Old', isProgress: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    ToastNotification.hide();
    ToastNotification.show(context, 'New', isProgress: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);
    expect(find.text('Old'), findsNothing);
    expect(find.text('New'), findsOneWidget);
    expect(ToastNotification.isShowing, isTrue);
    ToastNotification.hide();
    ToastNotification.hide();
    await tester.pump(const Duration(milliseconds: 350));
    expect(ToastNotification.isShowing, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active toast updates retain a single entry and reset expiry',
      (tester) async {
    await open(tester);
    ToastNotification.show(context, 'Old',
        duration: const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    ToastNotification.show(context, 'Updated',
        duration: const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Old'), findsNothing);
    expect(find.text('Updated'), findsOneWidget);
    expect(ToastNotification.isShowing, isTrue);
    ToastNotification.hide();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);
  });
}
