import 'dart:async';
import 'dart:io';

import 'package:aurora_music_v01/features/player/widgets/lyrics/lyric_interlude_dots.dart';
import 'package:aurora_music_v01/features/player/widgets/lyrics/lyrics_header_cover.dart';
import 'package:aurora_music_v01/features/player/widgets/lyrics/mini_lyrics_ticker.dart';
import 'package:aurora_music_v01/shared/models/timed_lyrics.dart';
import 'package:aurora_music_v01/features/player/widgets/lyrics_page_launcher.dart';
import 'package:aurora_music_v01/features/player/widgets/player_dialogs.dart';
import 'package:aurora_music_v01/features/player/widgets/player_page_route.dart';
import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/providers/theme_provider.dart';
import 'package:aurora_music_v01/shared/services/audio_player_service.dart';
import 'package:aurora_music_v01/shared/services/background_manager_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePlayer extends Fake implements AudioPlayer {
  // ignore: close_sinks
  final StreamController<Duration> positions = StreamController.broadcast();
  // ignore: close_sinks
  final StreamController<bool> playingChanges = StreamController.broadcast();
  Duration current = Duration.zero;
  Duration? seekedTo;

  @override
  Stream<Duration> get positionStream => positions.stream;

  @override
  Stream<bool> get playingStream => playingChanges.stream;

  @override
  Stream<Duration?> get durationStream =>
      Stream.value(const Duration(minutes: 4));

  @override
  Duration get position => current;

  @override
  bool get playing => true;

  @override
  double get speed => 1;

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    seekedTo = position;
  }
}

class _FakeAudio extends ChangeNotifier implements AudioPlayerService {
  _FakeAudio(this.song, this.player);

  final SongModel song;
  final _FakePlayer player;

  @override
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(true);

  @override
  SongModel? get currentSong => song;

  @override
  AudioPlayer get audioPlayer => player;

  @override
  Stream<SongModel?> get currentSongStream => const Stream.empty();

  late final List<SongModel> upcoming = [
    SongModel({'_id': 8, 'title': 'Next Song', 'artist': 'Other Artist'}),
  ];

  @override
  List<SongModel> get playlist => [song, ...upcoming];

  @override
  List<SongModel> get queuedSongs => const [];

  @override
  List<SongModel> get sourceUpcoming => upcoming;

  @override
  int get currentIndex => 0;

  @override
  int get queueBoundary => 0;

  @override
  bool get hasUpcoming => true;

  @override
  bool get isShuffle => false;

  @override
  LoopMode get loopMode => LoopMode.off;

  @override
  PlaybackSourceInfo get playbackSource =>
      PlaybackSourceInfo(source: PlaybackSource.values.first);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late Directory dir;
  late _FakePlayer player;
  late _FakeAudio audio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('lyrics_screen');
    await File('${dir.path}/song.mp3').writeAsString('x');
    await File('${dir.path}/song.lrc').writeAsString([
      '[00:01.00]First line of the song',
      '[00:05.00]Second line goes here',
      '[00:09.00]Third line is next',
      '[00:40.00]Line after a long instrumental break',
      '[00:44.00]Last line',
    ].join('\n'));

