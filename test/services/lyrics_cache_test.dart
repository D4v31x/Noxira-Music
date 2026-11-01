import 'dart:io';

import 'package:aurora_music_v01/shared/services/lyrics_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lyrics reloaded after a save used to be thrown away when their last line
/// ended well before the song did, which sent the lyrics views into a
/// fetch -> save -> reload loop that ended in "no lyrics available".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory docs;

  setUp(() async {
    docs = await Directory.systemTemp.createTemp('lyrics_cache');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => docs.path);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, null);
    await docs.delete(recursive: true);
  });

  const lrc = '[00:10.00]First\n[01:30.00]Second\n[03:15.00]Last line';

  test('lyrics ending before the song ends are a valid match', () async {
    final service = TimedLyricsService();
    await service.saveLyricsToCache('Artist A', 'Song A', lrc);

    final loaded = await service.loadLyricsFromFile('Artist A', 'Song A',
        songDuration: const Duration(minutes: 4));
    expect(loaded, isNotNull);
    expect(loaded, hasLength(3));
  });

  test('lyrics running well past the song are another version', () async {
    final service = TimedLyricsService();
    await service.saveLyricsToCache('Artist B', 'Song B', lrc);

    final loaded = await service.loadLyricsFromFile('Artist B', 'Song B',
        songDuration: const Duration(minutes: 2));
    expect(loaded, isNull);
  });

  test('saving lyrics by hand tells open lyrics views to reload', () async {
    final service = TimedLyricsService();
    final before = service.lyricsRevisionNotifier.value;
    await service.saveLyricsToCache('Artist C', 'Song C', lrc);
    expect(service.lyricsRevisionNotifier.value, before + 1);
  });
}
