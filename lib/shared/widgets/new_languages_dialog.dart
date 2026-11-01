import 'dart:async';

import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../l10n/generated/app_localizations.dart';
import '../../features/settings/screens/appearance_settings_screen.dart'
    show showLanguagePicker;
import '../services/new_languages_service.dart';
import 'glassmorphic_dialog.dart';

/// Dialog shown once after new languages are added to Noxira Music.
/// It notifies the user and offers a shortcut to the language settings.
class NewLanguagesDialog extends StatelessWidget {
  final VoidCallback? onGoToSettings;

  const NewLanguagesDialog({super.key, this.onGoToSettings});

  /// Shows the dialog if there are newly registered languages the user has
  /// not yet been notified about. Marks them all as seen immediately so the
  /// dialog is never shown twice for the same set.
  static Future<void> showIfNeeded(
    BuildContext context, {
    VoidCallback? onGoToSettings,
  }) async {
    final newLangs = await NewLanguagesService.getNewLanguages();
    if (newLangs.isEmpty) return;

    await NewLanguagesService.markAllSeen();

    if (context.mounted) {
      unawaited(showDialog(
        context: context,
        builder: (_) => NewLanguagesDialog(onGoToSettings: onGoToSettings),
      ));
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
            l10n.newLanguagesAvailableTitle,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Body
          Text(
            l10n.newLanguagesAvailableBody,
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
                // Captured before pop; the dialog's own context is gone afterwards.
                final rootContext =
                    Navigator.of(context, rootNavigator: true).context;
                Navigator.pop(context);
                if (onGoToSettings != null) {
                  onGoToSettings!();
                } else {
                  showLanguagePicker(rootContext);
                }
              },
              icon: const iconoir.Settings(
                color: Colors.white,
                width: 20,
                height: 20,
              ),
              label: Text(
                l10n.newLanguagesGoToSettings,
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
              l10n.newLanguagesDismiss,
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
