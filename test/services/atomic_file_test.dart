import 'dart:io';

import 'package:aurora_music_v01/shared/utils/atomic_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('atomic'));
  tearDown(() async => dir.delete(recursive: true));

  test('writes and replaces the file without leaving temp files', () async {
    final file = File('${dir.path}/playlists.json');
    await writeStringAtomic(file, '[1]');
    await writeStringAtomic(file, '[1,2]');

    expect(await file.readAsString(), '[1,2]');
    expect(
      dir.listSync().map((e) => e.path.split('/').last),
      ['playlists.json'],
    );
  });

  test('overlapping writes do not fail and leave one complete version',
      () async {
    final file = File('${dir.path}/data.json');
    await Future.wait([
      for (var i = 0; i < 20; i++) writeStringAtomic(file, '{"v":$i}'),
    ]);

    expect(await file.readAsString(), matches(RegExp(r'^\{"v":\d+\}$')));
    expect(dir.listSync(), hasLength(1));
  });
}
