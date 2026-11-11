import 'package:aurora_music_v01/shared/services/duplicate_tracks_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';

SongModel song(int id, String title, String? artist,
        {int duration = 200000, int size = 5000000, String ext = 'mp3'}) =>
    SongModel({
      '_id': id,
      '_data': '/storage/emulated/0/Music/$id.$ext',
      '_display_name': '$id.$ext',
      '_display_name_wo_ext': '$id',
      '_size': size,
      'title': title,
      'artist': artist,
      'duration': duration,
      'file_extension': ext,
    });

void main() {
  test('groups same title/artist with close duration, best quality first', () {
    final groups = DuplicateTracksService.findDuplicates([
      song(1, 'Hello!', 'Adele', size: 4000000),
      song(2, 'hello', 'ADELE', duration: 201000, size: 30000000, ext: 'flac'),
      song(3, 'Hello', 'Adele', duration: 260000),
      song(4, 'Other', 'Adele'),
    ]);
    expect(groups, hasLength(1));
    expect(groups.single.songs.map((s) => s.id), [2, 1]);
  });

  test('unknown artists must also match in size', () {
    final groups = DuplicateTracksService.findDuplicates([
      song(1, 'Recording', '<unknown>', size: 1000),
      song(2, 'Recording', null, size: 2000),
      song(3, 'Memo', '<unknown>', size: 500),
      song(4, 'Memo', null, size: 500),
    ]);
    expect(groups, hasLength(1));
    expect(groups.single.songs.map((s) => s.id).toSet(), {3, 4});
  });
}
