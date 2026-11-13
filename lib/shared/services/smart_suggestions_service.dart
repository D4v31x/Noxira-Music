import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'folder_filter_service.dart';
import '../models/artist_utils.dart';
import '../utils/performance_optimizations.dart';
import '../utils/atomic_file.dart';

/// Smart suggestion service that analyzes user listening patterns
/// to provide personalized track and artist recommendations
///
/// Performance optimizations:
/// - Memoized suggestions to avoid recomputation
/// - Cached score calculations
/// - Debounced data saving
class SmartSuggestionsService {
  static final SmartSuggestionsService _instance =
      SmartSuggestionsService._internal();
  factory SmartSuggestionsService() => _instance;
  SmartSuggestionsService._internal()
      : _directoryProvider = getApplicationDocumentsDirectory;

  /// A service that keeps its data in a directory of the caller's choosing.
  @visibleForTesting
  SmartSuggestionsService.forTesting(this._directoryProvider);

  final Future<Directory> Function() _directoryProvider;

  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Listening history with timestamps
  List<ListeningEvent> _listeningHistory = [];

  // Real time spent listening over the whole life of the data, in ms. The
  // history is capped, so summing it would shrink as old events drop off.
  int _totalListenMs = 0;

  // Play counts by time of day (0-23 hours)
  Map<int, Map<String, int>> _hourlyTrackCounts = {};
  Map<int, Map<String, int>> _hourlyArtistCounts = {};
  Map<int, Map<String, int>> _hourlyGenreCounts = {};

  // Day of week patterns (0=Monday, 6=Sunday)
  Map<int, Map<String, int>> _weekdayTrackCounts = {};
  Map<int, Map<String, int>> _weekdayArtistCounts = {};

  // Overall play counts
  Map<String, int> _trackPlayCounts = {};
  Map<String, int> _artistPlayCounts = {};
  Map<String, int> _genrePlayCounts = {};

  // Skip patterns (tracks user tends to skip)
  Map<String, int> _trackSkipCounts = {};

  // Recently played tracking
  List<String> _recentlyPlayedTrackIds = [];
  List<String> _recentlyPlayedArtists = [];

  bool _isLoaded = false;
  Future<void>? _initFuture;

  // Performance optimizations
  final Memoizer<Future<List<SongModel>>> _suggestionsMemoizer =
      Memoizer<Future<List<SongModel>>>();
  final Debouncer _saveDebouncer = Debouncer(delay: const Duration(seconds: 5));
  DateTime? _lastSuggestionTime;

  // Cache suggestion results for 5 minutes
  static const _suggestionCacheDuration = Duration(minutes: 5);

  /// Load the saved data. Safe to call from anywhere, any number of times:
  /// everyone shares one load, and recording waits for it, so a play that
  /// happens before the history has loaded is not lost or saved over it.
  Future<void> initialize() => _initFuture ??= _loadData().whenComplete(() {
        _isLoaded = true;
      });

  /// Write any pending changes now instead of after the save delay. Call when
  /// playback pauses or the app is going away.
  Future<void> flush() async {
    if (_initFuture == null) return;
    await _initFuture;
    _saveDebouncer.dispose();
    await _saveData();
  }

