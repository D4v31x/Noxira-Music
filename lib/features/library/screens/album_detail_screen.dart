import '../../../shared/widgets/online/online_artist_widgets.dart';
import '../../../shared/services/album_query_cache.dart';
import '../../../shared/widgets/motion/touch_and_reveal.dart';
import '../../../shared/widgets/motion/musicfy_motion.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/utils/album_sanitizer.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:typed_data';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/folder_filter_service.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/widgets/detail_header.dart';
import '../../../shared/widgets/song_context_menu.dart';
import '../../../shared/mixins/mixins.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumName;

  const AlbumDetailScreen({
    super.key,
    required this.albumName,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen>
    with DetailScreenMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ArtworkCacheService _artworkService = ArtworkCacheService();
  late ScrollController _scrollController;

  // The palette colour, and the eased value the buttons actually show.
  Color _paletteColor = Colors.deepPurple.shade900;
  Color _animatedColor = Colors.deepPurple.shade900;

  // Lazy loading state
  List<SongModel> _allSongs = [];
  final List<SongModel> _displayedSongs = [];
  int _currentPage = 0;
  final int _songsPerPage = kDetailPageSize;
  bool _isLoading = false;
  bool _hasMoreSongs = true;

  // Album metadata
  String? _artistName;
  Duration _totalDuration = Duration.zero;
  List<AlbumModel> _relatedAlbums = [];
  Uint8List? _artworkBytes;

  // Header artwork: fetched and blurred while the page opens (see
  // _prepareArtwork), the palette comes from the same bytes afterwards.
  bool _artworkRequested = false;
  Future<void>? _artworkTask;
  bool _colorRequested = false;
  late final Future<void> _revealDone;

  // DetailScreenMixin requirements
  @override
  Color get dominantColor => _animatedColor;

  @override
  List<SongModel> get allSongs => _allSongs;

  @override
  PlaybackSourceInfo get playbackSource => PlaybackSourceInfo(
        source: PlaybackSource.album,
        name: widget.albumName,
      );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    // The header's reveal gets a head start before the songs are loaded, and
    // the palette (and the rebuild it brings) waits for the reveal to finish.
    _revealDone = whenDetailRevealed(context);
    unawaited(whenDetailReady(context).then((_) {
      if (mounted) unawaited(_loadSongs());
    }));
  }

  AudioPlayerService? _audioServiceRef;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = Provider.of<AudioPlayerService>(context, listen: false);
    if (_audioServiceRef == null) {
      _audioServiceRef = service;
      service.songsNotifier.addListener(_onSongsChanged);
      // The artwork is fetched and blurred while the cover is still flying in.
      unawaited(_prepareArtwork(service.songs));
    }
  }

  /// Fetches the header artwork and blurs it ahead of time, then shows it.
  /// Setting it only once the blurred bitmap exists keeps that rebuild cheap
  /// instead of running a live full-size blur on the first frame.
  Future<void> _prepareArtwork(List<SongModel> songs) async {
    if (_artworkRequested) return;
    SongModel? song;
    for (final candidate in songs) {
      if (candidate.album == widget.albumName) {
        song = candidate;
        break;
      }
    }
    if (song == null) return;
    _artworkRequested = true;
    final task = _loadHeaderArtwork(song.id);
    _artworkTask = task;
    await task;
  }

  Future<void> _loadHeaderArtwork(int songId) async {
    final artwork = await _artworkService.getArtwork(songId);
    if (!mounted || artwork == null) return;
    await DetailHeader.precacheArtwork(context, artwork);
    if (!mounted) return;
    setState(() => _artworkBytes = artwork);
  }

  void _onSongsChanged() {
    if (!mounted) return;
    _loadSongs();
  }

  @override
  void dispose() {
    _audioServiceRef?.songsNotifier.removeListener(_onSongsChanged);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 2500 &&
        !_isLoading &&
        _hasMoreSongs) {
      _loadMoreSongs();
    }
  }

  Future<void> _loadSongs() async {
    // The player already holds the filtered library; querying MediaStore again
    // decodes thousands of songs on the UI thread.
    List<SongModel> songs = _audioServiceRef?.songs ?? const [];
    if (songs.isEmpty) {
      final rawSongs = await _audioQuery.querySongs(
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      await FolderFilterService().ensureInitialized();
      songs = FolderFilterService().filterSongs(rawSongs);
    }

    final albumSongs = songs
        .where((song) => song.album == widget.albumName)
        .toList()
      ..sort((a, b) => (a.track ?? 0).compareTo(b.track ?? 0));

    // Get album metadata
    String? artistName;
    Duration totalDuration = Duration.zero;

    if (albumSongs.isNotEmpty) {
      artistName = albumSongs.first.artist;
      for (final song in albumSongs) {
        totalDuration += Duration(milliseconds: song.duration ?? 0);
      }
    }

    if (!mounted) return;
    setState(() {
      _allSongs = albumSongs;
      _artistName = artistName;
      _totalDuration = totalDuration;
    });

    _loadMoreSongs();
    unawaited(_prepareArtwork(albumSongs));
    unawaited(_updateDominantColor());

    // Related albums come last so they don't delay the song list.
    final allAlbums = sanitizeAlbums(await AlbumQueryCache.get(
        _audioQuery, _audioServiceRef?.songs ?? songs));
    if (!mounted) return;
    setState(() {
      _relatedAlbums = allAlbums
          .where((album) =>
              album.artist == artistName && album.album != widget.albumName)
          .toList();
    });
  }

  void _loadMoreSongs() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final int startIndex = _currentPage * _songsPerPage;
    final int endIndex =
        (startIndex + _songsPerPage).clamp(0, _allSongs.length);

    if (startIndex < _allSongs.length) {
      final newSongs = _allSongs.sublist(startIndex, endIndex);

      setState(() {
        _displayedSongs.addAll(newSongs);
        _currentPage++;
        _isLoading = false;
        _hasMoreSongs = endIndex < _allSongs.length;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasMoreSongs = false;
      });
    }
  }

  Future<void> _updateDominantColor() async {
    await _revealDone;
    await _artworkTask;
    final artwork = _artworkBytes;
    if (!mounted || artwork == null || _colorRequested) return;
    _colorRequested = true;

    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      MemoryImage(artwork),
      maximumColorCount: 8,
      size: const Size(100, 100),
    );
    if (!mounted) return;
    setState(() {
      _paletteColor =
          paletteGenerator.dominantColor?.color ?? Colors.deepPurple.shade900;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (context) {
          final dominantColor = _paletteColor;
          if (_displayedSongs.isEmpty && _isLoading) {
            return AppBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: const iconoir.NavArrowLeft(
                              color: Colors.white,
                              width: 26,
                              height: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: DetailHeaderSkeleton(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const ListSkeleton(),
                  ],
                ),
              ),
            );
          }

          return AppBackground(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Blurred artwork header
                DetailHeader(
                  artworkBytes: _artworkBytes,
                  title: widget.albumName,
                  subtitle: _artistName,
                  metadata: _allSongs.isNotEmpty
                      ? '${_allSongs.length} ${localizations.songs} · ${formatDuration(_totalDuration)}'
                      : null,
                  badge: localizations.album,
                  accentColor: dominantColor == Colors.deepPurple.shade900
                      ? Colors.cyan
                      : dominantColor,
                ),

                // Action row (play, search, shuffle)
                SliverToBoxAdapter(
                  // Only the buttons rebuild while the colour eases in.
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: _paletteColor),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutCubic,
                    builder: (context, animated, _) {
                      _animatedColor = animated ?? _paletteColor;
                      return buildActionButtonsRow();
                    },
                  ),
                ),

                // Songs list
                _buildSongsList(),

                // Related albums section
                if (_relatedAlbums.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        localizations.moreFromArtist(_artistName ?? ''),
                        style: const TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _relatedAlbums.length,
                        itemBuilder: (context, index) {
                          final album = _relatedAlbums[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Press3D(
                                child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlbumDetailScreen(
                                      albumName: album.album,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 130,
                                child: GlassmorphicContainer(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ArtworkHero(
                                          radius: 10,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: _artworkService
                                                .buildCachedAlbumArtwork(
                                              album.id,
                                              size: 100,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          album.album,
                                          style: const TextStyle(
                                            fontFamily:
                                                FontConstants.fontFamily,
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                if (_artistName != null && _artistName!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SimilarArtistsRow(artistName: _artistName!),
                  ),

                // Bottom padding for mini player
                buildMiniPlayerPadding(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSongsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _displayedSongs.length) {
            return _hasMoreSongs
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink();
          }

          if (index >= _displayedSongs.length) return null;

          final song = _displayedSongs[index];
          final duration = Duration(milliseconds: song.duration ?? 0);
          final durationString =
              '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

          return RevealOnAppear(
              revealKey: '${identityHashCode(ModalRoute.of(context))}_0_$index',
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: GestureDetector(
                  onTap: () {
                    Provider.of<AudioPlayerService>(context, listen: false)
                        .setPlaylist(_allSongs, index);
                  },
                  onLongPress: () => _showSongOptions(song),
                  child: GlassmorphicContainer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // Track number
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Song info
                          Expanded(
                            child: Text(
                              song.title,
                              style: const TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Duration
                          Text(
                            durationString,
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                            ),
                          ),
                          // More options
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _showSongOptions(song),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
        },
        childCount: _displayedSongs.length + (_hasMoreSongs ? 1 : 0),
      ),
    );
  }

  void _showSongOptions(SongModel song) => showSongContextMenu(context, song);
}
