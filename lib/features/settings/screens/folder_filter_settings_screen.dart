/// Library folder filter — choose which folders are included in the music library.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/folder_filter_service.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/expanding_player.dart';
import '../widgets/settings_tile_builders.dart';

class FolderFilterSettingsScreen extends StatefulWidget {
  const FolderFilterSettingsScreen({super.key});

  @override
  State<FolderFilterSettingsScreen> createState() =>
      _FolderFilterSettingsScreenState();
}

class _FolderFilterSettingsScreenState
    extends State<FolderFilterSettingsScreen> {
  final _filterService = FolderFilterService();
  final _audioQuery = OnAudioQuery();
  final _searchController = TextEditingController();

  /// All folders discovered from the MediaStore query.
  List<String> _allFolders = [];

  /// Folders visible after applying the search filter.
  List<String> _visibleFolders = [];

  /// Song count per folder path (unfiltered total).
  Map<String, int> _songCounts = {};

  bool _isLoading = true;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearch);
    _loadFolders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadFolders() async {
    await _filterService.ensureInitialized();

    try {
      final songs = await _audioQuery.querySongs(
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      final counts = <String, int>{};
      for (final song in songs) {
        final folder = File(song.data).parent.path;
        counts[folder] = (counts[folder] ?? 0) + 1;
      }

      final sorted = counts.keys.toList()..sort();

      if (mounted) {
        setState(() {
          _allFolders = sorted;
          _visibleFolders = sorted;
          _songCounts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('FolderFilter: error loading folders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _visibleFolders = q.isEmpty
          ? _allFolders
          : _allFolders.where((f) => f.toLowerCase().contains(q)).toList();
    });
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _toggle(String folder, bool excluded) async {
    await _filterService.setExcluded(folder, excluded);
    if (mounted) setState(() {});
  }

  void _applyAndPop() => Navigator.pop(context);

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns just the last path component as a display name.
  String _displayName(String path) =>
      path.split('/').where((p) => p.isNotEmpty).last;

  int get _excludedCount => _filterService.excludedFolders.length;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _applyAndPop();
      },
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: iconoir.NavArrowLeft(
                color: isDark ? Colors.white : Colors.black,
                width: 28,
                height: 28,
              ),
              onPressed: _applyAndPop,
            ),
            title: Text(
              AppLocalizations.of(context).folderFilterTitle,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          body: Selector<AudioPlayerService, bool>(
            selector: (_, s) => s.currentSong != null,
            builder: (context, hasCurrentSong, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search bar ─────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchFolders,
                      hintStyle: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: iconoir.Search(
                          color: isDark ? Colors.white54 : Colors.black45,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: iconoir.Xmark(
                                  color:
                                      isDark ? Colors.white54 : Colors.black45,
                                  width: 20,
                                  height: 20),
                              onPressed: () {
                                _searchController.clear();
                                _applySearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                // ── Info header ────────────────────────────────────────────
                SettingsTiles.buildSectionHeader(
                  context,
                  _isLoading
                      ? '${AppLocalizations.of(context).loading}…'
                      : '${AppLocalizations.of(context).foldersCountPlural(_allFolders.length)}'
                          '${_excludedCount > 0 ? ' · ${AppLocalizations.of(context).foldersExcludedCount(_excludedCount)}' : ''}',
                ),

                // ── Folder list ────────────────────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _visibleFolders.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: hasCurrentSong
                                    ? ExpandingPlayer
                                        .getMiniPlayerPaddingHeight(context)
                                    : MediaQuery.of(context).padding.bottom +
                                        24,
                              ),
                              itemCount: _visibleFolders.length,
                              itemBuilder: (context, i) => _FolderTile(
                                folder: _visibleFolders[i],
                                displayName: _displayName(_visibleFolders[i]),
                                songCount: _songCounts[_visibleFolders[i]] ?? 0,
                                isExcluded: _filterService
                                    .isExcluded(_visibleFolders[i]),
                                isDark: isDark,
                                onToggle: (v) => _toggle(_visibleFolders[i], v),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconoir.FolderMinus(
            width: 52,
            height: 52,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).noFoldersFound,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Folder tile ───────────────────────────────────────────────────────────────

class _FolderTile extends StatelessWidget {
  final String folder;
  final String displayName;
  final int songCount;
  final bool isExcluded;
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const _FolderTile({
    required this.folder,
    required this.displayName,
    required this.songCount,
    required this.isExcluded,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final included = !isExcluded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SettingsTiles.buildGlassRow(
        context,
        active: included,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: SizedBox(
              width: 28,
              child: Center(
                  child:
                      (included ? iconoir.Folder.new : iconoir.FolderMinus.new)(
                width: 20,
                height: 20,
                color: included
                    ? Colors.white
                    : (isDark ? Colors.white38 : Colors.black26),
              ))),
          title: Text(
            displayName,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: included
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                folder,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(context).songsCountPlural(songCount),
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          trailing: SettingsTiles.glassSwitchTheme(
            context,
            Switch(
              value: included,
              onChanged: (v) => onToggle(!v),
            ),
          ),
        ),
      ),
    );
  }
}
