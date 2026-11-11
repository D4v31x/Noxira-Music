/// The data contract between the native audio analysis engine and Dart.
///
/// [AudioFrame] is a typed, zero-copy view over the native `NoxiraAudioFrame`
/// struct (`android/app/src/main/cpp/noxira_audio/include/noxira_audio/
/// noxira_audio.h`). Its byte offsets are part of the engine's ABI and are
/// pinned by `static_assert`s in the C++ sources and by the unit tests.
library;

import 'dart:typed_data';

/// Where the analysis currently stands. Mirrors `NoxiraState`.
enum AudioAnalysisState {
  /// Analysis is not running.
  inactive,

  /// Running, but no PCM has reached the engine yet (track still loading, or
  /// the playback path bypasses audio processors, e.g. passthrough/offload).
  waiting,

  /// Audio is playing and being analysed.
  playing,

  /// Playback is paused; the frame values decay to zero.
  paused,

  /// The player is buffering or loading.
  buffering,

  /// Playback completed or was stopped.
  ended,

  /// This platform has no analysis backend (only Android is implemented).
  unsupported;

  static AudioAnalysisState fromNative(int value) =>
      value >= 0 && value < values.length ? values[value] : inactive;
}

/// The seven frequency regions with independently readable energy.
///
/// The default boundaries (Hz) are 20 / 60 / 250 / 500 / 2000 / 4000 / 8000 /
/// 20000 and can be changed through `AudioAnalysisConfig.regionEdgesHz`.
enum AudioRegion { subBass, bass, lowMid, midrange, upperMid, presence, high }

/// Byte offsets inside the native frame struct (all little-endian on Android).
abstract final class AudioFrameLayout {
  static const int size = 18688;
  static const int maxBands = 128;
  static const int maxSpectrum = 1024;
  static const int maxWaveform = 512;
  static const int regionCount = 7;

  // header
  static const int timestampUs = 0;
  static const int sequence = 8;
  static const int structSize = 16;
  static const int abiVersion = 20;
  static const int state = 24;
  static const int sampleRate = 28;
  static const int sourceChannels = 32;
  static const int fftSize = 36;
  static const int bandCount = 40;
  static const int spectrumCount = 44;
  static const int waveformCount = 48;
  static const int discontinuityCount = 52;
  static const int flags = 56;
  static const int visualizerSpectrumCount = 60;

  // scalar features (float32)
  static const int rms = 64;
  static const int peak = 68;
  static const int peakHold = 72;
  static const int energy = 76;
  static const int centroidHz = 80;
  static const int centroid = 84;
  static const int flux = 88;
  static const int zeroCrossingRate = 92;
  static const int transient = 96;
  static const int onsetStrength = 100;
  static const int beatConfidence = 104;
  static const int bpm = 108;
  static const int kick = 112;
  static const int snare = 116;
  static const int hihat = 120;
  static const int percussion = 124;
  static const int bassActivity = 128;
  static const int stereoWidth = 132;
  static const int stereoCorrelation = 136;
  static const int stereoBalance = 140;
  static const int rmsLeft = 144;
  static const int rmsRight = 148;
  static const int peakLeft = 152;
  static const int peakRight = 156;

  // arrays (float32)
  static const int regions = 192;
  static const int regionPeaks = 224;
  static const int bands = 256;
  static const int bandsLeft = 768;
  static const int bandsRight = 1280;
  static const int bandPeaks = 1792;
  static const int spectrum = 2304;
  static const int waveformLeft = 6400;
  static const int waveformRight = 8448;
  static const int visualizerSpectrum = 10496;
  static const int visualizerBins = 2048;

  // bits of `flags`
  static const int flagOnset = 1 << 0;
  static const int flagBeat = 1 << 1;
  static const int flagKick = 1 << 2;
  static const int flagSnare = 1 << 3;
  static const int flagHihat = 1 << 4;
  static const int flagSilent = 1 << 5;
}

