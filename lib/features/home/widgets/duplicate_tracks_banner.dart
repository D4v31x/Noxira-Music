import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/duplicate_tracks_service.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../library/screens/duplicate_tracks_screen.dart';

/// Inline card (not a popup) shown at the top of the library when duplicate
/// tracks are detected. Hidden when there is nothing to resolve.
class DuplicateTracksBanner extends StatefulWidget {
  const DuplicateTracksBanner({super.key});

  @override
  State<DuplicateTracksBanner> createState() => _DuplicateTracksBannerState();
}

class _DuplicateTracksBannerState extends State<DuplicateTracksBanner> {
  static const _accent = Color(0xFFFFB74D);
  final _service = DuplicateTracksService.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service.attach(context.read<AudioPlayerService>());
  }

  void _openReview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DuplicateTracksScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final count = _service.groups.length;
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: count == 0
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GlassPanel(
                    blur: false,
                    tint: _accent,
                    onTap: () => _openReview(context),
                    padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accent.withValues(alpha: 0.18),
                            border: Border.all(
                                color: _accent.withValues(alpha: 0.4)),
                          ),
                          child: const Center(
                            child: iconoir.Copy(
                                color: _accent, width: 22, height: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.duplicatesBannerTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.duplicatesBannerSubtitle(count),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _accent.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            l10n.duplicatesReview,
                            style: const TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: _accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.dismiss,
                          visualDensity: VisualDensity.compact,
                          onPressed: _service.ignoreAll,
                          icon: const iconoir.Xmark(
                              color: Colors.white60, width: 20, height: 20),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
