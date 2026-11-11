/// Dart FFI bindings to the native engine (`libnoxira_audio.so`).
///
/// This layer only marshals data; lifecycle policy (reference counting,
/// backgrounding, player state) lives in `AudioAnalysisService`.
library;

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'audio_analysis_config.dart';
import 'audio_frame.dart';

// ignore_for_file: non_constant_identifier_names

typedef _StartC = Int32 Function(Pointer<Uint8>);
typedef _StartD = int Function(Pointer<Uint8>);
typedef _VoidC = Void Function();
typedef _VoidD = void Function();
typedef _IntC = Int32 Function();
typedef _IntD = int Function();
typedef _SetStateC = Void Function(Int32);
typedef _SetStateD = void Function(int);
typedef _AcquireFrameC = Pointer<Uint8> Function();
typedef _AcquireFrameD = Pointer<Uint8> Function();
typedef _CallbackC = Void Function(Int64);
typedef _SetCallbackC = Void Function(Pointer<NativeFunction<_CallbackC>>);
typedef _SetCallbackD = void Function(Pointer<NativeFunction<_CallbackC>>);
typedef _StatsC = Void Function(Pointer<Uint8>);
typedef _StatsD = void Function(Pointer<Uint8>);
typedef _DefaultConfigC = Void Function(Pointer<Uint8>);
typedef _DefaultConfigD = void Function(Pointer<Uint8>);
typedef _ConfigureSourceC = Void Function(Int32, Int32, Int32);
typedef _ConfigureSourceD = void Function(int, int, int);
typedef _SourceC = Void Function(Int32);
typedef _SourceD = void Function(int);
typedef _PushC = Int32 Function(Int32, Pointer<Void>, Int32, Int32);
typedef _PushD = int Function(int, Pointer<Void>, int, int);

/// Byte offsets inside the native `NoxiraConfig` struct.
abstract final class _ConfigLayout {
  static const size = 644;
  static const fftSize = 4;
  static const bandCount = 8;
  static const analysisRate = 12;
  static const stereoBands = 16;
  static const spectrumBins = 20;
  static const waveformSize = 24;
  static const visualizerSpectrum = 28;
  static const minHz = 32;
  static const maxHz = 36;
  static const regionEdges = 40;
  static const attackMs = 72;
  static const releaseMs = 76;
  static const peakHoldMs = 80;
  static const peakDecay = 84;
  static const noiseFloor = 88;
  static const dynamicRange = 92;
  static const minReference = 96;
  static const normRelease = 100;
  static const tilt = 104;
  static const bandSensitivity = 108;
  static const onsetSensitivity = 620;
  static const latency = 624;
  static const contrast = 628;
  static const referenceMix = 632;
  static const levelFloor = 636;
  static const normAttack = 640;
}

/// Thin typed wrapper around the C ABI declared in `noxira_audio.h`.
class NativeAudioAnalysis {
  NativeAudioAnalysis._(DynamicLibrary lib)
      : _start = lib.lookupFunction<_StartC, _StartD>('noxira_engine_start'),
        _updateConfig =
            lib.lookupFunction<_StartC, _StartD>('noxira_engine_update_config'),
        _stop = lib.lookupFunction<_VoidC, _VoidD>('noxira_engine_stop'),
        _shutdown =
            lib.lookupFunction<_VoidC, _VoidD>('noxira_engine_shutdown'),
        _isRunning =
            lib.lookupFunction<_IntC, _IntD>('noxira_engine_is_running'),
        _setPlaybackState = lib.lookupFunction<_SetStateC, _SetStateD>(
            'noxira_engine_set_playback_state'),
        _acquireFrame = lib.lookupFunction<_AcquireFrameC, _AcquireFrameD>(
            'noxira_engine_acquire_frame'),
        _setCallback = lib.lookupFunction<_SetCallbackC, _SetCallbackD>(
            'noxira_engine_set_frame_callback'),
        _getStats =
            lib.lookupFunction<_StatsC, _StatsD>('noxira_engine_get_stats'),
        _defaultConfig = lib.lookupFunction<_DefaultConfigC, _DefaultConfigD>(
            'noxira_config_default'),
        _acquireSource =
            lib.lookupFunction<_IntC, _IntD>('noxira_engine_acquire_source'),
        _releaseSource = lib
            .lookupFunction<_SourceC, _SourceD>('noxira_engine_release_source'),
        _configureSource =
            lib.lookupFunction<_ConfigureSourceC, _ConfigureSourceD>(
                'noxira_engine_configure_source'),
        _flushSource = lib
            .lookupFunction<_SourceC, _SourceD>('noxira_engine_flush_source'),
        _pushPcm = lib.lookupFunction<_PushC, _PushD>('noxira_engine_push_pcm'),
        abiVersion = lib.lookupFunction<_IntC, _IntD>('noxira_abi_version')(),
        frameSize = lib.lookupFunction<_IntC, _IntD>('noxira_frame_size')(),
        configSize = lib.lookupFunction<_IntC, _IntD>('noxira_config_size')();

