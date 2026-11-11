import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote_config_helper.dart';

enum UpdateLevel { recommended, required }

/// What the Firebase console asks of this app version.
class UpdateNotice {
  const UpdateNotice({
    required this.level,
    required this.version,
    this.message,
  });

  final UpdateLevel level;

  /// The version the user is asked to move to.
  final String version;

  /// Optional text from the console, shown instead of the default.
  final String? message;
}

/// Remote update policy, so a broken release can be pushed off without
/// shipping another one.
///
/// `update_min_version`: older versions get a dialog that can't be dismissed.
/// `update_recommended_version`: older versions get a one-time prompt.
/// `update_message`: optional text for either.
class AppUpdatePolicy {
  AppUpdatePolicy._();

  static const String _seenKey = 'update_recommended_seen';

  static const String storeUrl =
      'https://play.google.com/store/apps/details?id=com.aurorasoftware.music';

  static Version? _parse(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return Version.parse(value.split('+').first);
    } catch (_) {
      return null;
    }
  }

  /// A malformed console value is ignored, so a typo can never lock users out.
  static UpdateNotice? decide({
    required Version appVersion,
    String? minVersion,
    String? recommendedVersion,
    String? message,
    String? recommendedSeen,
  }) {
    final text = message == null || message.isEmpty ? null : message;
    final min = _parse(minVersion);
    if (min != null && appVersion < min) {
      return UpdateNotice(
        level: UpdateLevel.required,
        version: min.toString(),
        message: text,
      );
    }
    final recommended = _parse(recommendedVersion);
    if (recommended != null &&
        appVersion < recommended &&
        recommendedSeen != recommended.toString()) {
      return UpdateNotice(
        level: UpdateLevel.recommended,
        version: recommended.toString(),
        message: text,
      );
    }
    return null;
  }

  /// The notice for this app version right now, or null. Never throws.
  static Future<UpdateNotice?> pending() async {
    try {
      await RemoteConfigHelper.instance();
      final info = await PackageInfo.fromPlatform();
      final appVersion = _parse(info.version);
      if (appVersion == null) return null;
      final prefs = await SharedPreferences.getInstance();
      return decide(
        appVersion: appVersion,
        minVersion: RemoteConfigHelper.string('update_min_version'),
        recommendedVersion:
            RemoteConfigHelper.string('update_recommended_version'),
        message: RemoteConfigHelper.string('update_message'),
        recommendedSeen: prefs.getString(_seenKey),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> markRecommendedSeen(UpdateNotice notice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seenKey, notice.version);
  }
}
