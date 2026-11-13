/// Listening insights: what you have been listening to and what stands out.
///
/// Laid out like a poster rather than a dashboard. The #1 track's cover opens
/// the screen full-bleed with the listening time right under it; the day is a
/// record you can drag across; the week is a row of columns in the same flat
/// style; tracks 2 to 5 are a row of covers; the top artists are a festival
/// bill. Sections sit on the page itself, separated by space.
///
/// Data sources:
///   • SmartSuggestionsService  — play counts, hourly/weekday patterns, genres
///   • AudioPlayerService.songs — song metadata for resolving track IDs
///   • ArtworkCacheService      — cover art for the top tracks
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import '../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/font_constants.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/smart_suggestions_service.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/expanding_player.dart';

const _tabular = [FontFeature.tabularFigures()];
const _gutter = 20.0;

/// The localized labels carry a line break for an older stacked layout.
String _oneLine(String s) => s.replaceAll('\n', ' ');

/// Whether a stored artist or genre name is really "no name": empty, "Unknown"
/// or the `<unknown>` Android reports for untagged files.
bool _isUnknownName(String name) {
  final n = name.replaceAll(RegExp(r'[<>]'), '').trim().toLowerCase();
  return n.isEmpty || n == 'unknown';
}

// ── Data model ────────────────────────────────────────────────────────────────

class _InsightsData {
  final int totalListens;
  final int uniqueTracksHeard;
  final int estimatedMinutes;
  final int? mostActiveHour;
  final int? mostActiveWeekday;
  final List<MapEntry<String, int>> topTracks; // trackId → count
  final List<MapEntry<String, int>> topArtists; // artist → count
  final List<MapEntry<String, int>> topGenres; // genre → count
  final int genreTotal; // plays across every genre, not only the top ones
  final Map<int, int> playsByHour; // 0–23
  final Map<int, int> playsByWeekday; // 0–6

  // Resolved track display names from AudioPlayerService
  final Map<String, String> trackTitles; // trackId → "Title\nArtist"