/// One analysis result.
///
/// All "normalised" values are in 0..1. Time based values (smoothing, decay,
/// peak hold) do not depend on the analysis rate. The array getters return
/// views into the frame's memory without copying.
///
/// **Lifetime.** Frames delivered by `AudioAnalysisService` are a small pool of
/// reused objects backed by native memory, so no allocation happens per
/// update. A frame stays valid until the service delivers the next frame;
/// call [snapshot] to keep a copy.
class AudioFrame {
  AudioFrame._(this._bytes)
      : _data = ByteData.sublistView(_bytes),
        assert(_bytes.lengthInBytes >= AudioFrameLayout.size);

  /// Wraps [bytes], which must hold at least [AudioFrameLayout.size] bytes in
  /// the native frame layout (e.g. memory returned by the engine).
  factory AudioFrame.view(Uint8List bytes) {
    if (bytes.lengthInBytes < AudioFrameLayout.size) {
      throw ArgumentError.value(bytes.lengthInBytes, 'bytes',
          'must be at least ${AudioFrameLayout.size} bytes');
    }
    return AudioFrame._(bytes);
  }

  /// An all-zero frame in the given state.
  factory AudioFrame.empty(
      [AudioAnalysisState state = AudioAnalysisState.inactive]) {
    final frame = AudioFrame._(Uint8List(AudioFrameLayout.size));
    frame._data.setInt32(
        AudioFrameLayout.structSize, AudioFrameLayout.size, Endian.host);
    frame._data.setInt32(AudioFrameLayout.state, state.index, Endian.host);
    return frame;
  }

  final Uint8List _bytes;
  final ByteData _data;

  // Cached array views (rebuilt only when the entry count changes).
  Float32List? _bands, _bandsLeft, _bandsRight, _bandPeaks, _spectrum;
  Float32List? _waveformLeft, _waveformRight, _regions, _regionPeaks;
  Float32List? _visualizerSpectrum;
  int _visualizerSpectrumFor = -1;
  int _bandsFor = -1, _spectrumFor = -1, _waveformFor = -1;

  /// An independent copy that stays valid after the engine reuses this frame.
  AudioFrame snapshot() => AudioFrame._(Uint8List.fromList(_bytes));

  double _f(int offset) => _data.getFloat32(offset, Endian.host);
  int _i(int offset) => _data.getInt32(offset, Endian.host);

  Float32List _view(int offset, int count) =>
      Float32List.view(_bytes.buffer, _bytes.offsetInBytes + offset, count);

  // ---- header ----

  /// Analysed audio time in microseconds since the last [discontinuityCount]
  /// change (seek, track change). Relative, not the player's media position.
  int get timestampUs =>
      _data.getInt64(AudioFrameLayout.timestampUs, Endian.host);

  /// Increases by one per published frame; use it to detect new frames.
  int get sequence => _data.getInt64(AudioFrameLayout.sequence, Endian.host);

  AudioAnalysisState get state =>
      AudioAnalysisState.fromNative(_i(AudioFrameLayout.state));

  /// Sample rate (Hz) of the analysed stream, 0 when unknown.
  int get sampleRate => _i(AudioFrameLayout.sampleRate);

  /// Channel count of the analysed stream before the stereo fold-down.
  int get sourceChannels => _i(AudioFrameLayout.sourceChannels);

  int get fftSize => _i(AudioFrameLayout.fftSize);
  int get bandCount => _i(AudioFrameLayout.bandCount);
  int get spectrumCount => _i(AudioFrameLayout.spectrumCount);
  int get waveformCount => _i(AudioFrameLayout.waveformCount);

  /// Increments whenever the stream jumps (seek, track change, flush).
  int get discontinuityCount => _i(AudioFrameLayout.discontinuityCount);

  int get _flags => _i(AudioFrameLayout.flags);

  // ---- events (true for a single frame) ----

  /// Any onset (note/beat/percussion start) happened in this frame.
  bool get isOnset => _flags & AudioFrameLayout.flagOnset != 0;

