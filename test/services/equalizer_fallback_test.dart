import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aurora_music_v01/main.dart' as app;
import 'package:aurora_music_v01/shared/services/audio_handler.dart';
import 'package:aurora_music_v01/shared/services/audio_player_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const root = MethodChannel('com.ryanheise.just_audio.methods');
  final channels = <MethodChannel>[];
  var effectError = 'audio_effect_unavailable';
  var loads = 0;
  var pauses = 0;
  Future<void> Function(int)? beforeLoad;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    effectError = 'audio_effect_unavailable';
    loads = 0;
    pauses = 0;
    beforeLoad = null;
    messenger.setMockMethodCallHandler(root, (call) async {
      if (call.method != 'init') return <String, Object?>{};
      final id = (call.arguments as Map)['id'] as String;
      final methods = MethodChannel('com.ryanheise.just_audio.methods.$id');
      final events = MethodChannel('com.ryanheise.just_audio.events.$id');
      final data = MethodChannel('com.ryanheise.just_audio.data.$id');
      channels.addAll([methods, events, data]);
      messenger.setMockMethodCallHandler(events, (_) async => null);
      messenger.setMockMethodCallHandler(data, (_) async => null);
      messenger.setMockMethodCallHandler(methods, (call) async {
        if (call.method == 'androidEqualizerGetParameters') {
          throw PlatformException(
              code: effectError, message: 'Equalizer hardware unavailable');
        }
        if (call.method == 'load') {
          loads++;
          await beforeLoad?.call(loads);
          scheduleMicrotask(() {
            ServicesBinding.instance.channelBuffers.push(
              events.name,
              const StandardMethodCodec().encodeSuccessEnvelope({
                'processingState': 3,
                'updateTime': DateTime.now().millisecondsSinceEpoch,
                'updatePosition': 0,
                'bufferedPosition': 1000000,
                'duration': 1000000,
                'currentIndex': 0,
                'androidAudioSessionId': 7,
              }),
              (_) {},
            );
          });
          return {'duration': 1000000};
        }
        if (call.method == 'pause') pauses++;
        return <String, Object?>{};
      });
      return <String, Object?>{};
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(root, null);
    for (final channel in channels) {
      messenger.setMockMethodCallHandler(channel, null);
    }
    channels.clear();
  });

  AudioPlayer player(AndroidEqualizer eq) => AudioPlayer(
        audioPipeline: AudioPipeline(androidAudioEffects: [eq]),
        handleInterruptions: false,
        handleAudioSessionActivation: false,
        androidApplyAudioAttributes: false,
      );

  test('unavailable optional equalizer does not prevent loading audio',
      () async {
    final eq = AndroidEqualizer();
    final audio = player(eq);
    addTearDown(audio.dispose);
    final parameters = expectLater(
        eq.parameters,
        throwsA(isA<PlatformException>().having(
            (error) => error.code, 'code', 'audio_effect_unavailable')));
    expect(await audio.setUrl('https://example.test/tone.mp3'),
        const Duration(seconds: 1));
    await parameters;
    expect(loads, 1);
    expect(eq.enabled, isFalse);
    await expectLater(eq.setEnabled(true), throwsA(isA<PlatformException>()));
    expect(eq.enabled, isFalse);
    expect(await audio.setUrl('https://example.test/next.mp3'),
        const Duration(seconds: 1));
    expect(loads, 2);
  });

  test('unexpected platform errors are not disguised as unavailable effects',
      () async {
    effectError = 'unexpected_failure';
    final eq = AndroidEqualizer();
    final audio = player(eq);
    addTearDown(audio.dispose);
    final parameters = expectLater(
        eq.parameters,
        throwsA(isA<PlatformException>()
            .having((error) => error.code, 'code', 'unexpected_failure')));
    await expectLater(audio.setUrl('https://example.test/tone.mp3'),
        throwsA(anyOf(isA<PlatformException>(), isA<PlayerException>())));
    expect(loads, 0);
    await parameters;
  });

  test('queue restore cannot pause a newer user-selected playlist', () async {
    SharedPreferences.setMockInitialValues({});
    final directory = await Directory.systemTemp.createTemp('startup_race_');
    final saved = File('${directory.path}/saved.mp3');
    final selected = File('${directory.path}/selected.mp3');
    await saved.writeAsString('audio');
    await selected.writeAsString('audio');
    await File('${directory.path}/settings.json')
        .writeAsString('{"gaplessPlayback":true,"playbackSpeed":1.25}');
    await File('${directory.path}/queue_state.json').writeAsString(jsonEncode({
      'queue': [
        {'_id': 1, '_data': saved.path, 'title': 'Restored'},
      ],
      'currentIndex': 0,
    }));
    for (final name in [
      'plugins.flutter.io/path_provider',
      'com.ryanheise.audio_session',
      'home_widget',
      'home_widget/updates',
      'com.lucasjosino.on_audio_query',
    ]) {
      final channel = MethodChannel(name);
      channels.add(channel);
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (name == 'plugins.flutter.io/path_provider') return directory.path;
        if (call.method == 'saveWidgetData' || call.method == 'updateWidget') {
          return true;
        }
        return null;
      });
    }
    final audio = AudioPlayer(
      handleInterruptions: false,
      handleAudioSessionActivation: false,
      androidApplyAudioAttributes: false,
    );
    app.audioHandler = AuroraAudioHandler(audio);
    final restoreStarted = Completer<void>();
    final interruptRestore = Completer<void>();
    beforeLoad = (number) async {
      if (number != 1) return;
      restoreStarted.complete();
      await interruptRestore.future;
      throw PlatformException(code: 'abort', message: 'Loading interrupted');
    };
    final service = AudioPlayerService();
    addTearDown(() async {
      if (!interruptRestore.isCompleted) interruptRestore.complete();
      service.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await directory.delete(recursive: true);
    });
    await restoreStarted.future.timeout(const Duration(seconds: 5));
    expect(audio.speed, 1.25);
    final change = service.setPlaylist([
      SongModel({'_id': 2, '_data': selected.path, 'title': 'Selected'}),
    ], 0);
    await Future<void>.delayed(Duration.zero);
    interruptRestore.complete();
    await change.timeout(const Duration(seconds: 5));
    final pauseCount = pauses;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(service.currentSong?.id, 2);
    expect(audio.playing, isTrue);
    expect(pauses, pauseCount);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
  });
}
