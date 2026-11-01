import 'dart:io';

import 'package:aurora_music_v01/features/settings/screens/storage_settings_screen.dart';
import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/providers/theme_provider.dart';
import 'package:aurora_music_v01/shared/services/audio_player_service.dart';
import 'package:aurora_music_v01/shared/services/background_manager_service.dart';
import 'package:aurora_music_v01/shared/services/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAudio extends ChangeNotifier implements AudioPlayerService {
  @override
  SongModel? get currentSong => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// The dialogs live on the root navigator, so Cancel/Close must pop the dialog
/// and never the settings page underneath it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory docs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    docs = await Directory.systemTemp.createTemp('storage_screen');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => docs.path);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, null);
    await docs.delete(recursive: true);
  });

  Future<AppLocalizations> openScreen(WidgetTester tester) async {
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
        // Like the app: the page lives in an inner navigator, the dialogs on
        // the root one.
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => StorageSettingsScreen(
              notificationManager: NotificationManager(),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    return AppLocalizations.of(
        tester.element(find.byType(StorageSettingsScreen)));
  }

  testWidgets('cache info shows sizes and closes without leaving the page',
      (tester) async {
    await tester.runAsync(() async {
      await Directory('${docs.path}/lyrics').create();
      await File('${docs.path}/lyrics/a.lrc').writeAsString('x' * 2048);
    });

    final l10n = await openScreen(tester);

    await tester.tap(find.text(l10n.settingsCacheInfo));
    for (var i = 0;
        i < 30 && find.text(l10n.settingsMemoryCache).evaluate().isEmpty;
        i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text(l10n.settingsMemoryCache), findsOneWidget);
    expect(find.text('2.0 KB'), findsWidgets);

    await tester.tap(find.text(l10n.close));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10n.settingsMemoryCache), findsNothing);
    expect(find.byType(StorageSettingsScreen), findsOneWidget);
  });

  testWidgets('clear cache Cancel closes the dialog and keeps the page',
      (tester) async {
    final l10n = await openScreen(tester);

    await tester.tap(find.text(l10n.settingsClearCache));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10n.settingsClearCacheTitle), findsOneWidget);

    await tester.tap(find.text(l10n.cancel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10n.settingsClearCacheTitle), findsNothing);
    expect(find.byType(StorageSettingsScreen), findsOneWidget);
  });
}
