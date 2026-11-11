import 'package:aurora_music_v01/features/player/widgets/lyrics/lyric_word_text.dart';
import 'package:aurora_music_v01/shared/models/timed_lyrics.dart';
import 'package:aurora_music_v01/shared/services/lyrics_providers/better_lyrics_provider.dart';
import 'package:aurora_music_v01/shared/services/lyrics_providers/lyrics_provider.dart';
import 'package:aurora_music_v01/shared/services/lyrics_providers/youlyplus_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseLrc', () {
    test('plain lines have no words', () {
      final lyrics = parseLrc('[00:01.00]Hello world\n[00:05.50]Bye');
      expect(lyrics.map((l) => l.text), ['Hello world', 'Bye']);
      expect(lyrics.every((l) => l.words == null), isTrue);
    });

    test('enhanced lines carry word timing', () {
      final lyrics = parseLrc(
          '[00:01.00]<00:01.000>Hello <00:01.400>world<00:02.000>\n[00:03.00]<00:03.000>Next');
      expect(lyrics[0].text, 'Hello world');
      final words = lyrics[0].words!;
      expect(words.map((w) => w.text), ['Hello ', 'world']);
      expect(words[0].start, const Duration(milliseconds: 1000));
      expect(words[0].end, const Duration(milliseconds: 1400));
      expect(words[1].end, const Duration(milliseconds: 2000));
      // Last word of the last line has no end marker.
      expect(
          lyrics[1].words!.single.end > lyrics[1].words!.single.start, isTrue);
    });

    test('a missing end marker ends at the next line', () {
      final lyrics = parseLrc(
          '[00:01.00]<00:01.000>One <00:01.500>two\n[00:03.00]<00:03.000>Three');
      expect(lyrics[0].words!.last.end, const Duration(seconds: 3));
    });
  });

  group('providers', () {
    test('TTML spans become enhanced LRC', () {
      const ttml = '''
<tt xmlns="http://www.w3.org/ns/ttml"><body><div>
<p begin="0:01.000" end="0:02.000"><span begin="0:01.000" end="0:01.400">Hello</span> <span begin="0:01.400" end="0:02.000">world</span></p>
<p begin="0:03.000" end="0:04.000">Plain line</p>
</div></body></tt>''';
      final lrc = BetterLyricsProvider.ttmlToLrc(ttml)!;
      final lines = lrc.split('\n');
      expect(
          lines[0], '[00:01.00]<00:01.000>Hello <00:01.400>world<00:02.000>');
      expect(lines[1], '[00:03.00]Plain line');
      expect(lrcHasWordTiming(lrc), isTrue); // half the lines are timed
      final parsed = parseLrc(lrc);
      expect(parsed[0].words!.length, 2);
      expect(parsed[1].words, isNull);
    });

    test('YouLyPlus syllables become enhanced LRC', () {
      final lrc = YouLyPlusProvider.toLrc({
        'lyrics': [
          {
            'time': 1000,
            'text': 'Hello world',
            'syllabus': [
              {'time': 1000, 'duration': 200, 'text': 'Hel'},
              {'time': 1200, 'duration': 200, 'text': 'lo '},
              {'time': 1400, 'duration': 600, 'text': 'world'},
              {
                'time': 1500,
                'duration': 100,
                'text': 'ooh',
                'isBackground': true
              },
            ],
          },
        ],
      })!;
      expect(lrc,
          '[00:01.00]<00:01.000>Hel<00:01.200>lo <00:01.400>world<00:02.000>');
      expect(lrcHasWordTiming(lrc), isTrue);
      expect(parseLrc(lrc).single.text, 'Hello world');
    });

    test('YouLyPlus without syllable timing falls back to the server LRC', () {
      final lrc = YouLyPlusProvider.toLrc({
        'syncedLyrics': '[00:01.00]Line',
        'lyrics': [
          {'time': 1000, 'text': 'Line'},
        ],
      });
      expect(lrc, '[00:01.00]Line');
    });
  });

  testWidgets('LyricWordText lights words as they are sung', (tester) async {
    final clock = ValueNotifier<int>(0);
    const words = [
      LyricWord(
          start: Duration(milliseconds: 1000),
          end: Duration(milliseconds: 2000),
          text: 'One '),
      LyricWord(
          start: Duration(milliseconds: 2000),
          end: Duration(milliseconds: 3000),
          text: 'two'),
    ];
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: LyricWordText(
          words: words,
          clock: clock,
          style: const TextStyle(color: Colors.white)),
    ));

    List<double> alphas() {
      final rich = tester.widget<RichText>(find.byType(RichText));
      final root = (rich.text as TextSpan).children!.first as TextSpan;
      return [for (final c in root.children!) (c as TextSpan).style!.color!.a];
    }

    expect(alphas()[0], lessThan(0.5));
    clock.value = 2500;
    await tester.pump();
    expect(alphas()[0], 1.0);
    expect(alphas()[1], inExclusiveRange(0.38, 1.0));
    clock.value = 4000;
    await tester.pump();
    expect(alphas(), [1.0, 1.0]);
  });
}
