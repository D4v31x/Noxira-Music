import 'dart:async';

import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import '../services/translation_reminder_service.dart';
import 'glassmorphic_dialog.dart';

/// A glassmorphic dialog encouraging non-English users to help translate
/// Noxira Music on Crowdin.
class TranslationReminderDialog extends StatelessWidget {
  const TranslationReminderDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final shouldShow = await TranslationReminderService.shouldShowPrompt();

    if (shouldShow && context.mounted) {
      await TranslationReminderService.markShown();

      if (context.mounted) {
        unawaited(showDialog(
          context: context,
          builder: (context) => const TranslationReminderDialog(),
        ));
      }
    }
  }

  void _openCrowdin() async {
    final url = Uri.parse('https://crowdin.com/project/aurora-music');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final colorScheme = Theme.of(context).colorScheme;

    final innerContent = GlassDialogSurface(
      borderRadius: 24,
      alwaysDark: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: iconoir.Language(
                color: colorScheme.primary,
                width: 44,
                height: 44,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            l10n.contributeTranslationsTitle,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            l10n.contributeTranslationsSubtitle,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Primary action
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openCrowdin();
              },
              icon: const iconoir.Language(
                color: Colors.white,
                width: 20,
                height: 20,
              ),
              label: Text(
                l10n.contributeTranslationsOpenCrowdin,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Dismiss
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.maybeLater,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: innerContent,
      ),
    );
  }
}