  const _InsightsData({
    required this.totalListens,
    required this.uniqueTracksHeard,
    required this.estimatedMinutes,
    required this.mostActiveHour,
    required this.mostActiveWeekday,
    required this.topTracks,
    required this.topArtists,
    required this.topGenres,
    required this.genreTotal,
    required this.playsByHour,
    required this.playsByWeekday,
    required this.trackTitles,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ListeningInsightsScreen extends StatefulWidget {
  const ListeningInsightsScreen({super.key});

  @override
  State<ListeningInsightsScreen> createState() =>
      _ListeningInsightsScreenState();
}

class _ListeningInsightsScreenState extends State<ListeningInsightsScreen> {
  _InsightsData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);
    final suggestions = SmartSuggestionsService();
    await suggestions.initialize();

    // Build quick-lookup from song id → SongModel
    final songs = audioService.songs;
    final songById = <String, dynamic>{};
    for (final s in songs) {
      songById[s.id.toString()] = s;
    }

    // Resolve track titles
    final trackTitles = <String, String>{};
    for (final entry in suggestions.trackPlayCounts.entries) {
      final song = songById[entry.key];
      if (song != null) {
        final artist = (song.artist as String?)?.isNotEmpty == true
            ? song.artist as String
            : 'Unknown';
        trackTitles[entry.key] = '${song.title}\n$artist';
      }
    }

    // Only tracks still in the library can be shown with a title and cover.
    final sortedTracks = suggestions.trackPlayCounts.entries
        .where((e) => trackTitles.containsKey(e.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedArtists = suggestions.artistPlayCounts.entries
        .where((e) => !_isUnknownName(e.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedGenres = suggestions.genrePlayCounts.entries
        .where((e) => !_isUnknownName(e.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (!mounted) return;
    setState(() {
      _data = _InsightsData(
        totalListens: suggestions.totalListens,
        uniqueTracksHeard: suggestions.trackPlayCounts.length,
        estimatedMinutes: suggestions.estimatedListeningMinutes,
        mostActiveHour: suggestions.mostActiveHour,
        mostActiveWeekday: suggestions.mostActiveWeekday,
        topTracks: sortedTracks.take(5).toList(),
        topArtists: sortedArtists.take(5).toList(),
        topGenres: sortedGenres.take(5).toList(),
        genreTotal: sortedGenres.fold<int>(0, (sum, e) => sum + e.value),
        playsByHour: suggestions.playsByHour,
        playsByWeekday: suggestions.playsByWeekday,
        trackTitles: trackTitles,
      );
      _loading = false;
    });
  }

  // ── Formatting helpers ─────────────────────────────────────────────────────

  static String _hourFull(int h, String locale) =>
      DateFormat.j(locale).format(DateTime(2000, 1, 1, h));

  // 1 Jan 2024 is a Monday, matching the Monday-first weekday index.
  static String _weekdayName(int index, String locale, {bool short = false}) {
    final day = DateTime(2024, 1, 1 + index);
    return (short ? DateFormat.E(locale) : DateFormat.EEEE(locale)).format(day);
  }

  static String _fmtMinutes(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem > 0 ? '${h}h ${rem}m' : '${h}h';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppLocalizations.of(context).musicInsightsTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: FontConstants.fontFamily,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final data = _data!;
    final accent = Theme.of(context).colorScheme.primary;
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    final hourSubtitle = data.mostActiveHour == null
        ? null
        : loc.insightsMostActiveAround(_hourFull(data.mostActiveHour!, locale));
    final daySubtitle = data.mostActiveWeekday == null
        ? null
        : loc.insightsMostActiveOn(
            _weekdayName(data.mostActiveWeekday!, locale));
    final hasHero = data.topTracks.isNotEmpty;
    final totals = _Totals(
      data: data,
      findings: [
        if (hourSubtitle != null) hourSubtitle,
        if (daySubtitle != null) daySubtitle,
      ],
    );

    final Widget opening;
    final bands = <Widget>[];

    if (data.totalListens == 0) {
      opening = Padding(
        padding: EdgeInsets.fromLTRB(_gutter, topInset + 24, _gutter, 0),
        child: _Heading(
          title: loc.insightsNoDataTitle,
          subtitle: loc.insightsNoDataBody,
        ),
      );
    } else {
      opening = hasHero
          ? _Opening(
              id: data.topTracks.first.key,
              hero: _Hero(
                id: data.topTracks.first.key,
                label: data.trackTitles[data.topTracks.first.key]!,
                plays: data.topTracks.first.value,
                accent: accent,
                topInset: topInset,
              ),
              totals: Padding(
                padding: const EdgeInsets.fromLTRB(_gutter, 22, _gutter, 0),
                child: totals,
              ),
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(_gutter, topInset + 16, _gutter, 0),
              child: totals,
            );

      // Each section below is its own band, and the bands alternate between
      // a darker tone and the plain page, so where one ends and the next
      // begins is clear without lines or boxes.
      if (data.playsByHour.isNotEmpty) {
        bands.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Heading(
                title: loc.insightsActivityByTimeOfDay,
                subtitle: hourSubtitle,
              ),
              const SizedBox(height: 8),
              _DayDial(
                counts: List.generate(24, (i) => data.playsByHour[i] ?? 0),
                peak: data.mostActiveHour,
                accent: accent,
                hourLabel: (h) => _hourFull(h, locale),
              ),
            ],
          ),
        ));
      }
      if (data.playsByWeekday.isNotEmpty) {
        bands.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Heading(
                title: loc.insightsActivityByDay,
                subtitle: daySubtitle,
              ),
              const SizedBox(height: 20),
              _WeekRow(
                counts: List.generate(7, (i) => data.playsByWeekday[i] ?? 0),
                peak: data.mostActiveWeekday,
                accent: accent,
                labels: [
                  for (var i = 0; i < 7; i++)
                    _weekdayName(i, locale, short: true),
                ],
              ),
            ],
          ),
        ));
      }
      if (data.topTracks.length > 1) {
        bands.add(_TrackCovers(
          items: data.topTracks.sublist(1),
          labels: data.trackTitles,
        ));
      }
      if (data.topArtists.isNotEmpty) {
        bands.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: _Lineup(items: data.topArtists, accent: accent),
        ));
      }
      if (data.topGenres.isNotEmpty && data.genreTotal > 0) {
        bands.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: _GenreShare(
            genres: data.topGenres,
            total: data.genreTotal,
            accent: accent,
          ),
        ));
      }
    }

    return ListView(
      padding: EdgeInsets.only(
        bottom: ExpandingPlayer.getMiniPlayerPaddingHeight(context) + 24,
      ),
      children: [
        _Reveal(index: 0, child: opening),
        for (var i = 0; i < bands.length; i++)
          _Reveal(
            index: i + 1,
            child: _Band(shaded: i.isEven, child: bands[i]),
          ),
      ],
    );
  }
}

