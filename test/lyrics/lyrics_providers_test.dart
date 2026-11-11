import 'dart:convert';

import 'package:aurora_music_v01/shared/services/lyrics_providers/better_lyrics_provider.dart';
import 'package:aurora_music_v01/shared/services/lyrics_providers/kugou_provider.dart';
import 'package:aurora_music_v01/shared/services/lyrics_providers/lyrics_provider.dart';
import 'package:aurora_music_v01/shared/services/lyrics_providers/youlyplus_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('lrcTag formats minutes, seconds and centiseconds', () {
    expect(lrcTag(0), '[00:00.00]');
    expect(lrcTag(62350), '[01:02.35]');
  });

  test('sanitizeLrc removes word timings and markers', () {
    expect(sanitizeLrc('[00:01.00]{agent:v1}<00:01.00>Hel<00:01.30>lo{bg}'),
        '[00:01.00]Hello');
  });

  group('BetterLyrics TTML', () {
    const ttml = '''
<tt xmlns="http://www.w3.org/ns/ttml" xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <body><div>
    <p begin="0:01.500" end="0:03.000"><span>Hello</span> <span>world</span>
      <span ttm:role="x-bg">(ooh)</span></p>
    <p begin="00:00:05.250" end="00:00:07.000">Second line</p>
    <p begin="9.5s" end="12s"><span>Third</span></p>
  </div></body>
</tt>''';

    test('converts paragraphs to LRC and drops background vocals', () {
      expect(BetterLyricsProvider.ttmlToLrc(ttml),
          '[00:01.50]Hello world\n[00:05.25]Second line\n[00:09.50]Third');
    });

    test('parseTime handles all formats', () {
      expect(BetterLyricsProvider.parseTime('1:23.456'), 83456);
      expect(BetterLyricsProvider.parseTime('01:01:01.5'), 3661500);
      expect(BetterLyricsProvider.parseTime('12.5s'), 12500);
      expect(BetterLyricsProvider.parseTime('nope'), isNull);
    });

    test('invalid xml yields null', () {
      expect(BetterLyricsProvider.ttmlToLrc('<tt'), isNull);
    });

    test('fetchLrc reads the ttml field', () async {
      final client = MockClient((req) async {
        expect(req.url.host, 'lyrics-api.boidu.dev');
        expect(req.url.queryParameters['s'], 'Song');
        expect(req.url.queryParameters['d'], '200');
        return http.Response(json.encode({'ttml': ttml}), 200);
      });
      final lrc = await const BetterLyricsProvider().fetchLrc(
        const LyricsQuery(title: 'Song', artist: 'Art', durationSeconds: 200),
        client,
      );
      expect(lrc, contains('[00:05.25]Second line'));
    });
  });

  group('YouLyPlus', () {
    test('prefers server LRC', () {
      expect(YouLyPlusProvider.toLrc({'syncedLyrics': '[00:01.00]a'}),
          '[00:01.00]a');
    });

    test('joins untimed syllables and skips background lines', () {
      final lrc = YouLyPlusProvider.toLrc({
        'lyrics': [
          {
            'time': 1500,
            'text': 'ignored',
            'syllabus': [
              {'text': 'Hel'},
              {'text': 'lo '},
              {'text': 'you'},
            ],
          },
          {
            'time': 3000,
            'syllabus': [
              {'text': 'ooh', 'isBackground': true},
            ],
          },
          {'time': 4000, 'text': 'Plain line'},
        ],
      });
      expect(lrc, '[00:01.50]Hello you\n[00:04.00]Plain line');
    });

    test('plain-only lyrics are not usable', () {
      expect(YouLyPlusProvider.toLrc({'plainLyrics': 'text'}), isNull);
    });

    test('first server with lyrics wins, failures are tolerated', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        if (req.url.host == 'lyricsplus.atomix.one') {
          return http.Response(
              json.encode({'syncedLyrics': '[00:02.00]ok'}), 200);
        }
        return http.Response('nope', 500);
      });
      final lrc = await const YouLyPlusProvider().fetchLrc(
        const LyricsQuery(title: 't', artist: 'a'),
        client,
      );
      expect(lrc, '[00:02.00]ok');
      expect(calls, greaterThan(0));
    });
  });

  group('KuGou', () {
    test('normalize drops credit blocks but keeps lyrics with colons', () {
      const raw = '[00:00.00]Song - Artist\n'
          '[00:01.00]作词 : Someone\n'
          '[00:02.00]作曲 : Someone\n'
          '[00:10.00]First line\n'
          '[00:14.00]Note: keep this\n'
          '[00:20.00]Last line\n'
          '[03:50.00]制作人 : Someone\n'
          'not a timed line';
      expect(
        KuGouProvider.normalize(raw),
        '[00:10.00]First line\n[00:14.00]Note: keep this\n[00:20.00]Last line',
      );
    });

    test('full search -> lyrics -> download flow', () async {
      final lrcBody =
          base64.encode(utf8.encode('[00:05.00]Hello\n[00:09.00]Bye'));
      final client = MockClient((req) async {
        if (req.url.host == 'mobileservice.kugou.com') {
          return http.Response(
              json.encode({
                'data': {
                  'info': [
                    {
                      'duration': 400,
                      'hash': 'far',
                      'songname': 'Hello',
                      'singername': 'Adele',
                    },
                    {
                      'duration': 201,
                      'hash': 'abc',
                      'songname': 'Hello',
                      'singername': 'Adele',
                    },
                  ],
                },
              }),
              200);
        }
        if (req.url.path == '/search') {
          expect(req.url.queryParameters['hash'], 'abc');
          return http.Response(
              json.encode({
                'candidates': [
                  {'id': 7, 'accesskey': 'k'},
                ],
              }),
              200);
        }
        if (req.url.path == '/download') {
          expect(req.url.queryParameters['id'], '7');
          return http.Response(json.encode({'content': lrcBody}), 200);
        }
        return http.Response('', 404);
      });

      final lrc = await const KuGouProvider().fetchLrc(
        const LyricsQuery(
            title: 'Hello', artist: 'Adele', durationSeconds: 200),
        client,
      );
      expect(lrc, '[00:05.00]Hello\n[00:09.00]Bye');
    });

    test('network failure returns null', () async {
      final client = MockClient((_) async => throw http.ClientException('x'));
      expect(
        await const KuGouProvider()
            .fetchLrc(const LyricsQuery(title: 't', artist: 'a'), client),
        isNull,
      );
    });
  });
}
