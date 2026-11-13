import '../../../shared/widgets/motion/musicfy_motion.dart';
import 'dart:async';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/smart_playlist_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/expanding_player.dart';
import '../../../shared/widgets/library_screen_header.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/glassmorphic_dialog.dart';
import '../../../shared/providers/performance_mode_provider.dart';
import '../../../shared/utils/sort_preferences.dart';
import 'playlist_detail_screen.dart';
import 'smart_playlist_editor_screen.dart';
import '../../../shared/widgets/adaptive_blur.dart';
import '../../../shared/services/notification_manager.dart';

/// Data class to hold playlist-related state for efficient rebuilds
class _PlaylistsState {
  final Playlist? likedPlaylist;
  final List<Playlist> autoPlaylists;
  final List<Playlist> userPlaylists;

  const _PlaylistsState({
    required this.likedPlaylist,
    required this.autoPlaylists,
    required this.userPlaylists,
  });

  static _PlaylistsState fromService(AudioPlayerService service) {
    final likedPlaylist = service.likedSongsPlaylist;
    final autoPlaylists = service.playlists
        .where((p) => p.id == 'most_played' || p.id == 'recently_added')
        .toList();
    final userPlaylists = service.playlists
        .where((p) =>
            p.id != 'most_played' &&
            p.id != 'recently_added' &&
            p.id != 'liked_songs')
        .toList();
    return _PlaylistsState(
      likedPlaylist: likedPlaylist,
      autoPlaylists: autoPlaylists,
      userPlaylists: userPlaylists,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PlaylistsState) return false;
    if (likedPlaylist?.songs.length != other.likedPlaylist?.songs.length) {
      return false;
    }
    if (autoPlaylists.length != other.autoPlaylists.length) return false;
    if (userPlaylists.length != other.userPlaylists.length) return false;
    for (var i = 0; i < userPlaylists.length; i++) {
      if (userPlaylists[i].id != other.userPlaylists[i].id ||
          userPlaylists[i].name != other.userPlaylists[i].name) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        likedPlaylist?.songs.length ?? 0,
        autoPlaylists.length,
        Object.hashAll(userPlaylists.map((p) => Object.hash(p.id, p.name))),
      );
}

enum PlaylistSortOption { name, trackCount }

class PlaylistsScreenList extends StatefulWidget {
  const PlaylistsScreenList({super.key});

  @override
  State<PlaylistsScreenList> createState() => _PlaylistsScreenListState();
}

class _PlaylistsScreenListState extends State<PlaylistsScreenList> {
  final ArtworkCacheService _artworkService = ArtworkCacheService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PlaylistSortOption _sortOption = PlaylistSortOption.name;
  bool _isAscending = true;

  static const String _sortPrefsKey = 'playlists';

  @override
  void initState() {
    super.initState();
    _loadSortPreferences();
  }

  Future<void> _loadSortPreferences() async {
    final saved = await SortPreferences.load(_sortPrefsKey);
    if (!mounted) return;
    final index = saved.index;
    if (index != null &&
        index >= 0 &&
        index < PlaylistSortOption.values.length) {
      setState(() {
        _sortOption = PlaylistSortOption.values[index];
        _isAscending = saved.ascending;
      });
    }
  }

