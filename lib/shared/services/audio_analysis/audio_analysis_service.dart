/// Public API of the audio analysis backend.
///
/// ```dart
/// final service = AudioAnalysisService.instance;
/// final lease = service.requestAnalysis(); // starts the engine
/// final sub = service.frames.listen((frame) {
///   // frame.bands, frame.bass, frame.isBeat ... (valid until the next frame)
/// });
/// ...
/// await sub.cancel();
/// lease.release(); // stops the engine when the last lease is released
/// ```
///
/// The engine analyses the PCM Noxira itself plays (captured inside ExoPlayer,
/// no microphone, no extra permission). It runs only while at least one lease
/// is held, and pauses while the app is in the background unless a lease asks
/// to keep running.
library;

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_analysis_config.dart';
import 'audio_frame.dart';
import 'native_audio_analysis.dart';

/// A claim on the analysis engine; see [AudioAnalysisService.requestAnalysis].
class AudioAnalysisLease {
  AudioAnalysisLease._(this._service, this.config, this.keepAliveInBackground);

  final AudioAnalysisService _service;

  /// Settings this lease asked for. The newest active lease's settings win.
  final AudioAnalysisConfig config;

  /// Keep analysing while the app is in the background.
  final bool keepAliveInBackground;

  bool _active = true;

  /// False after [release] (releasing twice is harmless).
  bool get isActive => _active;

  /// Gives the claim back; the engine stops once no lease is left.
  void release() {
    if (!_active) return;
    _active = false;
    _service._release(this);
  }
}

class AudioAnalysisService with WidgetsBindingObserver {
  AudioAnalysisService._(
      {NativeAudioAnalysis? Function()? loader, bool? supported})
      : _loader = loader ?? NativeAudioAnalysis.tryLoad,
        _platformSupported = supported ?? Platform.isAndroid;

  /// The app-wide instance.
  static final AudioAnalysisService instance = AudioAnalysisService._();

  /// An isolated instance for tests, bound to a specific native library.
  @visibleForTesting
  factory AudioAnalysisService.forTesting(NativeAudioAnalysis native) =>
      AudioAnalysisService._(loader: () => native, supported: true);

  final NativeAudioAnalysis? Function() _loader;
  final bool _platformSupported;

  NativeAudioAnalysis? _native;
  bool _loadAttempted = false;
  NativeCallable<Void Function(Int64)>? _callable;
  final List<AudioAnalysisLease> _leases = [];
  bool _observing = false;
  bool _inBackground = false;
  bool _running = false;

  AudioFrame _latest = AudioFrame.empty();
  final StreamController<AudioFrame> _controller =
      StreamController<AudioFrame>.broadcast(sync: true);

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerSub;
  AudioAnalysisState _playbackState = AudioAnalysisState.paused;

  /// Whether this platform has an analysis backend (Android with the native
  /// library present). When false, [frames] never emits and
  /// [latestFrame] stays in [AudioAnalysisState.unsupported].
  bool get isSupported {
    if (!_platformSupported) return false;
    _ensureLoaded();
    return _native != null;
  }

  /// True while the native analysis thread is running.
  bool get isRunning => _running;

  /// The newest frame (an empty frame before the first one). Valid until the
  /// next frame arrives; see [AudioFrame].
  AudioFrame get latestFrame => _latest;

  /// Analysis state as of the newest frame.
  AudioAnalysisState get state =>
      isSupported ? _latest.state : AudioAnalysisState.unsupported;

  /// A broadcast stream of frames, one per analysis update (30-60 Hz), only
  /// while at least one lease is active. Every event is the same few reused
  /// objects; copy with [AudioFrame.snapshot] to keep one. Events are
  /// delivered on the main isolate; the DSP itself runs natively.
  Stream<AudioFrame> get frames => _controller.stream;

  /// Claims the engine for visualisation. The first lease starts the native
  /// thread; the last one to be released stops it.
  ///
  /// Returns an inactive lease when the platform is unsupported.
  AudioAnalysisLease requestAnalysis({
    AudioAnalysisConfig config = const AudioAnalysisConfig(),
    bool keepAliveInBackground = false,
  }) {
    final lease = AudioAnalysisLease._(this, config, keepAliveInBackground);
    if (!isSupported) {
      _latest = AudioFrame.empty(AudioAnalysisState.unsupported);
      lease._active = false;
      return lease;
    }
    _leases.add(lease);
    _observeLifecycle();
    _applyDesiredState();
    return lease;
  }

