import 'dart:io';

import 'package:aurora_music_v01/shared/utils/mp4_repair.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> _atom(String type, int payload) {
  final size = 8 + payload;
  return [
    size >> 24 & 255,
    size >> 16 & 255,
    size >> 8 & 255,
    size & 255,
    ...type.codeUnits,
    ...List.filled(payload, 1),
  ];
}

void main() {
  late Directory dir;
  late File file;
  final valid = [
    ..._atom('ftyp', 12),
    ..._atom('mdat', 100),
    ..._atom('moov', 50)
  ];

  setUp(() {
    dir = Directory.systemTemp.createTempSync('mp4_repair');
    file = File('${dir.path}/a.m4a');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('leaves a clean file untouched', () async {
    file.writeAsBytesSync(valid);
    expect(await Mp4Repair.trimTrailingGarbage(file.path), isFalse);
    expect(file.lengthSync(), valid.length);
  });

  test('removes a non-atom trailer', () async {
    file.writeAsBytesSync(
        [...valid, ...'SEFH'.codeUnits, ...List.filled(40, 7)]);
    expect(await Mp4Repair.trimTrailingGarbage(file.path), isTrue);
    expect(file.lengthSync(), valid.length);
  });

  test('ignores files that are not MP4', () async {
    file.writeAsBytesSync(List.filled(100, 3));
    expect(await Mp4Repair.trimTrailingGarbage(file.path), isFalse);
    expect(file.lengthSync(), 100);
  });
}
