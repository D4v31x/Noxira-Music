import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OnlineArtist {
  const OnlineArtist({
    required this.id,
    required this.name,
    this.pictureUrl,
    this.fans,
    this.link,
  });

  final int id;
  final String name;
  final String? pictureUrl;
  final int? fans;
  final String? link;
}

class OnlineArtistProfile {
  const OnlineArtistProfile({
    required this.artist,
    this.bio,
    this.wikiUrl,
    this.albumCount,
  });

  final OnlineArtist artist;
  final String? bio;
  final String? wikiUrl;
  final int? albumCount;
}

class OnlineTrack {
  const OnlineTrack({
    required this.title,
    this.albumTitle,
    this.coverUrl,
    this.link,
    this.durationSeconds,
  });

  final String title;
  final String? albumTitle;
  final String? coverUrl;
  final String? link;
  final int? durationSeconds;
}

/// Artist info and "fans also like" suggestions from the public Deezer and
/// Wikipedia APIs. Nothing is sent but the artist name being looked up.
class OnlineDiscoveryService {
  OnlineDiscoveryService._();
  static final OnlineDiscoveryService instance = OnlineDiscoveryService._();

  static const _prefKey = 'online_suggestions_enabled';
  static const _deezer = 'https://api.deezer.com';
  static const _headers = {
    'Accept-Language': 'en-US,en;q=0.9',
    'User-Agent': 'AuroraMusic/1.5',
  };
  static const _timeout = Duration(seconds: 8);

  /// Whether online lookups are allowed; toggled in Settings.
  final ValueNotifier<bool> enabled = ValueNotifier<bool>(true);
  bool _loaded = false;

  final Map<String, Future<OnlineArtist?>> _artistCache = {};
  final Map<String, Future<OnlineArtistProfile?>> _profileCache = {};
  final Map<int, Future<List<OnlineArtist>>> _relatedCache = {};
  final Map<int, Future<List<OnlineTrack>>> _topCache = {};

