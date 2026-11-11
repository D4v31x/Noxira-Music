import 'package:aurora_music_v01/shared/utils/responsive_utils.dart';
import '../../../shared/services/album_query_cache.dart';
import '../../../shared/widgets/online/online_artist_widgets.dart';
import '../../../shared/widgets/motion/touch_and_reveal.dart';
import '../../../shared/widgets/motion/musicfy_motion.dart';
import 'dart:async';
import 'dart:io';
import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:on_audio_query/on_audio_query.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/notification_manager.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../../shared/services/local_caching_service.dart';
import '../../../shared/utils/album_sanitizer.dart';
import '../../../shared/services/folder_filter_service.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/widgets/expanding_player.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/detail_header.dart';
import '../../../shared/widgets/blurred_image.dart';
import '../../../shared/widgets/song_context_menu.dart';
import 'album_detail_screen.dart';

class ArtistDetailsScreen extends StatefulWidget {
  final String artistName;
  final String? artistImagePath;

  const ArtistDetailsScreen({
    super.key,
    required this.artistName,
    this.artistImagePath,
  });

  @override
  State<ArtistDetailsScreen> createState() => _ArtistDetailsScreenState();
}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ArtworkCacheService _artworkService = ArtworkCacheService();
  late ScrollController _scrollController;
  Color _dominantColor = Colors.deepPurple.shade900;
  // Eases towards [_dominantColor] so the buttons shift gradually once the palette is ready.
  Color _animatedColor = Colors.deepPurple.shade900;
  late Future<void> _colorFuture;
  final LocalCachingArtistService _artistService = LocalCachingArtistService();

  // Lazy loading state
  List<SongModel> _allSongs = [];
  final List<SongModel> _displayedSongs = [];
  int _currentPage = 0;
  final int _songsPerPage = 40;
  bool _isLoading = false;
  bool _hasMoreSongs = true;

  // Categories
  int _selectedCategory = 0; // 0 = Songs, 1 = Albums
  List<AlbumModel> _albums = [];
  final Map<int, List<SongModel>> _albumSongs = {};

  // Stats
  Duration _totalDuration = Duration.zero;
  String? _artistImagePath;

  @override
  void initState() {
    super.initState();
    // The palette work and the rebuild it triggers wait for the header's reveal.
    _colorFuture = whenRouteSettled(context).then((_) async {
      if (!mounted) return;
      if (widget.artistImagePath == null) {
        await _artistService.fetchArtistImage(widget.artistName);
      }
      await Future<void>.delayed(kRevealDuration);
      if (!mounted) return;
      await _updateDominantColor();
    });
    _scrollController = ScrollController()..addListener(_scrollListener);
    // Short head start for the header reveal, which begins as the route settles.
    whenRouteSettled(context)
        .then((_) => Future<void>.delayed(const Duration(milliseconds: 120)))
        .then((_) {
      if (mounted) _loadSongs();
    });
  }

  AudioPlayerService? _audioServiceRef;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = Provider.of<AudioPlayerService>(context, listen: false);
    if (_audioServiceRef == null) {
      _audioServiceRef = service;
      service.songsNotifier.addListener(_onSongsChanged);
      // Blur the header artwork while the image is still flying in.
      final path = widget.artistImagePath;
      if (path != null) {
        unawaited(BlurredImage.precache(FileImage(File(path)),
            sigma: 30, extent: MediaQuery.sizeOf(context).width));
      }
    }
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

    final artistSongs = songs
        .where((song) =>
            // Cheap pre-check: splitArtists builds regexes on every call.
            (song.artist?.contains(widget.artistName) ?? false) &&
            splitArtists(song.artist!).contains(widget.artistName))
        .toList();

    // Calculate total duration
    Duration totalDuration = Duration.zero;
    for (final song in artistSongs) {
      totalDuration += Duration(milliseconds: song.duration ?? 0);
    }

    if (!mounted) return;
    setState(() {
      _allSongs = artistSongs;
      _totalDuration = totalDuration;
    });

    _loadMoreSongs();

    // Albums come last so they don't delay the song list.
    final rawAlbums = await AlbumQueryCache.get(
        _audioQuery, _audioServiceRef?.songs ?? songs);
    final artistAlbums = sanitizeAlbums(rawAlbums)
        .where((album) => album.artist?.contains(widget.artistName) ?? false)
        .toList();
    if (!mounted) return;
    setState(() {
      _albums = artistAlbums;
      for (final album in artistAlbums) {
        _albumSongs[album.id] =
            _allSongs.where((song) => song.albumId == album.id).toList();
      }
    });

    // Load artist image if not provided
    if (widget.artistImagePath == null) {
      final imagePath =
          await _artistService.fetchArtistImage(widget.artistName);
      if (mounted && imagePath != null) {
        setState(() {
          _artistImagePath = imagePath;
        });
      }
    } else {
      _artistImagePath = widget.artistImagePath;
    }
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
    if (widget.artistImagePath != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        FileImage(File(widget.artistImagePath!)),
        maximumColorCount: 8,
        size: const Size(100, 100),
      );

      setState(() {
        _dominantColor =
            paletteGenerator.dominantColor?.color ?? Colors.deepPurple.shade900;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return FutureBuilder(
      future: _colorFuture,
      builder: (context, snapshot) {
        final effectiveImagePath = widget.artistImagePath ?? _artistImagePath;

        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: _dominantColor),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          builder: (context, animated, _) {
            _animatedColor = animated ?? _dominantColor;
            return _buildScaffold(context, localizations, effectiveImagePath);
          },
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, AppLocalizations localizations,
      String? effectiveImagePath) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Blurred artwork header
            DetailHeader(
              artworkFilePath: effectiveImagePath,
              fallbackAsset: 'assets/images/UI/unknown.png',
              title: widget.artistName,
              metadata: _allSongs.isNotEmpty
                  ? '${_allSongs.length} ${localizations.songs} · ${_albums.length} ${localizations.albums} · ${_formatDuration(_totalDuration)}'
                  : null,
              badge: localizations.artist,
              accentColor: _dominantColor == Colors.deepPurple.shade900
                  ? Colors.cyan
                  : _dominantColor,
            ),

            // Action buttons
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        const iconoir.Play(
                            color: Colors.white, width: 22, height: 22),
                        localizations.playAll,
                        () => _playAllSongs(context),
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      context,
                      const iconoir.Shuffle(
                          color: Colors.white, width: 22, height: 22),
                      localizations.shuffle,
                      () => _shuffleAllSongs(context),
                      iconOnly: true,
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      context,
                      const iconoir.Playlist(
                          color: Colors.white, width: 22, height: 22),
                      AppLocalizations.of(context).queue,
                      () => _addAllToQueue(context),
                      iconOnly: true,
                    ),
                  ],
                ),
              ),
            ),

            // Category tabs
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCategoryTab(
                        '${localizations.songs} (${_allSongs.length})',
                        0,
                        const iconoir.MusicNote(
                            color: Colors.white, width: 18, height: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCategoryTab(
                        '${localizations.albums} (${_albums.length})',
                        1,
                        const iconoir.Album(
                            color: Colors.white, width: 18, height: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content based on selected category
            _selectedCategory == 0 ? _buildSongsList() : _buildAlbumsList(),

            SliverToBoxAdapter(
              child: OnlineAboutCard(artistName: widget.artistName),
            ),
            SliverToBoxAdapter(
              child: OnlinePopularTracks(artistName: widget.artistName),
            ),
            SliverToBoxAdapter(
              child: SimilarArtistsRow(artistName: widget.artistName),
            ),

            // Bottom padding for mini player
            SliverToBoxAdapter(
              child: Selector<AudioPlayerService, bool>(
                selector: (_, service) => service.currentSong != null,
                builder: (context, hasCurrentSong, _) {
                  return SizedBox(
                    height: hasCurrentSong
                        ? ExpandingPlayer.getMiniPlayerPaddingHeight(context)
                        : 16,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String label, int index, Widget icon) {
    final isSelected = _selectedCategory == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = index;
          _currentPage = 0;
          _displayedSongs.clear();
          if (index == 0) {
            _loadMoreSongs();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    _animatedColor.withValues(alpha: 0.8),
                    _animatedColor.withValues(alpha: 0.6),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _animatedColor
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumsList() {
    if (_albums.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconoir.Album(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 64,
                  height: 64),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).noAlbumsFound,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      );
    }

    final isTablet = ResponsiveUtils.isTablet(context);
    final columns = isTablet ? 4 : 2;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: isTablet ? 0.9 : 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= _albums.length) return null;

            final album = _albums[index];
            final albumSongs = _albumSongs[album.id] ?? [];
            final artworkSize = isTablet ? 100.0 : 120.0;

            return RevealOnAppear(
                revealKey:
                    '${identityHashCode(ModalRoute.of(context))}_0_$index',
                child: Press3D(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AlbumDetailScreen(albumName: album.album),
                      ),
                    );
                  },
                  onLongPress: () => _showAlbumOptions(album, albumSongs),
                  child: GlassmorphicContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ArtworkHero(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child:
                                        _artworkService.buildCachedAlbumArtwork(
                                      album.id,
                                      size: artworkSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            album.album,
                            style: const TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)
                                .songsCountPlural(albumSongs.length),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )));
          },
          childCount: _albums.length,
        ),
      ),
    );
  }

  void _showAlbumOptions(AlbumModel album, List<SongModel> albumSongs) {
    final audioPlayerService =
        Provider.of<AudioPlayerService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final loc = AppLocalizations.of(context);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _artworkService.buildCachedAlbumArtwork(album.id,
                          size: ResponsiveUtils.scaledArtwork(context, 50)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.album,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            loc.songCount(albumSongs.length),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const iconoir.Play(
                    color: Colors.white, width: 24, height: 24),
                title:
                    Text(loc.play, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  if (albumSongs.isNotEmpty) {
                    audioPlayerService.setPlaylist(
                      albumSongs,
                      0,
                      source: PlaybackSourceInfo(
                        source: PlaybackSource.album,
                        name: album.album,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const iconoir.Shuffle(
                    color: Colors.white, width: 24, height: 24),
                title: Text(loc.shuffle,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  if (albumSongs.isNotEmpty) {
                    final shuffled = List<SongModel>.from(albumSongs)
                      ..shuffle();
                    audioPlayerService.setPlaylist(
                      shuffled,
                      0,
                      source: PlaybackSourceInfo(
                        source: PlaybackSource.album,
                        name: album.album,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const iconoir.InfoCircle(
                    color: Colors.white, width: 24, height: 24),
                title: Text(loc.viewAlbum,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AlbumDetailScreen(albumName: album.album),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongsList() {
    if (_displayedSongs.isEmpty && _isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SongTileSkeleton(),
            ),
            childCount: 6,
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _displayedSongs.length) {
            return _hasMoreSongs
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SongTileSkeleton(),
                  )
                : const SizedBox.shrink();
          }

          if (index >= _displayedSongs.length) return null;

          final song = _displayedSongs[index];
          final duration = Duration(milliseconds: song.duration ?? 0);
          final durationString =
              '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

          return RevealOnAppear(
              revealKey: '${identityHashCode(ModalRoute.of(context))}_1_$index',
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    Provider.of<AudioPlayerService>(context, listen: false)
                        .setPlaylist(
                      _allSongs,
                      _allSongs.indexWhere((s) => s.id == song.id),
                      source: PlaybackSourceInfo(
                        source: PlaybackSource.artist,
                        name: widget.artistName,
                      ),
                    );
                  },
                  onLongPress: () => showSongContextMenu(context, song),
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
                          // Artwork
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 42,
                              height: 42,
                              child: _artworkService.buildCachedArtwork(song.id,
                                  size: 42),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Song info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
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
                                const SizedBox(height: 2),
                                Text(
                                  song.album ??
                                      AppLocalizations.of(context).unknownAlbum,
                                  style: TextStyle(
                                    fontFamily: FontConstants.fontFamily,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
                          // More
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => showSongContextMenu(context, song),
                            child: iconoir.MoreVert(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 20,
                              height: 20,
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

  void _playAllSongs(BuildContext context) async {
    if (_allSongs.isNotEmpty) {
      final audioPlayerService =
          Provider.of<AudioPlayerService>(context, listen: false);
      unawaited(audioPlayerService.setPlaylist(
        _allSongs,
        0,
        source: PlaybackSourceInfo(
          source: PlaybackSource.artist,
          name: widget.artistName,
        ),
      ));
    }
  }

  void _addAllToQueue(BuildContext context) async {
    if (_allSongs.isEmpty) return;
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);
    await audioService.addMultipleToQueue(_allSongs);
    if (context.mounted) {
      NotificationManager.showMessage(
        context,
        AppLocalizations.of(context).songsAddedToQueue(_allSongs.length),
      );
    }
  }

  void _shuffleAllSongs(BuildContext context) async {
    if (_allSongs.isNotEmpty) {
      final shuffledSongs = List<SongModel>.from(_allSongs)..shuffle();
      final audioPlayerService =
          Provider.of<AudioPlayerService>(context, listen: false);
      unawaited(audioPlayerService.setPlaylist(
        shuffledSongs,
        0,
        source: PlaybackSourceInfo(
          source: PlaybackSource.artist,
          name: widget.artistName,
        ),
      ));
    }
  }

  Widget _buildActionButton(
    BuildContext context,
    Widget icon,
    String label,
    VoidCallback onTap, {
    bool isPrimary = false,
    bool iconOnly = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: iconOnly ? 14 : 20,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    _animatedColor.withValues(alpha: 0.8),
                    _animatedColor.withValues(alpha: 0.6),
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? _animatedColor
                : Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (!iconOnly) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
