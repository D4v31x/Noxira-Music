import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote_config_helper.dart';

/// This month's support goal, as set in the Firebase console (Remote Config).
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
/// The goal is set in the Firebase console (Remote Config); the last good
/// value is cached and a built-in default is used offline.
class SupportGoalService {
  SupportGoalService._();

  /// The banner returns this many calendar days after it was last shown
  /// (`prompt_support_banner_interval_days`).
  static int get intervalDays => RemoteConfigHelper.integer(
        'prompt_support_banner_interval_days',
        min: 1,
      );

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
    _followConsoleUpdates();
    if (!RemoteConfigHelper.boolean('donation_enabled')) return;
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
    _followConsoleUpdates();
    final prefs = await SharedPreferences.getInstance();
    await _loadGoal(prefs);
  }

  static bool _following = false;

  /// Re-reads the goal as soon as new values are published in the console.
  static void _followConsoleUpdates() {
    if (_following) return;
    _following = true;
    RemoteConfigHelper.updates.addListener(() => unawaited(refreshGoal()));
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
    await _loadGoalFromRemoteConfig(prefs);
  }

  /// Reads the goal from the Firebase console (parameters
  /// `support_goal_amount`, `support_goal_raised`, `support_goal_currency`).
  /// Returns false if no goal is set there, keeping the cached / default goal.
  static Future<bool> _loadGoalFromRemoteConfig(SharedPreferences prefs) async {
    final config = await RemoteConfigHelper.instance();
    if (config == null) return false;
    try {
      final data = {
        'goal': config.getDouble('support_goal_amount'),
        'raised': config.getDouble('support_goal_raised'),
        'currency': config.getString('support_goal_currency'),
      };
      if ((data['goal'] as double) <= 0) return false;
      goal.value = SupportGoal.fromJson(data);
      await prefs.setString(_cachedGoalKey, json.encode(data));
      return true;
    } catch (_) {
      return false;
    }
  }

  static void dismiss() => bannerNotifier.value = false;
}