  /// Record a listening event
  Future<void> recordPlay(SongModel song,
      {bool wasSkipped = false, int listenDurationMs = 0}) async {
    await initialize();
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday - 1; // Convert to 0-indexed
    final trackId = song.id.toString();
    final artists = splitArtists(song.artist ?? 'Unknown');
    final genre = song.genre ?? 'Unknown';

    // Record the event
    _listeningHistory.add(ListeningEvent(
      trackId: trackId,
      artists: artists,
      genre: genre,
      timestamp: now,
      wasSkipped: wasSkipped,
      listenDurationMs: listenDurationMs,
      totalDurationMs: song.duration ?? 0,
    ));

    // Keep only last 1000 events
    if (_listeningHistory.length > 1000) {
      _listeningHistory =
          _listeningHistory.sublist(_listeningHistory.length - 1000);
    }

    if (wasSkipped) {
      _trackSkipCounts[trackId] = (_trackSkipCounts[trackId] ?? 0) + 1;
    } else {
      // Update overall counts
      _trackPlayCounts[trackId] = (_trackPlayCounts[trackId] ?? 0) + 1;
      for (final artist in artists) {
        _artistPlayCounts[artist] = (_artistPlayCounts[artist] ?? 0) + 1;
      }
      _genrePlayCounts[genre] = (_genrePlayCounts[genre] ?? 0) + 1;

      // Update hourly patterns
      _hourlyTrackCounts[hour] ??= {};
      _hourlyTrackCounts[hour]![trackId] =
          (_hourlyTrackCounts[hour]![trackId] ?? 0) + 1;

      _hourlyArtistCounts[hour] ??= {};
      for (final artist in artists) {
        _hourlyArtistCounts[hour]![artist] =
            (_hourlyArtistCounts[hour]![artist] ?? 0) + 1;
      }

      _hourlyGenreCounts[hour] ??= {};
      _hourlyGenreCounts[hour]![genre] =
          (_hourlyGenreCounts[hour]![genre] ?? 0) + 1;

      // Update weekday patterns
      _weekdayTrackCounts[weekday] ??= {};
      _weekdayTrackCounts[weekday]![trackId] =
          (_weekdayTrackCounts[weekday]![trackId] ?? 0) + 1;

      _weekdayArtistCounts[weekday] ??= {};
      for (final artist in artists) {
        _weekdayArtistCounts[weekday]![artist] =
            (_weekdayArtistCounts[weekday]![artist] ?? 0) + 1;
      }

      // Track recently played
      _recentlyPlayedTrackIds.remove(trackId);
      _recentlyPlayedTrackIds.insert(0, trackId);
      if (_recentlyPlayedTrackIds.length > 50) {
        _recentlyPlayedTrackIds = _recentlyPlayedTrackIds.sublist(0, 50);
      }

      for (final artist in artists) {
        _recentlyPlayedArtists.remove(artist);
        _recentlyPlayedArtists.insert(0, artist);
      }
      if (_recentlyPlayedArtists.length > 30) {
        _recentlyPlayedArtists = _recentlyPlayedArtists.sublist(0, 30);
      }
    }

    // Save periodically (debounced to reduce disk I/O)
    _saveDebouncer.call(() => _saveData());
  }

  /// Record the real listened duration (in ms) for the most recent play of
  /// [trackId]. This is the time actually spent listening (e.g. they stopped
  /// at 1:25), NOT the song's full length. Safe to call repeatedly as the
  /// listened time grows: only an increase is applied, and the lifetime total
  /// moves by the difference.
  Future<void> recordListenDuration(
      String trackId, int listenDurationMs) async {
    if (listenDurationMs <= 0) return;
    await initialize();
    if (_listeningHistory.isEmpty) return;
    // Find the most recent non-skipped event for this track.
    for (var i = _listeningHistory.length - 1; i >= 0; i--) {
      final e = _listeningHistory[i];
      if (e.trackId == trackId && !e.wasSkipped) {
        if (listenDurationMs > e.listenDurationMs) {
          _totalListenMs += listenDurationMs - e.listenDurationMs;
          e.listenDurationMs = listenDurationMs;
          _saveDebouncer.call(() => _saveData());
        }
        break;
      }
    }
  }

  /// Discard the cached suggestions so the next call recomputes with the
  /// current folder filter.  Call this whenever folder exclusions change.
  void invalidateSuggestionCache() {
    _suggestionsMemoizer.clear();
    _lastSuggestionTime = null;
  }

  /// Get suggested tracks based on current time and listening patterns
  Future<List<SongModel>> getSuggestedTracks({
    int count = 3,
    List<SongModel>? songs,
  }) async {
    final now = DateTime.now();
    final cacheKey =
        '${now.hour}_${now.weekday}_${count}_${songs?.length ?? 'query'}';

    // Check if we can use cached suggestions
    if (_lastSuggestionTime != null) {
      final timeSinceLastSuggestion = now.difference(_lastSuggestionTime!);
      if (timeSinceLastSuggestion < _suggestionCacheDuration) {
        return _suggestionsMemoizer.call(
            cacheKey, () => _computeSuggestedTracks(count, songs: songs));
      }
    }

    // Clear cache and recompute
    _suggestionsMemoizer.clear();
    _lastSuggestionTime = now;
    return _suggestionsMemoizer.call(
        cacheKey, () => _computeSuggestedTracks(count, songs: songs));
  }

