import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'remote_config_helper.dart';

/// Someone listed on the support page, by name only. Only people who agreed
/// to be listed should ever be added in the console.
@immutable
class Supporter {
  const Supporter(this.name);

  final String name;
}

/// Supporters shown under Settings > Support, as set in the Firebase console
/// (Remote Config parameter `support_supporters`, a JSON list of names such as
/// `["Anna", "Tom"]`; `{"name": "Anna"}` entries work too).
///
/// Bad or oversized data never throws: invalid entries are skipped and an
/// invalid list is treated as empty.
class SupporterService {
  SupporterService._();

  static const String parameter = 'support_supporters';
  static const int maxEntries = 300;
  static const int maxNameLength = 40;
  static const int maxParameterLength = 20000;

  static final ValueNotifier<List<Supporter>> supporters =
      ValueNotifier(const []);

  static bool _following = false;

  /// Reads the list now and again whenever new values are published.
  static Future<void> load() async {
    if (!_following) {
      _following = true;
      RemoteConfigHelper.updates.addListener(_read);
    }
    _read();
    await RemoteConfigHelper.instance();
    _read();
  }

  static void _read() {
    supporters.value = parse(RemoteConfigHelper.string(parameter));
  }

  static List<Supporter> parse(String raw) {
    if (raw.isEmpty || raw.length > maxParameterLength) return const [];
    final Object? decoded;
    try {
      decoded = json.decode(raw);
    } catch (_) {
      return const [];
    }
    if (decoded is! List) return const [];

    final result = <Supporter>[];
    for (final item in decoded) {
      if (result.length >= maxEntries) break;
      final name = _clean(item is Map ? item['name'] : item);
      if (name != null) result.add(Supporter(name));
    }
    return result;
  }

  static String? _clean(Object? value) {
    if (value is! String) return null;
    final text = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty) return null;
    return text.length <= maxNameLength
        ? text
        : '${text.substring(0, maxNameLength - 1).trimRight()}…';
  }
}