/// One section of the screen: full width, with even space above and below,
/// and either a darker flat tone or the plain page behind it. Alternating the
/// two is what separates the sections.
class _Band extends StatelessWidget {
  final bool shaded;
  final Widget child;

  const _Band({required this.shaded, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: shaded ? Colors.black.withValues(alpha: 0.26) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: child,
      ),
    );
  }
}

// ── Entrance ──────────────────────────────────────────────────────────────────

/// Fades a block in and lifts it a little, one after another. Content is
/// shown at once when the system asks for reduced motion.
class _Reveal extends StatefulWidget {
  final int index;
  final Widget child;

  const _Reveal({required this.index, required this.child});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    _delay = Timer(Duration(milliseconds: 70 * math.min(widget.index, 5)), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 18 * (1 - curved.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ── Shared pieces ─────────────────────────────────────────────────────────────

class _Heading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _Heading({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w800,
            fontFamily: FontConstants.fontFamily,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              height: 1.35,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ],
      ],
    );
  }
}

/// Cover art that fills its parent, with a flat placeholder while loading.
/// [cacheWidth] decodes it at the size it is shown instead of its full size.
class _CoverImage extends StatefulWidget {
  final String id;
  final bool highQuality;
  final int? cacheWidth;

  const _CoverImage({
    required this.id,
    this.highQuality = false,
    this.cacheWidth,
  });

  @override
  State<_CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<_CoverImage> {
  static final _artworkService = ArtworkCacheService();
  ImageProvider? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.id);
    if (id == null) return;
    final provider = await _artworkService.getCachedImageProvider(id,
        highQuality: widget.highQuality);
    if (mounted) setState(() => _image = provider);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _image != null
          ? SizedBox.expand(
              key: const ValueKey('art'),
              child: Image(
                image: widget.cacheWidth == null
                    ? _image!
                    : ResizeImage(_image!, width: widget.cacheWidth),
                fit: BoxFit.cover,
              ),
            )
          : const ColoredBox(
              key: ValueKey('empty'),
              color: Colors.white10,
              child: SizedBox.expand(),
            ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

/// Opaque down to [start] (0..1 of the height), then fading to nothing along
/// a smootherstep curve. A straight two-stop ramp has a kink where it begins
/// that the eye reads as an edge; this one has none at either end.
LinearGradient _softFade(double start) {
  const steps = 14;
  final colors = <Color>[Colors.black];
  final stops = <double>[0];
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final eased = t * t * t * (t * (t * 6 - 15) + 10);
    colors.add(Colors.black.withValues(alpha: 1 - eased));
    stops.add(start + (1 - start) * t);
  }
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
    stops: stops,
  );
}

/// The opening block: the hero and the totals under it, with a blurred copy
/// of the cover bleeding out from beneath the artwork and fading away down
/// the totals. Past that the page is the plain app background.
class _Opening extends StatelessWidget {
  final String id;
  final Widget hero;
  final Widget totals;

  const _Opening({required this.id, required this.hero, required this.totals});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _CoverBleed(id: id)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [hero, totals, const SizedBox(height: 56)],
        ),
      ],
    );
  }
}

/// The blurred, faded copy of the cover, made once instead of on every frame.
///
/// A blurred picture is just a soft, low-detail one, so the cover is decoded
/// at 64 px, softened, darkened a little and faded out into a small bitmap
/// when it loads, then drawn stretched to the block. Scrolling then costs one
/// texture draw; a live blur filter over the full image (and a mask on top)
/// re-ran every frame and made the page stutter. Being a bitmap it also has
/// no spill outside its box.
class _CoverBleed extends StatefulWidget {
  final String id;

  const _CoverBleed({required this.id});

  @override
  State<_CoverBleed> createState() => _CoverBleedState();
}

class _CoverBleedState extends State<_CoverBleed> {
  static final _artworkService = ArtworkCacheService();
  static const _bakedWidth = 64;
  static const _bakedHeight = 96;

