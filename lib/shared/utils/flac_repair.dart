import 'dart:io';
import 'dart:typed_data';

/// Fixes FLAC files whose metadata block chain has no "last block" flag.
///
/// Some tag writers (notably after embedding artwork) leave the final
/// metadata block (usually PADDING) flagged as "not last". Tolerant players
/// resync on the next audio frame, but ExoPlayer/Media3 fails with
/// "First frame does not start with sync code" and refuses to play the file.
class FlacRepair {
  FlacRepair._();

  /// Ensures the last metadata block of the FLAC at [path] carries the
  /// "last block" flag. Rewrites the file when a fix is needed and returns
  /// true if it did. Non-FLAC or already valid files are left untouched.
  static Future<bool> ensureLastBlockFlag(String path) async {
    final fixOffset = await _findUnflaggedLastBlock(path);
    if (fixOffset == null) return false;

    // Dart has no non-truncating read/write mode, so stream a patched copy
    // and swap it in.
    final source = File(path);
    final repaired = File('$path.repair');
    final reader = await source.open();
    final Uint8List prefix;
    try {
      prefix = await reader.read(fixOffset + 1);
    } finally {
      await reader.close();
    }
    prefix[fixOffset] |= 0x80;

    final sink = repaired.openWrite();
    try {
      sink.add(prefix);
      await sink.addStream(source.openRead(fixOffset + 1));
      await sink.close();
      await repaired.rename(path);
    } catch (_) {
      try {
        await repaired.delete();
      } catch (_) {}
      rethrow;
    }
    return true;
  }

  /// Returns the offset of the metadata block header that should carry the
  /// "last block" flag, or null if the file is not a FLAC or already valid.
  static Future<int?> _findUnflaggedLastBlock(String path) async {
    final raf = await File(path).open();
    try {
      final length = await raf.length();
      var offset = 4;
      if (length < offset + 4 || !await _hasFlacMagic(raf)) return null;

      // A FLAC has a handful of metadata blocks; cap the walk defensively.
      for (var i = 0; i < 128; i++) {
        final header = await _readAt(raf, offset, 4);
        if (header == null) return null;

        final isLast = header[0] & 0x80 != 0;
        final type = header[0] & 0x7f;
        if (isLast) return null;
        // 127 is invalid, so a non-last block must be followed by a header.
        if (type == 127) return null;

        final blockLength = (header[1] << 16) | (header[2] << 8) | header[3];
        final next = offset + 4 + blockLength;
        final probe = await _readAt(raf, next, 2);
        if (probe == null) return null;

        // Audio frame sync right after a block flagged "not last".
        if (probe[0] == 0xFF && (probe[1] & 0xFE) == 0xF8) return offset;
        offset = next;
      }
      return null;
    } finally {
      await raf.close();
    }
  }

  static Future<bool> _hasFlacMagic(RandomAccessFile raf) async {
    final magic = await _readAt(raf, 0, 4);
    return magic != null &&
        magic[0] == 0x66 &&
        magic[1] == 0x4C &&
        magic[2] == 0x61 &&
        magic[3] == 0x43;
  }

  static Future<Uint8List?> _readAt(
      RandomAccessFile raf, int position, int count) async {
    await raf.setPosition(position);
    final bytes = await raf.read(count);
    return bytes.length == count ? bytes : null;
  }
}