  /// Internal method to compute suggestions (expensive operation)
  Future<List<SongModel>> _computeSuggestedTracks(
    int count, {
    List<SongModel>? songs,
  }) async {
    late final List<SongModel> allSongs;
    if (songs != null) {
      allSongs = List<SongModel>.from(songs);
    } else {
      final rawSongs = await _audioQuery.querySongs();
      await FolderFilterService().ensureInitialized();
      allSongs = FolderFilterService().filterSongs(rawSongs);
    }

    if (allSongs.isEmpty) return [];

    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday - 1;

    // Calculate scores for each track
    final scores = <String, double>{};

    for (final song in allSongs) {
      final trackId = song.id.toString();
      double score = 0;

      // 1. Time-of-day relevance (weight: 3x)
      final hourlyData = _hourlyTrackCounts[hour];
      if (hourlyData != null && hourlyData.containsKey(trackId)) {
        score += (hourlyData[trackId]! * 3);
      }

      // Check adjacent hours too (weight: 1.5x)
      for (final adj in [(hour - 1) % 24, (hour + 1) % 24]) {
        final adjData = _hourlyTrackCounts[adj];
        if (adjData != null && adjData.containsKey(trackId)) {
          score += (adjData[trackId]! * 1.5);
        }
      }

      // 2. Day-of-week relevance (weight: 2x)
      final weekdayData = _weekdayTrackCounts[weekday];
      if (weekdayData != null && weekdayData.containsKey(trackId)) {
        score += (weekdayData[trackId]! * 2);
      }

      // 3. Overall play count (weight: 1x, but diminishing returns)
      final playCount = _trackPlayCounts[trackId] ?? 0;
      score += sqrt(playCount.toDouble());

      // 4. Genre matching current time preference (weight: 2x)
      final genre = song.genre ?? 'Unknown';
      final hourlyGenres = _hourlyGenreCounts[hour];
      if (hourlyGenres != null && hourlyGenres.containsKey(genre)) {
        score += (hourlyGenres[genre]! * 0.5);
      }

      // 5. Artist preference at this time (weight: 2x)
      final artists = splitArtists(song.artist ?? '');
      final hourlyArtists = _hourlyArtistCounts[hour];
      if (hourlyArtists != null) {
        for (final artist in artists) {
          if (hourlyArtists.containsKey(artist)) {
            score += (hourlyArtists[artist]! * 2);
          }
        }
      }

      // 6. Penalty for recently played (avoid repetition)
      final recentIndex = _recentlyPlayedTrackIds.indexOf(trackId);
      if (recentIndex >= 0 && recentIndex < 10) {
        score *= (0.3 +
            (recentIndex * 0.07)); // 30-100% of score based on how recent
      }

      // 7. Penalty for frequently skipped tracks
      final skipCount = _trackSkipCounts[trackId] ?? 0;
      if (skipCount > 0) {
        score *= max(0.2, 1.0 - (skipCount * 0.1));
      }

      // 8. Small random factor for variety (5%)
      score *= (0.95 + Random().nextDouble() * 0.1);

      scores[trackId] = score;
    }

    // If no listening history, use weighted random based on song metadata
    if (_listeningHistory.isEmpty) {
      return _getFallbackSuggestions(allSongs, count);
    }

    // Sort by score and get top tracks
    final sortedIds = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final suggestedIds = sortedIds.take(count * 2).map((e) => e.key).toList();

    // Shuffle top results slightly for variety
    suggestedIds.shuffle();

    final result = <SongModel>[];
    for (final id in suggestedIds.take(count)) {
      final song = allSongs.firstWhere(
        (s) => s.id.toString() == id,
        orElse: () => allSongs.first,
      );
      result.add(song);
    }

    return result;
  }