  void _persistSort() {
    unawaited(SortPreferences.save(
      _sortPrefsKey,
      optionIndex: _sortOption.index,
      ascending: _isAscending,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Playlist> _filterAndSort(List<Playlist> playlists) {
    var result = _searchQuery.isEmpty
        ? List<Playlist>.from(playlists)
        : playlists
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    switch (_sortOption) {
      case PlaylistSortOption.name:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PlaylistSortOption.trackCount:
        result.sort((a, b) => a.songs.length.compareTo(b.songs.length));
        break;
    }
    if (!_isAscending) result = result.reversed.toList();
    return result;
  }

  String _getSortLabel(PlaylistSortOption opt) {
    final l10n = AppLocalizations.of(context);
    switch (opt) {
      case PlaylistSortOption.name:
        return l10n.sortName;
      case PlaylistSortOption.trackCount:
        return l10n.tracks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Use Selector to only rebuild when playlists actually change
    return Selector<AudioPlayerService, _PlaylistsState>(
      selector: (_, service) => _PlaylistsState.fromService(service),
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, state, _) {
        final audioService = context.read<AudioPlayerService>();
        final query = _searchQuery.trim().toLowerCase();
        bool matches(String name) =>
            query.isEmpty || name.toLowerCase().contains(query);

        final collections = <_Collection>[
          if (state.likedPlaylist != null)
            _Collection(
              playlist: state.likedPlaylist!,
              name: localizations.favoriteSongs,
              asset: 'assets/images/UI/liked.png',
            ),
          for (final p in state.autoPlaylists)
            _Collection(
              playlist: p,
              name: p.id == 'most_played'
                  ? localizations.mostPlayed
                  : p.id == 'recently_added'
                      ? localizations.recentlyAdded
                      : p.name,
              asset: p.id == 'most_played'
                  ? 'assets/images/UI/mostplayed.png'
                  : 'assets/images/UI/recentlyadded.png',
            ),
        ].where((c) => matches(c.name)).toList();

        final userPlaylists =
            _filterAndSort(state.userPlaylists).where((p) => matches(p.name));
        final userList = userPlaylists.toList();
        final totalCount = state.userPlaylists.length +
            state.autoPlaylists.length +
            (state.likedPlaylist != null ? 1 : 0);

        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                _buildHeader(context, audioService, localizations, totalCount),

                // System collections: Favorites, Most Played, Recently Added.
                if (collections.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(localizations.autoPlaylists),
                  ),
                  SliverToBoxAdapter(
                    child: _TileGrid(
                      children: [
                        for (final c in collections)
                          _buildCollectionTile(
                            context,
                            name: c.name,
                            count: c.playlist.songs.length,
                            artwork: Image.asset(c.asset, fit: BoxFit.cover),
                            onTap: () => _openPlaylist(context, c.playlist),
                          ),
                      ],
                    ),
                  ),
                ],

                // Smart playlists, shown in the same tile style.
                SliverToBoxAdapter(
                  child: Consumer<SmartPlaylistService>(
                    builder: (context, smartService, _) {
                      final smart = smartService.smartPlaylists
                          .where((sp) => matches(sp.name))
                          .toList();
                      if (smart.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(localizations.smartPlaylists),
                          _TileGrid(
                            children: [
                              for (final sp in smart)
                                _buildSmartTile(
                                  context,
                                  sp,
                                  smartService,
                                  audioService,
                                  localizations,
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // The user's own playlists.
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    localizations.yourPlaylists,
                    count: state.userPlaylists.length,
                  ),
                ),
                if (state.userPlaylists.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(context, localizations),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;
                        final columns =
                            (constraints.crossAxisExtent / 190).ceil();
                        final cardWidth = (constraints.crossAxisExtent -
                                spacing * (columns - 1)) /
                            columns;
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            // Square artwork + name and track count.
                            mainAxisExtent: cardWidth + 50,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildPlaylistCard(
                              context,
                              userList[index],
                              audioService,
                              localizations,
                            ),
                            childCount: userList.length,
                          ),
                        );
                      },
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: ExpandingPlayer.getMiniPlayerPaddingHeight(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPlaylist(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AudioPlayerService audioService,
    AppLocalizations localizations,
    int totalCount,
  ) {
    return LibraryScreenHeader(
      badge: localizations.library,
      title: localizations.playlists,
      subtitle: localizations.playlistsCountPlural(totalCount),
      accentColor: Colors.pink,
      showBackButton: true,
      actions: [
        IconButton(
          tooltip: localizations.newPlaylist,
          icon: const iconoir.Plus(color: Colors.white, width: 24, height: 24),
          onPressed: () => _showCreatePlaylistDialog(context),
        ),
        PopupMenuButton<String>(
          icon: const iconoir.MoreVert(
              color: Colors.white, width: 24, height: 24),
          color: Colors.grey.shade900,
          onSelected: (value) {
            switch (value) {
              case 'import':
                _importPlaylist(context, audioService);
                break;
              case 'sync_folder':
                _chooseSyncFolder(context, audioService);
                break;
              case 'sync_now':
                _syncNow(context, audioService);
                break;
              case 'create_smart':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SmartPlaylistEditorScreen(),
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            _menuItem('import', localizations.importPlaylistM3u),
            _menuItem('sync_folder', localizations.setSyncFolder),
            _menuItem('sync_now', localizations.syncNow),
            _menuItem('create_smart', localizations.createSmartPlaylist),
          ],
        ),
        const SizedBox(width: 8),
      ],
      searchField: LibrarySearchField(
        controller: _searchController,
        hint: localizations.searchPlaylists,
        onChanged: (q) => setState(() => _searchQuery = q),
        hasQuery: _searchQuery.isNotEmpty,
        onClear: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
      ),
      controlsRow: Row(
        children: [
          Expanded(
            child: PopupMenuButton<PlaylistSortOption>(
              onSelected: (opt) {
                setState(() => _sortOption = opt);
                _persistSort();
              },
              color: Colors.grey.shade900,
              child: LibraryControlPill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const iconoir.Sort(
                        color: Colors.white70, width: 18, height: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getSortLabel(_sortOption),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const iconoir.NavArrowDown(
                        color: Colors.white70, width: 18, height: 18),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                _sortItem(PlaylistSortOption.name,
                    AppLocalizations.of(context).sortName),
                _sortItem(PlaylistSortOption.trackCount,
                    AppLocalizations.of(context).tracks),
              ],
            ),
          ),
          const SizedBox(width: 8),
          LibraryControlPill(
            onTap: () {
              setState(() => _isAscending = !_isAscending);
              _persistSort();
            },
            child: _isAscending
                ? const iconoir.ArrowUp(
                    color: Colors.white70, width: 18, height: 18)
                : const iconoir.ArrowDown(
                    color: Colors.white70, width: 18, height: 18),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  PopupMenuItem<PlaylistSortOption> _sortItem(
      PlaylistSortOption opt, String label) {
    return PopupMenuItem(
      value: opt,
      child: Row(
        children: [
          if (_sortOption == opt)
            const iconoir.Check(color: Colors.white, width: 18, height: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {int? count}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Compact tile: artwork on the left, name and track count on the right.
  /// Used for the automatic collections and smart playlists.
  Widget _buildCollectionTile(
    BuildContext context, {
    required String name,
    required int count,
    required Widget artwork,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final localizations = AppLocalizations.of(context);
    return Press3D(
      cornerRadius: 18,
      child: GlassPanel(
        blur: false,
        radius: 18,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Row(
          children: [
            ArtworkHero(
              radius: 18,
              child: SizedBox(width: 68, height: 68, child: artwork),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count ${localizations.tracks}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartTile(
    BuildContext context,
    SmartPlaylist sp,
    SmartPlaylistService smartService,
    AudioPlayerService audioService,
    AppLocalizations localizations,
  ) {
    final built = smartService.buildPlaylist(
      sp,
      library: audioService.songs,
      isLiked: audioService.isLiked,
      playCountOf: audioService.playCountFor,
    );
    return _buildCollectionTile(
      context,
      name: sp.name,
      count: built.songs.length,
      artwork: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.withValues(alpha: 0.7),
              Colors.blue.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: const Center(
          child: iconoir.Sparks(color: Colors.white, width: 28, height: 28),
        ),
      ),
      onTap: () => _openPlaylist(context, built),
      onLongPress: () => _showSmartPlaylistOptions(context, sp, smartService),
    );
  }

  /// Grid card: square artwork with a play button, name and track count.
  Widget _buildPlaylistCard(
    BuildContext context,
    Playlist playlist,
    AudioPlayerService audioService,
    AppLocalizations localizations,
  ) {
    return Press3D(
      cornerRadius: 22,
      child: GlassPanel(
        blur: false,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        onTap: () => _openPlaylist(context, playlist),
        onLongPress: () => _showPlaylistOptions(
            context, audioService, playlist, localizations),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ArtworkHero(
                radius: 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildPlaylistArtwork(playlist),
                    ),
                    if (playlist.songs.isNotEmpty)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: GestureDetector(
                          onTap: () =>
                              audioService.setPlaylist(playlist.songs, 0),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Center(
                              child: iconoir.Play(
                                  color: Colors.white, width: 18, height: 18),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${playlist.songs.length} ${localizations.tracks}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistArtwork(Playlist playlist) {
    if (playlist.songs.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: Center(
          child: iconoir.MusicNote(
            color: Colors.white.withValues(alpha: 0.45),
            width: 40,
            height: 40,
          ),
        ),
      );
    }

    Widget art(int id) => SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: _artworkService.buildCachedArtwork(id, size: 200),
          ),
        );

    final ids = <int>{};
    for (final s in playlist.songs) {
      ids.add(s.id);
      if (ids.length == 4) break;
    }
    if (ids.length < 4) return art(playlist.songs.first.id);

    final list = ids.toList();
    return Column(
      children: [
        Expanded(
          child: Row(children: [
            Expanded(child: art(list[0])),
            Expanded(child: art(list[1])),
          ]),
        ),
        Expanded(
          child: Row(children: [
            Expanded(child: art(list[2])),
            Expanded(child: art(list[3])),
          ]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassPanel(
        blur: false,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const iconoir.PlaylistPlus(
                  color: Colors.white54, width: 48, height: 48),
              const SizedBox(height: 14),
              Text(
                localizations.noPlaylists,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                localizations.createFirstPlaylist,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              LibraryControlPill(
                onTap: () => _showCreatePlaylistDialog(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const iconoir.Plus(
                        color: Colors.white, width: 18, height: 18),
                    const SizedBox(width: 8),
                    Text(
                      localizations.newPlaylist,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSmartPlaylistOptions(
    BuildContext context,
    SmartPlaylist playlist,
    SmartPlaylistService smartService,
  ) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const iconoir.EditPencil(
                  color: Colors.white, width: 22, height: 22),
              title: Text(l10n.editSmartPlaylist,
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SmartPlaylistEditorScreen(existing: playlist),
                  ),
                );
              },
            ),
            ListTile(
              leading: const iconoir.Trash(
                  color: Colors.redAccent, width: 22, height: 22),
              title: Text(l10n.delete,
                  style: const TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => GlassmorphicDialog(
                    title: Text(l10n.editSmartPlaylist,
                        style: const TextStyle(color: Colors.white)),
                    content: Text(l10n.deleteSmartPlaylistConfirm,
                        style: const TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(l10n.delete,
                            style: const TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await smartService.deleteSmartPlaylist(playlist.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importPlaylist(
      BuildContext context, AudioPlayerService audioService) async {
    final loc = AppLocalizations.of(context);
    try {
      final result = await FilePicker.pickFile();
      final path = result?.path;
      if (path == null) return;
      final lower = path.toLowerCase();
      if (!lower.endsWith('.m3u') && !lower.endsWith('.m3u8')) {
        NotificationManager.show(loc.pleaseSelectM3uFile);
        return;
      }
      final playlist = await audioService.importPlaylistFromM3uFile(path);
      if (playlist == null) {
        NotificationManager.show(loc.noMatchingSongsForPlaylist);
      } else {
        NotificationManager.show(
            loc.importedPlaylist(playlist.name, playlist.songs.length));
      }
    } catch (e) {
      NotificationManager.show(loc.importFailed('$e'));
    }
  }

  Future<void> _chooseSyncFolder(
      BuildContext context, AudioPlayerService audioService) async {
    final loc = AppLocalizations.of(context);
    try {
      final folder = await FilePicker.getDirectoryPath();
      if (folder == null) return;
      await audioService.setPlaylistSyncFolder(folder);
      await audioService.syncPlaylistsWithFolder();
      NotificationManager.show(loc.playlistsSyncWith(folder));
    } catch (e) {
      NotificationManager.show(loc.couldNotSetSyncFolder('$e'));
    }
  }

  Future<void> _syncNow(
      BuildContext context, AudioPlayerService audioService) async {
    final loc = AppLocalizations.of(context);
    final folder = await audioService.playlistSyncFolder();
    if (folder == null) {
      NotificationManager.show(loc.setSyncFolderFirst);
      return;
    }
    try {
      final changed = await audioService.syncPlaylistsWithFolder();
      NotificationManager.show(
          changed ? loc.playlistsSynced : loc.alreadyUpToDate);
    } catch (e) {
      NotificationManager.show(loc.syncFailed('$e'));
    }
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    final controller = TextEditingController();
    final useBlur = Provider.of<PerformanceModeProvider>(context, listen: false)
        .shouldEnableGlassmorphic;

    showDialog(
      context: context,
      builder: (context) {
        final dialogContent = Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: useBlur
                ? Colors.white.withValues(alpha: 0.1)
                : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.newPlaylist,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: localizations.playlistName,
                    hintStyle: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        localizations.cancel,
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.text.isNotEmpty) {
                          final audioService = Provider.of<AudioPlayerService>(
                              context,
                              listen: false);
                          audioService.createPlaylist(controller.text, []);
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            localizations.create,
                            style: const TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        return Dialog(
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(),
          child: useBlur
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AdaptiveBackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: dialogContent,
                  ),
                )
              : dialogContent,
        );
      },
    );
  }

  void _showPlaylistOptions(
    BuildContext context,
    AudioPlayerService audioService,
    Playlist playlist,
    AppLocalizations localizations,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Playlist name
            Text(
              playlist.name,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Rename option
            _buildOptionTile(
              context,
              (color) =>
                  iconoir.EditPencil(color: color, width: 22, height: 22),
              localizations.rename,
              isDark,
              () {
                Navigator.pop(context);
                _showRenameDialog(context, audioService, playlist);
              },
            ),
            // Delete option
            _buildOptionTile(
              context,
              (color) => iconoir.Trash(color: color, width: 22, height: 22),
              localizations.delete,
              isDark,
              () {
                Navigator.pop(context);
                _showDeleteConfirmation(
                    context, audioService, playlist, localizations);
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    Widget Function(Color color) icon,
    String label,
    bool isDark,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            icon(isDestructive
                ? Colors.red
                : (isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: isDestructive
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    AudioPlayerService audioService,
    Playlist playlist,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    final controller = TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        child: GlassDialogSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.renamePlaylist,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: localizations.playlistName,
                    hintStyle: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        localizations.cancel,
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.text.isNotEmpty) {
                          audioService.renamePlaylist(
                              playlist.id, controller.text);
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            localizations.save,
                            style: const TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AudioPlayerService audioService,
    Playlist playlist,
    AppLocalizations localizations,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        child: GlassDialogSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconoir.Trash(
                color: Colors.red.withValues(alpha: 0.8),
                width: 48,
                height: 48,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.deletePlaylist,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${localizations.deletePlaylistConfirm} "${playlist.name}"?',
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: isDark ? Colors.white54 : Colors.black45,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        localizations.cancel,
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        audioService.deletePlaylist(playlist);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            localizations.delete,
                            style: const TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An automatic playlist (Favorites, Most Played, Recently Added) with its
/// localized name and artwork asset.
class _Collection {
  const _Collection({
    required this.playlist,
    required this.name,
    required this.asset,
  });

  final Playlist playlist;
  final String name;
  final String asset;
}

/// Lays tiles out in equal-width columns (two on phones, more on tablets).
/// With an odd number of tiles on two columns, the first one spans the full
/// width so the last row is never left with a gap.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});

  final List<Widget> children;

  static const double _spacing = 10;
  static const double _tileHeight = 68;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / 260).ceil();
          final tileWidth =
              (constraints.maxWidth - _spacing * (columns - 1)) / columns;
          final spanFirst = columns == 2 && children.length.isOdd;
          return Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: [
              for (var i = 0; i < children.length; i++)
                SizedBox(
                  width: i == 0 && spanFirst ? constraints.maxWidth : tileWidth,
                  height: _tileHeight,
                  child: children[i],
                ),
            ],
          );
        },
      ),
    );
  }
}
