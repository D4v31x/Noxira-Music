import 'effect_support.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EqualizerPreset {
  final String name;

  /// Gains in dB for each band. Applied proportionally when the device
  /// has a different band count than the preset was created with.
  final List<double> gains;

  /// True when this preset was created by the user.
  final bool isCustom;

  const EqualizerPreset({
    required this.name,
    required this.gains,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {'name': name, 'gains': gains};

  factory EqualizerPreset.fromJson(Map<String, dynamic> json) =>
      EqualizerPreset(
        name: json['name'] as String,
        gains:
            (json['gains'] as List).map((e) => (e as num).toDouble()).toList(),
        isCustom: true,
      );
}

class EqualizerService extends ChangeNotifier {
  AndroidEqualizerParameters? _params;
  bool _enabled = false;
  String _preset = 'Flat';
  bool _initialized = false;
  final List<EqualizerPreset> _customPresets = [];
  Timer? _saveTimer;

  AndroidEqualizerParameters? get params => _params;
  bool get enabled => _enabled;
  String get preset => _preset;
  bool get initialized => _initialized;

  /// User-created presets (read-only view).
  List<EqualizerPreset> get customPresets => List.unmodifiable(_customPresets);

  static const List<EqualizerPreset> builtInPresets = [
    EqualizerPreset(name: 'Flat', gains: [0, 0, 0, 0, 0]),
    EqualizerPreset(name: 'Bass Boost', gains: [6, 4, 0, 0, 0]),
    EqualizerPreset(name: 'Bass Cut', gains: [-6, -4, 0, 0, 0]),
    EqualizerPreset(name: 'Treble Boost', gains: [0, 0, 0, 4, 6]),
    EqualizerPreset(name: 'Treble Cut', gains: [0, 0, 0, -4, -6]),
    EqualizerPreset(name: 'Rock', gains: [4, 2, -2, 2, 4]),
    EqualizerPreset(name: 'Pop', gains: [-2, 2, 4, 2, -1]),
    EqualizerPreset(name: 'Jazz', gains: [3, 0, 2, 0, 2]),
    EqualizerPreset(name: 'Classical', gains: [4, 2, 0, 2, 4]),
    EqualizerPreset(name: 'Electronic', gains: [4, 2, 0, 2, 4]),
    EqualizerPreset(name: 'Hip Hop', gains: [5, 3, 0, 2, 3]),
    EqualizerPreset(name: 'R&B', gains: [3, 4, 0, -1, 2]),
    EqualizerPreset(name: 'Vocal', gains: [0, 2, 4, 2, 0]),
    EqualizerPreset(name: 'Acoustic', gains: [3, 1, 0, 1, 3]),
    EqualizerPreset(name: 'Dance', gains: [4, 2, 0, -2, 1]),
    EqualizerPreset(name: 'Metal', gains: [5, 3, -1, 3, 5]),
    EqualizerPreset(name: 'Lounge', gains: [-1, 2, 3, 2, -1]),
    EqualizerPreset(name: 'Spoken Word', gains: [-3, 0, 4, 3, 1]),
  ];

  /// Backward-compatible alias for [builtInPresets].
  static List<EqualizerPreset> get presets => builtInPresets;

  /// All presets — built-in first, then user-created.
  List<EqualizerPreset> get allPresets =>
      [...builtInPresets, ..._customPresets];

  /// True until the equalizer's parameters are known. The player only exposes
  /// them once its audio session exists, which starts with the first track
  /// that is loaded, so before that there is simply nothing to configure yet.
  bool get waitingForAudio => !_initialized && _waitingForAudio;
  bool _waitingForAudio = false;

  Future<void> init(AndroidEqualizer eq, {bool retry = false}) async {
    if (_initialized && !retry) return;
    if (!EffectSupport.equalizerAvailable) {
      // Not attached to the player: nothing to configure.
      _params = null;
      _initialized = true;
      notifyListeners();
      return;
    }
    if (_initializing != null) return _initializing!;

    _initializing = _awaitParameters(eq);
    try {
      await _initializing;
    } finally {
      _initializing = null;
    }
  }

  Future<void>? _initializing;

  /// Waits for the parameters to arrive (no timeout: a timer would only
  /// report a failure that is really "no song has played yet"), then restores
  /// the saved settings.
  Future<void> _awaitParameters(AndroidEqualizer eq) async {
    _waitingForAudio = true;
    notifyListeners();
    try {
      _params = await eq.parameters;
      await _restoreSettings(eq);
    } catch (e) {
      // Reached only if the player itself failed to create the effect.
      debugPrint('[EQ] unavailable: $e');
      _params = null;
    }
    _waitingForAudio = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> _restoreSettings(AndroidEqualizer eq) async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('eq_enabled') ?? false;
    _preset = prefs.getString('eq_preset') ?? 'Flat';
    await eq.setEnabled(_enabled);

    _customPresets.clear();
    final customJson = prefs.getString('eq_custom_presets');
    if (customJson != null) {
      final list = jsonDecode(customJson) as List;
      _customPresets.addAll(
        list.map((e) => EqualizerPreset.fromJson(e as Map<String, dynamic>)),
      );
    }

    final gainsJson = prefs.getString('eq_gains');
    if (gainsJson != null) {
      final list = (jsonDecode(gainsJson) as List)
          .map((e) => (e as num).toDouble())
          .toList();
      final bands = _params!.bands;
      final minDb = _params!.minDecibels.toDouble();
      final maxDb = _params!.maxDecibels.toDouble();
      for (int i = 0; i < bands.length && i < list.length; i++) {
        await bands[i].setGain(list[i].clamp(minDb, maxDb));
      }
    } else {
      await _applyGains(builtInPresets.first.gains);
      _preset = 'Flat';
    }
  }

  Future<void> setEnabled(AndroidEqualizer eq, bool value) async {
    _enabled = value;
    try {
      await eq.setEnabled(value);
    } catch (e) {
      debugPrint('[EQ] setEnabled failed: $e');
    }
    await _save();
    notifyListeners();
  }

  Future<void> setBandGain(int bandIndex, double gainDb) async {
    final p = _params;
    if (p == null || bandIndex >= p.bands.length) return;
    final clamped = gainDb.clamp(
      p.minDecibels.toDouble(),
      p.maxDecibels.toDouble(),
    );
    try {
      await p.bands[bandIndex].setGain(clamped);
    } catch (e) {
      debugPrint('[EQ] setBandGain failed: $e');
      return;
    }
    _preset = 'Custom';
    // Debounced save — avoids hammering SharedPreferences during rapid dragging
    _scheduleSave();
    notifyListeners();
  }

  Future<void> applyPreset(EqualizerPreset preset) async {
    if (_params == null) return;
    await _applyGains(preset.gains);
    _preset = preset.name;
    await _save();
    notifyListeners();
  }

  /// Save the current band gains as a new user preset with [name].
  /// Overwrites any existing custom preset with the same name.
  Future<void> saveCurrentAsPreset(String name) async {
    final p = _params;
    if (p == null) return;
    _customPresets.removeWhere((cp) => cp.name == name);
    final gains = p.bands.map((b) => b.gain).toList();
    _customPresets
        .add(EqualizerPreset(name: name, gains: gains, isCustom: true));
    _preset = name;
    await _saveCustomPresets();
    await _save();
    notifyListeners();
  }

  /// Delete a user-created preset by [name].
  Future<void> deleteCustomPreset(String name) async {
    _customPresets.removeWhere((p) => p.name == name);
    if (_preset == name) _preset = 'Custom';
    await _saveCustomPresets();
    await _save();
    notifyListeners();
  }

  Future<void> _applyGains(List<double> gains) async {
    final p = _params;
    if (p == null) return;
    final minDb = p.minDecibels.toDouble();
    final maxDb = p.maxDecibels.toDouble();
    final bands = p.bands;
    try {
      for (int i = 0; i < bands.length; i++) {
        final g = i < gains.length ? gains[i] : 0.0;
        await bands[i].setGain(g.clamp(minDb, maxDb));
      }
    } catch (e) {
      debugPrint('[EQ] applyGains failed: $e');
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _save);
  }

  Future<void> _saveCustomPresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'eq_custom_presets',
      jsonEncode(_customPresets.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> _save() async {
    final p = _params;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eq_enabled', _enabled);
    await prefs.setString('eq_preset', _preset);
    if (p != null) {
      final gains = p.bands.map((b) => b.gain).toList();
      await prefs.setString('eq_gains', jsonEncode(gains));
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  /// Launches the device's native audio effects panel (e.g. Samsung Sound
  /// Experience / Dolby Atmos). Returns true if the dedicated panel opened,
  /// false if it fell back to system Sound Settings. Throws on hard failure.
  Future<bool> openSystemEqualizer({int audioSessionId = 0}) async {
    const channel = MethodChannel('aurora/media_actions');
    final result = await channel.invokeMethod<bool>(
      'openSystemEqualizer',
      {'audioSessionId': audioSessionId},
    );
    return result ?? false;
  }
}
