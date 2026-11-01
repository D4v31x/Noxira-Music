import 'package:flutter/widgets.dart';

/// Text scaling for the whole app: follows the system font size, with the
/// app's hard-coded sizes toned down so text matches system apps.
///
/// Every declared size is multiplied by [_baseFactor] (headers included, no
/// extra boost), but never drops below [_floor] sp so captions stay legible.
/// The result is then scaled by the user's system font size.
@immutable
class AppTextScaler extends TextScaler {
  const AppTextScaler(this.system);

  /// The system (user-chosen) scaler, as provided by [MediaQuery].
  final TextScaler system;

  static const double _baseFactor = 0.88;
  static const double _floor = 10;

  /// The app's size for a font declared as [size], before the system scale.
  static double adjust(double size) {
    if (size <= _floor) return size;
    final scaled = size * _baseFactor;
    return scaled < _floor ? _floor : scaled;
  }

  @override
  double scale(double fontSize) => system.scale(adjust(fontSize));

  @Deprecated('Use scale() instead.')
  @override
  double get textScaleFactor => system.scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is AppTextScaler && other.system == system;

  @override
  int get hashCode => Object.hash(AppTextScaler, system);
}
