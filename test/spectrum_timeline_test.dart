import 'package:aurora_music_v01/features/player/utils/spectrum_timeline.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('aurora/media_actions');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('cached Dolby frames are ready again when the screen is reopened',
      () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return {
        'sampleRate': 48000,
        'frameRate': 30,
        'bins': 512,
        'durationUs': 100000,
        'data': Uint8List(3 * 512)..fillRange(0, 3 * 512, 10),
      };
    });

    final timeline = SpectrumTimeline.forSong(100001, '/song.m4a');
    timeline.focus(0);
    await Future<void>.delayed(Duration.zero);
    expect(timeline.frame(0), isNotNull);
    expect(timeline.frame(0)!.length, 512);
    expect(timeline.frame(0)!.any((v) => v != 0), isTrue);
    expect(timeline.frame(3), isNull);
    expect(calls.single.method, 'analyzeSpectrum');
    expect(calls.single.arguments['startFrame'], 0);
    expect(calls.single.arguments['frameCount'], 300);

    final reopened = SpectrumTimeline.forSong(100001, '/song.m4a');
    expect(identical(timeline, reopened), isTrue);
    reopened.focus(0);
    await Future<void>.delayed(Duration.zero);
    expect(calls.length, 1);
    expect(reopened.frame(1), isNotNull);
  });

  test('seeking prioritizes the chunk containing the playback position',
      () async {
    final requestedStarts = <int>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      requestedStarts.add(call.arguments['startFrame'] as int);
      return {
        'sampleRate': 44100,
        'frameRate': 30,
        'bins': 512,
        'durationUs': 0,
        'data': Uint8List(3 * 512)..fillRange(0, 3 * 512, 20),
      };
    });
    final timeline = SpectrumTimeline.forSong(100002, '/seek.m4a');
    timeline.focus(601);
    await Future<void>.delayed(Duration.zero);
    expect(requestedStarts.first, 600);
    expect(timeline.frame(601), isNotNull);
    expect(timeline.sampleRate, 44100);
    expect(timeline.failed, isFalse);
  });

  test('concurrent visits share an in-progress decode without self-waiting',
      () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls++;
      await Future<void>.delayed(Duration.zero);
      return {
        'sampleRate': 48000,
        'frameRate': 30,
        'bins': 512,
        'durationUs': 100000,
        'data': Uint8List(3 * 512),
      };
    });
    final first = SpectrumTimeline.forSong(100003, '/shared.m4a')..focus(0);
    final second = SpectrumTimeline.forSong(100003, '/shared.m4a')..focus(0);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(calls, 1);
    expect(first.frame(0), isNotNull);
    expect(second.frame(0), isNotNull);
  });
}
