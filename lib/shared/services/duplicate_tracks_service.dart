import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_player_service.dart';

/// Songs that look like copies of the same track.
class DuplicateGroup {
  DuplicateGroup(this.songs)
      : signature = (songs.map((s) => s.id).toList()..sort()).join(',');

  /// Identifies this exact set of songs, so a group the user ignored shows up
  /// again if a new copy appears.
  final String signature;

  /// Sorted best-quality first.
  final List<SongModel> songs;

  SongModel get best => songs.first;
}

/// Watches the library for duplicate tracks (same title and artist, nearly the
/// same duration) and exposes them so the UI can offer to resolve them.
class DuplicateTracksService extends ChangeNotifier {
  DuplicateTracksService._();
  static final DuplicateTracksService instance = DuplicateTracksService._();

  static const _ignoredKey = 'duplicate_tracks_ignored';
  static const _durationToleranceMs = 2000;
  static const _losslessExtensions = {'flac', 'wav', 'alac', 'aiff', 'aif'};

  AudioPlayerService? _audio;
  Timer? _debounce;
  Set<String> _ignored = {};
  List<DuplicateGroup> _all = const [];
  List<DuplicateGroup> _visible = const [];

  /// Groups the user hasn't dismissed.
  List<DuplicateGroup> get groups => _visible;

  /// Starts watching [audio]'s library. Safe to call repeatedly.
  Future<void> attach(AudioPlayerService audio) async {
    if (identical(_audio, audio)) return;
    _audio?.songsNotifier.removeListener(_onSongsChanged);
    _audio = audio;

    final prefs = await SharedPreferences.getInstance();
    _ignored = (prefs.getStringList(_ignoredKey) ?? const []).toSet();

    audio.songsNotifier.addListener(_onSongsChanged);
    unawaited(_scan());
  }

  void _onSongsChanged() {
    // The library list is replaced several times while loading.
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () => unawaited(_scan()));
  }

  int _scanGeneration = 0;

  Future<void> _scan() async {
    final audio = _audio;
    if (audio == null) return;
    final generation = ++_scanGeneration;
    // Grouping thousands of songs would stall the UI isolate.
    final result = await compute(findDuplicates, audio.songs);
    if (generation != _scanGeneration) return; // a newer scan superseded this
    _all = result;
    _publish();
  }

  void _publish() {
    _visible = _all
        .where((g) => !_ignored.contains(g.signature))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> ignore(DuplicateGroup group) => _ignoreAll([group]);

  Future<void> ignoreAll() => _ignoreAll(_visible);

  Future<void> _ignoreAll(List<DuplicateGroup> groups) async {
    _ignored = {..._ignored, ...groups.map((g) => g.signature)};
    _publish();
    final prefs = await SharedPreferences.getInstance();
    // Drop signatures that no longer match any current group.
    final current = _all.map((g) => g.signature).toSet();
    await prefs.setStringList(
      _ignoredKey,
      _ignored.where(current.contains).toList(),
    );
  }

  /// Re-scans the library right away (e.g. after deleting copies).
  void rescan() => unawaited(_scan());

  @visibleForTesting
  static List<DuplicateGroup> findDuplicates(List<SongModel> songs) {
    final byKey = <String, List<SongModel>>{};
    for (final song in songs) {
      final title = _normalize(song.title);
      if (title.isEmpty) continue;
      final artist = _normalizeArtist(song.artist);
      byKey.putIfAbsent('$title|$artist', () => []).add(song);
    }

    final groups = <DuplicateGroup>[];
    for (final entry in byKey.entries) {
      if (entry.value.length < 2) continue;
      final unknownArtist = entry.key.endsWith('|');
      for (final cluster in _clusterByDuration(entry.value, unknownArtist)) {
        if (cluster.length < 2) continue;
        cluster.sort(_compareQuality);
        groups.add(DuplicateGroup(cluster));
      }
    }
    groups.sort((a, b) =>
        a.best.title.toLowerCase().compareTo(b.best.title.toLowerCase()));
    return groups;
  }

  /// Splits same-title songs into runs whose durations are close together.
  /// Unknown artists are a weak signal, so those must also match in size.
  static List<List<SongModel>> _clusterByDuration(
      List<SongModel> songs, bool unknownArtist) {
    final sorted = [...songs]
      ..sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
    final clusters = <List<SongModel>>[];
    for (final song in sorted) {
      List<SongModel>? target;
      for (final cluster in clusters) {
        final last = cluster.last;
        final close = ((song.duration ?? 0) - (last.duration ?? 0)).abs() <=
            _durationToleranceMs;
        if (close && (!unknownArtist || song.size == last.size)) {
          target = cluster;
          break;
        }
      }
      if (target != null) {
        target.add(song);
      } else {
        clusters.add([song]);
      }
    }
    return clusters;
  }

  static int _compareQuality(SongModel a, SongModel b) {
    final aLossless =
        _losslessExtensions.contains(a.fileExtension.toLowerCase());
    final bLossless =
        _losslessExtensions.contains(b.fileExtension.toLowerCase());
    if (aLossless != bLossless) return aLossless ? -1 : 1;
    final bySize = b.size.compareTo(a.size);
    if (bySize != 0) return bySize;
    return a.id.compareTo(b.id);
  }

  static final _nonAlphanumeric = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  static String _normalize(String? value) =>
      (value ?? '').toLowerCase().replaceAll(_nonAlphanumeric, '');

  static String _normalizeArtist(String? artist) {
    final normalized = _normalize(artist);
    return normalized == 'unknown' ? '' : normalized;
  }
}
