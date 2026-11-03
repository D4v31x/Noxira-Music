/// "Up next" card on Now Playing: the next three songs, in the same card
/// style as the lyrics box. Tapping it opens the full queue page.
library;

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/performance_mode_provider.dart';
import '../../../shared/services/artist_separator_service.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/audio_player_service.dart';
import 'player_dialogs.dart';
import 'player_page_route.dart';

const int _kPreviewCount = 3;
const double _kRowArt = 44;

class QueuePreviewSection extends StatelessWidget {
  const QueuePreviewSection({
    super.key,
    required this.audioPlayerService,
    required this.isTablet,
  });

  final AudioPlayerService audioPlayerService;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLowEnd =
        Provider.of<PerformanceModeProvider>(context, listen: false)
            .isLowEndDevice;
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: audioPlayerService,
      builder: (context, _) {
        final upcoming =
            audioPlayerService.upcomingQueue.take(_kPreviewCount).toList();
        return Column(
          children: [
            SizedBox(height: isTablet ? 40 : 30),
            Text(
              l10n.queue,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 26 : 22,
                fontWeight: FontWeight.bold,
                fontFamily: FontConstants.fontFamily,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<double>(
                valueListenable: PlayerPageSources.cardChrome,
                builder: (context, chrome, child) => Container(
                  key: PlayerPageSources.queueCard,
                  width: double.infinity,
                  decoration: PlayerPageSources.forCard(
                              PlayerPageSources.queueCard, chrome) <
                          1
                      ? null
                      : BoxDecoration(
                          color: isLowEnd
                              ? colorScheme.surfaceContainerHigh
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isLowEnd
                                ? colorScheme.outlineVariant
                                : Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                  child: child,
                ),
                child: ValueListenableBuilder<double>(
                  valueListenable: PlayerPageSources.cardReveal,
                  builder: (context, reveal, child) => Opacity(
                    opacity: PlayerPageSources.forCard(
                        PlayerPageSources.queueCard, reveal),
                    child: child,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => showQueueDialog(context, audioPlayerService,
                          fromCard: true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: upcoming.isEmpty
                            ? SizedBox(
                                height: 72,
                                child: Center(
                                  child: Text(
                                    l10n.queueEmpty,
                                    style: TextStyle(
                                      fontFamily: FontConstants.fontFamily,
                                      color:
                                          Colors.white.withValues(alpha: 0.55),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  for (var i = 0; i < upcoming.length; i++)
                                    _row(upcoming[i], i),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _row(SongModel song, int index) {
    final keys =
        index < kPlayerPageRows ? PlayerPageSources.previewRows[index] : null;
    final artist = ArtistSeparatorService()
        .splitArtists(song.artist ?? 'Unknown Artist')
        .join(', ');
    final row = SizedBox(
      height: 56,
      child: Row(
        children: [
          ClipRRect(
            key: keys?.art,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: _kRowArt,
              height: _kRowArt,
              child: ArtworkCacheService()
                  .buildCachedArtwork(song.id, size: _kRowArt),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  key: keys?.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  artist,
                  key: keys?.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (keys == null) return row;
    // Its copy flies to the queue page; draw nothing here meanwhile.
    return ValueListenableBuilder<bool>(
      valueListenable: PlayerPageSources.hidden,
      child: row,
      builder: (context, hidden, child) => Opacity(
        opacity: hidden &&
                PlayerPageSources.activeCard == PlayerPageSources.queueCard
            ? 0
            : 1,
        child: child,
      ),
    );
  }
}
