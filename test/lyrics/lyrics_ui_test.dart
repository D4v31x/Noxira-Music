import 'package:aurora_music_v01/features/player/widgets/lyrics/lyric_interlude_dots.dart';
import 'package:aurora_music_v01/features/player/widgets/lyrics/lyric_line_widget.dart';
import 'package:aurora_music_v01/features/player/widgets/lyrics/lyrics_clock.dart';
import 'package:aurora_music_v01/features/player/widgets/lyrics/lyrics_stagger.dart';
import 'package:aurora_music_v01/features/player/widgets/lyrics/lyrics_timing.dart';
import 'package:aurora_music_v01/shared/models/timed_lyrics.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/services/local_lyrics_source.dart';
import 'dart:async';
import 'dart:io';
import 'package:aurora_music_v01/features/player/widgets/player_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

TimedLyric _l(int ms, String text) =>
    TimedLyric(time: Duration(milliseconds: ms), text: text);

void main() {
  test('parseTimestamp keeps centiseconds and milliseconds', () {
    expect(TimedLyric.parseTimestamp('01', '02', '34'),
        const Duration(minutes: 1, seconds: 2, milliseconds: 340));
    expect(TimedLyric.parseTimestamp('00', '10', '456'),
        const Duration(seconds: 10, milliseconds: 456));
    expect(TimedLyric.parseTimestamp('00', '10'), const Duration(seconds: 10));
  });

  test('sidecar .lrc next to the audio file is picked up', () async {
    final dir = await Directory.systemTemp.createTemp('lrc_test');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}/song.mp3').writeAsString('x');
    await File('${dir.path}/song.lrc')
        .writeAsString('[00:01.50]first\n[00:04.25]second\n');

    final lyrics = await LocalLyricsSource.find('${dir.path}/song.mp3');
    expect(lyrics, hasLength(2));
    expect(lyrics!.first.time, const Duration(seconds: 1, milliseconds: 500));
    expect(lyrics.last.text, 'second');
  });

  group('LyricsTiming', () {
    test('no interlude for a continuous song', () {
      final lyrics = [_l(1000, 'a'), _l(4000, 'b'), _l(7000, 'c')];
      expect(LyricsTiming.interludes(lyrics), isEmpty);
      expect(
          LyricsTiming.buildRows(lyrics).every((r) => !r.isInterlude), isTrue);
    });

    test('long gap becomes an interlude after the line', () {
      final lyrics = [_l(1000, 'short'), _l(31000, 'next')];
      final gaps = LyricsTiming.interludes(lyrics);
      expect(gaps, hasLength(1));
      expect(gaps.first.afterLine, 0);
      expect(gaps.first.endMs, 31000);
      expect(gaps.first.startMs, greaterThan(1000));
      expect(gaps.first.endMs - gaps.first.startMs,
          greaterThanOrEqualTo(kMinInterludeGapMs));

      final rows = LyricsTiming.buildRows(lyrics);
      expect(rows.map((r) => r.isInterlude), [false, true, false]);
    });

    test('long intro gets an interlude before the first line', () {
      final lyrics = [_l(12000, 'first'), _l(15000, 'second')];
      final rows = LyricsTiming.buildRows(lyrics);
      expect(rows.first.isInterlude, isTrue);
      expect(rows.first.interlude!.afterLine, -1);
      expect(rows.length, 3);
    });

    test('sungMs fills short gaps and caps long ones', () {
      final lyrics = [_l(0, 'a b c'), _l(3000, 'x'), _l(60000, 'y')];
      expect(LyricsTiming.sungMs(lyrics, 0), 2850);
      expect(LyricsTiming.sungMs(lyrics, 1), lessThanOrEqualTo(12000));
    });
  });

  group('widgets', () {
    testWidgets('line widget renders words for active and inactive state',
        (tester) async {
      Widget build(bool active) => ChangeNotifierProvider(
            create: (_) => PerformanceModeProvider(),
            child: MaterialApp(
              home: Scaffold(
                body: LyricLineWidget(
                  text: 'hello big world',
                  isActive: active,
                  distance: active ? 0 : 4,
                ),
              ),
            ),
          );

      await tester.pumpWidget(build(false));
      expect(find.text('hello big world'), findsOneWidget);

      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      expect(find.text('hello big world'), findsOneWidget);
    });

    testWidgets('interlude dots collapse when hidden', (tester) async {
      final clock = LyricsClock(tester);
      addTearDown(clock.dispose);

      Widget build(bool visible) => MaterialApp(
            home: Scaffold(
              body: Column(children: [
                LyricInterludeDots(
                  startMs: 0,
                  endMs: 10000,
                  clock: clock,
                  accentColor: Colors.purple,
                  visible: visible,
                ),
              ]),
            ),
          );

      await tester.pumpWidget(build(true));
      expect(tester.getSize(find.byType(LyricInterludeDots)).height,
          kLyricsInterludeHeight);

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(LyricInterludeDots)).height, 0);
    });

    testWidgets('clock follows paused seeks and applies the sync offset',
        (tester) async {
      final clock = LyricsClock(tester);
      addTearDown(clock.dispose);

      clock.offsetMs = 250;
      clock.sync(const Duration(seconds: 5), playing: false);
      expect(clock.value, 5250);

      clock.sync(const Duration(seconds: 42), playing: false);
      expect(clock.value, 42250);
    });
  });

  group('PlayerPageRoute', () {
    test('spring curve starts at 0, ends at 1 and overshoots when underdamped',
        () {
      final curve = SpringCurve(stiffness: 230, dampingRatio: 0.82);
      expect(curve.transform(0), 0);
      expect(curve.transform(1), 1);
      final peak = [for (var i = 1; i < 100; i++) curve.transform(i / 100)]
          .reduce((a, b) => a > b ? a : b);
      expect(peak, greaterThan(1.0));
    });

    testWidgets('opens and closes', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navKey,
        home: const Scaffold(body: Text('home')),
      ));

      unawaited(navKey.currentState!.push(PlayerPageRoute<void>(
        targets: PlayerPageTargets(),
        builder: (_) => const Scaffold(body: Text('page')),
      )));
      await tester.pumpAndSettle();
      expect(find.text('page'), findsOneWidget);

      navKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('page'), findsNothing);
    });
  });

  group('PlayerPageRoute drag', () {
    Future<PlayerPageRoute<void>> open(
        WidgetTester tester, GlobalKey<NavigatorState> navKey) async {
      final route = PlayerPageRoute<void>(
        targets: PlayerPageTargets(),
        builder: (_) => const Scaffold(body: Text('page')),
      );
      unawaited(navKey.currentState!.push(route));
      await tester.pumpAndSettle();
      return route;
    }

    Widget app(GlobalKey<NavigatorState> navKey) => MaterialApp(
          navigatorKey: navKey,
          home: const Scaffold(body: Text('home')),
        );

    testWidgets('a hard downward fling closes the page', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(app(navKey));
      final route = await open(tester, navKey);
      expect(route.progress.value, closeTo(1, 1e-6));

      route.beginDrag();
      route.dragBy(-0.2);
      expect(route.progress.value, closeTo(0.8, 1e-6));
      route.endDrag(-3);
      await tester.pumpAndSettle();
      expect(find.text('page'), findsNothing);
    });

    testWidgets('a short slow drag springs back open', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(app(navKey));
      final route = await open(tester, navKey);

      route.beginDrag();
      route.dragBy(-0.1);
      route.endDrag(0);
      await tester.pumpAndSettle();
      expect(find.text('page'), findsOneWidget);
      expect(route.progress.value, closeTo(1, 1e-6));
    });
  });

  group('LyricsStagger', () {
    testWidgets('lags decay to rest, further rows later', (tester) async {
      final stagger = LyricsStagger(tester);
      addTearDown(stagger.dispose);

      stagger.addScroll(100, [3, 8], 2);
      expect(stagger.lagOf(3), 100);

      var t = 0.0;
      double? near;
      double? far;
      while (stagger.isActive && t < 5) {
        stagger.step(0.016);
        t += 0.016;
        if (near == null && stagger.lagOf(3) == 0) near = t;
        if (far == null && stagger.lagOf(8) == 0) far = t;
      }
      expect(stagger.isActive, isFalse);
      expect(near, isNotNull);
      expect(far, greaterThan(near!));
      stagger.clear();
    });
  });
}
