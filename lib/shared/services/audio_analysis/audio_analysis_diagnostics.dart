/// Developer-only logging of the analysis engine (no UI).
///
/// Enabled with `--dart-define=NOXIRA_ANALYSIS_DIAG=true`; does nothing
/// otherwise. While enabled it holds an analysis lease and prints a summary of
/// the live frame plus the engine's CPU/latency counters every two seconds,
/// which is how the backend is profiled on real devices.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'audio_analysis_service.dart';
import 'audio_frame.dart';

abstract final class AudioAnalysisDiagnostics {
  static const bool _enabled = bool.fromEnvironment('NOXIRA_ANALYSIS_DIAG');

  static AudioAnalysisLease? _lease;
  static Timer? _timer;
  static int _frames = 0;
  static int _beats = 0;
  static int _kicks = 0;
  static int _lastSequence = -1;
  static StreamSubscription<AudioFrame>? _sub;

  /// Starts the periodic log when the define is set. Safe to call repeatedly.
  static void startIfEnabled() {
    if (!_enabled || _lease != null) return;
    final service = AudioAnalysisService.instance;
    if (!service.isSupported) {
      debugPrint('[analysis] backend unavailable on this device');
      return;
    }
    _lease = service.requestAnalysis(keepAliveInBackground: true);
    _sub = service.frames.listen((f) {
      if (f.sequence != _lastSequence + 1 && _lastSequence >= 0) {
        // frames dropped on the way to Dart are expected when the UI is busy
      }
      _lastSequence = f.sequence;
      _frames++;
      if (f.isBeat) _beats++;
      if (f.isKickHit) _kicks++;
    });
    _timer =
        Timer.periodic(const Duration(seconds: 2), (_) => _report(service));
    debugPrint('[analysis] diagnostics started');
  }

  static void stop() {
    _timer?.cancel();
    _sub?.cancel();
    _lease?.release();
    _timer = null;
    _sub = null;
    _lease = null;
  }

  static void _report(AudioAnalysisService service) {
    final f = service.latestFrame;
    final stats = service.readStats();
    var peakBand = 0;
    final bands = f.bands;
    for (var i = 1; i < bands.length; i++) {
      if (bands[i] > bands[peakBand]) peakBand = i;
    }
    debugPrint(
      '[analysis] ${f.state.name} ${f.sampleRate}Hz/${f.sourceChannels}ch '
      'fft=${f.fftSize} rx=$_frames/2s beats=$_beats kicks=$_kicks '
      'bpm=${f.bpm.toStringAsFixed(0)} energy=${f.energy.toStringAsFixed(2)} '
      'rms=${f.rms.toStringAsFixed(3)} peakBand=$peakBand/${bands.length} '
      'regions=${f.regions.map((v) => v.toStringAsFixed(2)).join(",")} '
      'disc=${f.discontinuityCount} ts=${(f.timestampUs / 1e6).toStringAsFixed(1)}s',
    );
    debugPrint('[analysis] $stats');
    _frames = 0;
    _beats = 0;
    _kicks = 0;
  }
}
