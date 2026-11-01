import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../core/constants/font_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/performance_mode_provider.dart';
import '../services/artwork_cache_service.dart';
import '../services/audio_constants.dart';
import '../services/audio_player_service.dart';
import 'adaptive_blur.dart';

/// Bottom sheet for putting [song] into one (or several) of the user's
/// playlists. Feedback is shown inside the sheet itself, so nothing has to be
/// looked up on a context that has already been popped.
Future<void> showAddToPlaylistSheet(BuildContext context, SongModel song) {
  final audioService = Provider.of<AudioPlayerService>(context, listen: false);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _AddToPlaylistSheet(song: song, audioService: audioService),
  );
}

class _AddToPlaylistSheet extends StatefulWidget {
  const _AddToPlaylistSheet({required this.song, required this.audioService});

  final SongModel song;
  final AudioPlayerService audioService;

  @override
  State<_AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<_AddToPlaylistSheet> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  bool _creating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  /// Playlists the user can add to (not the automatic ones).
  List<Playlist> get _playlists => [
        for (final p in widget.audioService.playlists)
          if (p.id != kMostPlayedPlaylistId && p.id != kRecentlyAddedPlaylistId)
            p,
      ];

  void _add(Playlist playlist) {
    if (widget.audioService.addSongToPlaylist(playlist.id, widget.song)) {
      unawaited(HapticFeedback.lightImpact());
    }
    setState(() {});
  }

  void _remove(Playlist playlist) {
    widget.audioService.removeSongFromPlaylist(playlist.id, widget.song);
    unawaited(HapticFeedback.lightImpact());
    setState(() {});
  }

  void _createPlaylist() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.audioService.createPlaylist(name, [widget.song]);
    unawaited(HapticFeedback.lightImpact());
    _nameController.clear();
    _nameFocus.unfocus();
    setState(() => _creating = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final lowEnd =
        context.select<PerformanceModeProvider, bool>((p) => p.isLowEndDevice);
    final media = MediaQuery.of(context);
    final playlists = _playlists;

    final content = Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.78),
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 16 + media.viewInsets.bottom + media.padding.bottom),
      decoration: BoxDecoration(
        color: lowEnd
            ? scheme.surfaceContainerHigh
            : const Color(0xFF16161A).withValues(alpha: 0.88),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SongHeader(song: widget.song, title: l10n.addToPlaylist),
          const SizedBox(height: 16),
          _NewPlaylistRow(
            creating: _creating,
            controller: _nameController,
            focusNode: _nameFocus,
            label: l10n.newPlaylist,
            hint: l10n.playlistName,
            createLabel: l10n.create,
            onToggle: () {
              setState(() => _creating = !_creating);
              if (_creating) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _nameFocus.requestFocus());
              }
            },
            onCreate: _createPlaylist,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: playlists.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      l10n.noPlaylists,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: playlists.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final playlist = playlists[i];
                      final inIt = widget.audioService
                          .isSongInPlaylist(playlist.id, widget.song);
                      return _PlaylistRow(
                        playlist: playlist,
                        added: inIt,
                        addedLabel: l10n.songAddedChip,
                        removeHint: l10n.tapToRemove,
                        onTap: inIt
                            ? () => _remove(playlist)
                            : () => _add(playlist),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              textStyle: const TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(l10n.done),
          ),
        ],
      ),
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: lowEnd
            ? content
            : AdaptiveBackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: content,
              ),
      ),
    );
  }
}

class _SongHeader extends StatelessWidget {
  const _SongHeader({required this.song, required this.title});

  final SongModel song;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 52,
            height: 52,
            child: ArtworkCacheService().buildCachedArtwork(song.id, size: 52),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                song.artist ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NewPlaylistRow extends StatelessWidget {
  const _NewPlaylistRow({
    required this.creating,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.createLabel,
    required this.onToggle,
    required this.onCreate,
  });

  final bool creating;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final String createLabel;
  final VoidCallback onToggle;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AnimatedRotation(
                        turns: creating ? 0.125 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(Icons.add_rounded, color: primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (creating)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onCreate(),
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: Colors.white38),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: onCreate,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(createLabel),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({
    required this.playlist,
    required this.added,
    required this.addedLabel,
    required this.removeHint,
    required this.onTap,
  });

  final Playlist playlist;
  final bool added;
  final String addedLabel;
  final String removeHint;
  final VoidCallback onTap;

  static const _accent = Color(0xFFFFC857);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final coverId = playlist.songs.isNotEmpty ? playlist.songs.first.id : null;

    return Material(
      color: added
          ? _accent.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: coverId != null
                      ? ArtworkCacheService()
                          .buildCachedArtwork(coverId, size: 48)
                      : ColoredBox(
                          color: primary.withValues(alpha: 0.16),
                          child: Icon(Icons.queue_music_rounded,
                              color: primary, size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      added
                          ? '${playlist.songs.length}  ·  $removeHint'
                          : '${playlist.songs.length}',
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: added
                    ? Container(
                        key: const ValueKey('added'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: _accent),
                            const SizedBox(width: 4),
                            Text(
                              addedLabel,
                              style: const TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                color: _accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        key: const ValueKey('add'),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.add_rounded,
                            size: 20, color: Colors.white),
                      ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
