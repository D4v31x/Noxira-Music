import 'dart:io';

import 'package:aurora_music_v01/shared/services/audio_player_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late File file;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('audio_settings_');
    file = File('${directory.path}/settings.json');
  });
  tearDown(() => directory.delete(recursive: true));

  test('missing settings use the initial defaults without creating files',
      () async {
    expect(await readAudioSettings(file), isNull);
    expect(await directory.list().toList(), isEmpty);
  });

  test('valid legacy settings are preserved', () async {
    const saved =
        '{"gaplessPlayback":false,"playbackSpeed":1.25,"cacheSize":100,'
        '"crossfadeDurationMs":6000,"defaultSortOrder":"artist"}';
    await file.writeAsString(saved);
    expect(await readAudioSettings(file), {
      'gaplessPlayback': false,
      'playbackSpeed': 1.25,
      'cacheSize': 100,
      'crossfadeDurationMs': 6000,
      'defaultSortOrder': 'artist',
    });
    expect(await file.readAsString(), saved);
  });

  for (final contents in [
    '',
    '{"gaplessPlayback":',
    '[]',
    'null',
    '{"gaplessPlayback":"true"}',
    '{"playbackSpeed":"fast"}',
    '{"pitch":0}',
    '{"cacheSize":1.5}',
    '{"defaultSortOrder":true}',
  ]) {
    test('corrupt settings are quarantined: $contents', () async {
      await file.writeAsString(contents);
      expect(await readAudioSettings(file), isNull);
      expect(await file.exists(), isFalse);
      expect(await File('${file.path}.corrupt').readAsString(), contents);
      expect(await readAudioSettings(file), isNull);
    });
  }
}
