import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../../l10n/generated/app_localizations.dart';
import '../widgets/onboarding_kit.dart';

/// Where the app talks to the internet, and what it sends.
class InternetUsagePage extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const InternetUsagePage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const color = Colors.white;

    final services = <({Widget icon, String title, String body})>[
      (
        icon: const iconoir.MediaImage(color: color, width: 24, height: 24),
        title: l10n.onboardingAlbumArtwork,
        body: l10n.onboardingAlbumArtworkDesc,
      ),
      (
        icon: const iconoir.InfoCircle(color: color, width: 24, height: 24),
        title: l10n.onboardingMusicMetadata,
        body: l10n.onboardingMusicMetadataDesc,
      ),
      (
        icon: const iconoir.TextSize(color: color, width: 24, height: 24),
        title: l10n.onboardingLyrics,
        body: l10n.onboardingLyricsDesc,
      ),
      (
        icon: const iconoir.Heart(color: color, width: 24, height: 24),
        title: l10n.onboardingSupportGoal,
        body: l10n.onboardingSupportGoalDesc,
      ),
      (
        icon: const iconoir.Bug(color: color, width: 24, height: 24),
        title: l10n.onboardingAnalytics,
        body: l10n.onboardingAnalyticsDesc,
      ),
    ];

    return StepScaffold(
      title: l10n.onboardingInternetTitle,
      lead: l10n.onboardingInternetSubtitle,
      primaryLabel: l10n.continueButton,
      onPrimary: onContinue,
      onBack: onBack,
      backLabel: l10n.back,
      children: [
        Column(
          spacing: 12,
          children: [
            for (var i = 0; i < services.length; i++)
              GlassRow(
                order: 2 + i,
                leading: services[i].icon,
                title: services[i].title,
                body: services[i].body,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Reveal(
          order: 2 + services.length,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: iconoir.Lock(color: color, width: 18, height: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  l10n.onboardingPrivacyNote,
                  textAlign: TextAlign.center,
                  style: OnboardingText.rowBody,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
