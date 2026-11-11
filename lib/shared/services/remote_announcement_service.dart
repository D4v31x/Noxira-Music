import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote_config_helper.dart';

/// A message published through the `announcement_*` Firebase Remote Config
/// parameters, shown once per [id].
///
/// Only [message] is required, and `announcement_enabled` must be on. Without
/// an `announcement_id`, the id is derived from the text, so editing the
/// message makes it show again.
///
/// The button opens an in-app screen (`announcement_screen`) or a web link
/// (`announcement_url`); the screen wins when both are set.
@immutable
class RemoteAnnouncement {
  const RemoteAnnouncement({
    required this.id,
    required this.message,
    this.title,
    this.buttonLabel,
    this.url,
    this.screen,
    this.minVersion,
    this.maxVersion,
    this.expires,
  });

  final String id;
  final String message;
  final String? title;
  final String? buttonLabel;
  final Uri? url;

  /// Name of an in-app screen the button opens (see `announcementScreens`).
  /// Wins over [url] when it is a known screen.
  final String? screen;
  final Version? minVersion;
  final Version? maxVersion;
  final DateTime? expires;

  /// Builds the announcement from the Remote Config values (keys without the
  /// `announcement_` prefix). Returns null when it's switched off or has no
  /// message; malformed optional values are ignored, so a typo in the console
  /// can never break the app.
  static RemoteAnnouncement? fromValues(Map<String, String> values) {
    String? value(String key) {
      final v = values[key]?.trim();
      return v == null || v.isEmpty ? null : v;
    }

    final enabled = value('enabled')?.toLowerCase();
    if (enabled != 'true' && enabled != '1') return null;

    final message = value('message');
    if (message == null) return null;
    final title = value('title');

    final url = Uri.tryParse(value('url') ?? '');
    return RemoteAnnouncement(
      id: value('id') ??
          'auto-${md5.convert(utf8.encode('${title ?? ''}|$message')).toString().substring(0, 12)}',
      message: message,
      title: title,
      buttonLabel: value('button_label'),
      // Only web links are opened.
      url: url != null && (url.scheme == 'https' || url.scheme == 'http')
          ? url
          : null,
      screen: value('screen')?.toLowerCase(),
      minVersion: _version(value('min_version')),
      maxVersion: _version(value('max_version')),
      expires: DateTime.tryParse(value('expires') ?? ''),
    );
  }

  static Version? _version(String? value) {
    if (value == null) return null;
    try {
      return Version.parse(value);
    } catch (_) {
      return null;
    }
  }

  bool isActive({required Version appVersion, DateTime? now}) {
    if (expires != null && (now ?? DateTime.now()).isAfter(expires!)) {
      return false;
    }
    if (minVersion != null && appVersion < minVersion!) return false;
    if (maxVersion != null && appVersion > maxVersion!) return false;
    return true;
  }
}

/// Fetches the current announcement from Firebase Remote Config so messages
/// can be published from the Firebase console without an app update.
class RemoteAnnouncementService {
  RemoteAnnouncementService._();

  static const List<String> keys = [
    'enabled',
    'id',
    'title',
    'message',
    'button_label',
    'url',
    'screen',
    'min_version',
    'max_version',
    'expires',
  ];
  static const String _seenKey = 'remote_announcement_seen_ids';

  /// The announcement to show now, or null if there is none, it has been shown
  /// before, expired, or doesn't target this app version. Never throws.
  static Future<RemoteAnnouncement?> pending() async {
    try {
      final config = await RemoteConfigHelper.instance();
      if (config == null) return null;

      final announcement = RemoteAnnouncement.fromValues({
        for (final key in keys) key: config.getString('announcement_$key'),
      });
      if (announcement == null) return null;

      final info = await PackageInfo.fromPlatform();
      final appVersion = Version.parse(info.version.split('+').first);
      if (!announcement.isActive(appVersion: appVersion)) return null;

      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getStringList(_seenKey) ?? const [];
      return seen.contains(announcement.id) ? null : announcement;
    } catch (e) {
      debugPrint('⚠️ Remote announcement check failed: $e');
      return null;
    }
  }

  static Future<void> markSeen(RemoteAnnouncement announcement) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_seenKey) ?? <String>[];
    if (seen.contains(announcement.id)) return;
    // Keep the list from growing forever.
    final updated = [...seen, announcement.id];
    await prefs.setStringList(
      _seenKey,
      updated.length > 20 ? updated.sublist(updated.length - 20) : updated,
    );
  }
}
