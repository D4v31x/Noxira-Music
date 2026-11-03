/// The playback queue as a full page that opens out of Now Playing.
///
/// History is tucked above Now Playing, followed by what is queued and what
/// comes next from the source. Rows are 60dp with a 44dp cover, lined up with
/// the page header; the song playing gets a light highlight and playing bars,
/// queued songs can be dragged to reorder, and any row can be swiped away.
///
/// Layout and motion adapted from musicfy's QueueScreen
/// (https://github.com/realidkroo/musicfy, GPL-3.0).
library;

import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:on_audio_query/on_audio_query.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/artist_separator_service.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/optimized_tiles.dart';
import '../widgets/lyrics/lyrics_constants.dart';
import '../widgets/player_page_header.dart';
import '../widgets/player_page_route.dart';

const double _kRowHeight = 60;
const double _kRowArt = 44;
const double _kRowInset = 12;
const double _kHandleSize = 40;
const double _kHeaderHeight = 46;

class QueuePage extends StatefulWidget {
  const QueuePage({
    super.key,
    required this.audioPlayerService,
    required this.targets,
  });

  final AudioPlayerService audioPlayerService;
  final PlayerPageTargets targets;

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  late final ScrollController _scroll;

  AudioPlayerService get _audio => widget.audioPlayerService;

