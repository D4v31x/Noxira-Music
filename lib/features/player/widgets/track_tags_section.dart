/// Widget shown on the Now Playing screen (between the playback controls
/// and the lyrics section) for tagging/jumping between named parts of a
/// single long track — e.g. marking where each song starts within a DJ mix.
///
/// - If the current track already has tags, renders a scrollable list of
///   them (time + name); tapping a tag seeks the player to that position.
/// - If the track has no tags yet but is longer than [_setThreshold], shows
///   a lightweight suggestion bar inviting the user to tag it.
/// - Otherwise renders nothing.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/models/track_tag_model.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/track_tag_service.dart';
import '../../../shared/utils/formatters/duration_formatter.dart';
import '../../../shared/widgets/optimized_tiles.dart' show NowPlayingBars;
import '../screens/track_tag_editor_screen.dart';

const double _kTagsBoxHeight = 220;

/// Index of the tag currently playing — the last tag whose position is at
/// or before [position] — or -1 if [position] precedes every tag.
int _activeTagIndex(List<TrackTag> tags, Duration position) {
  var active = -1;
  for (var i = 0; i < tags.length; i++) {
    if (tags[i].position <= position) {
      active = i;
    } else {
      break;
    }
  }
  return active;
}

class TrackTagsSection extends StatelessWidget {
  final AudioPlayerService audioPlayerService;
  final bool isTablet;

  const TrackTagsSection({
    super.key,
    required this.audioPlayerService,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final song = audioPlayerService.currentSong;
    if (song == null) return const SizedBox.shrink();

    return Consumer<TrackTagService>(
      builder: (context, trackTagService, _) {
        // suggestionDismissed loads eagerly alongside the tags themselves
        // (TrackTagService.load()), so there's no separate async round trip
        // that could flash the suggestion bar and then hide it a moment
        // later — that was the source of the layout "jump".
        Widget child = const SizedBox.shrink();
        if (trackTagService.loaded) {
          final tags = trackTagService.tagsFor(song.id);
          if (tags.isNotEmpty) {
            child = _TagsListCard(
              tags: tags,
              audioPlayerService: audioPlayerService,
              isTablet: isTablet,
            );
          } else if (!trackTagService.suggestionDismissed) {
            child = _TagSuggestionBar(
              audioPlayerService: audioPlayerService,
              isTablet: isTablet,
              onDismiss: trackTagService.dismissSuggestion,
            );
          }
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
    );
  }
}

class _TagsListCard extends StatelessWidget {
  final List<TrackTag> tags;
  final AudioPlayerService audioPlayerService;
  final bool isTablet;

  const _TagsListCard({
    required this.tags,
    required this.audioPlayerService,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final song = audioPlayerService.currentSong!;

    return Column(
      children: [
        SizedBox(height: isTablet ? 40 : 30),
        SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                loc.trackTags,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontConstants.fontFamily,
                  letterSpacing: 0.5,
                ),
              ),
              Positioned(
                right: 16,
                child: IconButton(
                  tooltip: loc.editTrackTags,
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.white70, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackTagEditorScreen(song: song),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 24 : 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          // Only the active tag matters, so rebuild when it changes rather
          // than on every position tick.
          child: StreamBuilder<int>(
            stream: audioPlayerService.audioPlayer.positionStream
                .map((position) => _activeTagIndex(tags, position))
                .distinct(),
            initialData:
                _activeTagIndex(tags, audioPlayerService.audioPlayer.position),
            builder: (context, snapshot) {
              final activeIndex = snapshot.data ?? -1;

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: _kTagsBoxHeight,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      for (var index = 0; index < tags.length; index++) ...[
                        if (index > 0)
                          Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.08),
                            indent: 16,
                            endIndent: 16,
                          ),
                        Builder(builder: (context) {
                          final tag = tags[index];
                          final isActive = index == activeIndex;
                          return ColoredBox(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.transparent,
                            child: InkWell(
                              onTap: () => audioPlayerService.audioPlayer
                                  .seek(tag.position),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 56,
                                      child: Text(
                                        formatDuration(tag.position),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                              alpha: isActive ? 0.9 : 0.55),
                                          fontFamily: FontConstants.fontFamily,
                                          fontSize: 13,
                                          fontWeight: isActive
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures()
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        tag.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: FontConstants.fontFamily,
                                          fontSize: 14,
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isActive)
                                      NowPlayingBars(
                                        isPlaying: audioPlayerService.isPlaying,
                                        size: 16,
                                      )
                                    else
                                      const Icon(Icons.play_arrow_rounded,
                                          color: Colors.white38, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TagSuggestionBar extends StatelessWidget {
  final AudioPlayerService audioPlayerService;
  final bool isTablet;
  final VoidCallback onDismiss;

  const _TagSuggestionBar({
    required this.audioPlayerService,
    required this.isTablet,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final song = audioPlayerService.currentSong!;

    return Padding(
      // The like button's tap area adds ~21px above and the lyrics header
      // adds its own top spacing below, so this keeps the box centred between
      // the like row and the "Lyrics" title.
      padding: EdgeInsets.fromLTRB(16.0, isTablet ? 58.0 : 38.0, 16.0, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.bookmark_add_outlined,
                color: Colors.white70, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.isThisASet,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: FontConstants.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.tagPartsForEasySwitching,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 12,
                    ),
                  ),
                  // Under the text, not beside it: at large font sizes a
                  // button in the row would squeeze the text to a sliver.
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackTagEditorScreen(song: song),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(loc.tagThisTrack),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white38, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: AppLocalizations.of(context).dismiss,
            ),
          ],
        ),
      ),
    );
  }
}
