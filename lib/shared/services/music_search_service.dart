import 'package:on_audio_query/on_audio_query.dart';
import '../models/artist_utils.dart';
import '../models/separated_artist.dart';
import 'artist_separator_service.dart';

/// Improved search service with fuzzy matching and scoring
class MusicSearchService {
  /// Calculate Levenshtein distance for fuzzy matching
  static int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    // Two rolling rows instead of a full matrix: same result, no per-call
    // allocation of (len1 + 1) lists.
    var previous = List<int>.generate(s2.length + 1, (j) => j);
    var current = List<int>.filled(s2.length + 1, 0);

    for (int i = 1; i <= s1.length; i++) {
      current[0] = i;
      final c1 = s1.codeUnitAt(i - 1);
      for (int j = 1; j <= s2.length; j++) {
        final cost = c1 == s2.codeUnitAt(j - 1) ? 0 : 1;
        var best = previous[j] + 1; // deletion
        final insertion = current[j - 1] + 1;
        if (insertion < best) best = insertion;
        final substitution = previous[j - 1] + cost;
        if (substitution < best) best = substitution;
        current[j] = best;
      }
      final swap = previous;
      previous = current;
      current = swap;
    }

    return previous[s2.length];
  }

  /// Lower-cased, pre-split text of a song. Building it runs the artist
  /// separator regex, so it is cached instead of redone for every song on
  /// every keystroke.
  static final Map<int, _SearchEntry> _entries = {};
  static bool _listeningForSeparatorChanges = false;

  static _SearchEntry _entryFor(SongModel song) {
    if (!_listeningForSeparatorChanges) {
      _listeningForSeparatorChanges = true;
      // Different separators change how artists are split.
      ArtistSeparatorService().addListener(_entries.clear);
    }
    final cached = _entries[song.id];
    if (cached != null &&
        cached.title == song.title &&
        cached.rawArtist == song.artist &&
        cached.album == song.album) {
      return cached;
    }
    final entry = _SearchEntry(song);
    _entries[song.id] = entry;
    return entry;
  }

  /// Calculate search score for a song (higher is better)
  static double _calculateScore(
      SongModel song, String queryLower, List<String> queryWords) {
    final entry = _entryFor(song);
    final title = entry.titleLower;
    final rawArtist = entry.rawArtistLower;
    final album = entry.albumLower;
    final artists = entry.artists;
    final artist = entry.artistJoined; // Combined for contains checks

    double score = 0.0;

    // Exact match bonus
    if (title == queryLower) score += 100;
    if (rawArtist == queryLower) score += 80;
    if (album == queryLower) score += 60;

    // Check if query matches any individual artist exactly
    for (final a in artists) {
      if (a == queryLower) score += 85;
    }

    // Starts with bonus
    if (title.startsWith(queryLower)) score += 50;
    if (rawArtist.startsWith(queryLower)) score += 40;
    if (album.startsWith(queryLower)) score += 30;

    // Check if any individual artist starts with query
    for (final a in artists) {
      if (a.startsWith(queryLower)) score += 45;
    }

    // Contains bonus
    if (title.contains(queryLower)) score += 30;
    if (artist.contains(queryLower)) score += 25;
    if (album.contains(queryLower)) score += 20;

    // Word match bonus (matches whole words)
    for (final queryWord in queryWords) {
      for (final titleWord in entry.titleWords) {
        if (titleWord == queryWord) {
          score += 15;
        } else if (titleWord.startsWith(queryWord)) {
          score += 10;
        }
      }
      for (final artistWord in entry.artistWords) {
        if (artistWord == queryWord) {
          score += 12;
        } else if (artistWord.startsWith(queryWord)) {
          score += 8;
        }
      }
    }

    // Fuzzy match using Levenshtein distance
    final titleDistance = _levenshteinDistance(title, queryLower);
    final artistDistance = _levenshteinDistance(artist, queryLower);

    // Normalize distance (smaller is better, convert to score where higher is better)
    final maxLength =
        title.length > queryLower.length ? title.length : queryLower.length;
    if (maxLength > 0 && titleDistance < maxLength / 2) {
      score += (1 - titleDistance / maxLength) * 25;
    }

    final maxArtistLength =
        artist.length > queryLower.length ? artist.length : queryLower.length;
    if (maxArtistLength > 0 && artistDistance < maxArtistLength / 2) {
      score += (1 - artistDistance / maxArtistLength) * 20;
    }

    return score;
  }

  /// Search songs with intelligent fuzzy matching
  static List<SongModel> searchSongs(
    List<SongModel> songs,
    String query, {
    int limit = 50,
    double minScore = 10.0,
  }) {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final queryWords = queryLower.split(' ');

    // Calculate scores for all songs
    final scoredSongs = songs
        .map((song) {
          final score = _calculateScore(song, queryLower, queryWords);
          return MapEntry(song, score);
        })
        .where((entry) => entry.value >= minScore)
        .toList();

    // Sort by score (descending)
    scoredSongs.sort((a, b) => b.value.compareTo(a.value));

    // Return top results
    return scoredSongs.take(limit).map((entry) => entry.key).toList();
  }

  /// Search artists (using ArtistModel from on_audio_query)
  /// Note: For separated artist search, use searchSeparatedArtists instead
  static List<ArtistModel> searchArtists(
    List<ArtistModel> artists,
    String query, {
    int limit = 30,
  }) {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    return artists
        .where((artist) {
          final name = artist.artist.toLowerCase();
          return name.contains(queryLower) || name.startsWith(queryLower);
        })
        .take(limit)
        .toList();
  }

  /// Search separated artists with proper individual artist matching
  static List<SeparatedArtist> searchSeparatedArtists(
    List<SeparatedArtist> artists,
    String query, {
    int limit = 30,
  }) {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    final results = artists.where((artist) {
      final name = artist.name.toLowerCase();
      return name.contains(queryLower);
    }).toList();

    // Sort by relevance (starts with > contains, then by track count)
    results.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final aStartsWith = aName.startsWith(queryLower);
      final bStartsWith = bName.startsWith(queryLower);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;

      // If same relevance, sort by track count (more tracks first)
      return b.numberOfTracks.compareTo(a.numberOfTracks);
    });

    return results.take(limit).toList();
  }

  /// Search albums
  static List<AlbumModel> searchAlbums(
    List<AlbumModel> albums,
    String query, {
    int limit = 30,
  }) {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    return albums
        .where((album) {
          final name = album.album.toLowerCase();
          final artist = (album.artist ?? '').toLowerCase();
          return name.contains(queryLower) || artist.contains(queryLower);
        })
        .take(limit)
        .toList();
  }
}

class _SearchEntry {
  _SearchEntry(SongModel song)
      : title = song.title,
        rawArtist = song.artist,
        album = song.album,
        titleLower = song.title.toLowerCase(),
        rawArtistLower = (song.artist ?? '').toLowerCase(),
        albumLower = (song.album ?? '').toLowerCase(),
        artists = splitArtists(song.artist ?? '')
            .map((a) => a.toLowerCase())
            .toList(growable: false) {
    artistJoined = artists.join(' ');
    titleWords = titleLower.split(' ');
    artistWords = artistJoined.split(' ');
  }

  // Original values, to detect when a song's tags changed.
  final String title;
  final String? rawArtist;
  final String? album;

  final String titleLower;
  final String rawArtistLower;
  final String albumLower;
  final List<String> artists;
  late final String artistJoined;
  late final List<String> titleWords;
  late final List<String> artistWords;
}