  /// Caches [load]'s future but forgets empty results, so a failed request
  /// (offline, timeout) is retried next time instead of sticking for the session.
  Future<T> _cached<K, T>(
    Map<K, Future<T>> cache,
    K key,
    Future<T> Function() load,
    bool Function(T) usable,
  ) {
    final future = cache.putIfAbsent(key, load);
    future.then((v) {
      if (!usable(v)) cache.remove(key);
    });
    return future;
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    enabled.value = prefs.getBool(_prefKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    enabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  /// GET + decode JSON; retries once on a transient failure. [ok] is false when
  /// the request failed, as opposed to a definitive "not found".
  Future<(bool ok, dynamic data)> _fetch(Uri uri) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final r = await http.get(uri, headers: _headers).timeout(_timeout);
        if (r.statusCode == 200) {
          return (true, json.decode(utf8.decode(r.bodyBytes)));
        }
        if (r.statusCode != 429 && r.statusCode < 500) return (true, null);
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
    return (false, null);
  }

  Future<dynamic> _getJson(Uri uri) async => (await _fetch(uri)).$2;

  OnlineArtist? _artistFrom(Map<String, dynamic> m) {
    final id = m['id'];
    final name = m['name'];
    if (id is! int || name is! String) return null;
    return OnlineArtist(
      id: id,
      name: name,
      pictureUrl: (m['picture_big'] ?? m['picture_medium']) as String?,
      fans: m['nb_fan'] as int?,
      link: m['link'] as String?,
    );
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Best Deezer match for [name], only accepted when the names agree.
  Future<OnlineArtist?> findArtist(String name) {
    final key = _norm(name);
    if (key.isEmpty) return Future.value();
    return _cached(_artistCache, key, () async {
      final data = await _getJson(Uri.parse('$_deezer/search/artist')
          .replace(queryParameters: {'q': name, 'limit': '15'}));
      final list = (data is Map ? data['data'] : null) as List?;
      if (list == null) return null;
      // Deezer has many artists sharing a name; the most followed is the real one.
      OnlineArtist? best;
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final artist = _artistFrom(item);
        if (artist == null || _norm(artist.name) != key) continue;
        if (best == null || (artist.fans ?? 0) > (best.fans ?? 0)) {
          best = artist;
        }
      }
      return best;
    }, (v) => v != null);
  }

  Future<List<OnlineArtist>> relatedArtists(String name) async {
    final artist = await findArtist(name);
    if (artist == null) return const [];
    return _cached(_relatedCache, artist.id, () async {
      final data = await _getJson(
          Uri.parse('$_deezer/artist/${artist.id}/related?limit=14'));
      final list = (data is Map ? data['data'] : null) as List?;
      if (list == null) return const <OnlineArtist>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(_artistFrom)
          .whereType<OnlineArtist>()
          .toList();
    }, (v) => v.isNotEmpty);
  }

  Future<List<OnlineTrack>> topTracks(String name) async {
    final artist = await findArtist(name);
    if (artist == null) return const [];
    return _cached(_topCache, artist.id, () async {
      final data =
          await _getJson(Uri.parse('$_deezer/artist/${artist.id}/top?limit=5'));
      final list = (data is Map ? data['data'] : null) as List?;
      if (list == null) return const <OnlineTrack>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map((t) {
            final album = t['album'] as Map<String, dynamic>?;
            return OnlineTrack(
              title: (t['title'] as String?) ?? '',
              albumTitle: album?['title'] as String?,
              coverUrl: album?['cover_medium'] as String?,
              link: t['link'] as String?,
              durationSeconds: t['duration'] as int?,
            );
          })
          .where((t) => t.title.isNotEmpty)
          .toList();
    }, (v) => v.isNotEmpty);
  }

  Future<OnlineArtistProfile?> profile(String name) {
    final key = _norm(name);
    if (key.isEmpty) return Future.value();
    return _cached(_profileCache, key, () async {
      final artist = await findArtist(name);
      if (artist == null) return null;
      final tracks = await topTracks(name);
      final hints = [
        for (final t in tracks)
          for (final h in [t.title, t.albumTitle])
            if (h != null && _norm(h).length >= 5) _norm(h),
      ];
      final wiki = await _wikipedia(name, hints);
      if (wiki != null) {
        return OnlineArtistProfile(
            artist: artist, bio: wiki.$1, wikiUrl: wiki.$2);
      }
      // No English article under a guessable title: follow MusicBrainz, which
      // is matched through the artist's own tracks, to Wikidata and its articles.
      final mb = await _musicBrainzArtist(name, tracks);
      final wikidata = await _wikidata(mb, name);
      final other = wikidata?.summary;
      return OnlineArtistProfile(
        artist: artist,
        bio: other?.$1 ?? _fallbackBio(name, mb, wikidata?.description),
        wikiUrl: other?.$2,
      );
    }, (v) => v != null && v.bio != null);
  }

  DateTime _nextMusicBrainz = DateTime.fromMillisecondsSinceEpoch(0);

  /// MusicBrainz allows about one request per second.
  Future<dynamic> _musicBrainz(String path, Map<String, String> query) async {
    final now = DateTime.now();
    final slot = _nextMusicBrainz.isAfter(now) ? _nextMusicBrainz : now;
    _nextMusicBrainz = slot.add(const Duration(milliseconds: 1100));
    final wait = slot.difference(now);
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    return _getJson(Uri.parse('https://musicbrainz.org/ws/2/$path')
        .replace(queryParameters: {...query, 'fmt': 'json'}));
  }

  /// The MusicBrainz artist, only when one of the artist's own tracks (from
  /// Deezer) is credited to an artist of that name there. This keeps
  /// same-named artists apart.
  Future<Map?> _musicBrainzArtist(String name, List<OnlineTrack> tracks) async {
    final key = _norm(name);
    final quotedName = name.replaceAll('"', '');
    for (final t in tracks.take(3)) {
      final trackKey = _norm(t.title);
      if (trackKey.isEmpty) continue;
      final data = await _musicBrainz('recording', {
        'query':
            'recording:"${t.title.replaceAll('"', '')}" AND artist:"$quotedName"',
        'limit': '5',
      });
      final recordings = data is Map ? data['recordings'] as List? : null;
      for (final r in recordings ?? const []) {
        if (r is! Map) continue;
        final title = _norm('${r['title']}');
        if (!title.contains(trackKey) && !trackKey.contains(title)) continue;
        for (final credit in (r['artist-credit'] as List?) ?? const []) {
          final a = credit is Map ? credit['artist'] : null;
          if (a is! Map || a['id'] is! String) continue;
          if (_norm('${a['name']}') != key) continue;
          final detail =
              await _musicBrainz('artist/${a['id']}', {'inc': 'url-rels+tags'});
          if (detail is Map) return detail;
        }
      }
    }
    return null;
  }

  static const _wikiLangs = ['en', 'cs', 'de', 'fr', 'es', 'ru', 'nl', 'it'];

  /// The Wikidata entry MusicBrainz links the artist to: its short description,
  /// plus the summary of its Wikipedia article in any language.
  Future<({String? description, (String, String)? summary})?> _wikidata(
      Map? musicBrainz, String name) async {
    final key = _norm(name);
    String? id;
    for (final rel in (musicBrainz?['relations'] as List?) ?? const []) {
      if (rel is! Map || rel['type'] != 'wikidata') continue;
      final url = rel['url'];
      final resource = url is Map ? url['resource'] : null;
      id = resource is String ? RegExp(r'Q\d+$').stringMatch(resource) : null;
      if (id != null) break;
    }
    if (id == null) return null;

    final entity =
        await _getJson(Uri.parse('https://www.wikidata.org/w/api.php').replace(
      queryParameters: {
        'action': 'wbgetentities',
        'ids': id,
        'props': 'sitelinks|descriptions',
        'languages': 'en',
        'format': 'json',
        'origin': '*',
      },
    ));
    final entities = entity is Map ? entity['entities'] : null;
    final item = entities is Map ? entities[id] : null;
    if (item is! Map) return null;
    final descriptions = item['descriptions'];
    final en = descriptions is Map ? descriptions['en'] : null;
    final description = en is Map ? en['value'] as String? : null;
    final links = item['sitelinks'];
    final candidates = <(String, String)>[];
    if (links is Map) {
      for (final e in links.entries) {
        final m = RegExp(r'^([a-z]{2,3})wiki$').firstMatch('${e.key}');
        final title = e.value is Map ? (e.value as Map)['title'] : null;
        if (m != null && title is String) candidates.add((m.group(1)!, title));
      }
    }
    int rank((String, String) c) {
      final i = _wikiLangs.indexOf(c.$1);
      return i < 0 ? _wikiLangs.length : i;
    }

    candidates.sort((a, b) => rank(a).compareTo(rank(b)));
    for (final (lang, title) in candidates.take(3)) {
      final slug = Uri.encodeComponent(title.replaceAll(' ', '_'));
      final summary = await _getJson(Uri.parse(
          'https://$lang.wikipedia.org/api/rest_v1/page/summary/$slug'));
      if (summary is! Map || summary['type'] == 'disambiguation') continue;
      final extract = summary['extract'];
      if (extract is! String || extract.isEmpty) continue;
      // A sitelink can be a redirect to something else (e.g. the artist's label).
      if (!_norm('${summary['title']} $extract').contains(key)) continue;
      final urls = summary['content_urls'];
      final mobile = urls is Map ? urls['mobile'] : null;
      final url = (mobile is Map ? mobile['page'] as String? : null) ??
          'https://$lang.wikipedia.org/wiki/$slug';
      return (description: description, summary: (extract, url));
    }
    return (description: description, summary: null);
  }

  /// Short factual blurb for artists without a Wikipedia article, from the
  /// verified MusicBrainz entry and the Wikidata [description]. Null when
  /// nothing could be verified, rather than guessing.
  String? _fallbackBio(String name, Map? mb, String? description) {
    if (mb == null) return null;
    final area = mb['area'];
    final country = area is Map ? area['name'] as String? : null;
    final disambiguation = mb['disambiguation'] as String?;
    final isGroup = mb['type'] == 'Group';
    final span = mb['life-span'];
    final begin = span is Map ? span['begin'] as String? : null;
    // For a person the start date is their birth, not when they began their career.
    final year = isGroup && begin != null && begin.length >= 4
        ? begin.substring(0, 4)
        : null;

    final what = description ??
        (disambiguation != null && disambiguation.isNotEmpty
            ? disambiguation
            : (country != null
                ? '$country ${isGroup ? 'group' : 'artist'}'
                : null));
    final tags = [...?(mb['tags'] as List?)].whereType<Map>().toList()
      ..sort((a, b) =>
          ((b['count'] as num?) ?? 0).compareTo((a['count'] as num?) ?? 0));
    final genres = [for (final t in tags.take(3)) '${t['name']}'];

    final parts = <String>[];
    if (what != null) {
      final an =
          RegExp(r'^(?!uni|use|eur|one|uk\b)[aeiou]', caseSensitive: false);
      parts.add('$name is a${an.hasMatch(what) ? 'n' : ''} $what'
          '${year != null ? ', active since $year' : ''}.');
    }
    if (genres.isNotEmpty) parts.add('Genres: ${genres.join(', ')}.');
    return parts.isEmpty ? null : parts.join(' ');
  }

  static final _musicWords = RegExp(
      r'\b(band|singer|rapper|musician|duo|group|songwriter|composer|producer|DJ|vocalist|guitarist|pianist|drummer|bassist|violinist|cellist|instrumentalist|orchestra|ensemble|choir|trio|artist)\b',
      caseSensitive: false);

  /// Whether the article's text mentions one of [hints] (the artist's known
  /// track or album titles), which separates same-named artists. A failed
  /// request counts as a pass, since the page could not be disproved.
  Future<bool> _mentionsAny(String title, List<String> hints) async {
    final (ok, data) =
        await _fetch(Uri.parse('https://en.wikipedia.org/w/api.php').replace(
      queryParameters: {
        'action': 'query',
        'prop': 'extracts',
        'explaintext': '1',
        'redirects': '1',
        'titles': title,
        'format': 'json',
      },
    ));
    if (!ok) return true;
    final query = data is Map ? data['query'] : null;
    final pages = query is Map ? query['pages'] : null;
    if (pages is! Map || pages.isEmpty) return false;
    final page = pages.values.first;
    final text = page is Map ? page['extract'] : null;
    if (text is! String) return false;
    final haystack = _norm(text);
    return hints.any((h) => haystack.contains(h));
  }

  Future<(String, String)?> _wikiSummary(
      String title, String name, List<String> hints) async {
    final slug = Uri.encodeComponent(title.replaceAll(' ', '_'));
    final summary = await _getJson(
        Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$slug'));
    if (summary is! Map || summary['type'] == 'disambiguation') return null;
    // A redirect can land on a song or album page; only accept the artist's own page.
    final pageTitle = summary['title'];
    if (pageTitle is! String || !_norm(pageTitle).contains(_norm(name))) {
      return null;
    }
    final extract = summary['extract'];
    if (extract is! String || extract.isEmpty) return null;
    final description = summary['description'];
    // The short description says what the page is about; a surname list or an
    // album page may still mention musicians in its text.
    final about =
        description is String && description.isNotEmpty ? description : extract;
    if (!_musicWords.hasMatch(about)) return null;
    // A title qualified as a musician is already specific; others need a track match.
    final specific = RegExp(
            r'\((band|musician|singer|rapper|DJ|record producer|duo|group|singer-songwriter|producer|composer)\)$',
            caseSensitive: false)
        .hasMatch(title);
    if (!specific && hints.isNotEmpty && !await _mentionsAny(title, hints)) {
      return null;
    }
    final urls = summary['content_urls'];
    final mobile = urls is Map ? urls['mobile'] : null;
    final url = (mobile is Map ? mobile['page'] as String? : null) ??
        'https://en.wikipedia.org/wiki/$slug';
    return (extract, url);
  }

  /// (extract, page url) of the Wikipedia article about the artist [name].
  Future<(String, String)?> _wikipedia(String name, List<String> hints) async {
    final first = await _wikiSummary(name, name, hints);
    if (first != null) return first;
    final guesses = await Future.wait([
      for (final title in [
        '$name (band)',
        '$name (musician)',
        '$name (singer)',
        '$name (rapper)',
        '$name (DJ)',
        '$name (record producer)',
        '$name (duo)',
        '$name (group)',
      ])
        _wikiSummary(title, name, hints),
    ]);
    // Results are in priority order; the first verified one wins.
    for (final hit in guesses) {
      if (hit != null) return hit;
    }
    final search =
        await _getJson(Uri.parse('https://en.wikipedia.org/w/api.php').replace(
      queryParameters: {
        'action': 'query',
        'list': 'search',
        'srsearch': name,
        'srlimit': '5',
        'format': 'json',
      },
    ));
    final query = search is Map ? search['query'] : null;
    final hits = query is Map ? query['search'] as List? : null;
    if (hits == null) return null;
    final key = _norm(name);
    for (final h in hits) {
      final title = h is Map ? h['title'] as String? : null;
      if (title == null || !_norm(title).contains(key)) continue;
      final hit = await _wikiSummary(title, name, hints);
      if (hit != null) return hit;
    }
    return null;
  }
}