  /// Follows [player]'s state so the engine knows about pause, resume,
  /// buffering and completion. Safe to call again when the active player is
  /// replaced (crossfade); does not load or start anything.
  void bindPlayer(AudioPlayer player) {
    if (identical(player, _player)) return;
    _playerSub?.cancel();
    _player = player;
    _playerSub = player.playerStateStream.listen((s) {
      _playbackState = mapPlayerState(s);
      _native?.setPlaybackState(_playbackState);
    });
    _playbackState = mapPlayerState(player.playerState);
    _native?.setPlaybackState(_playbackState);
  }

  /// Engine counters (DSP time, CPU, buffer overruns) for profiling.
  AudioAnalysisStats readStats() =>
      _native?.readStats() ?? const AudioAnalysisStats();

  /// Stops analysis and drops all leases and listeners. Mainly for tests;
  /// the app-wide instance lives as long as the process.
  void dispose() {
    for (final lease in List.of(_leases)) {
      lease._active = false;
    }
    _leases.clear();
    _applyDesiredState();
    _playerSub?.cancel();
    _playerSub = null;
    _player = null;
    if (_observing) {
      WidgetsBinding.instance.removeObserver(this);
      _observing = false;
    }
  }

  // ---------------------------------------------------------------- internals

  /// How a just_audio state is reported to the engine.
  @visibleForTesting
  static AudioAnalysisState mapPlayerState(PlayerState s) {
    switch (s.processingState) {
      case ProcessingState.idle:
        return AudioAnalysisState.ended;
      case ProcessingState.completed:
        return AudioAnalysisState.ended;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return s.playing
            ? AudioAnalysisState.buffering
            : AudioAnalysisState.paused;
      case ProcessingState.ready:
        return s.playing
            ? AudioAnalysisState.playing
            : AudioAnalysisState.paused;
    }
  }

  void _ensureLoaded() {
    if (_loadAttempted) return;
    _loadAttempted = true;
    if (!_platformSupported) return;
    _native = _loader();
    final native = _native;
    if (native != null) {
      // A previous isolate (hot restart, recreated engine) may have left the
      // native thread and its callback behind: start from a clean slate.
      native.setFrameCallback(nullptr);
      native.stop();
      native.setPlaybackState(_playbackState);
    }
  }

  void _observeLifecycle() {
    if (_observing) return;
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final background = state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;
    if (background == _inBackground) return;
    _inBackground = background;
    _applyDesiredState();
  }

  void _release(AudioAnalysisLease lease) {
    _leases.remove(lease);
    _applyDesiredState();
  }

  /// Reconciles the native engine with the current leases and app state.
  void _applyDesiredState() {
    final native = _native;
    if (native == null) return;

    final wanted =
        _leases.where((l) => !_inBackground || l.keepAliveInBackground);
    if (wanted.isEmpty) {
      if (_running) {
        native.setFrameCallback(nullptr);
        native.stop();
        _callable?.close();
        _callable = null;
        _running = false;
        _latest = AudioFrame.empty();
      }
      return;
    }

    final config = wanted.last.config;
    if (!_running) {
      _callable = NativeCallable<Void Function(Int64)>.listener(_onNativeFrame);
      native.setFrameCallback(_callable!.nativeFunction);
      native.setPlaybackState(_playbackState);
      _running = native.start(config);
      if (!_running) {
        native.setFrameCallback(nullptr);
        _callable?.close();
        _callable = null;
      }
    } else {
      native.updateConfig(config);
    }
  }

  /// Runs on the main isolate for every frame the native thread publishes.
  void _onNativeFrame(int sequence) {
    final native = _native;
    if (native == null || !_running) return;
    final frame = native.acquireFrame();
    if (frame == null) return;
    _latest = frame;
    if (_controller.hasListener) _controller.add(frame);
  }
}