    player = _FakePlayer();
    audio = _FakeAudio(
      SongModel({
        '_id': 7,
        'title': 'Test Song',
        'artist': 'Test Artist',
        'album': 'Album',
        '_data': '${dir.path}/song.mp3',
        'duration': 240000,
      }),
      player,
    );
  });

  tearDown(() async {
    await player.positions.close();
    await player.playingChanges.close();
    await dir.delete(recursive: true);
  });

  Widget app(GlobalKey<NavigatorState> navKey) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioPlayerService>.value(value: audio),
        ChangeNotifierProvider<BackgroundManagerService>(
            create: (_) => BackgroundManagerService()),
        ChangeNotifierProvider<PerformanceModeProvider>(
            create: (_) => PerformanceModeProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openLyricsPage(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openPage(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('opens, shows lyrics, follows playback and seeks on tap',
      (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(navKey));
    await openPage(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Test Song'), findsOneWidget);
    expect(find.text('First line of the song'), findsOneWidget);

    // Playback reaches the third line.
    player.current = const Duration(seconds: 10);
    player.positions.add(player.current);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(tester.takeException(), isNull);

    // The active line has been recentred near the top of the list, with the
    // rest of the song below it.
    final third = tester.getTopLeft(find.text('Third line is next')).dy;
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(third, lessThan(screenHeight * 0.45));

    // Tapping a line seeks to it.
    await tester.tap(find.text('Third line is next'));
    await tester.pump();
    expect(player.seekedTo, const Duration(seconds: 9));
  });

  testWidgets('auto-hides the chrome when idle once enabled', (tester) async {
    SharedPreferences.setMockInitialValues({'lyrics_auto_hide_chrome': true});
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(navKey));
    await openPage(tester);

    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    final before = tester.getRect(find.text('Test Song'));

    await tester.pump(const Duration(milliseconds: 4000));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);

    // The header has collapsed away (clipped to nothing) and the controls too.
    final after = tester.getRect(find.text('Test Song', skipOffstage: false));
    expect(after.top, lessThan(before.top));
  });

  testWidgets('keeps the chrome visible by default', (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(navKey));
    await openPage(tester);

    final before = tester.getRect(find.text('Test Song'));
    await tester.pump(const Duration(milliseconds: 6000));
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.text('Test Song')), before);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
  });

  testWidgets('pulling the header down closes the page', (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(navKey));
    await openPage(tester);
    expect(find.text('Test Song'), findsOneWidget);

    await tester.fling(find.text('Test Song'), const Offset(0, 400), 2500);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Test Song'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(PlayerPageSources.hidden.value, isFalse);
  });

  testWidgets('queue opens as a page and a tap on the cover closes it',
      (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioPlayerService>.value(value: audio),
        ChangeNotifierProvider<BackgroundManagerService>(
            create: (_) => BackgroundManagerService()),
        ChangeNotifierProvider<PerformanceModeProvider>(
            create: (_) => PerformanceModeProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showQueueDialog(context, audio),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await openPage(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Test Song'), findsWidgets);
    expect(find.text('Next Song'), findsOneWidget);

    await tester.tap(find.byType(LyricsHeaderCover));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Next Song'), findsNothing);
  });

  testWidgets(
      'ticker rolls through lines, shows dots in gaps, long lines slide',
      (tester) async {
    final lyrics = [
      TimedLyric(time: const Duration(seconds: 1), text: 'Short one'),
      TimedLyric(
          time: const Duration(seconds: 5),
          text: 'A very long lyric line that cannot possibly fit into the '
              'narrow ticker space on a phone screen at all'),
      TimedLyric(time: const Duration(seconds: 40), text: 'After the break'),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            child: MiniLyricsTicker(lyrics: lyrics, player: player),
          ),
        ),
      ),
    ));

    Future<void> at(Duration position) async {
      player.current = position;
      player.positions.add(position);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
    }

    await at(const Duration(seconds: 2));
    expect(find.text('Short one'), findsOneWidget);

    await at(const Duration(seconds: 7));
    expect(find.text('Short one'), findsNothing);
    expect(find.textContaining('A very long lyric line'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await at(const Duration(seconds: 25));
    expect(find.byType(LyricInterludeDots), findsOneWidget);
    expect(tester.takeException(), isNull);

    await at(const Duration(seconds: 41));
    expect(find.text('After the break'), findsOneWidget);
    expect(find.byType(LyricInterludeDots), findsNothing);
  });

  testWidgets('line during an instrumental gap shows the dots row',
      (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(navKey));
    await openPage(tester);

    expect(find.byType(LyricInterludeDots), findsWidgets);
    player.current = const Duration(seconds: 20);
    player.positions.add(player.current);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(tester.takeException(), isNull);

    // The dots row has grown in for the gap.
    final dots = tester
        .widgetList<LyricInterludeDots>(find.byType(LyricInterludeDots))
        .where((d) => d.visible);
    expect(dots, hasLength(1));
  });
}
