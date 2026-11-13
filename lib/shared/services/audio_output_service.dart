import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  @override
  bool operator ==(Object other) =>
      other is AudioOutput &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.selected == selected;

  @override
  int get hashCode => Object.hash(id, name, kind, selected);

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
///
/// The list stays current without anyone asking: the native side reports every
/// device that connects or disconnects, the Bluetooth service reports its own
/// changes, and while the app is in the foreground the routing is also polled,
/// which catches switches made from the system output picker.
class AudioOutputService extends ChangeNotifier with WidgetsBindingObserver {
  AudioOutputService._() {
    _channel.setMethodCallHandler(_onNativeCall);
    BluetoothService().addListener(_refreshSoon);
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
    unawaited(refresh());
  }
  static final AudioOutputService instance = AudioOutputService._();

  static const _pollInterval = Duration(seconds: 3);

  Timer? _pollTimer;

  Future<dynamic> _onNativeCall(MethodCall call) async {
    if (call.method == 'outputsChanged') _refreshSoon();
  }

  /// A device event arrives before the system has finished switching the
  /// route, so read it again a couple of times while it settles.
  void _refreshSoon() {
    for (final ms in const [300, 1200, 3000]) {
      Future<void>.delayed(Duration(milliseconds: ms), refresh);
    }
  }

  void _startPolling() {
    if (!Platform.isAndroid) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      unawaited(refresh());
      _refreshSoon();
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
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
      final supportsSwitching = result['supportsSwitching'] == true;
      final outputs = [
        for (final o in (result['outputs'] as List? ?? const []))
          AudioOutput.fromMap(o as Map),
      ];
      if (supportsSwitching == _supportsSwitching &&
          listEquals(outputs, _outputs)) {
        return;
      }
      _supportsSwitching = supportsSwitching;
      _outputs = outputs;
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