  /// Get suggested artists based on current time and listening patterns
  Future<List<String>> getSuggestedArtists({
    int count = 3,
    List<SongModel>? songs,
  }) async {
    final allSongs = songs != null
        ? List<SongModel>.from(songs)
        : await _audioQuery.querySongs();
    if (allSongs.isEmpty) return [];

    // Get all unique artists
    final allArtists = <String>{};
    for (final song in allSongs) {
      allArtists.addAll(splitArtists(song.artist ?? ''));
    }

    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday - 1;

    // Calculate scores for each artist
    final scores = <String, double>{};

    for (final artist in allArtists) {
      if (artist.isEmpty || artist.toLowerCase() == 'unknown') continue;

      double score = 0;

      // 1. Time-of-day relevance (weight: 3x)
      final hourlyData = _hourlyArtistCounts[hour];
      if (hourlyData != null && hourlyData.containsKey(artist)) {
        score += (hourlyData[artist]! * 3);
      }

      // Check adjacent hours (weight: 1.5x)
      for (final adj in [(hour - 1) % 24, (hour + 1) % 24]) {
        final adjData = _hourlyArtistCounts[adj];
        if (adjData != null && adjData.containsKey(artist)) {
          score += (adjData[artist]! * 1.5);
        }
      }

      // 2. Day-of-week relevance (weight: 2x)
      final weekdayData = _weekdayArtistCounts[weekday];
      if (weekdayData != null && weekdayData.containsKey(artist)) {
        score += (weekdayData[artist]! * 2);
      }

      // 3. Overall play count (weight: 1x with diminishing returns)
      final playCount = _artistPlayCounts[artist] ?? 0;
      score += sqrt(playCount.toDouble());

      // 4. Penalty for very recently played artists
      final recentIndex = _recentlyPlayedArtists.indexOf(artist);
      if (recentIndex >= 0 && recentIndex < 5) {
        score *= (0.5 + (recentIndex * 0.1));
      }

      // 5. Small random factor for variety
      score *= (0.95 + Random().nextDouble() * 0.1);

      scores[artist] = score;
    }

    // If no listening history, return popular artists
    if (_listeningHistory.isEmpty) {
      final shuffled = allArtists.toList()..shuffle();
      return shuffled.take(count).toList();
    }

    // Sort by score and get top artists
    final sortedArtists = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take more than needed and shuffle for variety
    final topArtists = sortedArtists.take(count * 2).map((e) => e.key).toList();
    topArtists.shuffle();

    return topArtists.take(count).toList();
  }

