import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/timed_lyrics.dart';
import 'local_lyrics_source.dart';
import 'lyrics_providers/lyrics_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:math' show min, max;
import 'package:flutter/foundation.dart';

class TimedLyricsService {
  /// Singleton: every `TimedLyricsService()` call site (now_playing.dart,
  /// fullscreen_lyrics.dart, lyrics_editor_screen.dart,
  /// batch_download_service.dart, etc.) shares ONE instance, so the
  /// in-memory lyrics cache and HTTP keep-alive connection below are
  /// actually reused across screens/song changes instead of being
  /// recreated (and thus empty) on every call — this is what makes
  /// repeat lyric loads for the same song instant.
  static final TimedLyricsService _instance = TimedLyricsService._internal();
  factory TimedLyricsService() => _instance;
  TimedLyricsService._internal();

  static const String apiBaseUrl = 'https://lrclib.net/api';
  static const Duration _apiTimeout = Duration(seconds: 6);
  static const Duration _apiTimeoutRetry = Duration(seconds: 10);

  /// Shared keep-alive HTTP client so repeated requests to lrclib.net reuse
  /// the same TCP/TLS connection instead of paying a fresh handshake for
  /// every request (the `http.get` top-level helper opens/closes a new
  /// `Client` per call). Also reused by fullscreen_lyrics.dart's manual
  /// search via [httpClient].
  static final http.Client _client = http.Client();
  static http.Client get httpClient => _client;

  void Function(String)? _onLog;

  // In-memory cache for instant access
  final Map<String, List<TimedLyric>> _memoryCache = {};
  static const int _maxMemoryCacheSize = 50;

  /// Bumped whenever lyrics are saved/edited (see [_saveLyricsToFile]) so
  /// already-open lyrics views can reload instead of showing stale lyrics
  /// for the currently-playing song.
  final ValueNotifier<int> lyricsRevisionNotifier = ValueNotifier<int>(0);

  void _log(String message) {
    final fullMessage = '🎵 [LYRICS] $message';
    debugPrint(fullMessage);
    _onLog?.call(fullMessage);
  }

  /// Get lyrics synchronously from memory cache if available
  List<TimedLyric>? getCachedLyrics(String artist, String title) {
    final cacheKey = md5.convert(utf8.encode('$artist-$title')).toString();
    return _memoryCache[cacheKey];
  }

  /// Preload lyrics into memory cache for instant access
  Future<void> preloadLyricsToMemory(String artist, String title) async {
    final cacheKey = md5.convert(utf8.encode('$artist-$title')).toString();
    if (_memoryCache.containsKey(cacheKey)) return;

    final lyrics = await loadLyricsFromFile(artist, title);
    if (lyrics != null) {
      _addToMemoryCache(cacheKey, lyrics);
    }
  }

