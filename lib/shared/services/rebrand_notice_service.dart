import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the one-time "Aurora is now Noxira" page has been handled.
class RebrandNoticeService {
  RebrandNoticeService._();

  static const String _seenKey = 'rebrand_notice_seen';

  static Future<bool> hasBeenHandled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }

  /// Fresh installs call this too, so only updating users ever see the page.
  static Future<void> markHandled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }
}
