import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/supported_languages.dart';
import '../widgets/onboarding_kit.dart';

const _crowdinProjectUrl = 'https://crowdin.com/project/aurora-music';

/// Invites the user to help translate; shows the languages that exist today.
class TranslationContributionPage extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const TranslationContributionPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  Future<void> _openCrowdin() async {
    final uri = Uri.parse(_crowdinProjectUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StepScaffold(
      title: l10n.contributeTranslationsTitle,
      lead: l10n.contributeTranslationsSubtitle,
      primaryLabel: l10n.onboardingContinue,
      onPrimary: onContinue,
      onBack: onBack,
      backLabel: l10n.onboardingBack,
      children: [
        GlassPanel(
          order: 2,
          padding: const EdgeInsets.all(18),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final language in SupportedLanguages.all)
                _LanguageChip(label: language.nativeName),
              _LanguageChip(
                label: l10n.onboardingYourLanguage,
                highlighted: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassButton(
          order: 3,
          label: l10n.contributeTranslationsOpenCrowdin,
          icon: const Icon(Icons.open_in_new_rounded,
              color: Colors.white, size: 19),
          onPressed: () => unawaited(_openCrowdin()),
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.label, this.highlighted = false});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: highlighted ? Colors.white : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FontConstants.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: highlighted ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
