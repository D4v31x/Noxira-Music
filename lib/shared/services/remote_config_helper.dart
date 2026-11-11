import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Shared Firebase Remote Config setup so the announcement and support-goal
/// services fetch the console values once instead of each doing its own fetch.
class RemoteConfigHelper {
  RemoteConfigHelper._();

  static Future<FirebaseRemoteConfig?>? _ready;
  // Lives as long as the app, so it is never cancelled.
  // ignore: cancel_subscriptions
  static StreamSubscription<RemoteConfigUpdate>? _updateSub;

  /// Fetches are throttled per device (a few per hour), so anything shorter
  /// than this would just be refused. Published changes also arrive live, see
  /// [updates].
  static const Duration _fetchInterval = Duration(minutes: 15);

  /// Bumped whenever new values were published in the console and have been
  /// activated. Listen to it to re-read values without restarting the app.
  static final ValueNotifier<int> updates = ValueNotifier<int>(0);

  /// Defaults for every parameter the app reads; an unset console value
  /// falls back to these.
  static const Map<String, Object> defaults = {
    'announcement_enabled': false,
    'announcement_id': '',
    'announcement_title': '',
    'announcement_message': '',
    'announcement_button_label': '',
    'announcement_url': '',
    'announcement_min_version': '',
    'announcement_max_version': '',
    'announcement_expires': '',
    'support_goal_amount': 0,
    'support_goal_raised': 0,
    'support_goal_currency': '€',
    'support_supporters': '',
    'lyrics_provider_order': '',
    'lyrics_disabled_providers': '',
    'online_disabled_sources': '',
    'donation_enabled': true,
    'donation_kofi_username': 'aurorasoftwarecz',
    'donation_bmc_username': 'aurorasoftwareCZ',
    'update_min_version': '',
    'update_recommended_version': '',
    'update_message': '',
    'prompt_feedback_enabled': true,
    'prompt_feedback_min_days': 7,
    'prompt_feedback_min_opens': 5,
    'prompt_donation_interval_days': 7,
    'prompt_support_banner_interval_days': 3,
  };

  static FirebaseRemoteConfig? _config;

  /// Text value of [key]: the last activated console value, else its default.
  /// Synchronous, and safe before Remote Config is ready (or when it is
  /// unavailable): it then returns the built-in default.
  static String string(String key) {
    final config = _config;
    final value = config?.getString(key).trim();
    if (value != null && value.isNotEmpty) return value;
    final fallback = defaults[key];
    return fallback is String ? fallback : '';
  }

  static bool boolean(String key) {
    final config = _config;
    if (config != null) return config.getBool(key);
    final fallback = defaults[key];
    return fallback is bool ? fallback : false;
  }

  /// Whole number from the console, kept within [min]..[max] so a typo can't
  /// make a prompt appear on every launch or never.
  static int integer(String key, {int min = 0, int max = 365}) {
    final fallback = defaults[key];
    final base = fallback is int ? fallback : 0;
    final value = _config == null ? base : _config!.getInt(key);
    return value.clamp(min, max);
  }

  /// Comma-separated console value as lower-case, trimmed entries.
  static List<String> list(String key) => [
        for (final part in string(key).split(','))
          if (part.trim().isNotEmpty) part.trim().toLowerCase(),
      ];

  /// Fetches and activates the latest values. Resolves to the last activated
  /// values when offline, or null if Remote Config is unavailable.
  static Future<FirebaseRemoteConfig?> instance() =>
      _ready ??= _init().whenComplete(() {
        // Allow a later call to fetch again once the throttle has passed.
        Future<void>.delayed(_fetchInterval, () => _ready = null);
      });

  static Future<FirebaseRemoteConfig?> _init() async {
    try {
      final config = FirebaseRemoteConfig.instance;
      await config.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode ? Duration.zero : _fetchInterval,
      ));
      await config.setDefaults(defaults);
      _config = config;
      try {
        await config.fetchAndActivate();
      } catch (e) {
        _report('fetch failed', e);
      }
      _listenForUpdates(config);
      return config;
    } catch (e) {
      _report('unavailable', e);
      return null;
    }
  }

  /// Console changes are pushed to the app, so they show up without waiting
  /// for the next fetch or restarting.
  static void _listenForUpdates(FirebaseRemoteConfig config) {
    _updateSub ??= config.onConfigUpdated.listen(
      (_) async {
        try {
          await config.activate();
        } catch (e) {
          _report('activate failed', e);
        }
        updates.value++;
      },
      onError: (Object e) => _report('live update failed', e),
    );
  }

  /// Errors here explain a missing popup or goal, so they are printed even in
  /// release builds (where [debugPrint] is silenced).
  static void _report(String what, Object error) {
    // ignore: avoid_print
    print('⚠️ Remote Config $what: $error');
  }
}
