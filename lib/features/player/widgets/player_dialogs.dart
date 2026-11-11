import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/font_constants.dart';
import '../../../shared/widgets/glassmorphic_dialog.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/notification_manager.dart';
import '../../../shared/widgets/music_metadata_widget.dart';
import '../screens/queue_page.dart';
import 'lyrics_page_launcher.dart';
import 'player_page_route.dart';
import '../../../shared/widgets/add_to_playlist_sheet.dart';

/// Opens the "add to playlist" sheet for the current song.
void showAddToPlaylistDialog(
    BuildContext context, AudioPlayerService audioPlayerService) {
  final song = audioPlayerService.currentSong;
  if (song == null) {
    NotificationManager.showMessage(
      context,
      AppLocalizations.of(context).noSongPlaying,
    );
    return;
  }
  unawaited(showAddToPlaylistSheet(context, song));
}

/// Share the current song.
void shareSong(BuildContext context, AudioPlayerService audioPlayerService) {
  if (audioPlayerService.currentSong == null) return;

  final l10n = AppLocalizations.of(context);
  final song = audioPlayerService.currentSong!;
  final shareText =
      '${song.title} - ${splitArtists(song.artist ?? l10n.unknownArtist).join(", ")}';

  SharePlus.instance.share(
    ShareParams(
      text: shareText,
      subject: l10n.checkOutThisSong,
    ),
  );
}

/// Shows a dialog displaying the current playback queue with full management capabilities.
void showQueueDialog(
    BuildContext context, AudioPlayerService audioPlayerService,
    {bool fromCard = false}) {
  openPlayerPage(
    context,
    fromCard: fromCard,
    sourceKey: fromCard ? PlayerPageSources.queueCard : null,
    rows: fromCard
        ? [
            for (final song
                in audioPlayerService.upcomingQueue.take(kPlayerPageRows))
              PlayerPageRowShuttle(
                image:
                    ArtworkCacheService().getCachedImageProviderSync(song.id),
                title: song.title,
                artist: splitArtists(song.artist ??
                        AppLocalizations.of(context).unknownArtist)
                    .join(', '),
              ),
          ]
        : const [],
    builder: (targets) => QueuePage(
      audioPlayerService: audioPlayerService,
      targets: targets,
    ),
  );
}

/// Shows a dialog displaying detailed song information.
void showSongInfoDialog(
    BuildContext context, AudioPlayerService audioPlayerService) {
  final song = audioPlayerService.currentSong;
  if (song == null) {
    NotificationManager.showMessage(
      context,
      AppLocalizations.of(context).noSongPlaying,
    );
    return;
  }

  final colorScheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context);

  // Truncate path to last 2 segments for readability
  final pathParts = song.data.split('/');
  final shortPath = pathParts.length > 2
      ? '…/${pathParts[pathParts.length - 2]}/${pathParts.last}'
      : song.data;

  showGlassmorphicDialog<void>(
    context: context,
    builder: (ctx) => GlassmorphicDialog(
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.music_note_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.songInfo,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MusicMetadataWidget(song: song),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 4),
          InfoRow(
            icon: Icons.title_rounded,
            label: l10n.title,
            value: song.title,
          ),
          InfoRow(
            icon: Icons.person_outline_rounded,
            label: l10n.artist,
            value: splitArtists(song.artist ?? l10n.unknownArtist).join(', '),
          ),
          InfoRow(
            icon: Icons.album_outlined,
            label: l10n.album,
            value: song.album ?? l10n.unknownAlbum,
          ),
          InfoRow(
            icon: Icons.folder_outlined,
            label: l10n.songInfoPath,
            value: shortPath,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        GlassmorphicTextButton(
          isPrimary: true,
          onPressed: () {
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}

/// A labeled info row widget for displaying label-value pairs.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final int maxLines;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = iconColor ?? cs.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: color.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
