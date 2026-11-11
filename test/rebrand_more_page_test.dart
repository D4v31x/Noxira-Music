import 'package:aurora_music_v01/features/rebrand/rebrand_welcome_screen.dart';
import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The "and much more" page lists more than fits on a phone, so it has to
/// scroll, and its title starts a good way down like the onboarding steps.
void main() {
  testWidgets('the more page scrolls and its title is not glued to the top',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<PerformanceModeProvider>(
            create: (_) => PerformanceModeProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const RebrandWelcomeScreen(fromSettings: true),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)));

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text(l10n.next));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.pump(const Duration(seconds: 2));

    final title = find.text(l10n.rebrandSlideMoreTitle);
    expect(title, findsOneWidget);
    final safeTop = tester.view.padding.top / tester.view.devicePixelRatio;
    final startY = tester.getTopLeft(title).dy - safeTop;
    // Below the progress dots with the onboarding inset on top of them.
    expect(startY, greaterThan(60 + 24));

    final scrollable = find.byType(Scrollable);
    expect(scrollable, findsOneWidget);
    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    await tester.drag(scrollable, const Offset(0, -400));
    await tester.pump();
    final after = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(after, greaterThan(before));
    expect(tester.takeException(), isNull);
  });
}
