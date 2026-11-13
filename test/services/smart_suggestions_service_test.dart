import 'dart:convert';
import 'dart:io';

import 'package:aurora_music_v01/shared/services/smart_suggestions_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';

SongModel _song(int id, {String artist = 'Artist', String genre = 'Rock'}) =>
    SongModel({
      '_id': id,
      'title': 'Song $id',
      'artist': artist,
      'genre': genre,
      'duration': 200000,
    });

void main() {
  late Directory dir;
  late File file;

  SmartSuggestionsService create() =>
      SmartSuggestionsService.forTesting(() async => dir);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('smart_suggestions');
    file = File('${dir.path}/smart_suggestions.json');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('a play recorded before the history loads does not replace it',
      () async {
    final seed = create();
    await seed.recordPlay(_song(1));
    await seed.recordListenDuration('1', 120000);
    await seed.flush();

    // A fresh start: playback begins before anything asked for the history.
    final restarted = create();
    await restarted.recordPlay(_song(2));
    await restarted.flush();

    final reader = create();
    await reader.initialize();
    expect(reader.trackPlayCounts, {'1': 1, '2': 1});
    expect(reader.estimatedListeningMinutes, 2);
  });

  test('listening time covers every play, not only the capped history',
      () async {
    final service = create();
    for (var i = 0; i < 1005; i++) {
      await service.recordPlay(_song(i));
      await service.recordListenDuration('$i', 60000);
    }
    expect(service.totalListens, 1005);
    expect(service.estimatedListeningMinutes, 1005);
  });

  test('a listened time is applied once and only ever grows', () async {
    final service = create();
    await service.recordPlay(_song(1));
    await service.recordListenDuration('1', 30000);
    await service.recordListenDuration('1', 30000);
    await service.recordListenDuration('1', 90000);
    await service.recordListenDuration('1', 45000);
    expect(service.estimatedListeningMinutes, 1);

    await service.recordListenDuration('1', 150000);
    expect(service.estimatedListeningMinutes, 2);
  });

  test('the lifetime total survives a restart and old files migrate', () async {
    final service = create();
    await service.recordPlay(_song(1));
    await service.recordListenDuration('1', 180000);
    await service.flush();

    final restarted = create();
    await restarted.initialize();
    expect(restarted.estimatedListeningMinutes, 3);

    // A file written before the total was stored: summed from the history.
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>
      ..remove('totalListenMs');
    file.writeAsStringSync(jsonEncode(data));
    final migrated = create();
    await migrated.initialize();
    expect(migrated.estimatedListeningMinutes, 3);
  });

  test('one unreadable event does not drop the rest', () async {
    final service = create();
    await service.recordPlay(_song(1));
    await service.recordPlay(_song(2));
    await service.flush();

    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    (data['listeningHistory'] as List).insert(1, {'trackId': null});
    file.writeAsStringSync(jsonEncode(data));

    final restarted = create();
    await restarted.initialize();
    expect(restarted.getEventsForPeriod(1).map((e) => e.trackId), ['1', '2']);
  });

  test('an unreadable file is kept, not written over', () async {
    file.writeAsStringSync('{ this is not json');

    final service = create();
    await service.recordPlay(_song(1));
    await service.flush();

    expect(
        File('${file.path}.corrupt').readAsStringSync(), '{ this is not json');
  });
}