  /// A beat (low-frequency onset on the tempo grid) happened in this frame.
  bool get isBeat => _flags & AudioFrameLayout.flagBeat != 0;
  bool get isKickHit => _flags & AudioFrameLayout.flagKick != 0;
  bool get isSnareHit => _flags & AudioFrameLayout.flagSnare != 0;
  bool get isHihatHit => _flags & AudioFrameLayout.flagHihat != 0;

  /// The input is below the noise floor (silence, or paused/ended).
  bool get isSilent => _flags & AudioFrameLayout.flagSilent != 0;

  // ---- frequency regions (normalised, smoothed) ----

  /// Energy of one [AudioRegion], 0..1.
  double region(AudioRegion region) => regions[region.index];

  double get subBass => regions[0]; // 20-60 Hz by default
  double get bass => regions[1]; // 60-250 Hz
  double get lowMid => regions[2]; // 250-500 Hz
  double get midrange => regions[3]; // 500-2000 Hz
  double get upperMid => regions[4]; // 2000-4000 Hz
  double get presence => regions[5]; // 4000-8000 Hz
  double get high => regions[6]; // 8000-20000 Hz

  /// All seven region energies, indexed by [AudioRegion.index].
  Float32List get regions => _regions ??=
      _view(AudioFrameLayout.regions, AudioFrameLayout.regionCount);

  /// Floating-point Hann FFT magnitudes in the display's capture amplitude
  /// scale. Bin k is at k * sampleRate / fftSize Hz. No 8-bit quantization.
  /// Empty unless visualizerSpectrum is enabled in the analysis config.
  Float32List get visualizerSpectrum {
    final count = _i(AudioFrameLayout.visualizerSpectrumCount)
        .clamp(0, AudioFrameLayout.visualizerBins);
    if (count != _visualizerSpectrumFor) {
      _visualizerSpectrum = _view(AudioFrameLayout.visualizerSpectrum, count);
      _visualizerSpectrumFor = count;
    }
    return _visualizerSpectrum!;
  }

  /// Peak-hold markers of [regions].
  Float32List get regionPeaks => _regionPeaks ??=
      _view(AudioFrameLayout.regionPeaks, AudioFrameLayout.regionCount);

  // ---- signal analysis ----

  /// Linear RMS of both channels over the newest ~21 ms (0 .. ~1 full scale).
  double get rms => _f(AudioFrameLayout.rms);

  /// Largest absolute sample of the same window (0 .. ~1 full scale).
  double get peak => _f(AudioFrameLayout.peak);

  /// [peak] with hold and decay.
  double get peakHold => _f(AudioFrameLayout.peakHold);

  /// Overall loudness, normalised against recent history, 0..1.
  double get energy => _f(AudioFrameLayout.energy);

  /// Spectral centroid in Hz, 0 when silent.
  double get centroidHz => _f(AudioFrameLayout.centroidHz);

  /// Spectral centroid on a logarithmic 20 Hz .. 20 kHz scale, 0..1.
  double get centroid => _f(AudioFrameLayout.centroid);

  /// Spectral flux (how fast the spectrum changes), normalised 0..1.
  double get flux => _f(AudioFrameLayout.flux);

  /// Sign changes per sample, 0..1 (about 0.5 for white noise).
  double get zeroCrossingRate => _f(AudioFrameLayout.zeroCrossingRate);

  /// Transient strength, 0..1, decaying after a hit.
  double get transient => _f(AudioFrameLayout.transient);

  /// Strength (0..1) of the onset in this frame, 0 otherwise.
  double get onsetStrength => _f(AudioFrameLayout.onsetStrength);

  /// How regular the recent beats are, 0..1.
  double get beatConfidence => _f(AudioFrameLayout.beatConfidence);

  /// Tempo estimate in BPM from recent beats, 0 when unknown.
  double get bpm => _f(AudioFrameLayout.bpm);

  // ---- musical component activity (DSP heuristics, not instrument ID) ----
  //
  // These react to characteristic energy bursts: a kick is a sudden rise in
  // 30-120 Hz, a snare a simultaneous rise in the low-mids and 1.5-6 kHz, a
  // hi-hat a rise above 6 kHz. Frequency bands alone cannot identify
  // instruments or vocals; treat these as "kick-/snare-/hi-hat-like" activity.

