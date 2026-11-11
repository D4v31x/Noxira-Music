import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bluetooth_service.dart';

enum AudioOutputKind { speaker, bluetooth, wired, usb, other }

class AudioOutput {
  const AudioOutput({
    required this.id,
    required this.name,
    required this.kind,
    required this.selected,
  });

  final String id;
  final String name;
  final AudioOutputKind kind;
  final bool selected;

  factory AudioOutput.fromMap(Map<dynamic, dynamic> map) {
    final kind = AudioOutputKind.values.firstWhere(
      (k) => k.name == map['kind'],
      orElse: () => AudioOutputKind.other,
    );
    return AudioOutput(
      id: map['id'].toString(),
      name: (map['name'] as String?) ?? '',
      kind: kind,
      selected: map['selected'] == true,
    );
  }
}

/// Lists the audio outputs available on the device and lets the user pick
/// where playback is routed (Android only).
class AudioOutputService extends ChangeNotifier {
  AudioOutputService._() {
    // The routing can change when a device connects or disconnects, and the
    // app bar island reads it, so keep it fresh without anyone asking.
    final bluetooth = BluetoothService();
    bluetooth.addListener(_onBluetoothChanged);
    unawaited(refresh());
  }
  static final AudioOutputService instance = AudioOutputService._();

  void _onBluetoothChanged() {
    // The native side resets the route a moment after the device event.
    Future<void>.delayed(const Duration(milliseconds: 400), refresh);
  }

  static const _channel = MethodChannel('aurora/audio_output');

  List<AudioOutput> _outputs = const [];
  bool _supportsSwitching = false;

  List<AudioOutput> get outputs => _outputs;

  /// False on Android < 14, where the system output switcher is used instead.
  bool get supportsSwitching => _supportsSwitching;

  AudioOutput? get current {
    for (final output in _outputs) {
      if (output.selected) return output;
    }
    return null;
  }

  Future<void> refresh() async {
    if (!Platform.isAndroid) return;
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getOutputs');
      if (result == null) return;
      _supportsSwitching = result['supportsSwitching'] == true;
      _outputs = [
        for (final o in (result['outputs'] as List? ?? const []))
          AudioOutput.fromMap(o as Map),
      ];
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('⚠️ Could not list audio outputs: ${e.message}');
    }
  }

  /// Routes playback to [output]. Returns false if the switch couldn't be
  /// made.
  Future<bool> select(AudioOutput output) async {
    try {
      final ok = await _channel
              .invokeMethod<bool>('selectOutput', {'id': output.id}) ??
          false;
      if (ok) {
        // Give the route a moment to settle before reading it back.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await refresh();
      }
      return ok;
    } on PlatformException catch (e) {
      debugPrint('⚠️ Could not switch audio output: ${e.message}');
      return false;
    }
  }
}
