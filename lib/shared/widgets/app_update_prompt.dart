import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import '../services/app_update_policy.dart';
import '../services/notification_manager.dart';
import 'glassmorphic_dialog.dart';

/// Shows what [AppUpdatePolicy] asks for: a dialog that can't be dismissed
/// when this version is no longer supported, or a one-time toast when a newer
/// version is only recommended.
class AppUpdatePrompt {
  AppUpdatePrompt._();

  static bool _showing = false;

  static Future<void> _openStore() => launchUrl(
        Uri.parse(AppUpdatePolicy.storeUrl),
        mode: LaunchMode.externalApplication,
      );

  static Future<void> showIfNeeded(BuildContext context) async {
    if (_showing) return;
    _showing = true;
    try {
      final notice = await AppUpdatePolicy.pending();
      if (notice == null || !context.mounted) return;
      final l10n = AppLocalizations.of(context);

      if (notice.level == UpdateLevel.recommended) {
        await AppUpdatePolicy.markRecommendedSeen(notice);
        NotificationManager.show(
          notice.message ?? l10n.updateVersionAvailable(notice.version),
          duration: const Duration(seconds: 8),
          actionLabel: l10n.updateNow,
          onAction: _openStore,
        );
        return;
      }

      // Required: stays up (and comes back on the next launch) until the
      // user has updated.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.85),
        builder: (_) => PopScope(
          canPop: false,
          child: GlassmorphicDialog(
            title: Text(l10n.updateRequiredTitle),
            content: Text(notice.message ?? l10n.updateRequiredMessage),
            actions: [
              TextButton(
                onPressed: _openStore,
                child: Text(
                  l10n.updateNow,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: FontConstants.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      _showing = false;
    }
  }
}
