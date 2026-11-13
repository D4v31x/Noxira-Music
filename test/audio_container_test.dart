import 'dart:io';

import 'package:aurora_music_v01/shared/utils/audio_container.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> _id3(int bodySize) => [
      ...'ID3'.codeUnits,
      4,
      0,
      0,
      (bodySize >> 21) & 0x7F,
      (bodySize >> 14) & 0x7F,
      (bodySize >> 7) & 0x7F,
      bodySize & 0x7F,
      ...List.filled(bodySize, 0),
    ];

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('audio_container');
    file = File('${dir.path}/a.mp3');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<AudioContainerType> detect(List<int> bytes) {
    file.writeAsBytesSync(bytes);
    return AudioContainer.detect(file.path);
  }

  test('detects containers by content, not extension', () async {
    expect(await detect([...'fLaC'.codeUnits, 0, 0, 0, 0]),
        AudioContainerType.flac);
    expect(await detect([0, 0, 0, 24, ...'ftypM4A '.codeUnits, 0, 0, 0, 0]),
        AudioContainerType.mp4);
    expect(await detect([0xFF, 0xF1, 0x50, 0x80, 0, 0, 0, 0]),
        AudioContainerType.aac);
    expect(await detect([0xFF, 0xFB, 0x90, 0x00, 0, 0, 0, 0]),
        AudioContainerType.mpeg);
    expect(
        await detect([...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WAVE'.codeUnits]),
        AudioContainerType.wav);
  });

  test('sees through a leading ID3 block', () async {
    expect(await detect([..._id3(300), ...'fLaC'.codeUnits, 0, 0, 0, 0]),
        AudioContainerType.flac);
    expect(await detect([..._id3(20), 0xFF, 0xFB, 0x90, 0x00, 0, 0, 0, 0]),
        AudioContainerType.mpeg);
  });

  test('flags containers the tag writer cannot parse', () async {
    final asf = [0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11, 0, 0, 0, 0];
    expect(AudioContainer.unsupported.contains(await detect(asf)), isTrue);
  });

  test('strips a leading ID3 block and keeps the audio', () async {
    final audio = [...'fLaC'.codeUnits, 1, 2, 3, 4];
    file.writeAsBytesSync([..._id3(300), ...audio]);
    expect(await AudioContainer.stripLeadingId3(file.path), isTrue);
    expect(file.readAsBytesSync(), audio);
    expect(await AudioContainer.stripLeadingId3(file.path), isFalse);
  });
}
