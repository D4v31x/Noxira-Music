import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/widgets/motion/like_burst.dart';
import '../../../shared/widgets/motion/musicfy_motion.dart';

/// A like/favorite button for the current song.
///
/// Liking sends a heart flying out of the button (see [LikeBurst]); it bounces
/// when the heart lands back on it.
class SongLikeButton extends StatelessWidget {
  final AudioPlayerService audioPlayerService;
  final double size;
  final Color likedColor;
  final Color unlikedColor;

  const SongLikeButton({
    super.key,
    required this.audioPlayerService,
    this.size = 30,
    this.likedColor = Colors.red,
    this.unlikedColor = Colors.white,
  });

  void _onTap(BuildContext context, bool wasLiked) {
    // Only animate when liking (not unliking)
    if (!wasLiked) {
      LikeBurst.play(context, color: likedColor, glyphWidth: size);
    }
    audioPlayerService.toggleLike(audioPlayerService.currentSong!);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: audioPlayerService.likedSongsNotifier,
      builder: (context, likedSongs, _) {
        final currentSong = audioPlayerService.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        final isLiked = likedSongs.contains(currentSong.id.toString());

        return SpringPress(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onTap(context, isLiked),
            child: SizedBox(
              width: size * 2.4,
              height: size * 2.4,
              child: Center(
                child: LikeBurstTarget(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isLiked
                        ? HeartSolid(
                            key: const ValueKey('liked'),
                            color: likedColor,
                            width: size,
                            height: size,
                          )
                        : Heart(
                            key: const ValueKey('unliked'),
                            color: unlikedColor,
                            width: size,
                            height: size,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
