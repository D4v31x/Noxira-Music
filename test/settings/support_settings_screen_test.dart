import 'package:aurora_music_v01/features/settings/screens/support_settings_screen.dart';
import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/providers/theme_provider.dart';
import 'package:aurora_music_v01/shared/services/audio_player_service.dart';
import 'package:aurora_music_v01/shared/services/background_manager_service.dart';
import 'package:aurora_music_v01/shared/services/supporter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class _FakeAudio extends ChangeNotifier implements AudioPlayerService {
  @override
  SongModel? get currentSong => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupporterService.parse', () {
    test('invalid, empty or oversized data gives an empty list', () {
      expect(SupporterService.parse(''), isEmpty);
      expect(SupporterService.parse('not json'), isEmpty);
      expect(SupporterService.parse('{"name":"A"}'), isEmpty);
      expect(
        SupporterService.parse(' ' * (SupporterService.maxParameterLength + 1)),
        isEmpty,
      );
    });

    test('takes plain names and {"name"} entries, in order', () {
      final list = SupporterService.parse(
        '["Anna", {"name": "Tom", "amount": 5}, "  Eva   K  "]',
      );
      expect(list.map((s) => s.name), ['Anna', 'Tom', 'Eva K']);
    });

    test('skips bad entries and trims long names', () {
      final list = SupporterService.parse(
        '["", 7, null, {"amount": 3}, "${'x' * 100}", "ok"]',
      );
      expect(list, hasLength(2));
      expect(list[0].name.length, SupporterService.maxNameLength);
      expect(list[1].name, 'ok');
    });

    test('caps the number of entries', () {
      final raw = '[${List.generate(500, (i) => '"n$i"').join(',')}]';
      expect(
        SupporterService.parse(raw),
        hasLength(SupporterService.maxEntries),
      );
    });
  });

  group('SupportSettingsScreen', () {
    Future<void> open(WidgetTester tester, List<Supporter> supporters) async {
      SupporterService.supporters.value = supporters;
      tester.view.physicalSize = const Size(400, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AudioPlayerService>.value(value: _FakeAudio()),
          ChangeNotifierProvider<BackgroundManagerService>(
              create: (_) => BackgroundManagerService()),
          ChangeNotifierProvider<PerformanceModeProvider>(
              create: (_) => PerformanceModeProvider()),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const SupportSettingsScreen(refresh: false),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('shows the empty state without supporters', (tester) async {
      await open(tester, const []);
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)));
      expect(find.text(l10n.supportNoSupportersYet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lists the names without prices and without overflow',
        (tester) async {
      await open(
        tester,
        SupporterService.parse('["Anna", "Tom", "${'Very long name ' * 6}"]'),
      );
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)));
      expect(find.text(l10n.supportSupporters.toUpperCase()), findsOneWidget);
      expect(find.text('Anna'), findsOneWidget);
      expect(find.text('Tom'), findsOneWidget);
      expect(find.textContaining('€'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