  /// Fallback suggestions when no listening history exists
  List<SongModel> _getFallbackSuggestions(List<SongModel> allSongs, int count) {
    // Prefer songs with complete metadata
    final scored = allSongs.map((song) {
      double score = Random().nextDouble();
      if (song.artist != null && song.artist!.isNotEmpty) score += 0.3;
      if (song.album != null && song.album!.isNotEmpty) score += 0.2;
      if (song.genre != null && song.genre!.isNotEmpty) score += 0.1;
      return MapEntry(song, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(count).map((e) => e.key).toList();
  }

  /// Get time-based greeting and context
  String getTimeContext() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  /// Check if user has enough history for smart suggestions
  bool hasListeningHistory() => _listeningHistory.length >= 10;

  // ── Analytics / Insights ──────────────────────────────────────────────────

  /// Read-only snapshot of per-track play counts (trackId → count).
  Map<String, int> get trackPlayCounts => Map.unmodifiable(_trackPlayCounts);

  /// Read-only snapshot of per-artist play counts (artist name → count).
  Map<String, int> get artistPlayCounts => Map.unmodifiable(_artistPlayCounts);

  /// Read-only snapshot of per-genre play counts (genre → count).
  Map<String, int> get genrePlayCounts => Map.unmodifiable(_genrePlayCounts);

  /// Read-only snapshot of skip counts per track (trackId → skips).
  Map<String, int> get skipCounts => Map.unmodifiable(_trackSkipCounts);

  /// Aggregated play count per hour of day (0–23 → total plays that hour).
  Map<int, int> get playsByHour {
    final result = <int, int>{};
    for (final entry in _hourlyTrackCounts.entries) {
      result[entry.key] = entry.value.values.fold(0, (a, b) => a + b);
    }
    return result;
  }

  /// Aggregated play count per weekday (0 = Monday … 6 = Sunday).
  Map<int, int> get playsByWeekday {
    final result = <int, int>{};
    for (final entry in _weekdayTrackCounts.entries) {
      result[entry.key] = entry.value.values.fold(0, (a, b) => a + b);
    }
    return result;
  }

  /// Total non-skipped listens across all tracks.
  int get totalListens => _trackPlayCounts.values.fold(0, (a, b) => a + b);

  /// Estimated total listening time in minutes, over the whole life of the
  /// data (not only the capped history).
  int get estimatedListeningMinutes => (_totalListenMs / 60000).floor();

  /// The hour (0–23) with the most plays, or null if no data.
  int? get mostActiveHour {
    final byHour = playsByHour;
    if (byHour.isEmpty) return null;
    return byHour.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// The weekday (0 = Monday … 6 = Sunday) with the most plays, or null.
  int? get mostActiveWeekday {
    final byDay = playsByWeekday;
    if (byDay.isEmpty) return null;
    return byDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// First listen timestamp, or null if no history.
  DateTime? get firstListenTime =>
      _listeningHistory.isEmpty ? null : _listeningHistory.first.timestamp;

  /// Track ids in the order they were played, most recent first (at most 50).
  List<String> get recentTrackIds => List.unmodifiable(_recentlyPlayedTrackIds);

  // ── Period-based analytics ─────────────────────────────────────────────────

  /// All non-skipped events within the last [days] days.
  /// If [fromDate] is supplied it is used as the lower-bound cutoff directly
  /// (instead of `now − days`), which lets callers anchor the window to the
  /// user's first-listen time rather than the current clock.
  List<ListeningEvent> getEventsForPeriod(int days, {DateTime? fromDate}) {
    final cutoff = fromDate ?? DateTime.now().subtract(Duration(days: days));
    return _listeningHistory
        .where((e) => e.timestamp.isAfter(cutoff) && !e.wasSkipped)
        .toList();
  }

  /// Track play counts for the last [days] days.
  Map<String, int> trackPlayCountsForPeriod(int days, {DateTime? fromDate}) {
    final counts = <String, int>{};
    for (final e in getEventsForPeriod(days, fromDate: fromDate)) {
      counts[e.trackId] = (counts[e.trackId] ?? 0) + 1;
    }
    return counts;
  }

  /// Artist play counts for the last [days] days.
  Map<String, int> artistPlayCountsForPeriod(int days, {DateTime? fromDate}) {
    final counts = <String, int>{};
    for (final e in getEventsForPeriod(days, fromDate: fromDate)) {
      for (final artist in e.artists) {
        counts[artist] = (counts[artist] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Genre play counts for the last [days] days.
  Map<String, int> genrePlayCountsForPeriod(int days, {DateTime? fromDate}) {
    final counts = <String, int>{};
    for (final e in getEventsForPeriod(days, fromDate: fromDate)) {
      counts[e.genre] = (counts[e.genre] ?? 0) + 1;
    }
    return counts;
  }

  /// Estimated listening minutes for the last [days] days.
  int estimatedMinutesForPeriod(int days, {DateTime? fromDate}) {
    final totalMs = getEventsForPeriod(days, fromDate: fromDate)
        .fold<int>(0, (s, e) => s + e.listenDurationMs);
    return (totalMs / 60000).floor();
  }

  /// Most active hour (0–23) for the last [days] days, or null if no data.
  int? mostActiveHourForPeriod(int days, {DateTime? fromDate}) {
    final events = getEventsForPeriod(days, fromDate: fromDate);
    if (events.isEmpty) return null;
    final byHour = <int, int>{};
    for (final e in events) {
      byHour[e.timestamp.hour] = (byHour[e.timestamp.hour] ?? 0) + 1;
    }
    return byHour.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Most active weekday (0=Mon…6=Sun) for the last [days] days, or null.
  int? mostActiveWeekdayForPeriod(int days, {DateTime? fromDate}) {
    final events = getEventsForPeriod(days, fromDate: fromDate);
    if (events.isEmpty) return null;
    final byDay = <int, int>{};
    for (final e in events) {
      final day = e.timestamp.weekday - 1;
      byDay[day] = (byDay[day] ?? 0) + 1;
    }
    return byDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Save data to disk
  Future<void> _saveData() async {
    // Never write before the saved data has been read: that would replace the
    // history with whatever little has been recorded so far.
    if (!_isLoaded) return;
    try {
      final directory = await _directoryProvider();
      final file = File('${directory.path}/smart_suggestions.json');

      final data = {
        'listeningHistory': _listeningHistory.map((e) => e.toJson()).toList(),
        'totalListenMs': _totalListenMs,
        'hourlyTrackCounts':
            _hourlyTrackCounts.map((k, v) => MapEntry(k.toString(), v)),
        'hourlyArtistCounts':
            _hourlyArtistCounts.map((k, v) => MapEntry(k.toString(), v)),
        'hourlyGenreCounts':
            _hourlyGenreCounts.map((k, v) => MapEntry(k.toString(), v)),
        'weekdayTrackCounts':
            _weekdayTrackCounts.map((k, v) => MapEntry(k.toString(), v)),
        'weekdayArtistCounts':
            _weekdayArtistCounts.map((k, v) => MapEntry(k.toString(), v)),
        'trackPlayCounts': _trackPlayCounts,
        'artistPlayCounts': _artistPlayCounts,
        'genrePlayCounts': _genrePlayCounts,
        'trackSkipCounts': _trackSkipCounts,
        'recentlyPlayedTrackIds': _recentlyPlayedTrackIds,
        'recentlyPlayedArtists': _recentlyPlayedArtists,
      };

      await writeStringAtomic(file, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving smart suggestions data: $e');
    }
  }

  /// Load data from disk
  Future<void> _loadData() async {
    File? file;
    try {
      final directory = await _directoryProvider();
      file = File('${directory.path}/smart_suggestions.json');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents) as Map<String, dynamic>;

        // One unreadable event must not throw the whole history away.
        _listeningHistory = [
          for (final raw in (data['listeningHistory'] as List? ?? const []))
            ..._tryParseEvent(raw),
        ];

        _totalListenMs = (data['totalListenMs'] as num?)?.toInt() ??
            _listeningHistory
                .where((e) => !e.wasSkipped)
                .fold<int>(0, (sum, e) => sum + e.listenDurationMs);
        _hourlyTrackCounts =
            (data['hourlyTrackCounts'] as Map<String, dynamic>?)?.map((k, v) =>
                    MapEntry(int.parse(k), Map<String, int>.from(v))) ??
                {};

        _hourlyArtistCounts =
            (data['hourlyArtistCounts'] as Map<String, dynamic>?)?.map((k, v) =>
                    MapEntry(int.parse(k), Map<String, int>.from(v))) ??
                {};

        _hourlyGenreCounts =
            (data['hourlyGenreCounts'] as Map<String, dynamic>?)?.map((k, v) =>
                    MapEntry(int.parse(k), Map<String, int>.from(v))) ??
                {};

        _weekdayTrackCounts =
            (data['weekdayTrackCounts'] as Map<String, dynamic>?)?.map((k, v) =>
                    MapEntry(int.parse(k), Map<String, int>.from(v))) ??
                {};

        _weekdayArtistCounts =
            (data['weekdayArtistCounts'] as Map<String, dynamic>?)?.map(
                    (k, v) =>
                        MapEntry(int.parse(k), Map<String, int>.from(v))) ??
                {};

        _trackPlayCounts = Map<String, int>.from(data['trackPlayCounts'] ?? {});
        _artistPlayCounts =
            Map<String, int>.from(data['artistPlayCounts'] ?? {});
        _genrePlayCounts = Map<String, int>.from(data['genrePlayCounts'] ?? {});
        _trackSkipCounts = Map<String, int>.from(data['trackSkipCounts'] ?? {});
        _recentlyPlayedTrackIds =
            List<String>.from(data['recentlyPlayedTrackIds'] ?? []);
        _recentlyPlayedArtists =
            List<String>.from(data['recentlyPlayedArtists'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading smart suggestions data: $e');
      // The next save would overwrite the file with a mostly empty state, so
      // keep a copy of what could not be read.
      try {
        await file?.copy('${file.path}.corrupt');
      } catch (_) {}
    }
  }

  static Iterable<ListeningEvent> _tryParseEvent(dynamic raw) {
    try {
      return [ListeningEvent.fromJson(raw as Map<String, dynamic>)];
    } catch (_) {
      return const [];
    }
  }
}

/// Represents a single listening event
class ListeningEvent {
  final String trackId;
  final List<String> artists;
  final String genre;
  final DateTime timestamp;
  final bool wasSkipped;

  /// The real time the user spent listening to this play, in milliseconds
  /// (e.g. they stopped/skipped at 1:25 → 85000). Recorded when the song is
  /// switched/stopped, NOT derived from the song's full length. Mutable so it
  /// can be filled in once the play actually ends.
  int listenDurationMs;
  final int totalDurationMs;

  ListeningEvent({
    required this.trackId,
    required this.artists,
    required this.genre,
    required this.timestamp,
    this.wasSkipped = false,
    this.listenDurationMs = 0,
    this.totalDurationMs = 0,
  });

  Map<String, dynamic> toJson() => {
        'trackId': trackId,
        'artists': artists,
        'genre': genre,
        'timestamp': timestamp.toIso8601String(),
        'wasSkipped': wasSkipped,
        'listenDurationMs': listenDurationMs,
        'totalDurationMs': totalDurationMs,
      };

  factory ListeningEvent.fromJson(Map<String, dynamic> json) => ListeningEvent(
        trackId: json['trackId'],
        artists: List<String>.from(json['artists']),
        genre: json['genre'],
        timestamp: DateTime.parse(json['timestamp']),
        wasSkipped: json['wasSkipped'] ?? false,
        listenDurationMs: json['listenDurationMs'] ?? 0,
        totalDurationMs: json['totalDurationMs'] ?? 0,
      );
}