  void _addToMemoryCache(String key, List<TimedLyric> lyrics) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      // Remove oldest entry (first key)
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }
    _memoryCache[key] = lyrics;
  }

  /// GETs [url] with a timeout, then retries once with a longer timeout if
  /// the first attempt times out (surfaced as a synthetic HTTP 408).
  /// lrclib.net is a free public API that occasionally responds slowly
  /// under load, so a single retry with more patience avoids unnecessary
  /// "no lyrics found" failures without blocking the UI forever.
  ///
  /// [timeout] overrides the default first-attempt timeout (used to give
  /// the best-effort `/get-cached` call a shorter leash). [retryOnTimeout]
  /// can be set to false to skip the second, longer-timeout attempt
  /// entirely — used for the best-effort call so it can never end up
  /// taking longer overall than the reliable `/search` call it runs
  /// alongside.
  Future<http.Response> _getWithRetry(
    Uri url, {
    Duration? timeout,
    bool retryOnTimeout = true,
  }) async {
    const headers = {
      'Accept': 'application/json',
      'User-Agent': 'AuroraMusic v0.0.85',
    };
    final firstTimeout = timeout ?? _apiTimeout;
    try {
      final response = await _client
          .get(url, headers: headers)
          .timeout(firstTimeout, onTimeout: () => http.Response('', 408));
      if (response.statusCode != 408 || !retryOnTimeout) return response;

      _log(
          '  ⏳ $url timed out after ${firstTimeout.inSeconds}s — retrying with a ${_apiTimeoutRetry.inSeconds}s timeout...');
      return await _client
          .get(url, headers: headers)
          .timeout(_apiTimeoutRetry, onTimeout: () => http.Response('', 408));
    } catch (e) {
      _log('  ✗ Request to $url failed: $e');
      return http.Response('', 408);
    }
  }

  final Map<String, Future<List<TimedLyric>?>> _inflightFetches = {};

  /// Concurrent requests for the same song (the now-playing box and the full
  /// screen both ask) share one lookup instead of racing each other.
  Future<List<TimedLyric>?> fetchTimedLyrics(
    String artist,
    String title, {
    Duration? songDuration,
    String? audioPath,
    String? album,
    void Function(String)? onLog,
    Future<Map<String, dynamic>?> Function(List<Map<String, dynamic>>)?
        onMultipleResults,
  }) {
    if (onMultipleResults != null) {
      return _fetchTimedLyrics(artist, title,
          songDuration: songDuration,
          audioPath: audioPath,
          album: album,
          onLog: onLog,
          onMultipleResults: onMultipleResults);
    }
    final key = '$artist-$title-${songDuration?.inSeconds}';
    final running = _inflightFetches[key];
    if (running != null) return running;
    final future = _fetchTimedLyrics(artist, title,
        songDuration: songDuration,
        audioPath: audioPath,
        album: album,
        onLog: onLog);
    _inflightFetches[key] = future;
    return future.whenComplete(() => _inflightFetches.remove(key));
  }

  Future<List<TimedLyric>?> _fetchTimedLyrics(
    String artist,
    String title, {
    Duration? songDuration,
    String? audioPath,
    String? album,
    void Function(String)? onLog,
    Future<Map<String, dynamic>?> Function(List<Map<String, dynamic>>)?
        onMultipleResults,
  }) async {
    _onLog = onLog;
    _log('=' * 60);
    _log('SEARCH STARTED');
    _log('Original Artist: "$artist"');
    _log('Original Title: "$title"');
    if (songDuration != null) {
      _log(
          'Song Duration: ${songDuration.inMinutes}:${(songDuration.inSeconds % 60).toString().padLeft(2, '0')}');
    }

    try {
      // First try loading from local storage
      _log('Checking local cache...');
      final localLyrics = await loadLyricsFromFile(artist, title);
      if (localLyrics != null) {
        _log('✓ Found cached lyrics (${localLyrics.length} lines)');
        if (_isLyricsDurationValid(localLyrics, songDuration)) {
          _log('✓ Cached lyrics duration is valid - using cached version');
          _log('=' * 60);
          return localLyrics;
        } else {
          final lyricsDur = _getLyricsDuration(localLyrics);
          _log(
              '✗ Cached lyrics duration mismatch: ${lyricsDur.inMinutes}:${(lyricsDur.inSeconds % 60).toString().padLeft(2, '0')} vs song ${songDuration?.inMinutes}:${((songDuration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}');
          _log('Fetching fresh lyrics from API...');
        }
      } else {
        _log('✗ No cached lyrics found');
      }

      // Lyrics shipped with the file (sidecar .lrc or lyrics tag) beat any
      // online lookup: they are exact for this recording and work offline.
      final embedded = await LocalLyricsSource.find(audioPath);
      if (embedded != null) {
        _log('✓ Using lyrics from the audio file (${embedded.length} lines)');
        _log('=' * 60);
        return embedded;
      }

      // Extract the first (primary) artist and clean the title for better
      // API matching. Songs with multi-artist tags like "Artist1, Artist2" or
      // "Artist1 feat. Artist2" confuse lrclib; sending only the primary artist
      // yields far more reliable results.
      final searchArtist = _extractFirstArtist(artist);
      final searchTitle = _cleanTitleForSearch(title);

      _log('Primary artist: "$searchArtist" (original: "$artist")');
      _log('Cleaned title:  "$searchTitle" (original: "$title")');
      // Word-by-word lyrics beat everything else, so the other services are
      // asked alongside LRCLIB. A manual search (the user picks from a list)
      // only looks at LRCLIB.
      final providerLyrics = onMultipleResults == null
          ? _collectProviderLyrics(
              artist: searchArtist,
              title: searchTitle,
              album: album,
              songDuration: songDuration,
            ).catchError((_) => <_ProviderLyrics>[])
          : null;

      /// Saves LRCLIB's lyrics, unless a provider has word-by-word timing for
      /// the song, which is shown instead.
      Future<List<TimedLyric>> preferWordSynced(
        List<TimedLyric> lrclibLyrics,
        String lrclibContent,
      ) async {
        if (providerLyrics != null) {
          final fromProviders = await providerLyrics.timeout(
              const Duration(seconds: 8),
              onTimeout: () => const <_ProviderLyrics>[]);
          final wordSynced = fromProviders.where((c) => c.hasWords).firstOrNull;
          if (wordSynced != null) {
            return _useProviderLyrics(wordSynced, artist, title);
          }
        }
        await _saveLyricsToFile(artist, title, lrclibContent, notify: false);
        return lrclibLyrics;
      }

      _log('─' * 60);
      _log('METHOD 1 & 2: Parallel API Search (Direct + Search)');
      _log('Search Artist: "$searchArtist"');
      _log('Search Title: "$searchTitle"');

      // NOTE: the plain `/get` endpoint is intentionally NOT used here.
      // Per LRCLIB's docs, `/get` "will attempt to access external sources
      // in case the lyrics are not found in the internal database"
      // whenever there's no exact cached match, which means its response
      // time "will vary significantly" — this is what caused auto search
      // to time out while manual search (which only calls `/search`)
      // succeeded. `/get-cached` uses the exact same signature match but
      // ONLY looks at the internal database, so it's fast and predictable
      // like `/search`.
      final directQueryParams = {
        'artist_name': searchArtist,
        'track_name': searchTitle,
        if (songDuration != null) 'duration': songDuration.inSeconds.toString(),
      };
      final directUrl = Uri.parse('$apiBaseUrl/get-cached')
          .replace(queryParameters: directQueryParams);

      final searchUrl =
          Uri.parse('$apiBaseUrl/search').replace(queryParameters: {
        'artist_name': searchArtist,
        'track_name': searchTitle,
      });

      _log('Direct URL: $directUrl');
      _log('Search URL: $searchUrl');

      // Run both API calls in parallel. `/search` is the reliable endpoint
      // (same one the manual search flow uses) so it gets the full retry
      // treatment. `/get-cached` (exact match) is supplementary/best-effort
      // only — it's given a single, shorter-timeout attempt with NO retry
      // so a slow or stuck request can never hold up (or double the wait
      // for) the overall fetch when `/search` would have succeeded anyway.
      final results = await Future.wait([
        _getWithRetry(directUrl,
            retryOnTimeout: false, timeout: const Duration(seconds: 4)),
        _getWithRetry(searchUrl),
      ]);

      final directResponse = results[0];
      final searchResponse = results[1];

      // Try direct response first
      _log('Direct Response Status: ${directResponse.statusCode}');
      if (directResponse.statusCode == 200 && directResponse.body.isNotEmpty) {
        final directData = json.decode(utf8.decode(directResponse.bodyBytes));
        if (directData != null && directData['syncedLyrics'] != null) {
          final foundTrack = directData['trackName'] ?? 'Unknown';
          final foundArtist = directData['artistName'] ?? 'Unknown';

          final titleScore =
              _titleSimilarity(searchTitle, foundTrack as String);
          final artistScore =
              _artistSimilarity(searchArtist, foundArtist as String);

          _log('✓ Direct match candidate: "$foundTrack" by "$foundArtist"');
          _log(
              '  Title score: ${titleScore.toStringAsFixed(2)}, Artist score: ${artistScore.toStringAsFixed(2)}');

          // Strict: title ≥ 0.85 AND primary-artist ≥ 0.85
          // Relaxed: title ≥ 0.80 AND any individual artist from the tag ≥ 0.75
          final plausible =
              _isPlausibleVersion(searchTitle, directData as Map, songDuration);
          final strictDirect =
              plausible && titleScore >= 0.85 && artistScore >= 0.85;
          final relaxedDirect = !strictDirect &&
              plausible &&
              titleScore >= 0.80 &&
              _extractAllArtists(artist).any(
                (a) => _artistSimilarity(a, foundArtist) >= 0.75,
              );

          if (strictDirect || relaxedDirect) {
            if (relaxedDirect) _log('  (accepted via relaxed artist match)');
            _log('📍 Searched: "$searchTitle" by "$searchArtist"');
            _log('📍 Got: "$foundTrack" by "$foundArtist"');
            _log('Album: ${directData['albumName'] ?? 'N/A'}');

            final lrcContent = directData['syncedLyrics'] as String;
            final normalizedContent = utf8
                .decode(utf8.encode(lrcContent), allowMalformed: true)
                .replaceAll(RegExp(r'[\uFFFD]'), '');

            final lyrics = _parseLrc(normalizedContent);
            _log('✓ Parsed ${lyrics.length} lyric lines');

            final chosen = await preferWordSynced(lyrics, normalizedContent);
            _log('✓ USING direct match result');
            _log('=' * 60);
            return chosen;
          } else {
            _log('✗ Direct match rejected: title or artist score too low');
          }
        }
      }

      // Process search response
      _log('Search Response Status: ${searchResponse.statusCode}');

      if (searchResponse.statusCode == 200 && searchResponse.body.isNotEmpty) {
        final List searchResults =
            json.decode(utf8.decode(searchResponse.bodyBytes));

        _log('Found ${searchResults.length} search results');

        if (searchResults.isNotEmpty) {
          // Log all results before sorting
          _log('📍 Searched: "$searchTitle" by "$searchArtist"');
          for (var i = 0; i < searchResults.length; i++) {
            final r = searchResults[i];
            final hasSynced = r['syncedLyrics'] != null;
            final dur = hasSynced
                ? _parseApproximateDuration(r['syncedLyrics'])
                : Duration.zero;
            _log(
                '  Result ${i + 1}: "${r['trackName']}" by "${r['artistName']}" - Synced: $hasSynced - Duration: ${dur.inMinutes}:${(dur.inSeconds % 60).toString().padLeft(2, '0')}');
          }

          // Filter results to only those with synced lyrics
          final syncedResults =
              searchResults.where((r) => r['syncedLyrics'] != null).toList();

          // Tier 1 – strict: title ≥ 0.85 AND primary-artist ≥ 0.85
          final strictResults = syncedResults.where((r) {
            final titleScore =
                _titleSimilarity(searchTitle, r['trackName'] as String? ?? '');
            final artistScore = _artistSimilarity(
                searchArtist, r['artistName'] as String? ?? '');
            return titleScore >= 0.85 &&
                artistScore >= 0.85 &&
                _isPlausibleVersion(searchTitle, r, songDuration);
          }).toList();

          // Tier 2 – relaxed: title ≥ 0.80 AND any individual artist from the
          // tag (e.g. "Koven" out of "Koven and Aeon Mode") scores ≥ 0.75
          final filteredResults = strictResults.isNotEmpty
              ? strictResults
              : syncedResults.where((r) {
                  final titleScore = _titleSimilarity(
                      searchTitle, r['trackName'] as String? ?? '');
                  if (titleScore < 0.80) return false;
                  if (!_isPlausibleVersion(searchTitle, r, songDuration)) {
                    return false;
                  }
                  final resultArtist = r['artistName'] as String? ?? '';
                  return _extractAllArtists(artist).any(
                    (a) => _artistSimilarity(a, resultArtist) >= 0.75,
                  );
                }).toList();

          _log(
              '  Strict: ${strictResults.length} / Relaxed total: ${filteredResults.length} passing filter');

          if (filteredResults.isEmpty) {
            _log('✗ No results with synced lyrics');
          } else {
            _log('Found ${filteredResults.length} results with synced lyrics');

            // Sort results by relevance: title match first, then artist match, then duration
            // Best match first: title, artist, how close the track length is
            // (LRCLIB reports it per result) and whether the album agrees.
            double rank(Map r) {
              final title = _titleSimilarity(
                  searchTitle, r['trackName'] as String? ?? '');
              final art = _artistSimilarity(
                  searchArtist, r['artistName'] as String? ?? '');
              final lrcDuration = r['duration'];
              final durationScore =
                  (songDuration == null || lrcDuration is! num)
                      ? 0.5
                      : 1 -
                          ((lrcDuration.toDouble() - songDuration.inSeconds)
                                  .abs()
                                  .clamp(0.0, 15.0) /
                              15.0);
              final albumScore = (album == null ||
                      album.isEmpty ||
                      album == '<unknown>')
                  ? 0.5
                  : _titleSimilarity(album, r['albumName'] as String? ?? '');
              return title * 0.45 +
                  art * 0.25 +
                  durationScore * 0.25 +
                  albumScore * 0.05;
            }

            filteredResults.sort((a, b) => rank(b).compareTo(rank(a)));

            _log('After sorting by relevance:');
            for (var i = 0; i < min(5, filteredResults.length); i++) {
              final r = filteredResults[i];
              final dur = _parseApproximateDuration(r['syncedLyrics']);
              final artistScore =
                  _artistSimilarity(searchArtist, r['artistName'] ?? '');
              final titleScore =
                  _titleSimilarity(searchTitle, r['trackName'] ?? '');
              _log(
                  '  #${i + 1}: "${r['trackName']}" by "${r['artistName']}" - Title: ${titleScore.toStringAsFixed(2)}, Artist: ${artistScore.toStringAsFixed(2)} - Duration: ${dur.inMinutes}:${(dur.inSeconds % 60).toString().padLeft(2, '0')}');
            }

            // If we have multiple good results and a callback, let user choose
            if (filteredResults.length > 1 && onMultipleResults != null) {
              _log('Multiple results found - asking user to choose...');
              final userChoice = await onMultipleResults(
                  filteredResults.cast<Map<String, dynamic>>());

              if (userChoice != null) {
                final lrcContent = userChoice['syncedLyrics'] as String;
                final lyrics = _parseLrc(lrcContent);
                final foundTrack = userChoice['trackName'] ?? 'Unknown';
                final foundArtist = userChoice['artistName'] ?? 'Unknown';

                _log('✓ User selected: "$foundTrack" by "$foundArtist"');
                _log('✓ Parsed ${lyrics.length} lyric lines');
                await _saveLyricsToFile(artist, title, lrcContent,
                    notify: false);
                _log('=' * 60);
                return lyrics;
              } else {
                _log('✗ User cancelled selection');
                _log('=' * 60);
                return null;
              }
            }
          }

          // Auto-select if only one result or if top result is valid
          if (filteredResults.isNotEmpty) {
            _log('Evaluating top results for duration validity...');
            for (var i = 0; i < min(3, filteredResults.length); i++) {
              final result = filteredResults[i];
              final lrcContent = result['syncedLyrics'] as String;
              final lyrics = _parseLrc(lrcContent);

              if (_isLyricsDurationValid(lyrics, songDuration)) {
                final foundTrack = result['trackName'] ?? 'Unknown';
                final foundArtist = result['artistName'] ?? 'Unknown';

                _log('✓ Result #${i + 1} VALID (auto-selected)');
                _log('📍 Got: "$foundTrack" by "$foundArtist"');
                _log('✓ Parsed ${lyrics.length} lyric lines');
                _log('✓ USING search result #${i + 1}');
                final chosen = await preferWordSynced(lyrics, lrcContent);
                _log('=' * 60);
                return chosen;
              } else {
                final lyricsDur = _getLyricsDuration(lyrics);
                final diff = _getLyricsDurationDifference(lyrics, songDuration);
                _log(
                    '✗ Result #${i + 1} duration mismatch: ${diff.inSeconds}s (lyrics: ${lyricsDur.inMinutes}:${(lyricsDur.inSeconds % 60).toString().padLeft(2, '0')}, song: ${songDuration?.inMinutes}:${((songDuration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')})');
              }
            }

            // Without a matching length this is probably another version
            // (live, remix, radio edit) - better no lyrics than the wrong ones.
            final bestResult = filteredResults[0];
            final bestDuration = bestResult['duration'];
            final lengthKnownAndOff = songDuration != null &&
                bestDuration is num &&
                (bestDuration - songDuration.inSeconds).abs() > 12;
            if (lengthKnownAndOff) {
              _log('✗ Best result has a different length - not using it');
            } else {
              final lrcContent = bestResult['syncedLyrics'] as String;
              final lyrics = _parseLrc(lrcContent);
              final foundTrack = bestResult['trackName'] ?? 'Unknown';
              final foundArtist = bestResult['artistName'] ?? 'Unknown';

              _log('⚠️ No exact duration match - using best result');
              _log('📍 Got: "$foundTrack" by "$foundArtist"');
              _log('✓ Parsed ${lyrics.length} lyric lines');
              final chosen = await preferWordSynced(lyrics, lrcContent);
              _log('=' * 60);
              return chosen;
            }
          }
        }
      }

      _log('✗ No lyrics found on LRCLIB, trying other sources...');
      final candidates = await (providerLyrics ??
          _collectProviderLyrics(
            artist: searchArtist,
            title: searchTitle,
            album: album,
            songDuration: songDuration,
          ));
      if (candidates.isNotEmpty) {
        // Word-by-word first, then the services' priority order.
        final best =
            candidates.where((c) => c.hasWords).firstOrNull ?? candidates.first;
        final lyrics = await _useProviderLyrics(best, artist, title);
        _log('=' * 60);
        return lyrics;
      }

      _log('✗ No lyrics found matching title+artist criteria');
      _log('=' * 60);
      return null;
    } catch (e) {
      _log('✗ ERROR during lyrics fetch: $e');
      _log('=' * 60);
      return null;
    }
  }

  /// Asks the enabled secondary providers (see [LyricsProviders]) in parallel
  /// and returns every valid result, in provider priority order.
  Future<List<_ProviderLyrics>> _collectProviderLyrics({
    required String artist,
    required String title,
    required String? album,
    required Duration? songDuration,
  }) async {
    final providers = await LyricsProviders.enabled();
    if (providers.isEmpty) return const [];

    final query = LyricsQuery(
      title: title,
      artist: artist,
      album: (album == null || album.trim().isEmpty || album == '<unknown>')
          ? null
          : album.trim(),
      durationSeconds: songDuration?.inSeconds,
    );

    final results = [
      for (final p in providers)
        p
            .fetchLrc(query, _client)
            .timeout(const Duration(seconds: 15), onTimeout: () => null)
            .catchError((_) => null),
    ];

    final valid = <_ProviderLyrics>[];
    for (var i = 0; i < providers.length; i++) {
      final raw = await results[i];
      if (raw == null) continue;
      final hasWords = lrcHasWordTiming(raw);
      // Line-level callers don't want inline word markup.
      final lrc = hasWords ? stripLrcMarkers(raw) : sanitizeLrc(raw);
      final lyrics = _parseLrc(lrc);
      if (lyrics.isEmpty) continue;
      if (!lyricsMatchSongLanguage(lrc, query)) {
        _log(
            '✗ ${providers[i].name}: lyrics language does not match the song, skipped');
        continue;
      }
      if (!_isLyricsDurationValid(lyrics, songDuration)) {
        _log('✗ ${providers[i].name}: duration mismatch, skipped');
        continue;
      }
      valid.add(_ProviderLyrics(providers[i].name, lrc, lyrics, hasWords));
    }
    return valid;
  }

  /// Saves and returns [candidate] as the song's lyrics.
  Future<List<TimedLyric>> _useProviderLyrics(
    _ProviderLyrics candidate,
    String cacheArtist,
    String cacheTitle,
  ) async {
    _log('✓ USING ${candidate.name} '
        '(${candidate.lyrics.length} lines'
        '${candidate.hasWords ? ', word-by-word' : ''})');
    await _saveLyricsToFile(cacheArtist, cacheTitle, candidate.lrc,
        notify: false);
    return candidate.lyrics;
  }

  /// Extracts the primary (first) artist from a potentially multi-artist tag.
  /// Splits on common separators: `,` `;` `&` ` and ` ` feat.` ` feat ` ` ft.` ` ft `
  /// ` x ` (case-insensitive) and returns the first non-empty segment.
  String _extractFirstArtist(String artist) {
    final cleaned = artist
        .splitMapJoin(
          RegExp(
              r',|;|&|\band\b|\bfeat\.?\b|\bft\.?\b|\bversus\b|\bvs\.?\b|\bx\b',
              caseSensitive: false),
          onMatch: (_) => '\x00',
          onNonMatch: (s) => s,
        )
        .split('\x00')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .firstOrNull;
    return cleaned ?? artist.trim();
  }

  /// Extracts ALL individual artists from a potentially multi-artist tag.
  /// Used for relaxed matching: if ANY split artist matches a result, accept it.
  List<String> _extractAllArtists(String artist) {
    final parts = artist
        .splitMapJoin(
          RegExp(
              r',|;|&|\band\b|\bfeat\.?\b|\bft\.?\b|\bversus\b|\bvs\.?\b|\bx\b',
              caseSensitive: false),
          onMatch: (_) => '\x00',
          onNonMatch: (s) => s,
        )
        .split('\x00')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? [artist.trim()] : parts;
  }

  /// Strips common decorative suffixes from a track title so the API can
  /// match it more reliably.
  /// Removes:
  ///  - Parenthetical/bracketed suffixes: `(feat. ...)`, `[Remastered]`, etc.
  ///  - Trailing `feat. Artist` / `ft. Artist` without brackets
  String _cleanTitleForSearch(String title) {
    var s = title.trim();
    // Remove (feat. ...) / [feat. ...] and similar bracketed extras
    s = s.replaceAll(
        RegExp(r'\s*[\(\[]\s*(?:feat\.?|ft\.?|with|prod\.?)[^\)\]]*[\)\]]',
            caseSensitive: false),
        '');
    // Remove other bracketed qualifiers: (Official Video), [Remastered 2024], etc.
    s = s.replaceAll(
        RegExp(
            r'\s*[\(\[]\s*(?:official|remaster(?:ed)?|live|acoustic|radio\s+edit|single\s+version|album\s+version)[^\)\]]*[\)\]]',
            caseSensitive: false),
        '');
    // Remove trailing "feat. Artist" / "ft. Artist" without brackets
    s = s.replaceAll(
        RegExp(r'\s+(?:feat\.?|ft\.?)\s+.+$', caseSensitive: false), '');
    return s.trim();
  }

  /// Public method to parse LRC content
  List<TimedLyric> parseLrcContent(String lrcContent) {
    return _parseLrc(lrcContent);
  }

  /// Public method to save lyrics to cache
  Future<void> saveLyricsToCache(
      String artist, String title, String content) async {
    await _saveLyricsToFile(artist, title, content);
  }

  /// Deletes the cached lyrics (disk + memory) for a specific song.
  /// Returns true if a file was found and deleted, false if nothing was cached.
  Future<bool> deleteCachedLyricsForSong(String artist, String title) async {
    final cacheKey = md5.convert(utf8.encode('$artist-$title')).toString();
    _memoryCache.remove(cacheKey);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/lyrics/$cacheKey.lrc');
      if (await file.exists()) {
        await file.delete();
        lyricsRevisionNotifier.value = lyricsRevisionNotifier.value + 1;
        return true;
      }
      return false;
    } catch (e) {
      _log('✗ Error deleting cached lyrics: $e');
      return false;
    }
  }

  List<TimedLyric> _parseLrc(String lrcContent) {
    // Properly decode and normalize the content
    final normalizedContent = utf8
        .decode(utf8.encode(lrcContent), allowMalformed: true)
        .replaceAll(RegExp(r'[\uFFFD]'), '');
    return parseLrc(normalizedContent);
  }

  /// [notify] bumps [lyricsRevisionNotifier] so open lyrics views reload. Only
  /// edits and manual picks should do that: a save made by an automatic fetch
  /// is handed straight to its caller, and notifying would make every open
  /// view reload (and fetch again) in a loop.
  Future<void> _saveLyricsToFile(String artist, String title, String content,
      {bool notify = true}) async {
    _log('  Saving lyrics to cache...');
    try {
      final directory = await getApplicationDocumentsDirectory();

      final fileName = md5.convert(utf8.encode('$artist-$title')).toString();
      _log('  Cache filename: $fileName.lrc');

      final lyricsDir = Directory('${directory.path}/lyrics');
      if (!await lyricsDir.exists()) {
        _log('  Creating lyrics directory...');
        await lyricsDir.create();
      }

      final filePath = '${lyricsDir.path}/$fileName.lrc';
      _log('  Cache path: $filePath');

      final file = File(filePath);
      await file.writeAsString(content);
      _log('  ✓ Lyrics saved to cache');

      // Also add to memory cache for instant access
      final lyrics = _parseLrc(content);
      _addToMemoryCache(fileName, lyrics);
      if (notify) {
        lyricsRevisionNotifier.value = lyricsRevisionNotifier.value + 1;
      }
    } catch (e) {
      _log('  ✗ Error saving lyrics: $e');
    }
  }

  /// With [songDuration], cached lyrics whose timing does not fit the song
  /// (another version, a partial sync) are treated as a miss.
  Future<List<TimedLyric>?> loadLyricsFromFile(String artist, String title,
      {Duration? songDuration}) async {
    final lyrics = await _loadCached(artist, title);
    if (lyrics == null || _isLyricsDurationValid(lyrics, songDuration)) {
      return lyrics;
    }
    _log('  ✗ Cached lyrics do not fit the song length - ignoring them');
    return null;
  }

  Future<List<TimedLyric>?> _loadCached(String artist, String title) async {
    final cacheKey = md5.convert(utf8.encode('$artist-$title')).toString();

    // Check memory cache first for instant access
    if (_memoryCache.containsKey(cacheKey)) {
      _log('  ✓ Found in memory cache (instant)');
      return _memoryCache[cacheKey];
    }

    _log('  Loading from file cache...');
    try {
      final directory = await getApplicationDocumentsDirectory();

      final fileName = cacheKey;
      final filePath = '${directory.path}/lyrics/$fileName.lrc';

      _log('  Cache filename: $fileName.lrc');
      _log('  Cache path: $filePath');

      final file = File(filePath);
      if (await file.exists()) {
        _log('  ✓ Cache file exists, loading...');
        final content = await file.readAsString();
        final lyrics = _parseLrc(content);
        _log('  ✓ Loaded ${lyrics.length} lines from file cache');

        // Add to memory cache for next time
        _addToMemoryCache(cacheKey, lyrics);

        return lyrics;
      }
      _log('  ✗ Cache file does not exist');
      return null;
    } catch (e) {
      _log('  ✗ Error loading from cache: $e');
      return null;
    }
  }

  static final _versionWords = RegExp(
    r'\b(remix|live|acoustic|instrumental|karaoke|cover|sped up|slowed|reverb|nightcore|8d|demo)\b',
    caseSensitive: false,
  );

  /// Rejects LRCLIB entries that are another version of the song (a remix or
  /// live take the file isn't) or whose track length is clearly different.
  bool _isPlausibleVersion(String searchTitle, Map<dynamic, dynamic> result,
      Duration? songDuration) {
    if (result['instrumental'] == true) return false;
    final candidate = result['trackName'] as String? ?? '';
    final wanted = _versionWords
        .allMatches(searchTitle)
        .map((m) => m.group(0)!.toLowerCase())
        .toSet();
    for (final m in _versionWords.allMatches(candidate)) {
      if (!wanted.contains(m.group(0)!.toLowerCase())) return false;
    }
    final length = result['duration'];
    if (songDuration != null &&
        length is num &&
        (length - songDuration.inSeconds).abs() > 20) {
      return false;
    }
    return true;
  }

  /// Whether lyrics plausibly belong to a song of this length. The last synced
  /// line normally ends well before the song does (outro, fade-out), so being
  /// shorter is fine; only lyrics running past the end, or covering a tiny
  /// part of a long song, point to another version.
  bool _isLyricsDurationValid(List<TimedLyric> lyrics, Duration? songDuration) {
    if (songDuration == null || lyrics.isEmpty) return true;

    final lyricsDuration = _getLyricsDuration(lyrics);
    final overrun = (lyricsDuration - songDuration).inMilliseconds;
    final tolerance = max(songDuration.inMilliseconds * 0.1, 10000);
    if (overrun > tolerance) return false;

    final partial = songDuration.inSeconds > 60 &&
        lyricsDuration.inMilliseconds < songDuration.inMilliseconds * 0.2;
    return !partial;
  }

  Duration _getLyricsDuration(List<TimedLyric> lyrics) {
    if (lyrics.isEmpty) return Duration.zero;
    return lyrics.last.time;
  }

  Duration _getLyricsDurationDifference(
      List<TimedLyric> lyrics, Duration? songDuration) {
    if (songDuration == null || lyrics.isEmpty) return Duration.zero;
    return (lyrics.last.time - songDuration).abs();
  }

  Duration _parseApproximateDuration(String? lrcContent) {
    if (lrcContent == null || lrcContent.isEmpty) return Duration.zero;

    // Find the last timestamp in the lyrics
    final timeRegex = RegExp(r'\[(\d{2}):(\d{2})[\.:]\d{2,3}\]');
    final matches = timeRegex.allMatches(lrcContent);

    if (matches.isEmpty) return Duration.zero;

    final lastMatch = matches.last;
    final minutes = int.parse(lastMatch.group(1)!);
    final seconds = int.parse(lastMatch.group(2)!);

    return Duration(minutes: minutes, seconds: seconds);
  }

  /// Calculate similarity score between two track titles (0.0 to 1.0).
  /// Normalises both strings before comparison.
  double _titleSimilarity(String searchTitle, String resultTitle) {
    String normalise(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final a = normalise(searchTitle);
    final b = normalise(resultTitle);

    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Substring containment
    if (b.contains(a) || a.contains(b)) return 0.9;

    // Word overlap
    final aWords = a.split(' ').where((w) => w.length >= 2).toSet();
    final bWords = b.split(' ').where((w) => w.length >= 2).toSet();
    final intersection = aWords.intersection(bWords).length;
    final union = aWords.union(bWords).length;
    if (union > 0) {
      final jaccard = intersection / union;
      if (jaccard >= 0.5) return 0.6 + jaccard * 0.3;
    }

    // Levenshtein fallback
    final dist = _levenshteinDistance(a, b);
    final maxLen = max(a.length, b.length);
    return max(0.0, 1.0 - dist / maxLen);
  }

  /// Calculate similarity score between two artist names (0.0 to 1.0)
  /// Higher score means better match
  double _artistSimilarity(String searchArtist, String resultArtist) {
    final searchLower = searchArtist.toLowerCase().trim();
    final resultLower = resultArtist.toLowerCase().trim();

    // Exact match gets highest score
    if (searchLower == resultLower) {
      return 1.0;
    }

    // Check if one contains the other (for featuring artists, remixes, etc.)
    if (resultLower.contains(searchLower) ||
        searchLower.contains(resultLower)) {
      return 0.9;
    }

    // Check if search artist is mentioned anywhere in result artist
    // (e.g., "Artist feat. SearchArtist" or "SearchArtist & Other")
    final searchWords = searchLower.split(RegExp(r'\W+'));
    final resultWords = resultLower.split(RegExp(r'\W+'));

    var matchingWords = 0;
    for (final searchWord in searchWords) {
      if (searchWord.length < 3) continue; // Skip very short words
      for (final resultWord in resultWords) {
        if (resultWord.contains(searchWord) ||
            searchWord.contains(resultWord)) {
          matchingWords++;
          break;
        }
      }
    }

    if (matchingWords > 0) {
      return 0.5 +
          (matchingWords / max(searchWords.length, resultWords.length)) * 0.4;
    }

    // Calculate Levenshtein distance for fuzzy matching
    final distance = _levenshteinDistance(searchLower, resultLower);
    final maxLength = max(searchLower.length, resultLower.length);

    if (maxLength == 0) return 0.0;

    // Convert distance to similarity score (0.0 to 0.5 for non-matching artists)
    return max(0.0, 0.5 - (distance / maxLength) * 0.5);
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = min(
          min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1),
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    return matrix[s1.length][s2.length];
  }
}

/// Lyrics returned by a secondary provider that passed the language and
/// length checks.
class _ProviderLyrics {
  const _ProviderLyrics(this.name, this.lrc, this.lyrics, this.hasWords);

  final String name;
  final String lrc;
  final List<TimedLyric> lyrics;

  /// Whether [lrc] is enhanced LRC with word-by-word timing.
  final bool hasWords;
}
