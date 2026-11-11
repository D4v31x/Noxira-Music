import 'dart:io';
import 'dart:typed_data';

/// Removes non-box data appended after the last valid top-level atom of an
/// MP4/M4A file.
///
/// Some recorders (e.g. Samsung Voice Recorder) append a proprietary trailer
/// that is not a valid MP4 atom. Players ignore it, but strict tag parsers
/// fail with "failed to parse Mp4 file" and the file cannot be read or edited.
class Mp4Repair {
  Mp4Repair._();

  /// Truncates [path] right after its last valid top-level atom when trailing
  /// junk is present. Returns true if the file was modified. Files that are not
  /// MP4, lack a `moov`/`mdat` atom, or are already clean are left untouched.
  static Future<bool> trimTrailingGarbage(String path) async {
    final file = File(path);
    final int length;
    final int? validEnd;
    final reader = await file.open();
    try {
      length = await reader.length();
      validEnd = await _findValidEnd(reader, length);
    } finally {
      await reader.close();
    }
    if (validEnd == null || validEnd >= length) return false;

    // Append mode is write-only but, unlike write mode, doesn't truncate on open.
    final writer = await file.open(mode: FileMode.append);
    try {
      await writer.truncate(validEnd);
    } finally {
      await writer.close();
    }
    return true;
  }

  /// Returns the offset just past the last well-formed top-level atom, or
  /// null if the file doesn't look like a complete MP4.
  static Future<int?> _findValidEnd(RandomAccessFile raf, int length) async {
    var offset = 0;
    var sawFtyp = false;
    var sawMoov = false;
    var sawMdat = false;

    while (offset + 8 <= length) {
      final header = await _readAt(raf, offset, 8);
      if (header == null) break;

      final view = ByteData.sublistView(header);
      var size = view.getUint32(0);
      final type = header.sublist(4, 8);
      if (!_isPrintableAtomType(type)) break;

      if (size == 1) {
        final ext = await _readAt(raf, offset + 8, 8);
        if (ext == null) break;
        size = ByteData.sublistView(ext).getUint64(0);
      } else if (size == 0) {
        size = length - offset;
      }
      if (size < 8 || offset + size > length) break;

      final name = String.fromCharCodes(type);
      if (offset == 0 && name != 'ftyp') return null;
      if (name == 'ftyp') sawFtyp = true;
      if (name == 'moov') sawMoov = true;
      if (name == 'mdat') sawMdat = true;

      offset += size;
    }

    return sawFtyp && sawMoov && sawMdat ? offset : null;
  }

  static bool _isPrintableAtomType(Uint8List type) {
    for (final b in type) {
      // Atom types are ASCII, plus 0xA9 for the "©xyz"-style names.
      if (b != 0xA9 && (b < 0x20 || b > 0x7E)) return false;
    }
    return true;
  }

  static Future<Uint8List?> _readAt(
      RandomAccessFile raf, int position, int count) async {
    await raf.setPosition(position);
    final bytes = await raf.read(count);
    return bytes.length == count ? bytes : null;
  }
}
