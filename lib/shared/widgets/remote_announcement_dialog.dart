import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import '../services/remote_announcement_service.dart';
import 'announcement_destinations.dart';
import 'glassmorphic_dialog.dart';

/// Popup for a message published through Firebase Remote Config.
class RemoteAnnouncementDialog extends StatelessWidget {
  const RemoteAnnouncementDialog({super.key, required this.announcement});

  final RemoteAnnouncement announcement;

  static bool _showing = false;

  /// Shows the pending announcement, if any. It counts as seen only once the
  /// user has closed it, so if the app is closed first, it shows again next
  /// time.
  static Future<void> showIfNeeded(BuildContext context) async {
    if (_showing) return;
    _showing = true;
    try {
      final announcement = await RemoteAnnouncementService.pending();
      if (announcement == null || !context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.75),
        builder: (_) => RemoteAnnouncementDialog(announcement: announcement),
      );
      await RemoteAnnouncementService.markSeen(announcement);
    } finally {
      _showing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = announcement.title;
    final message = announcement.message;
    final buttonLabel = announcement.buttonLabel;
    final url = announcement.url;
    final screen = announcementScreens[announcement.screen];

    return GlassmorphicDialog(
      title: title == null ? null : Text(title),
      content: SingleChildScrollView(child: Text(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.close,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ),
        if (screen != null || url != null)
          TextButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              if (screen != null) {
                navigator
                    .push(MaterialPageRoute<void>(builder: (_) => screen()));
              } else {
                launchUrl(url!, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              buttonLabel ??
                  (screen != null
                      ? l10n.remoteAnnouncementOpenScreen
                      : l10n.remoteAnnouncementOpenLink),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: FontConstants.fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
