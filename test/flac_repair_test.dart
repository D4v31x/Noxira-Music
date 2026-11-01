import 'dart:io';
import 'dart:typed_data';

import 'package:aurora_music_v01/shared/utils/flac_repair.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _block(int type, bool last, int length) {
  final b = BytesBuilder();
  b.addByte((last ? 0x80 : 0) | type);
  b.add([(length >> 16) & 0xff, (length >> 8) & 0xff, length & 0xff]);
  b.add(List.filled(length, 0));
  return b.toBytes();
}

Uint8List _flac({required bool paddingIsLast}) {
  final b = BytesBuilder();
  b.add([0x66, 0x4C, 0x61, 0x43]);
  b.add(_block(0, false, 34));
  b.add(_block(4, false, 20));
  b.add(_block(1, paddingIsLast, 64));
  b.add([0xFF, 0xF8, 0xC9, 0x1C, 1, 2, 3, 4, 5, 6, 7, 8]);
  return b.toBytes();
}

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('flac_repair_'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('sets the last-block flag when audio follows a non-last block',
      () async {
    final broken = _flac(paddingIsLast: false);
    final f = File('${dir.path}/a.flac')..writeAsBytesSync(broken);

    expect(await FlacRepair.ensureLastBlockFlag(f.path), isTrue);

    final fixed = f.readAsBytesSync();
    final expected = _flac(paddingIsLast: true);
    expect(fixed, expected);
    // Idempotent.
    expect(await FlacRepair.ensureLastBlockFlag(f.path), isFalse);
  });

  test('leaves valid FLAC and non-FLAC files untouched', () async {
    final ok = File('${dir.path}/ok.flac')
      ..writeAsBytesSync(_flac(paddingIsLast: true));
    final other = File('${dir.path}/x.mp3')
      ..writeAsBytesSync(List.filled(64, 7));

    expect(await FlacRepair.ensureLastBlockFlag(ok.path), isFalse);
    expect(await FlacRepair.ensureLastBlockFlag(other.path), isFalse);
    expect(ok.readAsBytesSync(), _flac(paddingIsLast: true));
  });
}
