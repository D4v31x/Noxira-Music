import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// This month's support goal, as published in the small JSON file at
/// [SupportGoalService.goalUrl].
@immutable
class SupportGoal {
  const SupportGoal({
    required this.goal,
    required this.raised,
    this.currency = '€',
  });

  final double goal;
  final double raised;
  final String currency;

  double get progress => goal <= 0 ? 0 : (raised / goal).clamp(0.0, 1.0);

  String format(double amount) {
    final text = amount == amount.roundToDouble()
        ? amount.round().toString()
        : amount.toStringAsFixed(2);
    return '$currency$text';
  }

  static const fallback = SupportGoal(goal: 50, raised: 0);

  factory SupportGoal.fromJson(Map<String, dynamic> json) {
    final goal = (json['goal'] as num?)?.toDouble();
    final raised = (json['raised'] as num?)?.toDouble();
    if (goal == null || raised == null || goal <= 0 || raised < 0) {
      throw const FormatException('Invalid support goal');
    }
    return SupportGoal(
      goal: goal,
      raised: raised,
      currency: (json['currency'] as String?)?.trim().isNotEmpty == true
          ? (json['currency'] as String).trim()
          : '€',
    );
  }
}

/// Decides when the "Support Noxira!" banner appears on the home app bar and
/// supplies the monthly goal it displays.
///
/// The goal is read from a tiny public JSON file (no personal data is sent);
/// the last good value is cached and a built-in default is used offline.
class SupportGoalService {
  SupportGoalService._();

  /// A file in the project repository, editable at any time:
  /// `{"goal": 50, "raised": 12, "currency": "€"}`.
  static const String goalUrl =
      'https://raw.githubusercontent.com/D4v31x/Aurora-Music/main/support_goal.json';

  /// The banner returns this many calendar days after it was last shown.
  static const int intervalDays = 3;

  static const String _lastShownKey = 'support_banner_last_shown';
  static const String _cachedGoalKey = 'support_goal_cached';

  /// True while the banner should be visible on the app bar.
  static final ValueNotifier<bool> bannerNotifier = ValueNotifier(false);

  /// The goal currently shown by the banner.
  static final ValueNotifier<SupportGoal> goal =
      ValueNotifier(SupportGoal.fallback);

  /// Dev aid: `--dart-define=FORCE_SUPPORT_BANNER=true` shows the banner on
  /// every launch regardless of the schedule (and without using up the day).
  static const bool _forceShow = bool.fromEnvironment('FORCE_SUPPORT_BANNER');

  static String _dayStamp(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Call once per launch. Shows the banner if it is due; showing it marks
  /// today as used, so it stays away for the rest of the day and for the
  /// following [intervalDays] days whichever button (or none) is pressed.
  static Future<void> checkAndTrigger() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    if (_forceShow) {
      await _loadGoal(prefs);
      bannerNotifier.value = true;
      return;
    }

    final last = prefs.getString(_lastShownKey);
    if (last != null) {
      final parts = last.split('-').map(int.tryParse).toList();
      if (parts.length == 3 && !parts.contains(null)) {
        final lastDate = DateTime(parts[0]!, parts[1]!, parts[2]!);
        final today = DateTime(now.year, now.month, now.day);
        if (today.difference(lastDate).inDays < intervalDays) return;
      }
    }

    await _loadGoal(prefs);
    await prefs.setString(_lastShownKey, _dayStamp(now));
    bannerNotifier.value = true;
  }

  /// Refreshes the current goal without changing the app-bar reminder schedule.
  static Future<void> refreshGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await _loadGoal(prefs);
  }

  static Future<void> _loadGoal(SharedPreferences prefs) async {
    // Show the cached value straight away; refresh it from the network.
    final cached = prefs.getString(_cachedGoalKey);
    if (cached != null) {
      try {
        goal.value =
            SupportGoal.fromJson(json.decode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    try {
      final response = await http
          .get(Uri.parse(goalUrl))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return;
      final body = utf8.decode(response.bodyBytes);
      goal.value =
          SupportGoal.fromJson(json.decode(body) as Map<String, dynamic>);
      await prefs.setString(_cachedGoalKey, body);
    } catch (_) {
      // Offline or file unavailable: keep the cached / default goal.
    }
  }

  /// Shows the banner on the home app bar right now (from settings), without
  /// touching the reminder schedule.
  static Future<void> showNow() async {
    bannerNotifier.value = true;
    await refreshGoal();
  }

  static void dismiss() => bannerNotifier.value = false;
}