  /// Version of the C ABI this library was built with.
  final int abiVersion;

  /// `sizeof(NoxiraAudioFrame)` / `sizeof(NoxiraConfig)` of the library.
  final int frameSize, configSize;

  final _StartD _start;
  final _StartD _updateConfig;
  final _VoidD _stop;
  final _VoidD _shutdown;
  final _IntD _isRunning;
  final _SetStateD _setPlaybackState;
  final _AcquireFrameD _acquireFrame;
  final _SetCallbackD _setCallback;
  final _StatsD _getStats;
  final _DefaultConfigD _defaultConfig;
  final _IntD _acquireSource;
  final _SourceD _releaseSource;
  final _ConfigureSourceD _configureSource;
  final _SourceD _flushSource;
  final _PushD _pushPcm;

  /// Frame wrappers by native address (the engine rotates three buffers).
  final Map<int, AudioFrame> _frames = {};

  /// Loads the engine. Returns null when the library is missing or built
  /// against a different ABI, so callers can degrade gracefully.
  ///
  /// On Android the library is resolved by name; [libraryPath] lets host
  /// tests point at a locally built copy.
  static NativeAudioAnalysis? tryLoad({String? libraryPath}) {
    try {
      final lib = DynamicLibrary.open(
          libraryPath ?? (Platform.isAndroid ? 'libnoxira_audio.so' : ''));
      final native = NativeAudioAnalysis._(lib);
      if (native.abiVersion != 3 ||
          native.frameSize != AudioFrameLayout.size ||
          native.configSize != _ConfigLayout.size) {
        return null;
      }
      return native;
    } catch (_) {
      return null;
    }
  }

  /// Starts (or reconfigures) the analysis thread. Idempotent.
  bool start(AudioAnalysisConfig config) => _withConfig(config, _start);

  /// Applies new settings to a running engine.
  bool updateConfig(AudioAnalysisConfig config) =>
      _withConfig(config, _updateConfig);

  /// Stops the analysis thread. Idempotent; PCM pushes become no-ops.
  void stop() => _stop();

  /// Stops the engine and releases what can be released.
  void shutdown() => _shutdown();

  bool get isRunning => _isRunning() != 0;

  void setPlaybackState(AudioAnalysisState state) =>
      _setPlaybackState(state.index);

  /// Registers a native callback invoked on the analysis thread after every
  /// frame. Pass `nullptr` to remove it.
  void setFrameCallback(
          Pointer<NativeFunction<Void Function(Int64)>> callback) =>
      _setCallback(callback);

  /// The newest unread frame, or null. The returned object is reused; it
  /// stays valid until the next call (see [AudioFrame]).
  AudioFrame? acquireFrame() {
    final ptr = _acquireFrame();
    if (ptr == nullptr) return null;
    return _frames.putIfAbsent(ptr.address,
        () => AudioFrame.view(ptr.asTypedList(AudioFrameLayout.size)));
  }

  AudioAnalysisStats readStats() {
    final raw = calloc<Uint8>(72);
    try {
      _getStats(raw);
      final d = ByteData.sublistView(raw.asTypedList(72));
      return AudioAnalysisStats(
        framesPublished: d.getInt64(0, Endian.host),
        pushCalls: d.getInt64(8, Endian.host),
        pushedFrames: d.getInt64(16, Endian.host),
        ringOverruns: d.getInt64(24, Endian.host),
        activeSources: d.getInt32(32, Endian.host),
        running: d.getInt32(36, Endian.host) != 0,
        avgProcessUs: d.getFloat32(40, Endian.host),
        maxProcessUs: d.getFloat32(44, Endian.host),
        avgPushUs: d.getFloat32(48, Endian.host),
        maxPushUs: d.getFloat32(52, Endian.host),
        cpuPercent: d.getFloat32(56, Endian.host),
      );
    } finally {
      calloc.free(raw);
    }
  }

