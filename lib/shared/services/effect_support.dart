import 'dart:io';

import 'package:flutter/services.dart';
import 'logging_service.dart';

/// Whether the device can create an equalizer audio effect right now.
///
/// Android has a limited number of effect instances, and some devices refuse
/// them altogether. A player whose pipeline holds an equalizer then fails
/// before playing anything ("Cannot initialize effect engine"), so the
/// equalizer is only attached when a probe confirms it can be created.
class EffectSupport {
  EffectSupport._();

  static const _channel = MethodChannel('aurora/effects');

  /// Set once at startup by [probe].
  static bool equalizerAvailable = false;

  static Future<bool> probe() async {
    if (!Platform.isAndroid) return equalizerAvailable = true;
    try {
      equalizerAvailable =
          await _channel.invokeMethod<bool>('canCreateEqualizer') ?? false;
    } catch (e) {
      LoggingService.warning('Equalizer probe failed: $e', 'Equalizer');
      equalizerAvailable = false;
    }
    if (!equalizerAvailable) {
      LoggingService.warning(
          'Equalizer unavailable on this device; playing without it',
          'Equalizer');
    }
    return equalizerAvailable;
  }
}
