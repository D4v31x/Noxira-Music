import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../../l10n/generated/app_localizations.dart';
import '../widgets/onboarding_kit.dart';

/// What the app does, in five plain rows.
class AppInfoPage extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const AppInfoPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const color = Colors.white;

    final features = <({Widget icon, String title, String body})>[
      (
        icon: const iconoir.Folder(color: color, width: 24, height: 24),
        title: l10n.onboardingLocalMusic,
        body: l10n.onboardingLocalMusicDesc,
      ),
      (
        icon: const iconoir.MediaImage(color: color, width: 24, height: 24),
        title: l10n.onboardingBeautifulArtwork,
        body: l10n.onboardingBeautifulArtworkDesc,
      ),
      (
        icon: const iconoir.Palette(color: color, width: 24, height: 24),
        title: l10n.onboardingMaterialDesign,
        body: l10n.onboardingMaterialDesignDesc,
      ),
      (
        icon:
            const iconoir.MusicDoubleNote(color: color, width: 24, height: 24),
        title: l10n.onboardingSmartPlaylists,
        body: l10n.onboardingSmartPlaylistsDesc,
      ),
      (
        icon: const iconoir.TextSize(color: color, width: 24, height: 24),
        title: l10n.onboardingLyricsSupport,
        body: l10n.onboardingLyricsSupportDesc,
      ),
    ];

    return StepScaffold(
      title: l10n.onboardingAppInfoSubtitle,
      primaryLabel: l10n.continueButton,
      onPrimary: onContinue,
      onBack: onBack,
      backLabel: l10n.back,
      children: [
        Column(
          spacing: 12,
          children: [
            for (var i = 0; i < features.length; i++)
              GlassRow(
                order: 2 + i,
                leading: features[i].icon,
                title: features[i].title,
                body: features[i].body,
              ),
          ],
        ),
      ],
    );
  }
}
