/// Header shared by the pages that open out of Now Playing (lyrics, queue):
/// the cover, title and artist land here from the player, tapping the cover
/// closes the page, and dragging the header pulls the page back down.
library;

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../shared/services/artist_separator_service.dart';
import 'lyrics/lyrics_constants.dart';
import 'lyrics/lyrics_header_cover.dart';
import 'player_page_route.dart';

/// Hides [child] while the route's shuttle draws the shared element for it.
Widget playerPageSharedTarget(
  PlayerPageRoute<dynamic>? route,
  GlobalKey key,
  Widget child,
) {
  if (route == null) return KeyedSubtree(key: key, child: child);
  return ValueListenableBuilder<bool>(
    valueListenable: route.shuttleOn,
    child: child,
    builder: (context, shuttle, child) => KeyedSubtree(
      key: key,
      child: Opacity(opacity: shuttle ? 0 : 1, child: child),
    ),
  );
}

class PlayerPageHeader extends StatelessWidget {
  const PlayerPageHeader({
    super.key,
    required this.song,
    required this.targets,
    required this.onCoverTap,
    this.route,
    this.trailing = const [],
    this.leading,
    this.subtitle,
  });

  final SongModel? song;
  final PlayerPageTargets targets;
  final PlayerPageRoute<dynamic>? route;
  final VoidCallback onCoverTap;
  final List<Widget> trailing;
  final Widget? leading;

  /// Replaces the artist line when set.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final song = this.song;
    final route = this.route;

    Widget header = Padding(
      padding: EdgeInsets.fromLTRB(
          leading == null ? kLyricsHorizontalPadding : 4, 12, 8, 10),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 4),
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCoverTap,
            child: playerPageSharedTarget(
              route,
              targets.art,
              song == null
                  ? const SizedBox(
                      width: kLyricsHeaderArtSize,
                      height: kLyricsHeaderArtSize,
                    )
                  : LyricsHeaderCover(songId: song.id),
            ),
          ),
          const SizedBox(width: kLyricsHeaderGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                playerPageSharedTarget(
                  route,
                  targets.title,
                  Text(
                    song?.title ?? '',
                    style: kLyricsHeaderTitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                playerPageSharedTarget(
                  route,
                  targets.artist,
                  Text(
                    subtitle ??
                        (song?.artist == null
                            ? ''
                            : ArtistSeparatorService()
                                .splitArtists(song!.artist!)
                                .join(', ')),
                    style: kLyricsHeaderArtistStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ...trailing,
        ],
      ),
    );

    if (route != null) {
      final travel = PlayerPageScope.dragTravel(context);
      header = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: (_) => route.beginDrag(),
        onVerticalDragUpdate: (d) => route.dragBy(-d.delta.dy / travel),
        onVerticalDragEnd: (d) =>
            route.endDrag(-(d.primaryVelocity ?? 0) / travel),
        onVerticalDragCancel: () => route.endDrag(0),
        child: header,
      );
    }
    return header;
  }
}