  ui.Image? _baked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.id);
    if (id == null) return;
    final provider = await _artworkService.getCachedImageProvider(id);
    if (!mounted) return;

    final stream = ResizeImage(provider, width: _bakedWidth)
        .resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) async {
        stream.removeListener(listener);
        final baked = await _bake(info.image);
        if (!mounted) {
          baked.dispose();
          return;
        }
        setState(() => _baked = baked);
      },
      onError: (_, __) => stream.removeListener(listener),
    );
    stream.addListener(listener);
  }

  static Future<ui.Image> _bake(ui.Image source) {
    const rect = Rect.fromLTWH(0, 0, 64, 96);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, rect);

    canvas.saveLayer(rect, Paint());
    canvas.drawImageRect(
      source,
      Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble()),
      rect,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..imageFilter = ui.ImageFilter.blur(
            sigmaX: 2.5, sigmaY: 2.5, tileMode: TileMode.mirror),
    );
    // Keeps the type over the bleed readable.
    canvas.drawRect(
        rect, Paint()..color = Colors.black.withValues(alpha: 0.18));
    // The fade, applied to the pixels themselves.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = _softFade(0.5).createShader(rect)
        ..blendMode = BlendMode.dstIn,
    );
    canvas.restore();

    return recorder.endRecording().toImage(_bakedWidth, _bakedHeight);
  }

  @override
  void dispose() {
    _baked?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baked = _baked;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: baked == null ? 0 : 1,
        duration: const Duration(milliseconds: 400),
        child: baked == null
            ? const SizedBox.expand()
            : RawImage(
                image: baked,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
      ),
    );
  }
}

/// The #1 track: its cover runs edge to edge behind the app bar and fades
/// into the page, with the title and the play count over the fade.
class _Hero extends StatelessWidget {
  final String id;
  final String label; // "Title\nArtist"
  final int plays;
  final Color accent;
  final double topInset;

  const _Hero({
    required this.id,
    required this.label,
    required this.plays,
    required this.accent,
    required this.topInset,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final parts = label.split('\n');
    final title = parts.first;
    final artist = parts.length > 1 ? parts[1] : null;
    final height = MediaQuery.sizeOf(context).width * 1.08;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => _softFade(0.42).createShader(rect),
              child: _CoverImage(
                id: id,
                highQuality: true,
                cacheWidth: (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
              ),
            ),
          ),
          // Keeps the app bar readable over a bright cover.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset + 28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: _gutter,
            right: _gutter,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.recapTopTrackEyebrow,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontConstants.fontFamily,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    fontFamily: FontConstants.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (artist != null)
                      Flexible(
                        child: Text(
                          artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: FontConstants.fontFamily,
                          ),
                        ),
                      ),
                    const SizedBox(width: 14),
                    Icon(Icons.play_arrow_rounded, size: 22, color: accent),
                    Text(
                      '$plays',
                      style: TextStyle(
                        color: accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: FontConstants.fontFamily,
                        fontFeatures: _tabular,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Totals ────────────────────────────────────────────────────────────────────

/// Listening time as the lead figure, plays and distinct tracks beside it,
/// and the finding in words underneath. Bare type on the page, no box.
class _Totals extends StatelessWidget {
  final _InsightsData data;
  final List<String> findings;

  const _Totals({required this.data, required this.findings});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final number = NumberFormat.decimalPattern(locale);
    final mins = data.estimatedMinutes;

    Widget figure(String label, String value, double size) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontFamily: FontConstants.fontFamily,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  fontFamily: FontConstants.fontFamily,
                  fontFeatures: _tabular,
                ),
              ),
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 5,
              child: figure(
                _oneLine(loc.insightsEstListening),
                mins > 0
                    ? _ListeningInsightsScreenState._fmtMinutes(mins)
                    : '\u2014',
                44,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: figure(
                _oneLine(loc.insightsTotalPlays),
                number.format(data.totalListens),
                26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: figure(
                _oneLine(loc.insightsTracksHeard),
                number.format(data.uniqueTracksHeard),
                26,
              ),
            ),
          ],
        ),
        if (findings.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            findings.join(' \u00b7 '),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.35,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ],
      ],
    );
  }
}

// ── The day as a record ───────────────────────────────────────────────────────

/// Plays per hour as spokes around a record, midnight at the top and the day
/// running clockwise. The peak hour is in the accent and named in the middle;
/// drag a finger around the record to read any other hour.
class _DayDial extends StatefulWidget {
  final List<int> counts; // 24
  final int? peak;
  final Color accent;
  final String Function(int hour) hourLabel;

  const _DayDial({
    required this.counts,
    required this.peak,
    required this.accent,
    required this.hourLabel,
  });

  @override
  State<_DayDial> createState() => _DayDialState();
}