  @override
  void initState() {
    super.initState();
    // Open on Now Playing with the history tucked above it.
    final history = _audio.currentIndex.clamp(0, _audio.playlist.length);
    _scroll = ScrollController(
      initialScrollOffset:
          history == 0 ? 0 : _kHeaderHeight + history * _kRowHeight,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _play(int index) {
    _audio.play(index: index);
  }

  Future<void> _remove(int index) async {
    await _audio.removeFromQueue(index);
  }

  @override
  Widget build(BuildContext context) {
    final route = PlayerPageScope.maybeOf(context)?.route;
    final l10n = AppLocalizations.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _audio,
            builder: (context, _) {
              final song = _audio.currentSong;
              final count = _audio.playlist.length;
              return Column(
                children: [
                  PlayerPageHeader(
                    song: song,
                    targets: widget.targets,
                    route: route,
                    subtitle: '${l10n.queue} · $count '
                        '${count == 1 ? 'song' : 'songs'}',
                    onCoverTap: () => Navigator.pop(context),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white70, size: 24),
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                      onPressed: () => Navigator.pop(context),
                    ),
                    trailing: [
                      if (_audio.hasUpcoming)
                        IconButton(
                          icon: const iconoir.Trash(
                              color: Colors.white70, width: 24, height: 24),
                          tooltip: l10n.clearUpcoming,
                          onPressed: _audio.clearUpcoming,
                        ),
                    ],
                  ),
                  Expanded(child: _rise(route, _buildList(context, l10n))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Rows rise into place, fading in, as the page opens.
  Widget _rise(PlayerPageRoute<dynamic>? route, Widget child) {
    if (route == null) return child;
    return AnimatedBuilder(
      animation: route.progress,
      child: child,
      builder: (context, child) {
        final e = route.progress.value;
        final t = ((e - 0.14) / 0.55).clamp(0.0, 1.0);
        return Opacity(
          opacity: t * t * (3 - 2 * t),
          child: Transform.translate(
            offset: Offset(0, 140 * (1 - e)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, AppLocalizations l10n) {
    final playlist = _audio.playlist;
    final current = _audio.currentIndex;
    final song = _audio.currentSong;

    if (song == null || playlist.isEmpty) {
      return Center(
        child: Text(
          l10n.queueEmpty,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 15,
          ),
        ),
      );
    }

    final history = playlist.sublist(0, current.clamp(0, playlist.length));
    final queued = _audio.queuedSongs;
    final source = _audio.sourceUpcoming;
    final sourceName = _audio.playbackSource.name;
    final nothingNext = queued.isEmpty && source.isEmpty;

    return LayoutBuilder(builder: (context, constraints) {
      final fade = (18 / constraints.maxHeight).clamp(0.0, 0.25);
      return ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0, fade, 1 - fade, 1],
        ).createShader(bounds),
        child: CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (history.isNotEmpty) ...[
              _header('History'),
              SliverList.builder(
                itemCount: history.length,
                itemBuilder: (context, i) => _swipeable(
                  key: 'history_${history[i].id}_$i',
                  index: i,
                  child: _SongRow(
                    song: history[i],
                    dimmed: true,
                    onTap: () => _play(i),
                    onPlayNext: () => _audio.playNext(history[i]),
                    onRemove: () => _remove(i),
                  ),
                ),
              ),
            ],
            _header(AppLocalizations.of(context).nowPlaying),
            SliverToBoxAdapter(
              child: ValueListenableBuilder<bool>(
                valueListenable: _audio.isPlayingNotifier,
                builder: (context, playing, _) => _SongRow(
                  song: song,
                  nowPlaying: true,
                  playing: playing,
                  onTap: () => playing ? _audio.pause() : _audio.resume(),
                ),
              ),
            ),
            if (queued.isNotEmpty) ...[
              _header(l10n.queue),
              SliverReorderableList(
                itemCount: queued.length,
                onReorderItem: (oldIdx, newIdx) => _audio.moveInQueue(
                    current + 1 + oldIdx, current + 1 + newIdx),
                proxyDecorator: (child, index, animation) => Material(
                  color: Colors.transparent,
                  child: ScaleTransition(
                    scale:
                        Tween<double>(begin: 1, end: 1.02).animate(animation),
                    child: child,
                  ),
                ),
                itemBuilder: (context, i) {
                  final index = current + 1 + i;
                  return KeyedSubtree(
                    key: ValueKey('queued_${queued[i].id}_$index'),
                    child: _swipeable(
                      key: 'queued_swipe_${queued[i].id}_$index',
                      index: index,
                      child: _SongRow(
                        song: queued[i],
                        onTap: () => _play(index),
                        rowKeys: _keysFor(i),
                        handleIndex: i,
                      ),
                    ),
                  );
                },
              ),
            ],
            if (source.isNotEmpty) ...[
              _header(
                sourceName != null && sourceName.isNotEmpty
                    ? 'Next from $sourceName'
                    : 'Next Up',
              ),
              SliverList.builder(
                itemCount: source.length,
                itemBuilder: (context, i) {
                  final index = _audio.queueBoundary + i;
                  return _swipeable(
                    key: 'source_${source[i].id}_$index',
                    index: index,
                    child: _SongRow(
                      song: source[i],
                      onTap: () => _play(index),
                      rowKeys: _keysFor(queued.length + i),
                      onPlayNext: () => _audio.moveInQueue(index, current + 1),
                      onRemove: () => _remove(index),
                    ),
                  );
                },
              ),
            ],
            if (nothingNext)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      kLyricsHorizontalPadding, 16, 16, 12),
                  child: Text(
                    'Nothing else queued',
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      );
    });
  }

  /// Landing spot for the card's row [position] (0 = next song), if it has one.
  RowKeys? _keysFor(int position) =>
      position < kPlayerPageRows ? widget.targets.rows[position] : null;

  Widget _header(String title) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: _kHeaderHeight,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(kLyricsHorizontalPadding, 0, 16, 8),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Swipe a row away to remove it from the queue.
  Widget _swipeable({
    required String key,
    required int index,
    required Widget child,
  }) {
    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: _kRowInset),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const iconoir.Trash(color: Colors.white, width: 22, height: 22),
      ),
      onDismissed: (_) => _remove(index),
      child: child,
    );
  }
}

class _SongRow extends StatelessWidget {
  const _SongRow({
    required this.song,
    required this.onTap,
    this.dimmed = false,
    this.nowPlaying = false,
    this.playing = false,
    this.handleIndex,
    this.onPlayNext,
    this.onRemove,
    this.rowKeys,
  });

  final RowKeys? rowKeys;
  final VoidCallback? onPlayNext;
  final VoidCallback? onRemove;
  final SongModel song;
  final VoidCallback onTap;
  final bool dimmed;
  final bool nowPlaying;
  final bool playing;

  /// Position in the reorderable list, or null when the row can't be dragged.
  final int? handleIndex;

  @override
  Widget build(BuildContext context) {
    final fade = dimmed ? 0.6 : 1.0;
    final route = PlayerPageScope.maybeOf(context)?.route;
    Widget landing(GlobalKey? key, Widget child) =>
        key == null ? child : playerPageSharedTarget(route, key, child);
    final artist = ArtistSeparatorService()
        .splitArtists(song.artist ?? 'Unknown Artist')
        .join(', ');

    return SizedBox(
      height: _kRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kRowInset),
        child: Material(
          color: nowPlaying
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.06),
            highlightColor: Colors.white.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.only(
                left: kLyricsHorizontalPadding - _kRowInset,
                right: 4,
              ),
              child: Row(
                children: [
                  Opacity(
                    opacity: fade,
                    child: landing(
                        rowKeys?.art,
                        SizedBox(
                          width: _kRowArt,
                          height: _kRowArt,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ColoredBox(
                                    color: Colors.white.withValues(alpha: 0.1)),
                                ArtworkCacheService().buildCachedArtwork(
                                    song.id,
                                    size: _kRowArt),
                                if (nowPlaying)
                                  ColoredBox(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    child: Center(
                                      child: NowPlayingBars(
                                        isPlaying: playing,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: fade,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          landing(
                              rowKeys?.title,
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              )),
                          landing(
                              rowKeys?.artist,
                              Text(
                                artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  if (handleIndex != null)
                    ReorderableDragStartListener(
                      index: handleIndex!,
                      child: SizedBox(
                        width: _kHandleSize,
                        height: _kHandleSize,
                        child: Center(
                          child: iconoir.Drag(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ),
                    )
                  else if (onPlayNext != null || onRemove != null)
                    _RowMenu(onPlayNext: onPlayNext, onRemove: onRemove)
                  else
                    const SizedBox(width: _kHandleSize),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowMenu extends StatelessWidget {
  const _RowMenu({this.onPlayNext, this.onRemove});

  final VoidCallback? onPlayNext;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const style = TextStyle(
      fontFamily: FontConstants.fontFamily,
      color: Colors.white,
      fontSize: 14,
    );
    return PopupMenuButton<int>(
      color: const Color(0xFF24242B),
      icon: Icon(Icons.more_vert_rounded,
          color: Colors.white.withValues(alpha: 0.5), size: 22),
      constraints: const BoxConstraints(minWidth: 160),
      padding: EdgeInsets.zero,
      onSelected: (v) => v == 0 ? onPlayNext?.call() : onRemove?.call(),
      itemBuilder: (_) => [
        if (onPlayNext != null)
          PopupMenuItem(value: 0, child: Text(l10n.playNext, style: style)),
        if (onRemove != null)
          PopupMenuItem(value: 1, child: Text(l10n.remove, style: style)),
      ],
    );
  }
}
