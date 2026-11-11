/// Opens the fullscreen lyrics page out of the Now Playing screen.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';

import '../../../shared/models/models.dart';
import '../../../shared/services/artist_separator_service.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/audio_player_service.dart';
import '../screens/fullscreen_lyrics.dart';
import 'lyrics/lyrics_constants.dart';
import 'player_page_route.dart';

/// The on-screen rect of [key]'s box; null when it is missing or scrolled
/// out of view.
Rect? _globalRect(BuildContext context, GlobalKey key) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return null;
  final rect = box.localToGlobal(Offset.zero) & box.size;
  final screen = Offset.zero & MediaQuery.sizeOf(context);
  return rect.overlaps(screen) ? rect : null;
}

/// Pushes a page that opens out of Now Playing: the cover, title and artist
/// fly into the page's header when the launching screen has registered them in
/// [PlayerPageSources]. With [fromCard] the page also grows out of the lyrics
/// card, otherwise it rises from the bottom of the screen.
void openPlayerPage(
  BuildContext context, {
  required Widget Function(PlayerPageTargets targets) builder,
  bool fromCard = false,
  GlobalKey? sourceKey,
  List<PlayerPageRowShuttle> rows = const [],
}) {
  final audio = Provider.of<AudioPlayerService>(context, listen: false);
  final song = audio.currentSong;

  final targets = PlayerPageTargets();
  PlayerPageSources.activeCard =
      fromCard ? (sourceKey ?? PlayerPageSources.card) : null;
  final image = song == null
      ? null
      : ArtworkCacheService().getCachedImageProviderSync(song.id);

  Navigator.of(context).push(PlayerPageRoute<void>(
    targets: targets,
    rows: rows,
    cardRect: fromCard
        ? _globalRect(context, sourceKey ?? PlayerPageSources.card)
        : null,
    shuttle: song == null || image == null
        ? null
        : PlayerPageShuttle(
            image: image,
            title: song.title,
            artist: ArtistSeparatorService()
                .splitArtists(
                    song.artist ?? AppLocalizations.of(context).unknownArtist)
                .join(', '),
            titleTo: kLyricsHeaderTitleStyle,
            artistTo: kLyricsHeaderArtistStyle,
          ),
    builder: (_) => builder(targets),
  ));
}

/// Opens the fullscreen lyrics page out of the lyrics card.
void openLyricsPage(
  BuildContext context, {
  void Function(List<TimedLyric>)? onLyricsChanged,
  GlobalKey? sourceKey,
}) {
  if (Provider.of<AudioPlayerService>(context, listen: false).currentSong ==
      null) {
    return;
  }
  openPlayerPage(
    context,
    fromCard: true,
    sourceKey: sourceKey,
    builder: (targets) => FullscreenLyricsScreen(
      targets: targets,
      onLyricsChanged: onLyricsChanged,
    ),
  );
}