class _DayDialState extends State<_DayDial> {
  int? _selected;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  void _pick(Offset local, double side) {
    final d = local - Offset(side / 2, side / 2);
    if (d.distance < side * 0.12) return;
    var angle = math.atan2(d.dx, -d.dy);
    if (angle < 0) angle += 2 * math.pi;
    // Hour h is centred on h * 15 degrees.
    final hour = ((angle + math.pi / 24) / (2 * math.pi) * 24).floor() % 24;
    _reset?.cancel();
    if (hour != _selected) {
      HapticFeedback.selectionClick();
      setState(() => _selected = hour);
    }
  }

  void _release() {
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _selected = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shown = _selected ?? widget.peak;
    final count = shown == null ? 0 : widget.counts[shown];

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, 360.0);
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _pick(d.localPosition, side),
              onTapUp: (_) => _release(),
              onPanStart: (d) => _pick(d.localPosition, side),
              onPanUpdate: (d) => _pick(d.localPosition, side),
              onPanEnd: (_) => _release(),
              onPanCancel: _release,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.square(side),
                    painter: _DialPainter(
                      counts: widget.counts,
                      active: shown,
                      accent: widget.accent,
                      labels: {
                        for (final h in const [0, 6, 12, 18])
                          h: widget.hourLabel(h),
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shown == null ? '\u2014' : widget.hourLabel(shown),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          fontFamily: FontConstants.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded,
                              size: 17, color: Colors.white54),
                          Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: FontConstants.fontFamily,
                              fontFeatures: _tabular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  final List<int> counts;
  final int? active;
  final Color accent;
  final Map<int, String> labels;

  const _DialPainter({
    required this.counts,
    required this.active,
    required this.accent,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxCount = counts.reduce(math.max);

    // Measure the hour labels first: the disc leaves room for the widest.
    final tps = {
      for (final e in labels.entries)
        e.key: TextPainter(
          text: TextSpan(
            text: e.value,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
    };
    final labelWidth =
        tps.values.fold<double>(0, (m, t) => math.max(m, t.width));
    const gap = 10.0;
    // The record is drawn straight on the panel's glass; a disc of its own
    // would be glass on glass.
    final disc = size.width / 2 - gap - labelWidth - 4;
    final outer = disc - 6;
    final inner = outer * 0.44;

    canvas.drawCircle(
      c,
      outer + 3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.10),
    );
    canvas.drawCircle(
      c,
      inner - 6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.16),
    );

    final barWidth = 2 * math.pi * inner / 24 * 0.6;
    final room = outer - inner;
    for (var i = 0; i < 24; i++) {
      final a = i * 2 * math.pi / 24 - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final frac = maxCount == 0 ? 0.0 : counts[i] / maxCount;
      final len = counts[i] == 0 ? 2.0 : math.max(3.0, room * frac);
      final paint = Paint()
        ..strokeWidth = barWidth
        ..strokeCap = StrokeCap.butt
        ..color = i == active
            ? accent
            : Colors.white.withValues(alpha: counts[i] == 0 ? 0.14 : 0.34);
      canvas.drawLine(c + dir * inner, c + dir * (inner + len), paint);
    }

    // Hours at the four quarters, each placed by its nearest edge so the
    // side labels clear the disc instead of sitting on it.
    tps.forEach((h, tp) {
      final a = h * 2 * math.pi / 24 - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final centre = c +
          dir * (disc + gap) +
          Offset(dir.dx * tp.width / 2, dir.dy * tp.height / 2);
      tp.paint(canvas, centre - Offset(tp.width / 2, tp.height / 2));
    });
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.counts != counts || old.active != active || old.accent != accent;
}

// ── The week ──────────────────────────────────────────────────────────────────

/// Plays per weekday in the same flat style as the record: neutral columns,
/// the peak day in the accent with its count above it.
class _WeekRow extends StatelessWidget {
  final List<int> counts; // 7, Monday first
  final int? peak;
  final Color accent;
  final List<String> labels;

  const _WeekRow({
    required this.counts,
    required this.peak,
    required this.accent,
    required this.labels,
  });

  static const _maxBar = 104.0;

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < counts.length; i++)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 20,
                  child: i == peak
                      ? Text(
                          '${counts[i]}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFamily: FontConstants.fontFamily,
                            fontFeatures: _tabular,
                          ),
                        )
                      : null,
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: maxCount == 0 || counts[i] == 0
                        ? 0.0
                        : math.max(4.0, _maxBar * counts[i] / maxCount),
                  ),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (_, h, __) => Container(
                    width: 22,
                    height: math.max(h, 2),
                    decoration: BoxDecoration(
                      color: i == peak
                          ? accent
                          : Colors.white
                              .withValues(alpha: counts[i] == 0 ? 0.14 : 0.34),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[i],
                  style: TextStyle(
                    color: i == peak ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight: i == peak ? FontWeight.w700 : FontWeight.w400,
                    fontFamily: FontConstants.fontFamily,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Tracks 2 to 5 ─────────────────────────────────────────────────────────────

/// A row of covers for the tracks after the #1, scrolling sideways.
class _TrackCovers extends StatelessWidget {
  final List<MapEntry<String, int>> items; // ranks 2..
  final Map<String, String> labels;

  const _TrackCovers({required this.items, required this.labels});

  static const _cardWidth = 144.0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: _Heading(title: loc.recapTopTracksTitle),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: _cardWidth + 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final entry = items[i];
              final parts = (labels[entry.key] ?? entry.key).split('\n');
              return SizedBox(
                width: _cardWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: _cardWidth,
                        height: _cardWidth,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _CoverImage(
                              id: entry.key,
                              cacheWidth: (_cardWidth *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                            ),
                            // Neutral scrim so the rank reads on any cover.
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 70,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 6,
                              child: Text(
                                '${i + 2}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: FontConstants.fontFamily,
                                  fontFeatures: _tabular,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      parts.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontConstants.fontFamily,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            parts.length > 1 ? parts[1] : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontFamily: FontConstants.fontFamily,
                            ),
                          ),
                        ),
                        const Icon(Icons.play_arrow_rounded,
                            size: 14, color: Colors.white54),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontConstants.fontFamily,
                            fontFeatures: _tabular,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Artist lineup ─────────────────────────────────────────────────────────────

/// Top artists set like a festival bill: the headliner large, the names
/// getting smaller down the list, plays on the right.
class _Lineup extends StatelessWidget {
  final List<MapEntry<String, int>> items;
  final Color accent;

  const _Lineup({required this.items, required this.accent});

  static const _sizes = [46.0, 34.0, 26.0, 21.0, 18.0];
  static const _alphas = [1.0, 0.88, 0.74, 0.62, 0.52];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(title: loc.recapTopArtistsTitle),
        const SizedBox(height: 14),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      items[i].key,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: _alphas[i % _alphas.length]),
                        fontSize: _sizes[i % _sizes.length],
                        height: 1.12,
                        fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w700,
                        fontFamily: FontConstants.fontFamily,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${items[i].value}',
                  style: TextStyle(
                    color: i == 0 ? accent : Colors.white54,
                    fontSize: i == 0 ? 20 : 15,
                    fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w600,
                    fontFamily: FontConstants.fontFamily,
                    fontFeatures: _tabular,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Genre share ───────────────────────────────────────────────────────────────

/// Share of plays by genre: one 100% bar with 2px seams and a legend that
/// carries the numbers. The bar runs in one hue, darker to lighter; plays in
/// genres outside the top five stay as the unfilled remainder.
class _GenreShare extends StatelessWidget {
  final List<MapEntry<String, int>> genres;
  final int total;
  final Color accent;

  const _GenreShare({
    required this.genres,
    required this.total,
    required this.accent,
  });

  static const _alphas = [1.0, 0.75, 0.55, 0.40, 0.28];

  static String _percent(int count, int total) {
    final p = count / total * 100;
    return p < 1 ? '<1%' : '${p.round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final number = NumberFormat.decimalPattern(locale);
    final shown = genres.fold<int>(0, (s, e) => s + e.value);
    final rest = total - shown;

    Color shade(int i) => accent.withValues(alpha: _alphas[i % _alphas.length]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(title: loc.insightsGenreBreakdown),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                for (var i = 0; i < genres.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(
                    flex: genres[i].value,
                    child: ColoredBox(color: shade(i)),
                  ),
                ],
                if (rest > 0) ...[
                  const SizedBox(width: 2),
                  Expanded(
                    flex: rest,
                    child:
                        ColoredBox(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < genres.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Container(width: 8, height: 8, color: shade(i)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    genres[i].key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: FontConstants.fontFamily,
                    ),
                  ),
                ),
                Text(
                  number.format(genres[i].value),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontFamily: FontConstants.fontFamily,
                    fontFeatures: _tabular,
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    _percent(genres[i].value, total),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontConstants.fontFamily,
                      fontFeatures: _tabular,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
