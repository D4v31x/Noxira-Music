import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/font_constants.dart';
import '../../features/library/library_feature.dart';
import '../../features/player/widgets/share_clip_sheet.dart';
import '../../features/settings/settings_feature.dart';
import '../../l10n/generated/app_localizations.dart';
import 'glassmorphic_dialog.dart';
import '../models/models.dart';
import '../services/artwork_cache_service.dart';
import '../services/audio_player_service.dart';
import '../services/lyrics_service.dart';
import '../services/notification_manager.dart';
import 'adaptive_blur.dart';
import 'add_to_playlist_sheet.dart';

// ---------------------------------------------------------------------------
// Public entry-point
// ---------------------------------------------------------------------------

/// Shows the song context bottom sheet for [song].
///
/// Call this from any long-press or 3-dot button tap.
Future<void> showSongContextMenu(BuildContext context, SongModel song) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(),
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => _SongContextMenu(song: song),
  );
}

// ---------------------------------------------------------------------------
// Private bottom-sheet widget
// ---------------------------------------------------------------------------

class _SongContextMenu extends StatelessWidget {
  final SongModel song;

  static final _artworkService = ArtworkCacheService();
  static const _channel = MethodChannel('aurora/media_actions');

  const _SongContextMenu({required this.song});

  @override
  Widget build(BuildContext context) {
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: AdaptiveBackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          child: Material(
            color: Colors.grey[900]!.withValues(alpha: 0.88),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Song header
                  _buildHeader(context),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 4),
                  // Menu items
                  _item(
                    context,
                    icon: Icons.playlist_add_rounded,
                    label: AppLocalizations.of(context).addToPlaylist,
                    onTap: () => _addToPlaylist(context, audioService),
                  ),
                  _item(
                    context,
                    icon: Icons.queue_music_rounded,
                    label: AppLocalizations.of(context).addToQueue,
                    onTap: () => _addToQueue(context, audioService),
                  ),
                  _item(
                    context,
                    icon: Icons.notifications_active_rounded,
                    label: AppLocalizations.of(context).setAsRingtone,
                    onTap: () => _setAsRingtone(context),
                  ),
                  _item(
                    context,
                    icon: Icons.share_rounded,
                    label: AppLocalizations.of(context).share,
                    onTap: () => _share(context),
                  ),
                  _item(
                    context,
                    icon: Icons.movie_creation_outlined,
                    label: AppLocalizations.of(context).saveAsClip,
                    onTap: () => _shareClip(context),
                  ),
                  _item(
                    context,
                    icon: Icons.edit_rounded,
                    label: AppLocalizations.of(context).songInfoEdit,
                    onTap: () => _editInfo(context),
                  ),
                  _item(
                    context,
                    icon: Icons.album_rounded,
                    label: AppLocalizations.of(context).goToAlbum,
                    onTap: () => _goToAlbum(context),
                  ),
                  _item(
                    context,
                    icon: Icons.person_rounded,
                    label: AppLocalizations.of(context).goToArtist,
                    onTap: () => _goToArtist(context),
                  ),
                  _item(
                    context,
                    icon: Icons.lyrics_rounded,
                    label: AppLocalizations.of(context).clearCachedLyrics,
                    onTap: () => _clearCachedLyrics(context),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _item(
                    context,
                    icon: Icons.delete_outline_rounded,
                    label: AppLocalizations.of(context).deleteFromDevice,
                    color: Colors.redAccent,
                    onTap: () => _deleteSong(context),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _artworkService.buildCachedArtwork(song.id, size: 52),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  splitArtists(song.artist ??
                          AppLocalizations.of(context).unknownArtist)
                      .join(', '),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontFamily: FontConstants.fontFamily,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }

  // ---- Actions ----

  void _addToPlaylist(BuildContext context, AudioPlayerService audioService) {
    // The menu's own context is deactivated once it is popped, so open the
    // sheet from the (long-lived) root navigator's context instead.
    final navigatorContext = Navigator.of(context, rootNavigator: true).context;
    Navigator.pop(context);
    unawaited(showAddToPlaylistSheet(navigatorContext, song));
  }

  Future<void> _addToQueue(
      BuildContext context, AudioPlayerService audioService) async {
    // The menu's context is deactivated once popped; use the root one after.
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final l10n = AppLocalizations.of(context);
    Navigator.pop(context);
    await audioService.addToQueue(song);
    if (rootContext.mounted) {
      NotificationManager.showMessage(
          rootContext, l10n.songAddedToQueue(song.title));
    }
  }

  Future<void> _setAsRingtone(BuildContext context) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final l10n = AppLocalizations.of(context);
    Navigator.pop(context);
    try {
      await _channel.invokeMethod('setAsRingtone', {'path': song.data});
      if (rootContext.mounted) {
        NotificationManager.showMessage(
            rootContext, l10n.songSetAsRingtone(song.title));
      }
    } on PlatformException catch (e) {
      if (!rootContext.mounted) return;
      if (e.code == 'PERMISSION_NEEDED') {
        NotificationManager.showMessage(
            rootContext, l10n.modifySystemSettingsPermission);
      } else {
        NotificationManager.showMessage(
            rootContext, l10n.failedToSetRingtone(e.message ?? ''));
      }
    }
  }

  void _share(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Navigator.pop(context);
    final text =
        '${song.title} — ${splitArtists(song.artist ?? l10n.unknownArtist).join(', ')}';
    SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: l10n.checkOutThisSong,
      ),
    );
  }

  void _shareClip(BuildContext context) {
    Navigator.pop(context);
    showShareClipSheet(context, song: song);
  }

  void _editInfo(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MetadataDetailScreen(song: song)),
    );
  }

  void _goToAlbum(BuildContext context) {
    Navigator.pop(context);
    if (song.album == null || song.album!.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AlbumDetailScreen(albumName: song.album!)),
    );
  }

  void _goToArtist(BuildContext context) {
    Navigator.pop(context);
    final artist =
        splitArtists(song.artist ?? AppLocalizations.of(context).unknownArtist)
            .first;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ArtistDetailsScreen(artistName: artist)),
    );
  }

  Future<void> _clearCachedLyrics(BuildContext context) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final l10n = AppLocalizations.of(context);
    Navigator.pop(context);
    final artist = song.artist?.trim().isNotEmpty == true
        ? song.artist!.trim()
        : l10n.unknown;
    final title =
        song.title.trim().isNotEmpty ? song.title.trim() : l10n.unknown;
    final deleted =
        await TimedLyricsService().deleteCachedLyricsForSong(artist, title);
    if (!rootContext.mounted) return;
    NotificationManager.showMessage(
      rootContext,
      deleted ? l10n.lyricsCleared(song.title) : l10n.noLyricsCached,
    );
  }

  Future<void> _deleteSong(BuildContext context) async {
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final l10n = AppLocalizations.of(context);
    Navigator.pop(context);

    final confirmed = await showDialog<bool>(
      context: rootContext,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) {
        return GlassmorphicDialog(
          title: Text(
            l10n.deleteSong,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: FontConstants.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            l10n.deleteSongConfirm(song.title),
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: FontConstants.fontFamily),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n.delete,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontFamily: FontConstants.fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _channel.invokeMethod('deleteSong', {'path': song.data});
      // Reflect the deletion across the whole app immediately, without waiting
      // for a full MediaStore rescan.
      await audioService.removeSongFromLibrary(song);
      if (rootContext.mounted) {
        NotificationManager.showMessage(
            rootContext, l10n.songDeleted(song.title));
      }
    } on PlatformException catch (e) {
      if (rootContext.mounted) {
        NotificationManager.showMessage(
            rootContext, l10n.failedToDelete(e.message ?? ''));
      }
    }
  }
}
