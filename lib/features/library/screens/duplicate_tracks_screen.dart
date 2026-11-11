import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/duplicate_tracks_service.dart';
import '../../../shared/services/notification_manager.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/expanding_player.dart';
import '../../../shared/widgets/glass_panel.dart';

/// Lists groups of duplicate tracks and lets the user pick which copy to keep.
class DuplicateTracksScreen extends StatefulWidget {
  const DuplicateTracksScreen({super.key});

  @override
  State<DuplicateTracksScreen> createState() => _DuplicateTracksScreenState();
}

class _DuplicateTracksScreenState extends State<DuplicateTracksScreen> {
  static const _accent = Color(0xFFFFB74D);
  static const _mediaChannel = MethodChannel('aurora/media_actions');

  final _service = DuplicateTracksService.instance;
  final _artwork = ArtworkCacheService();

  /// Song id chosen to keep, per group signature. Defaults to the best copy.
  final Map<String, int> _keep = {};
  final Set<String> _busy = {};

  Future<void> _deleteOthers(DuplicateGroup group) async {
    final l10n = AppLocalizations.of(context);
    final audio = context.read<AudioPlayerService>();
    final keepId = _keep[group.signature] ?? group.best.id;
    final toDelete = group.songs.where((s) => s.id != keepId).toList();

    setState(() => _busy.add(group.signature));
    var failed = false;
    for (final song in toDelete) {
      try {
        await _mediaChannel.invokeMethod('deleteSong', {'path': song.data});
        await audio.removeSongFromLibrary(song);
      } on PlatformException {
        failed = true;
        break;
      }
    }
    if (!mounted) return;
    setState(() => _busy.remove(group.signature));
    _service.rescan();
    NotificationManager.showMessage(
      context,
      failed ? l10n.duplicatesDeleteFailed : l10n.duplicatesResolved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(
            l10n.duplicatesScreenTitle,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            ListenableBuilder(
              listenable: _service,
              builder: (context, _) => _service.groups.isEmpty
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: _service.ignoreAll,
                      child: Text(
                        l10n.duplicatesIgnoreAll,
                        style: const TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white70,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListenableBuilder(
          listenable: _service,
          builder: (context, _) {
            final groups = _service.groups;
            if (groups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const iconoir.CheckCircle(
                        color: Colors.white38, width: 56, height: 56),
                    const SizedBox(height: 12),
                    Text(
                      l10n.duplicatesEmpty,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white54,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                ExpandingPlayer.getMiniPlayerPaddingHeight(context),
              ),
              itemCount: groups.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.duplicatesHint,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return _buildGroup(l10n, groups[index - 1]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroup(AppLocalizations l10n, DuplicateGroup group) {
    final keepId = _keep[group.signature] ?? group.best.id;
    final keepValid = group.songs.any((s) => s.id == keepId);
    final effectiveKeep = keepValid ? keepId : group.best.id;
    final busy = _busy.contains(group.signature);

    return Padding(
      key: ValueKey(group.signature),
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassPanel(
        blur: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.best.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    l10n.duplicatesCopies(group.songs.length),
                    style: const TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < group.songs.length; i++)
              _buildCopy(
                l10n,
                group.songs[i],
                isBest: i == 0,
                selected: group.songs[i].id == effectiveKeep,
                enabled: !busy,
                onTap: () =>
                    setState(() => _keep[group.signature] = group.songs[i].id),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: busy ? null : () => _service.ignore(group),
                    child: Text(
                      l10n.duplicatesIgnore,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: busy ? null : () => _deleteOthers(group),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
                      foregroundColor: Colors.white,
                    ),
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const iconoir.Trash(
                            color: Colors.white, width: 18, height: 18),
                    label: Text(
                      l10n.duplicatesDeleteOthers(group.songs.length - 1),
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopy(
    AppLocalizations l10n,
    SongModel song, {
    required bool isBest,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final details = [
      song.fileExtension.toUpperCase(),
      _formatSize(song.size),
      _formatDuration(song.duration),
      _folderOf(song.data),
    ].where((s) => s.isNotEmpty).join(' • ');

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            selected
                ? const iconoir.CheckCircle(
                    color: _accent, width: 22, height: 22)
                : const iconoir.Circle(
                    color: Colors.white38, width: 22, height: 22),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _artwork.buildCachedArtwork(song.id, size: 44),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          song.album ?? song.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isBest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.duplicatesKeepBest,
                            style: const TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: _accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
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
          ],
        ),
      ),
    );
  }

  static String _formatSize(int bytes) =>
      bytes <= 0 ? '' : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  static String _formatDuration(int? ms) {
    if (ms == null || ms <= 0) return '';
    final total = ms ~/ 1000;
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }

  static String _folderOf(String path) {
    final parts = path.split('/');
    return parts.length >= 2 ? parts[parts.length - 2] : '';
  }
}
