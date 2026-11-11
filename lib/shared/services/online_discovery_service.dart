import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'online_sources.dart';
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

  /// The user's own songs by an artist, set at startup. They tell apart
  /// same-named artists, since the person owning these tracks is the right one.
  List<OnlineTrack> Function(String artist) localTracks = (_) => const [];

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
    // Switched off remotely (see OnlineSources): fail at once, without retrying.
    if (!OnlineSources.isUriEnabled(uri)) return (false, null);
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
      // Deezer has many artists sharing a name; the most followed is the real one
      // unless the user's own songs say otherwise.
      final candidates = <OnlineArtist>[];
      // Brackets are part of the identity ("DJ [IVY]" is not "Dj Ivy"), so
      // names containing them must match exactly, ignoring case and spacing.
      final exact = RegExp(r'[\[\]{}()<>]').hasMatch(name);
      String strict(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final artist = _artistFrom(item);
        if (artist == null || _norm(artist.name) != key) continue;
        if (exact && strict(artist.name) != strict(name)) continue;
        candidates.add(artist);
      }
      candidates.sort((a, b) => (b.fans ?? 0).compareTo(a.fans ?? 0));
      final local = localTracks(name);
      if (local.isEmpty) return candidates.firstOrNull;
      for (final c in candidates.take(6)) {
        if (await _ownsAny(c, local)) return c;
      }
      // No namesake owns the user's songs: better no match than the wrong person.
      return null;
    }, (v) => v != null);
  }

  static bool _sameTitle(String a, String b) {
    final x = _norm(a), y = _norm(b);
    if (x.isEmpty || y.isEmpty) return false;
    return x == y ||
        (x.length >= 5 && y.length >= 5 && (x.contains(y) || y.contains(x)));
  }

  /// Whether Deezer credits [artist] with any of [local]: in their top tracks,
  /// or by a direct track search for the first few.
  Future<bool> _ownsAny(OnlineArtist artist, List<OnlineTrack> local) async {
    final top =
        await _getJson(Uri.parse('$_deezer/artist/${artist.id}/top?limit=50'));
    final topList = (top is Map ? top['data'] : null) as List? ?? const [];
    for (final t in topList) {
      if (t is! Map) continue;
      final album = t['album'];
      final albumTitle = album is Map ? album['title'] : null;
      for (final l in local) {
        if (_sameTitle('${t['title']}', l.title)) return true;
        if (l.albumTitle != null &&
            albumTitle is String &&
            _norm(l.albumTitle!).length >= 5 &&
            _norm(albumTitle) == _norm(l.albumTitle!)) {
          return true;
        }
      }
    }
    for (final l in local.take(3)) {
      final res = await _getJson(
          Uri.parse('$_deezer/search/track').replace(queryParameters: {
        'q': 'artist:"${artist.name.replaceAll('"', '')}" '
            'track:"${l.title.replaceAll('"', '')}"',
        'limit': '5',
      }));
      final found = (res is Map ? res['data'] : null) as List? ?? const [];
      for (final f in found) {
        final a = f is Map ? f['artist'] : null;
        if (a is Map &&
            a['id'] == artist.id &&
            _sameTitle('${f['title']}', l.title)) {
          return true;
        }
      }
    }
    return false;
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
      final tracks = [...localTracks(name), ...await topTracks(name)];
      final hints = [
        for (final t in tracks)
          for (final h in [t.title, t.albumTitle])
            if (h != null && _norm(h).length >= 5) _norm(h),
      ];
      // Both routes are verified against the artist's own tracks; keep the fullest.
      final results = await Future.wait([
        _wikipedia(name, hints),
        _musicBrainzArtist(name, tracks).then((mb) async {
          final wikidata = await _wikidata(mb, name);
          return (mb, wikidata);
        }),
        _audioDbBio(name, tracks),
        _lastFmBio(name, tracks),
      ]);
      final wiki = results[0] as (String, String)?;
      final (mb, wikidata) = results[1] as (
        Map?,
        ({String? description, (String, String)? summary})?
      );
      final audioDb = results[2] as String?;
      final lastFm = results[3] as String?;
      final other = wikidata?.summary;
      (String, String)? best = wiki;
      if (other != null && (best == null || other.$1.length > best.$1.length)) {
        best = other;
      }
      // These have no page to link to, so they only supply the text.
      var text = best?.$1;
      for (final c in [audioDb, lastFm]) {
        if (c != null && (text == null || c.length > text.length)) {
          text = c;
        }
      }
      if (text != null && text != best?.$1) {
        return OnlineArtistProfile(
            artist: artist, bio: text, wikiUrl: best?.$2);
      }
      return OnlineArtistProfile(
        artist: artist,
        bio: best?.$1 ?? _fallbackBio(name, mb, wikidata?.description),
        wikiUrl: best?.$2,
      );
    }, (v) => v != null && v.bio != null);
  }

  static const _lastFmKey = String.fromEnvironment('LASTFM_API_KEY');

  /// English bio from Last.fm, only when one of the artist's own tracks is
  /// among that Last.fm artist's top tracks. Needs LASTFM_API_KEY.
  Future<String?> _lastFmBio(String name, List<OnlineTrack> tracks) async {
    if (_lastFmKey.isEmpty) return null;
    Future<dynamic> call(String method,
            [Map<String, String> extra = const {}]) =>
        _getJson(Uri.parse('https://ws.audioscrobbler.com/2.0/').replace(
          queryParameters: {
            'method': method,
            'artist': name,
            'autocorrect': '0',
            'api_key': _lastFmKey,
            'format': 'json',
            ...extra,
          },
        ));
    final info = await call('artist.getinfo', {'lang': 'en'});
    final artist = info is Map ? info['artist'] : null;
    final bio = artist is Map ? artist['bio'] : null;
    final raw = bio is Map ? bio['content'] as String? : null;
    if (artist is! Map || _norm('${artist['name']}') != _norm(name)) {
      return null;
    }
    final text = raw
        ?.replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'Read more on Last\.fm.*', dotAll: true), '')
        .trim();
    if (text == null || text.isEmpty || _isAmbiguous(text)) return null;
    if (tracks.isNotEmpty) {
      final top = await call('artist.gettoptracks', {'limit': '50'});
      final list = top is Map && top['toptracks'] is Map
          ? (top['toptracks'] as Map)['track'] as List?
          : null;
      final names = {
        for (final t in list ?? const [])
          if (t is Map) _norm('${t['name']}'),
      };
      if (!tracks.any((t) => names.contains(_norm(t.title)))) return null;
    }
    return '$text\n\nSource: Last.fm (CC BY-SA)';
  }

  DateTime _nextMusicBrainz = DateTime.fromMillisecondsSinceEpoch(0);

  /// English biography from TheAudioDB, only when one of the artist's own
  /// tracks resolves to the same TheAudioDB artist id (keeps namesakes apart).
  Future<String?> _audioDbBio(String name, List<OnlineTrack> tracks) async {
    const base = 'https://www.theaudiodb.com/api/v1/json/123';
    final key = _norm(name);
    final data = await _getJson(
        Uri.parse('$base/search.php').replace(queryParameters: {'s': name}));
    final list = data is Map ? data['artists'] as List? : null;
    for (final a in list ?? const []) {
      if (a is! Map || _norm('${a['strArtist']}') != key) continue;
      final bio = (a['strBiography'] as String?)?.trim();
      if (bio == null || bio.isEmpty || _isAmbiguous(bio)) continue;
      if (tracks.isEmpty) return bio;
      for (final t in tracks.take(3)) {
        final res = await _getJson(Uri.parse('$base/searchtrack.php')
            .replace(queryParameters: {'s': name, 't': t.title}));
        final found = res is Map ? res['track'] as List? : null;
        if (found != null &&
            found.any((f) => f is Map && f['idArtist'] == a['idArtist'])) {
          return bio;
        }
      }
    }
    return null;
  }

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

  /// The Wikidata entry MusicBrainz links the artist to: its short description,
  /// plus the summary of its English Wikipedia article.
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
    final enLink = links is Map ? links['enwiki'] : null;
    final enTitle = enLink is Map ? enLink['title'] : null;
    (String, String)? longest;
    if (enTitle is String) {
      final slug = Uri.encodeComponent(enTitle.replaceAll(' ', '_'));
      final summary = await _getJson(
          Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$slug'));
      final extract = summary is Map ? summary['extract'] : null;
      // A sitelink can be a redirect to something else (e.g. the artist's label).
      if (summary is Map &&
          summary['type'] != 'disambiguation' &&
          extract is String &&
          extract.isNotEmpty &&
          !_isAmbiguous(extract) &&
          _norm('${summary['title']} $extract').contains(key)) {
        final urls = summary['content_urls'];
        final mobile = urls is Map ? urls['mobile'] : null;
        final url = (mobile is Map ? mobile['page'] as String? : null) ??
            'https://en.wikipedia.org/wiki/$slug';
        longest = (await _fullIntro(enTitle, extract), url);
      }
    }
    return (description: description, summary: longest);
  }

  /// The whole lead section (several paragraphs) as plain text, falling back
  /// to the one-paragraph [summary] when it is not longer.
  Future<String> _fullIntro(String title, String summary) async {
    final data =
        await _getJson(Uri.parse('https://en.wikipedia.org/w/api.php').replace(
      queryParameters: {
        'action': 'query',
        'prop': 'extracts',
        'exintro': '1',
        'explaintext': '1',
        'redirects': '1',
        'titles': title,
        'format': 'json',
      },
    ));
    final query = data is Map ? data['query'] : null;
    final pages = query is Map ? query['pages'] : null;
    final page = pages is Map && pages.isNotEmpty ? pages.values.first : null;
    final text = page is Map ? page['extract'] : null;
    if (text is! String || text.trim().length <= summary.length) return summary;
    var full = text.trim();
    if (full.length > 1800) {
      final cut = full.lastIndexOf('\n', 1800);
      full = full.substring(0, cut > 400 ? cut : 1800).trim();
    }
    return full;
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

  static final _ambiguous = RegExp(
      r'(may|can|could) (also )?refer to|there (are|is) (at least |several |many |more than |over )?(\w+ )?(artists|people|musicians|bands|groups|persons|rappers|singers|songs|albums)|disambiguation',
      caseSensitive: false);

  /// Pages that list several things sharing the name, not one artist.
  static bool _isAmbiguous(String text) {
    final head = text.length > 300 ? text.substring(0, 300) : text;
    return _ambiguous.hasMatch(head) ||
        head.split('\n').first.trimRight().endsWith(':');
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
    if (extract is! String || extract.isEmpty || _isAmbiguous(extract)) {
      return null;
    }
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
    return (await _fullIntro(title, extract), url);
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
