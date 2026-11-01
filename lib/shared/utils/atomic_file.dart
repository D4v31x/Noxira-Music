import 'dart:io';

int _writeCounter = 0;

/// Writes [content] so [file] is always either the old or the new version.
///
/// `File.writeAsString` truncates the file first, so an app killed mid-write
/// (out of memory, battery, swipe-away) leaves it empty and the next start
/// fails to parse it (FLUTTER-31). Writing a sibling file and renaming it over
/// the target avoids that. Each call uses its own temporary file, so
/// overlapping saves cannot trip over each other: the last rename wins.
Future<void> writeStringAtomic(File file, String content) async {
  final temp = File('${file.path}.${_writeCounter++}.tmp');
  try {
    await temp.writeAsString(content, flush: true);
    await temp.rename(file.path);
  } catch (_) {
    if (await temp.exists()) await temp.delete();
    rethrow;
  }
}
