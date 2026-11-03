/// Online lyrics providers used after LRCLIB comes up empty.
///
/// Every provider turns a [LyricsQuery] into plain LRC text (`[mm:ss.xx]line`)
/// so the rest of the lyrics pipeline does not care where lyrics came from.
/// The set of services and the data each one receives is listed in the
/// onboarding "Internet usage" page; users can switch each one off in
/// Settings > Playback > Lyrics sources.
library;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'better_lyrics_provider.dart';
import 'kugou_provider.dart';
import 'youlyplus_provider.dart';

/// What providers are told about the song being looked up.
class LyricsQuery {
  const LyricsQuery({
    required this.title,
    required this.artist,
    this.album,
    this.durationSeconds,
  });

  final String title;
  final String artist;
  final String? album;
  final int? durationSeconds;
}

abstract class LyricsProvider {
  const LyricsProvider();

  /// Stable id, used for the preference key.
  String get id;

  /// Name shown in settings.
  String get name;

  /// Returns synced lyrics as LRC text, or null when there are none.
  Future<String?> fetchLrc(LyricsQuery query, http.Client client);
}

class LyricsProviders {
  LyricsProviders._();

  /// In priority order.
  static const List<LyricsProvider> all = [
    BetterLyricsProvider(),
    YouLyPlusProvider(),
    KuGouProvider(),
  ];

  static String _key(String id) => 'lyrics_provider_$id';

  static Future<bool> isEnabled(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(id)) ?? true;
  }

  static Future<void> setEnabled(String id, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(id), enabled);
  }

  static Future<List<LyricsProvider>> enabled() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      for (final p in all)
        if (prefs.getBool(_key(p.id)) ?? true) p,
    ];
  }
}

/// Drops inline markup some services add (`<00:01.20>` word timings,
/// `{agent:v1}` / `{bg}` markers) so only the sung text remains.
String sanitizeLrc(String lrc) => lrc
    .replaceAll(RegExp(r'<\d{1,2}:\d{2}(?:[.:]\d{1,3})?>'), '')
    .replaceAll(RegExp(r'\{(?:agent:[^}]*|bg)\}'), '');

/// Formats a millisecond offset as an LRC tag, e.g. `[01:02.35]`.
String lrcTag(int ms) {
  final clamped = ms < 0 ? 0 : ms;
  final minutes = clamped ~/ 60000;
  final seconds = (clamped % 60000) ~/ 1000;
  final centis = (clamped % 1000) ~/ 10;
  String two(int n) => n.toString().padLeft(2, '0');
  return '[${two(minutes)}:${two(seconds)}.${two(centis)}]';
}

enum _Script {
  latin,
  cyrillic,
  greek,
  han,
  kana,
  hangul,
  arabic,
  hebrew,
  devanagari,
  thai
}

_Script? _scriptOf(int r) {
  if ((r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A)) {
    return _Script.latin;
  }
  if (r >= 0xC0 && r <= 0x24F) return _Script.latin;
  if (r >= 0x400 && r <= 0x52F) return _Script.cyrillic;
  if (r >= 0x370 && r <= 0x3FF) return _Script.greek;
  if ((r >= 0x4E00 && r <= 0x9FFF) || (r >= 0x3400 && r <= 0x4DBF)) {
    return _Script.han;
  }
  if (r >= 0x3040 && r <= 0x30FF) return _Script.kana;
  if ((r >= 0xAC00 && r <= 0xD7AF) || (r >= 0x1100 && r <= 0x11FF)) {
    return _Script.hangul;
  }
  if (r >= 0x600 && r <= 0x6FF) return _Script.arabic;
  if (r >= 0x590 && r <= 0x5FF) return _Script.hebrew;
  if (r >= 0x900 && r <= 0x97F) return _Script.devanagari;
  if (r >= 0xE00 && r <= 0xE7F) return _Script.thai;
  return null;
}

Map<_Script, int> _scriptCounts(String text) {
  final counts = <_Script, int>{};
  for (final r in text.runes) {
    final s = _scriptOf(r);
    if (s != null) counts[s] = (counts[s] ?? 0) + 1;
  }
  return counts;
}

/// Whether [lrc] is written in the same script(s) as the song's own tags.
///
/// Secondary providers (KuGou in particular) often return Chinese lyrics or
/// bilingual lines for songs in other languages. Latin text is always
/// allowed; any other script must also appear in the song's title/artist/album,
/// and Han/Kana/Hangul count as one family since Japanese and Korean use Han.
bool lyricsMatchSongLanguage(String lrc, LyricsQuery query) {
  final body = lrc.replaceAll(RegExp(r'\[[^\]]*\]'), '');
  final lyricCounts = _scriptCounts(body);
  final total = lyricCounts.values.fold<int>(0, (a, b) => a + b);
  if (total == 0) return true;

  final tagCounts =
      _scriptCounts('${query.title} ${query.artist} ${query.album ?? ''}');
  final allowed = <_Script>{_Script.latin, ...tagCounts.keys};
  const eastAsian = {_Script.han, _Script.kana, _Script.hangul};
  if (allowed.any(eastAsian.contains)) {
    // Kana/Hangul in the tags imply Han in the lyrics, and Han implies Kana.
    if (allowed.contains(_Script.kana) || allowed.contains(_Script.hangul)) {
      allowed.add(_Script.han);
    }
    if (allowed.contains(_Script.han)) allowed.add(_Script.kana);
  }

  var foreign = 0;
  lyricCounts.forEach((script, count) {
    if (!allowed.contains(script)) foreign += count;
  });
  return foreign / total <= 0.15;
}

String _normTitle(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[\(\[（【].*?[\)\]）】]'), '')
    .replaceAll(RegExp(r'\s[-–]\s.*$'), '')
    .replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');

List<String> _artistParts(String s) => s
    .toLowerCase()
    .split(RegExp(r'[,;&、/＆]|\bfeat\.?\b|\bft\.?\b|\bwith\b|\band\b|\bx\b'))
    .map((p) => p.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ''))
    .where((p) => p.isNotEmpty)
    .toList();

/// Whether a provider's result ([gotTitle]/[gotArtist]) is the song we asked
/// for, so a service's loose "closest hit" never supplies another song's lyrics.
bool tracksMatch(
  String wantTitle,
  String wantArtist,
  String gotTitle,
  String gotArtist,
) {
  final wt = _normTitle(wantTitle);
  final gt = _normTitle(gotTitle);
  if (wt.isEmpty || gt.isEmpty) return false;
  final shorter = wt.length < gt.length ? wt : gt;
  final longer = wt.length < gt.length ? gt : wt;
  final titleOk = wt == gt ||
      (shorter.length >= 4 &&
          longer.contains(shorter) &&
          shorter.length / longer.length >= 0.85);
  if (!titleOk) return false;

  final want = _artistParts(wantArtist);
  final got = _artistParts(gotArtist);
  if (want.isEmpty || got.isEmpty) return true;
  return want.any((w) => got.any((g) =>
      w == g ||
      (w.length >= 3 && g.length >= 3 && (w.contains(g) || g.contains(w)))));
}