  // ---- PCM sources: used by the Kotlin tap through JNI; exposed here so the
  // ---- engine can be driven from tests without a player.

  int acquireSource() => _acquireSource();
  void releaseSource(int source) => _releaseSource(source);
  void configureSource(int source, int sampleRate, int channels) =>
      _configureSource(source, sampleRate, channels);
  void flushSource(int source) => _flushSource(source);

  /// Pushes interleaved signed 16-bit PCM. Returns the frames consumed.
  int pushPcm16(int source, Int16List interleaved, int channels) {
    final frames = interleaved.length ~/ channels;
    final buffer = calloc<Int16>(interleaved.length);
    try {
      buffer.asTypedList(interleaved.length).setAll(0, interleaved);
      return _pushPcm(source, buffer.cast(), frames, 1);
    } finally {
      calloc.free(buffer);
    }
  }

  bool _withConfig(AudioAnalysisConfig c, _StartD fn) {
    if (c.regionEdgesHz.length != AudioAnalysisConfig.regionEdgeCount) {
      throw ArgumentError.value(c.regionEdgesHz, 'regionEdgesHz',
          'needs ${AudioAnalysisConfig.regionEdgeCount} ascending values');
    }
    final raw = calloc<Uint8>(_ConfigLayout.size);
    try {
      _defaultConfig(raw);
      final d = ByteData.sublistView(raw.asTypedList(_ConfigLayout.size));
      void i32(int off, int v) => d.setInt32(off, v, Endian.host);
      void f32(int off, double v) => d.setFloat32(off, v, Endian.host);
      i32(_ConfigLayout.fftSize, c.fftSize);
      i32(_ConfigLayout.bandCount, c.bandCount);
      i32(_ConfigLayout.analysisRate, c.analysisRateHz);
      i32(_ConfigLayout.stereoBands, c.stereoBands ? 1 : 0);
      i32(_ConfigLayout.spectrumBins, c.spectrumBins);
      i32(_ConfigLayout.waveformSize, c.waveformSize);
      i32(_ConfigLayout.visualizerSpectrum, c.visualizerSpectrum ? 1 : 0);
      f32(_ConfigLayout.minHz, c.minHz);
      f32(_ConfigLayout.maxHz, c.maxHz);
      for (var i = 0; i < AudioAnalysisConfig.regionEdgeCount; i++) {
        f32(_ConfigLayout.regionEdges + 4 * i, c.regionEdgesHz[i]);
      }
      f32(_ConfigLayout.attackMs, c.attackMs);
      f32(_ConfigLayout.releaseMs, c.releaseMs);
      f32(_ConfigLayout.peakHoldMs, c.peakHoldMs);
      f32(_ConfigLayout.peakDecay, c.peakDecayPerSecond);
      f32(_ConfigLayout.noiseFloor, c.noiseFloorDb);
      f32(_ConfigLayout.dynamicRange, c.dynamicRangeDb);
      f32(_ConfigLayout.minReference, c.minReferenceDb);
      f32(_ConfigLayout.normRelease, c.normalizationReleaseDbPerSecond);
      f32(_ConfigLayout.tilt, c.sensitivityTiltDbPerOctave);
      for (var i = 0;
          i < c.bandSensitivityDb.length && i < AudioFrameLayout.maxBands;
          i++) {
        f32(_ConfigLayout.bandSensitivity + 4 * i, c.bandSensitivityDb[i]);
      }
      f32(_ConfigLayout.onsetSensitivity, c.onsetSensitivity);
      f32(_ConfigLayout.latency, c.latencyCompensationMs);
      f32(_ConfigLayout.contrast, c.contrast);
      f32(_ConfigLayout.referenceMix, c.globalReferenceMix);
      f32(_ConfigLayout.levelFloor, c.levelFloor);
      f32(_ConfigLayout.normAttack, c.normalizationAttackMs);
      return fn(raw) != 0;
    } finally {
      calloc.free(raw);
    }
  }
}
