import 'package:flutter/material.dart';
import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../screens/listening_insights_screen.dart';

/// Holds computed library statistics
class _LibraryStats {
  final int totalSongs;
  final int totalArtists;
  final int totalAlbums;
  final int totalPlaylists;
  final int totalHours;
  final int totalMinutes;

  const _LibraryStats({
    required this.totalSongs,
    required this.totalArtists,
    required this.totalAlbums,
    required this.totalPlaylists,
    required this.totalHours,
    required this.totalMinutes,
  });

  /// Compute stats from songs and playlists - expensive, should be cached
  static _LibraryStats compute(List<SongModel> songs, int playlistCount) {
    final uniqueArtists = <String>{};
    final uniqueAlbums = <String>{};
    int totalDurationMs = 0;

    for (final song in songs) {
      if (song.artist != null && song.artist!.isNotEmpty) {
        uniqueArtists.addAll(splitArtists(song.artist!));
      }
      if (song.album != null && song.album!.isNotEmpty) {
        uniqueAlbums.add(song.album!);
      }
      totalDurationMs += song.duration ?? 0;
    }

    return _LibraryStats(
      totalSongs: songs.length,
      totalArtists: uniqueArtists.length,
      totalAlbums: uniqueAlbums.length,
      totalPlaylists: playlistCount,
      totalHours: (totalDurationMs / 1000 / 60 / 60).floor(),
      totalMinutes: ((totalDurationMs / 1000 / 60) % 60).floor(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LibraryStats &&
          totalSongs == other.totalSongs &&
          totalPlaylists == other.totalPlaylists;

  @override
  int get hashCode => totalSongs.hashCode ^ totalPlaylists.hashCode;
}

const _tabular = [FontFeature.tabularFigures()];

/// Library overview on the home screen: the song count leads, with the total
/// playing time next to it, and the artist, album and playlist counts in one
/// divided row below. Opens the listening insights.
///
/// No backdrop blur: the app's blurred background already sits behind it and
/// the card is always on screen.
class MusicStatsCard extends StatefulWidget {
  const MusicStatsCard({super.key});

  @override
  State<MusicStatsCard> createState() => _MusicStatsCardState();
}

class _MusicStatsCardState extends State<MusicStatsCard> {
  // Memoization: only re-run the expensive _LibraryStats.compute() when the
  // song or playlist count actually changes.  During normal playback the
  // AudioPlayerService fires ~60 notifyListeners/sec (position debounce);
  // without memoization, compute() would iterate every song on every tick.
  _LibraryStats? _cachedStats;
  int _lastSongCount = -1;
  int _lastPlaylistCount = -1;
  bool _pressed = false;

  _LibraryStats _getMemoizedStats(List<SongModel> songs, int playlistCount) {
    if (songs.length == _lastSongCount &&
        playlistCount == _lastPlaylistCount &&
        _cachedStats != null) {
      return _cachedStats!;
    }
    _lastSongCount = songs.length;
    _lastPlaylistCount = playlistCount;
    _cachedStats = _LibraryStats.compute(songs, playlistCount);
    return _cachedStats!;
  }

  static String _formatNumber(int number) {
    if (number >= 10000) return '${(number / 1000).toStringAsFixed(0)}k';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Selector only extracts the two integer counts — O(1) per notification.
    // shouldRebuild ensures the builder body only runs when counts change, at
    // which point _getMemoizedStats() performs the full O(n) computation once.
    return Selector<AudioPlayerService, (int, int)>(
      selector: (_, service) =>
          (service.songs.length, service.playlists.length),
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, counts, _) {
        final audioPlayerService =
            Provider.of<AudioPlayerService>(context, listen: false);
        final stats = _getMemoizedStats(audioPlayerService.songs, counts.$2);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ListeningInsightsScreen(),
            ),
          ),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassPanel(
                radius: 22,
                blur: false,
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.yourLibrary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            size: 22, color: Colors.white54),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatNumber(stats.totalSongs),
                            style: const TextStyle(
                              fontSize: 36,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              fontFamily: FontConstants.fontFamily,
                              fontFeatures: _tabular,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.songs,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white60,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${stats.totalHours}h ${stats.totalMinutes}m',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontConstants.fontFamily,
                              fontFeatures: _tabular,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            _Figure(
                              value: _formatNumber(stats.totalArtists),
                              label: l10n.artists,
                            ),
                            const _Hairline(),
                            _Figure(
                              value: _formatNumber(stats.totalAlbums),
                              label: l10n.albums,
                              inset: true,
                            ),
                            const _Hairline(),
                            _Figure(
                              value: _formatNumber(stats.totalPlaylists),
                              label: l10n.playlists,
                              inset: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: Colors.white.withValues(alpha: 0.12));
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.value,
    required this.label,
    this.inset = false,
  });

  final String value;
  final String label;

  /// Figures after the first sit off the divider on their left.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: inset ? 14 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontConstants.fontFamily,
                  fontFeatures: _tabular,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: FontConstants.fontFamily,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
