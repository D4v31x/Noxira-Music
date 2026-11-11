import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/donation_service.dart';
import '../widgets/onboarding_kit.dart';

/// A gentle ask for support, easy to skip.
class DonationPage extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const DonationPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const arrow =
        Icon(Icons.north_east_rounded, color: Colors.white70, size: 20);

    return StepScaffold(
      title: l10n.supportAurora,
      lead: l10n.enjoyingAuroraDesc,
      primaryLabel: l10n.continueButton,
      onPrimary: onContinue,
      onBack: onBack,
      backLabel: l10n.back,
      footnote: Text(l10n.donationNote,
          textAlign: TextAlign.center, style: OnboardingText.small),
      children: [
        Column(
          spacing: 12,
          children: [
            if (DonationService.enabled)
              GlassRow(
                order: 2,
                leading: const iconoir.CoffeeCup(
                    color: Colors.white, width: 24, height: 24),
                title: l10n.buyMeACoffee,
                trailing: arrow,
                onTap: () => DonationService.openBuyMeACoffee(),
              ),
            if (DonationService.enabled)
              GlassRow(
                order: 3,
                leading: const iconoir.Heart(
                    color: Colors.white, width: 24, height: 24),
                title: l10n.kofi,
                trailing: arrow,
                onTap: () => DonationService.openKofi(),
              ),
          ],
        ),
      ],
    );
  }
}
