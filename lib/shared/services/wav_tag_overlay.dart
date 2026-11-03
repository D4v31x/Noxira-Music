import 'package:flutter/foundation.dart';
import 'package:haudiotagger/haudiotagger.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Android's MediaStore does not index the ID3/RIFF tags of WAV files, so
/// songs come back with the file name as title, no artist and no artwork.
/// This reads those tags directly from the file and layers them over the
/// MediaStore answer.
class WavTagOverlay {
  WavTagOverlay._();

  static const _concurrency = 8;

  /// Parsed tags keyed by path and modification time, so an edited file is
  /// read again but an untouched one is only parsed once.
  static final Map<String, _WavInfo> _cache = {};

  /// File paths of WAV songs seen so far, used to find artwork by song id.
  static final Map<int, String> _pathsById = {};

  static bool _isWav(SongModel song) {
    try {
      return song.data.toLowerCase().endsWith('.wav');
    } catch (_) {
      return false;
    }
  }

  static Future<List<SongModel>> apply(List<SongModel> songs) async {
    final wavIndexes = <int>[
      for (var i = 0; i < songs.length; i++)
        if (_isWav(songs[i])) i,
    ];
    if (wavIndexes.isEmpty) return songs;

    final result = List<SongModel>.of(songs);
    for (var start = 0; start < wavIndexes.length; start += _concurrency) {
      final chunk = wavIndexes.skip(start).take(_concurrency);
      await Future.wait(chunk.map((i) async {
        result[i] = await _enrich(songs[i]);
      }));
    }
    return result;
  }

  static Future<SongModel> _enrich(SongModel song) async {
    _pathsById[song.id] = song.data;
    final key = '${song.data}|${song.dateModified}';
    var info = _cache[key];
    if (info == null) {
      info = await _read(song.data);
      _cache[key] = info;
    }

    final map = Map<dynamic, dynamic>.of(song.getMap);
    void set(String field, String? value) {
      if (value != null && value.trim().isNotEmpty) map[field] = value.trim();
    }

    set('title', info.title);
    set('artist', info.artist);
    set('album', info.album);
    set('genre', info.genre);
    if (info.track != null) map['track'] = info.track;
    return SongModel(map);
  }

  static Future<_WavInfo> _read(String path) async {
    try {
      final tag = await Haudiotagger.read(path);
      if (tag == null) return const _WavInfo();
      return _WavInfo(
        title: tag.title,
        artist: tag.trackArtist,
        album: tag.album,
        genre: tag.genre,
        track: tag.trackNumber,
      );
    } catch (e) {
      debugPrint('WavTagOverlay: tag read failed for $path: $e');
      return const _WavInfo();
    }
  }

  /// Embedded cover of the WAV song with [id], or null if it has none.
  static Future<Uint8List?> artwork(int id) async {
    final path = _pathsById[id];
    if (path == null) return null;
    try {
      final pictures = await Haudiotagger.readPictures(path);
      if (pictures.isEmpty) return null;
      final cover = pictures.firstWhere(
        (p) => p.pictureType == PictureType.coverFront,
        orElse: () => pictures.first,
      );
      return cover.bytes.isEmpty ? null : cover.bytes;
    } catch (e) {
      debugPrint('WavTagOverlay: artwork read failed for $path: $e');
      return null;
    }
  }
}

class _WavInfo {
  const _WavInfo({this.title, this.artist, this.album, this.genre, this.track});

  final String? title;
  final String? artist;
  final String? album;
  final String? genre;
  final int? track;
}
