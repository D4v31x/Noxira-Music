import 'package:flutter/material.dart';
import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/models.dart';
import '../../library/library_feature.dart';
import '../../playlists/playlists_feature.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/widgets/glassmorphic_card.dart';
import '../../../shared/widgets/glass_fill.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive_utils.dart';

import '../../../shared/widgets/expanding_player.dart';
import 'duplicate_tracks_banner.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab>
    with AutomaticKeepAliveClientMixin {
  // Make artwork service static to prevent recreation on every build
  static final _artworkService = ArtworkCacheService();

  AudioPlayerService? _serviceRef;

  // Cached futures — only recreated when songs actually change, not on every setState.
  Future<List<SongModel>>? _tracksFuture;
  Future<List<AlbumModel>>? _albumsFuture;
  Future<List<ArtistModel>>? _artistsFuture;

  /// Plays the tapped track and then the rest of the library's tracks list.
  Future<void> _playTrack(AudioPlayerService service, dynamic song) async {
    if (song is! SongModel) return;
    final all = await service.getLibraryTracks(count: -1);
    final index = all.indexWhere((s) => s.id == song.id);
    if (!mounted) return;
    await service.setPlaylist(
      index >= 0 ? all : [song],
      index >= 0 ? index : 0,
      source: const PlaybackSourceInfo(source: PlaybackSource.library),
    );
  }

  void _refreshFutures() {
    final svc = _serviceRef;
    if (svc == null) return;
    _tracksFuture = svc.getLibraryTracks();
    _albumsFuture = svc.getMostPlayedAlbums();
    _artistsFuture = svc.getMostPlayedArtists();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = Provider.of<AudioPlayerService>(context, listen: false);
    if (_serviceRef == null) {
      _serviceRef = service;
      service.songsNotifier.addListener(_onSongsChanged);
      _refreshFutures();
    }
  }

  void _onSongsChanged() {
    if (mounted) {
      _refreshFutures();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _serviceRef?.songsNotifier.removeListener(_onSongsChanged);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Access service without listening for methods
    final audioPlayerService =
        Provider.of<AudioPlayerService>(context, listen: false);

    final isTablet = ResponsiveUtils.isTablet(context);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final layoutMode = ResponsiveUtils.getLayoutMode(context);

    return Selector<AudioPlayerService, bool>(
      selector: (context, service) => service.currentSong != null,
      builder: (context, hasCurrentSong, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: isTablet ? 40.0 : 30.0,
            bottom: hasCurrentSong
                ? ExpandingPlayer.getMiniPlayerPaddingHeight(context)
                : MediaQuery.of(context).padding.bottom +
                    (isTablet ? 40.0 : 30.0),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getContentMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DuplicateTracksBanner(),
                  _buildContent(audioPlayerService, isTablet, layoutMode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(AudioPlayerService audioPlayerService, bool isTablet,
      LayoutMode layoutMode) {
    // On tablets with twoColumn layout, show a 2-column grid of sections
    // Each section looks like the mobile version but arranged side by side
    if (layoutMode == LayoutMode.twoColumn ||
        layoutMode == LayoutMode.wideWithPanel) {
      return _buildTabletLayout(audioPlayerService, layoutMode);
    }

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            buildCategorySection(
              title: AppLocalizations.of(context).tracks,
              items: _tracksFuture ?? audioPlayerService.getLibraryTracks(),
              onDetailsTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TracksScreen(),
                ),
              ),
              onItemTap: (song) => _playTrack(audioPlayerService, song),
            ),
            const SizedBox(height: 24.0),
            buildCategorySection(
              title: AppLocalizations.of(context).albums,
              items: _albumsFuture ?? audioPlayerService.getMostPlayedAlbums(),
              onDetailsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlbumsScreen()),
              ),
              onItemTap: (album) {
                if (album is AlbumModel) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AlbumDetailScreen(albumName: album.album),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24.0),
            Selector<AudioPlayerService, List<Playlist>>(
              selector: (context, service) => service.playlists,
              builder: (context, playlists, child) {
                return buildCategorySection(
                  title: AppLocalizations.of(context).playlists,
                  items: audioPlayerService.getThreePlaylists(),
                  onDetailsTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlaylistsScreenList()),
                  ),
                  onItemTap: (playlist) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlaylistDetailScreen(playlist: playlist),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            buildCategorySection(
              title: AppLocalizations.of(context).artists,
              items:
                  _artistsFuture ?? audioPlayerService.getMostPlayedArtists(),
              onDetailsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArtistsScreen()),
              ),
              onItemTap: (artist) {
                if (artist is ArtistModel) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistDetailsScreen(
                        artistName: artist.artist,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24.0),
            buildCategorySection(
              title: AppLocalizations.of(context).folders,
              items: audioPlayerService.getThreeFolders(),
              onDetailsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoldersScreen()),
              ),
              onItemTap: (folder) {
                if (folder is String) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FolderDetailScreen(
                        folderPath: folder,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build a tablet-optimized grid layout for library categories
  /// Uses the same visual style as mobile but arranged in a 2-column grid
  Widget _buildTabletLayout(
      AudioPlayerService audioPlayerService, LayoutMode layoutMode) {
    final spacing = ResponsiveUtils.getSpacing(context);
    final isWideLayout = layoutMode == LayoutMode.wideWithPanel;

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            // First row: Tracks and Albums
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTabletCategorySection(
                    title: AppLocalizations.of(context).tracks,
                    items:
                        _tracksFuture ?? audioPlayerService.getLibraryTracks(),
                    onDetailsTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TracksScreen(),
                      ),
                    ),
                    onItemTap: (song) => _playTrack(audioPlayerService, song),
                    isWideLayout: isWideLayout,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: _buildTabletCategorySection(
                    title: AppLocalizations.of(context).albums,
                    items: _albumsFuture ??
                        audioPlayerService.getMostPlayedAlbums(),
                    onDetailsTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlbumsScreen()),
                    ),
                    onItemTap: (album) {
                      if (album is AlbumModel) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AlbumDetailScreen(albumName: album.album),
                          ),
                        );
                      }
                    },
                    isWideLayout: isWideLayout,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            // Second row: Playlists and Artists
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Selector<AudioPlayerService, List<Playlist>>(
                    selector: (context, service) => service.playlists,
                    builder: (context, playlists, child) {
                      return _buildTabletCategorySection(
                        title: AppLocalizations.of(context).playlists,
                        items: audioPlayerService.getThreePlaylists(),
                        onDetailsTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PlaylistsScreenList()),
                        ),
                        onItemTap: (playlist) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlaylistDetailScreen(playlist: playlist),
                            ),
                          );
                        },
                        isWideLayout: isWideLayout,
                      );
                    },
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: _buildTabletCategorySection(
                    title: AppLocalizations.of(context).artists,
                    items: _artistsFuture ??
                        audioPlayerService.getMostPlayedArtists(),
                    onDetailsTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ArtistsScreen()),
                    ),
                    onItemTap: (artist) {
                      if (artist is ArtistModel) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtistDetailsScreen(
                              artistName: artist.artist,
                            ),
                          ),
                        );
                      }
                    },
                    isWideLayout: isWideLayout,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            // Third row: Folders (full width)
            _buildTabletCategorySection(
              title: AppLocalizations.of(context).folders,
              items: audioPlayerService.getThreeFolders(),
              onDetailsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoldersScreen()),
              ),
              onItemTap: (folder) {
                if (folder is String) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FolderDetailScreen(
                        folderPath: folder,
                      ),
                    ),
                  );
                }
              },
              isWideLayout: isWideLayout,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Build a category section for tablet layout that matches mobile visual style
  Widget _buildTabletCategorySection({
    required String title,
    required dynamic items,
    required VoidCallback onDetailsTap,
    Function(dynamic)? onItemTap,
    bool isWideLayout = false,
    bool isFullWidth = false,
  }) {
    final theme = Theme.of(context);
    final cardSize = isWideLayout ? 120.0 : 110.0;
    final sectionHeight = cardSize + 60; // Card size + text space

    final detailsButtonContent = GlassFill(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        AppLocalizations.of(context).details,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: FontConstants.fontFamily,
          fontSize: 12,
        ),
      ),
    );

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 26,
                ),
              ),
              GestureDetector(
                onTap: onDetailsTap,
                child: detailsButtonContent,
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            height: sectionHeight,
            child: items is Future
                ? FutureBuilder<List<dynamic>>(
                    future: items as Future<List<dynamic>>,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CardSkeleton(size: cardSize),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(AppLocalizations.of(context)
                                .errorMessage('${snapshot.error}')));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context).noData,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      } else {
                        return _buildTabletItemsList(
                          snapshot.data!,
                          onItemTap,
                          cardSize,
                          isFullWidth ? 6 : 4,
                        );
                      }
                    },
                  )
                : _buildTabletItemsList(
                    items,
                    onItemTap,
                    cardSize,
                    isFullWidth ? 6 : 4,
                  ),
          ),
        ],
      ),
    );
  }

  /// Build items list for tablet layout with specified card size
  Widget _buildTabletItemsList(
    List<dynamic> items,
    Function(dynamic)? onItemTap,
    double cardSize,
    int maxItems,
  ) {
    final displayItems = items.take(maxItems).toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: displayItems.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return _buildTabletItemCard(context, item, onItemTap, cardSize);
      },
    );
  }

  /// Build individual item card for tablet layout
  Widget _buildTabletItemCard(
    BuildContext context,
    dynamic item,
    Function(dynamic)? onItemTap,
    double cardSize,
  ) {
    if (item is SongModel) {
      return GlassmorphicCard.song(
        key: ValueKey('tablet_song_${item.id}'),
        songId: item.id,
        title: item.title,
        artist: splitArtists(
                item.artist ?? AppLocalizations.of(context).unknownArtist)
            .join(', '),
        artworkService: _artworkService,
        onTap: () => onItemTap?.call(item),
        size: cardSize,
      );
    } else if (item is AlbumModel) {
      return GlassmorphicCard.album(
        key: ValueKey('tablet_album_${item.id}'),
        albumId: item.id,
        albumName: item.album,
        artistName: item.artist,
        artworkService: _artworkService,
        onTap: () => onItemTap?.call(item),
        size: cardSize,
      );
    } else if (item is Playlist) {
      final l10n = AppLocalizations.of(context);
      String playlistName;
      switch (item.id) {
        case 'most_played':
          playlistName = l10n.mostPlayed;
          break;
        case 'recently_added':
          playlistName = l10n.recentlyAdded;
          break;
        default:
          playlistName = item.name;
      }
      return GlassmorphicCard.playlist(
        key: ValueKey('tablet_playlist_${item.name}'),
        playlistName: playlistName,
        songCount: item.songs.length,
        subtitle: l10n.songCount(item.songs.length),
        playlistId: item.id,
        onTap: () => onItemTap?.call(item),
        size: cardSize,
      );
    } else if (item is ArtistModel) {
      return GlassmorphicCard.artist(
        key: ValueKey('tablet_artist_${item.artist}'),
        artistName: item.artist,
        artworkService: _artworkService,
        circularArtwork: false,
        onTap: () => onItemTap?.call(item),
        size: cardSize,
      );
    } else if (item is String) {
      return GlassmorphicCard.folder(
        key: ValueKey('tablet_folder_$item'),
        folderName: item.split('/').last,
        onTap: () => onItemTap?.call(item),
        size: cardSize,
      );
    }
    return const SizedBox.shrink();
  }

  Widget buildCategorySection({
    required String title,
    required dynamic items,
    required VoidCallback onDetailsTap,
    Function(dynamic)? onItemTap,
  }) {
    final theme = Theme.of(context);

    final detailsButtonContent = GlassFill(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        AppLocalizations.of(context).details,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: FontConstants.fontFamily,
        ),
      ),
    );

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: FontConstants.fontFamily,
                  fontSize: ResponsiveUtils.isTablet(context) ? 26 : null,
                ),
              ),
              GestureDetector(
                onTap: onDetailsTap,
                child: detailsButtonContent,
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            height: GlassmorphicCard.listHeight(context),
            child: items is Future
                ? FutureBuilder<List<dynamic>>(
                    future: items as Future<List<dynamic>>,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: CardSkeleton(size: 130),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(AppLocalizations.of(context)
                                .errorMessage('${snapshot.error}')));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context).noData,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      } else {
                        return _buildItemsList(snapshot.data!, onItemTap);
                      }
                    },
                  )
                : _buildItemsList(items, onItemTap),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<dynamic> items, Function(dynamic)? onItemTap) {
    final displayItems = items.take(5).toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: displayItems.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return _buildItemCard(context, item, onItemTap);
      },
    );
  }

  Widget _buildItemCard(
      BuildContext context, dynamic item, Function(dynamic)? onItemTap) {
    if (item is SongModel) {
      return GlassmorphicCard.song(
        key: ValueKey('song_${item.id}'),
        songId: item.id,
        title: item.title,
        artist: splitArtists(
                item.artist ?? AppLocalizations.of(context).unknownArtist)
            .join(', '),
        artworkService: _artworkService,
        onTap: () => onItemTap?.call(item),
      );
    } else if (item is AlbumModel) {
      return GlassmorphicCard.album(
        key: ValueKey('album_${item.id}'),
        albumId: item.id,
        albumName: item.album,
        artistName: item.artist,
        artworkService: _artworkService,
        onTap: () => onItemTap?.call(item),
      );
    } else if (item is Playlist) {
      final l10n = AppLocalizations.of(context);
      String playlistName;
      switch (item.id) {
        case 'most_played':
          playlistName = l10n.mostPlayed;
          break;
        case 'recently_added':
          playlistName = l10n.recentlyAdded;
          break;
        default:
          playlistName = item.name;
      }
      return GlassmorphicCard.playlist(
        key: ValueKey('playlist_${item.name}'),
        playlistName: playlistName,
        songCount: item.songs.length,
        subtitle: l10n.songCount(item.songs.length),
        playlistId: item.id,
        onTap: () => onItemTap?.call(item),
      );
    } else if (item is ArtistModel) {
      return GlassmorphicCard.artist(
        key: ValueKey('artist_${item.artist}'),
        artistName: item.artist,
        artworkService: _artworkService,
        circularArtwork: false,
        onTap: () => onItemTap?.call(item),
      );
    } else if (item is String) {
      return GlassmorphicCard.folder(
        key: ValueKey('folder_$item'),
        folderName: item.split('/').last,
        onTap: () => onItemTap?.call(item),
      );
    }
    return const SizedBox.shrink();
  }
}