  /// Kick-like activity, 0..1 (jumps on a hit, then decays).
  double get kick => _f(AudioFrameLayout.kick);
  double get snare => _f(AudioFrameLayout.snare);
  double get hihat => _f(AudioFrameLayout.hihat);

  /// General percussive activity (strongest of kick/snare/hi-hat).
  double get percussion => _f(AudioFrameLayout.percussion);

  /// Sustained low-frequency (sub-bass + bass) activity, 0..1.
  double get bassActivity => _f(AudioFrameLayout.bassActivity);

  // ---- stereo ----

  /// Side / (mid + side): 0 for mono, towards 1 for wide or out-of-phase.
  double get stereoWidth => _f(AudioFrameLayout.stereoWidth);

  /// Left/right correlation, -1 (out of phase) .. 1 (identical).
  double get stereoCorrelation => _f(AudioFrameLayout.stereoCorrelation);

  /// -1 (left only) .. 1 (right only).
  double get stereoBalance => _f(AudioFrameLayout.stereoBalance);

  double get rmsLeft => _f(AudioFrameLayout.rmsLeft);
  double get rmsRight => _f(AudioFrameLayout.rmsRight);
  double get peakLeft => _f(AudioFrameLayout.peakLeft);
  double get peakRight => _f(AudioFrameLayout.peakRight);

  // ---- spectrum, bands, waveform (views, no copies) ----

  /// Logarithmically spaced band levels (32, 64 or 128), normalised 0..1.
  Float32List get bands {
    _refreshBandViews();
    return _bands!;
  }

  /// Left channel bands; equal to [bands] unless `stereoBands` is enabled.
  Float32List get bandsLeft {
    _refreshBandViews();
    return _bandsLeft!;
  }

  Float32List get bandsRight {
    _refreshBandViews();
    return _bandsRight!;
  }

  /// Peak-hold markers of [bands].
  Float32List get bandPeaks {
    _refreshBandViews();
    return _bandPeaks!;
  }

  /// Linear-frequency spectrum (normalised dB), `spectrumCount` entries
  /// covering 0 Hz .. Nyquist; entry `i` is centred at
  /// `(i + 0.5) * nyquist / spectrumCount` Hz.
  Float32List get spectrum {
    final count = spectrumCount.clamp(0, AudioFrameLayout.maxSpectrum);
    if (count != _spectrumFor) {
      _spectrum = _view(AudioFrameLayout.spectrum, count);
      _spectrumFor = count;
    }
    return _spectrum!;
  }

  /// Newest samples of the left channel (-1..1), peak-preserving decimation.
  Float32List get waveformLeft {
    _refreshWaveformViews();
    return _waveformLeft!;
  }

  Float32List get waveformRight {
    _refreshWaveformViews();
    return _waveformRight!;
  }

  void _refreshBandViews() {
    final count = bandCount.clamp(0, AudioFrameLayout.maxBands);
    if (count == _bandsFor) return;
    _bands = _view(AudioFrameLayout.bands, count);
    _bandsLeft = _view(AudioFrameLayout.bandsLeft, count);
    _bandsRight = _view(AudioFrameLayout.bandsRight, count);
    _bandPeaks = _view(AudioFrameLayout.bandPeaks, count);
    _bandsFor = count;
  }

  void _refreshWaveformViews() {
    final count = waveformCount.clamp(0, AudioFrameLayout.maxWaveform);
    if (count == _waveformFor) return;
    _waveformLeft = _view(AudioFrameLayout.waveformLeft, count);
    _waveformRight = _view(AudioFrameLayout.waveformRight, count);
    _waveformFor = count;
  }

  @override
  String toString() => 'AudioFrame(#$sequence $state, ${sampleRate}Hz, '
      'energy=${energy.toStringAsFixed(2)}, bass=${bass.toStringAsFixed(2)}, '
      'beat=$isBeat)';
}
