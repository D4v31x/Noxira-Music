import 'dart:io';
import 'dart:typed_data';

enum AudioContainerType {
  mpeg,
  aac,
  mp4,
  flac,
  ogg,
  wav,
  aiff,
  ape,
  wavpack,
  musepack,
  asf,
  amr,
  matroska,
  unknown,
}

/// Identifies an audio file by its content instead of its extension.
///
/// The tag writer picks its code path from the file extension and from a
/// leading "ID3" marker: anything named `.mp3` or starting with ID3 is treated
/// as MPEG audio and gets an ID3v2 block prepended. Mislabelled files (an M4A
/// named `.mp3`, a FLAC with an ID3v2 prefix) are therefore corrupted or have
/// their edits silently ignored, and files with unusual extensions are not
/// recognised at all.
class AudioContainer {
  AudioContainer._();

  /// Containers the tag writer cannot parse, so editing them can only fail.
  static const unsupported = {
    AudioContainerType.asf,
    AudioContainerType.amr,
    AudioContainerType.matroska,
  };

  static Future<AudioContainerType> detect(String path) async {
    final raf = await File(path).open();
    try {
      final id3Size = await _id3Size(raf);
      final head = await _readAt(raf, id3Size, 16);
      final type = _classify(head);
      if (type == AudioContainerType.unknown && id3Size > 0) {
        return AudioContainerType.mpeg;
      }
      return type;
    } finally {
      await raf.close();
    }
  }

  /// Extension for a temporary copy of a file of this [type], chosen so the
  /// tag writer takes the right path. ADTS AAC is named `.mp3` on purpose: that
  /// selects the byte-level ID3v2 writer, which never has to parse the stream.
  /// Returns null when the type gives no hint and the original name is better.
  static String? extensionFor(AudioContainerType type) {
    switch (type) {
      case AudioContainerType.mpeg:
      case AudioContainerType.aac:
        return '.mp3';
      case AudioContainerType.mp4:
        return '.m4a';
      case AudioContainerType.flac:
        return '.flac';
      case AudioContainerType.ogg:
        return '.ogg';
      case AudioContainerType.wav:
        return '.wav';
      case AudioContainerType.aiff:
        return '.aiff';
      case AudioContainerType.ape:
        return '.ape';
      case AudioContainerType.wavpack:
        return '.wv';
      case AudioContainerType.musepack:
        return '.mpc';
      default:
        return null;
    }
  }

  /// Removes a leading ID3v2 block from non-MPEG [path] so the tag writer
  /// does not mistake the file for an MP3. Returns true if the file changed.
  static Future<bool> stripLeadingId3(String path) async {
    final file = File(path);
    final raf = await file.open();
    final int offset;
    try {
      offset = await _id3Size(raf);
    } finally {
      await raf.close();
    }
    if (offset == 0) return false;

    final stripped = File('$path.strip');
    final sink = stripped.openWrite();
    try {
      await sink.addStream(file.openRead(offset));
      await sink.close();
      await stripped.rename(path);
    } catch (_) {
      try {
        await stripped.delete();
      } catch (_) {}
      rethrow;
    }
    return true;
  }

  static AudioContainerType _classify(Uint8List h) {
    if (h.length < 4) return AudioContainerType.unknown;
    bool at(int i, String s) {
      if (h.length < i + s.length) return false;
      for (var k = 0; k < s.length; k++) {
        if (h[i + k] != s.codeUnitAt(k)) return false;
      }
      return true;
    }

    if (at(0, 'fLaC')) return AudioContainerType.flac;
    if (at(0, 'OggS')) return AudioContainerType.ogg;
    if (at(0, 'RIFF') && at(8, 'WAVE')) return AudioContainerType.wav;
    if (at(0, 'FORM') && (at(8, 'AIFF') || at(8, 'AIFC'))) {
      return AudioContainerType.aiff;
    }
    if (at(0, 'MAC ')) return AudioContainerType.ape;
    if (at(0, 'wvpk')) return AudioContainerType.wavpack;
    if (at(0, 'MPCK') || at(0, 'MP+')) return AudioContainerType.musepack;
    if (at(4, 'ftyp')) return AudioContainerType.mp4;
    if (at(0, '#!AMR')) return AudioContainerType.amr;
    if (h[0] == 0x1A && h[1] == 0x45 && h[2] == 0xDF && h[3] == 0xA3) {
      return AudioContainerType.matroska;
    }
    if (h.length >= 8 &&
        h[0] == 0x30 &&
        h[1] == 0x26 &&
        h[2] == 0xB2 &&
        h[3] == 0x75 &&
        h[4] == 0x8E &&
        h[5] == 0x66 &&
        h[6] == 0xCF &&
        h[7] == 0x11) {
      return AudioContainerType.asf;
    }
    if (h[0] == 0xFF && (h[1] & 0xE0) == 0xE0) {
      // Layer bits 00 mean ADTS AAC, anything else is an MPEG audio frame.
      return (h[1] & 0x06) == 0
          ? AudioContainerType.aac
          : AudioContainerType.mpeg;
    }
    return AudioContainerType.unknown;
  }

  /// Total size of a leading ID3v2 block (header, body and optional footer),
  /// or 0 if the file does not start with one.
  static Future<int> _id3Size(RandomAccessFile raf) async {
    final h = await _readAt(raf, 0, 10);
    if (h.length < 10 || h[0] != 0x49 || h[1] != 0x44 || h[2] != 0x33) {
      return 0;
    }
    if (h[6] & 0x80 != 0 ||
        h[7] & 0x80 != 0 ||
        h[8] & 0x80 != 0 ||
        h[9] & 0x80 != 0) {
      return 0;
    }
    final body = (h[6] << 21) | (h[7] << 14) | (h[8] << 7) | h[9];
    final footer = h[5] & 0x10 != 0 ? 10 : 0;
    return 10 + body + footer;
  }

  static Future<Uint8List> _readAt(
      RandomAccessFile raf, int position, int count) async {
    await raf.setPosition(position);
    return raf.read(count);
  }
}
