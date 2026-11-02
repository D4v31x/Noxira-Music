import 'package:aurora_music_v01/features/onboarding/pages/theme_selection_page.dart';
import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/providers/theme_provider.dart';
import 'package:aurora_music_v01/shared/services/device_performance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The look step tells the user which interface and background suit their
/// device, marks it as recommended and lets them try the other one.
void main() {
  late PerformanceModeProvider perf;
  late ThemeProvider theme;
  late AppLocalizations l10n;

  Future<void> open(WidgetTester tester, PerformanceLevel detected) async {
    SharedPreferences.setMockInitialValues({});
    DevicePerformanceService.instance.debugOverrideLevel(detected);
    perf = PerformanceModeProvider();
    await perf.initialize();
    theme = ThemeProvider();
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    addTearDown(
        () => DevicePerformanceService.instance.debugOverrideLevel(null));

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<PerformanceModeProvider>.value(value: perf),
        ChangeNotifierProvider<ThemeProvider>.value(value: theme),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ThemeSelectionPage(onContinue: () {}, onBack: () {}),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 800));
    l10n = AppLocalizations.of(tester.element(find.byType(ThemeSelectionPage)));
  }

  // The recommendation is applied once per run, so each case needs a fresh one.
  setUp(() => resetRecommendationForTests());

  testWidgets('a strong device is told high-end and artwork suit it',
      (tester) async {
    await open(tester, PerformanceLevel.high);

    expect(find.text(l10n.onboardingUiModeTitle), findsOneWidget);
    expect(find.text(l10n.onboardingRecommendedBadge), findsNWidgets(2));
    expect(find.text(l10n.onboardingRecommendedForDevice), findsNWidgets(2));
    expect(theme.highEndBackground, HighEndBackground.blurredArtwork);
    expect(
        find.text(l10n.onboardingHeaviestNote(l10n.backgroundBlurredArtwork)),
        findsNothing);
  });

  testWidgets(
      'a weaker device starts on the plain background and is warned '
      'when it tries the heaviest one', (tester) async {
    await open(tester, PerformanceLevel.medium);

    expect(theme.highEndBackground, HighEndBackground.solid);
    expect(find.text(l10n.onboardingRecommendedForDevice), findsNWidgets(2));

    await tester.tap(find.text(l10n.backgroundBlurredArtwork));
    await tester.pump(const Duration(milliseconds: 400));

    expect(theme.highEndBackground, HighEndBackground.blurredArtwork);
    expect(
        find.text(l10n.onboardingTryNote(
            l10n.backgroundSolid, l10n.backgroundBlurredArtwork)),
        findsOneWidget);
    expect(
        find.text(l10n.onboardingHeaviestNote(l10n.backgroundBlurredArtwork)),
        findsOneWidget);
  });

  testWidgets(
      'a low-end device is recommended lightweight, has no background '
      'choice and can try the high-end interface', (tester) async {
    await open(tester, PerformanceLevel.low);

    expect(perf.isLowEndDevice, isTrue);
    expect(find.text(l10n.backgroundHighEndStyle), findsNothing);
    expect(find.text(l10n.onboardingRecommendedForDevice), findsOneWidget);

    await tester.tap(find.text(l10n.onboardingUiHighEnd));
    await tester.pump(const Duration(milliseconds: 500));

    expect(perf.isLowEndDevice, isFalse);
    expect(
        find.text(l10n.onboardingTryNote(
            l10n.onboardingUiLowEnd, l10n.onboardingUiHighEnd)),
        findsOneWidget);
    // The plain background is preselected for it, with the heavier one a tap away.
    expect(theme.highEndBackground, HighEndBackground.solid);
    expect(find.text(l10n.backgroundHighEndStyle), findsOneWidget);
  });
}
