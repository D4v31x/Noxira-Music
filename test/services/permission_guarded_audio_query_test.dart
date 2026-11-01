import 'package:aurora_music_v01/shared/services/permission_guarded_audio_query.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// The plugin crashes the whole app natively when it is queried without audio
/// permission (FLUTTER-9J), so the guard must never forward such calls.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.lucasjosino.on_audio_query');
  late List<String> calls;
  late bool granted;

  setUp(() {
    calls = [];
    granted = false;
    PermissionGuardedAudioQuery.install();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'permissionsStatus':
        case 'permissionsRequest':
          return granted;
        case 'queryArtwork':
          return Uint8List.fromList([1, 2, 3]);
        default:
          return <dynamic>[];
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('without permission queries return empty and never reach the plugin',
      () async {
    final query = OnAudioQuery();
    expect(await query.querySongs(), isEmpty);
    expect(await query.queryAlbums(), isEmpty);
    expect(await query.queryArtists(), isEmpty);
    expect(await query.queryArtwork(1, ArtworkType.AUDIO), isNull);

    expect(calls.where((c) => c != 'permissionsStatus'), isEmpty);
  });

  test('with permission calls are forwarded', () async {
    granted = true;
    final query = OnAudioQuery();
    expect(await query.queryArtwork(1, ArtworkType.AUDIO), isNotNull);
    await query.querySongs();

    expect(calls, containsAll(['queryArtwork', 'querySongs']));
  });

  test('a later permission grant is picked up', () async {
    final query = OnAudioQuery();
    expect(await query.queryArtwork(1, ArtworkType.AUDIO), isNull);

    granted = true;
    expect(await query.permissionsRequest(), isTrue);
    expect(await query.queryArtwork(1, ArtworkType.AUDIO), isNotNull);
  });

  test('identical overlapping queries share one request', () async {
    granted = true;
    var songCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'permissionsStatus') return true;
      if (call.method == 'querySongs') {
        songCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return <dynamic>[
          {'_id': 1, 'title': 'A'},
        ];
      }
      return <dynamic>[];
    });

    final query = OnAudioQuery();
    final results = await Future.wait([
      query.querySongs(),
      query.querySongs(),
      query.querySongs(),
    ]);

    expect(songCalls, 1);
    expect(results.every((r) => r.length == 1), isTrue);
    // Each caller owns its list: editing one must not touch the others.
    results[0].clear();
    expect(results[1], hasLength(1));

    // A later query asks again, so changes to the library are picked up.
    await query.querySongs();
    expect(songCalls, 2);
  });
}
