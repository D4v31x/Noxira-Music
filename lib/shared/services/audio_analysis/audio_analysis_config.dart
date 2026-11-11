/// Configuration of the native audio analysis engine.
library;

/// Immutable engine settings. Every field has a documented range; the native
/// side clamps out-of-range values, the constructor rejects invalid discrete
/// choices early.
class AudioAnalysisConfig {
  const AudioAnalysisConfig({
    this.fftSize = 2048,
    this.bandCount = 64,
    this.analysisRateHz = 60,
    this.stereoBands = false,
    this.visualizerSpectrum = false,
    this.spectrumBins = 512,
    this.waveformSize = 512,
    this.minHz = 20,
    this.maxHz = 20000,
    this.regionEdgesHz = defaultRegionEdgesHz,
    this.attackMs = 40,
    this.releaseMs = 200,
    this.peakHoldMs = 400,
    this.peakDecayPerSecond = 0.8,
    this.noiseFloorDb = -70,
    this.dynamicRangeDb = 48,
    this.minReferenceDb = -18,
    this.normalizationReleaseDbPerSecond = 2.5,
    this.sensitivityTiltDbPerOctave = 0,
    this.bandSensitivityDb = const [],
    this.onsetSensitivity = 0.5,
    this.latencyCompensationMs = 0,
    this.contrast = 1,
    this.globalReferenceMix = 1,
    this.levelFloor = 0,
    this.normalizationAttackMs = 0,
  })  : assert(fftSize == 1024 || fftSize == 2048 || fftSize == 4096,
            'fftSize must be 1024, 2048 or 4096'),
        assert(bandCount == 32 || bandCount == 64 || bandCount == 128,
            'bandCount must be 32, 64 or 128'),
        assert(analysisRateHz >= 10 && analysisRateHz <= 120,
            'analysisRateHz must be 10..120');

  /// Boundaries of sub-bass, bass, low mids, midrange, upper mids, presence
  /// and high frequencies (Hz).
  static const List<double> defaultRegionEdgesHz = [
    20, 60, 250, 500, 2000, 4000, 8000, 20000, //
  ];
  static const int regionEdgeCount = 8;

  /// FFT length in samples: 1024, 2048 or 4096. Larger sizes resolve low
  /// frequencies better but react more slowly and cost more CPU.
  final int fftSize;

  /// Number of logarithmically spaced output bands: 32, 64 or 128.
  final int bandCount;

  /// Analysis updates per second (10..120). 30-60 is typical for visuals.
  final int analysisRateHz;

  /// Also analyse left and right separately (`bandsLeft` / `bandsRight`).
  final bool stereoBands;

  /// Export a full-resolution floating-point Hann spectrum in the display's
  /// capture amplitude scale. Generic bands and measurements are unchanged.
  final bool visualizerSpectrum;

  /// Entries of the exported linear spectrum (power of two, up to 1024).
  final int spectrumBins;

  /// Entries of the exported waveform (power of two, up to 512).
  final int waveformSize;

  /// Frequency range covered by the bands.
  final double minHz, maxHz;

  /// Region boundaries, 8 ascending values (see [defaultRegionEdgesHz]).
  final List<double> regionEdgesHz;

  /// Smoothing time constants for rising / falling band values.
  final double attackMs, releaseMs;

  /// How long peak markers hold, and how fast they then fall (units/second).
  final double peakHoldMs, peakDecayPerSecond;

  /// Band levels below this (dBFS) count as silence and are never amplified.
  final double noiseFloorDb;

  /// Dynamic normalisation: levels this far below the reference map to 0.
  /// The reference includes 6 dB of headroom above recent peaks.
  final double dynamicRangeDb;

  /// Lowest normalisation reference (dBFS), including headroom; limits gain
  /// during quiet passages instead of stretching them to full scale.
  final double minReferenceDb;

  /// How fast the normalisation reference falls after loud passages.
  final double normalizationReleaseDbPerSecond;

  /// Frequency dependent sensitivity: dB added per octave above 1 kHz
  /// (negative values below). Counters the natural spectral tilt of music.
  final double sensitivityTiltDbPerOctave;

  /// Optional extra gain (dB) per band, up to 128 entries (missing = 0).
  final List<double> bandSensitivityDb;

  /// 0..1; higher detects more onsets/percussion hits.
  final double onsetSensitivity;

  /// Delays the analysed audio (ms) to line visuals up with slower outputs
  /// such as Bluetooth speakers.
  final double latencyCompensationMs;

  /// Power curve applied to band/region levels (0.5..4). Values above 1 push
  /// mid levels down so only strong peaks reach the top; 1 is linear.
  final double contrast;

  /// 0..1: how much each band is scaled against a shared reference rather
  /// than its own recent peak. The default 1 preserves relative band levels;
  /// lower values opt into boosting quiet bands independently.
  final double globalReferenceMix;

  /// 0..0.9: normalised levels below this read exactly 0 and the remaining
  /// range is stretched to 0..1 (applied before [contrast]). Keeps weak
  /// content from cluttering the display.
  final double levelFloor;

  /// How fast the normalisation reference rises to louder content. 0 follows
  /// peaks instantly; a few hundred ms lets short peaks (bass hits, a vocal
  /// onset) overshoot instead of pulling every other band down for seconds.
  final double normalizationAttackMs;

  AudioAnalysisConfig copyWith({
    int? fftSize,
    int? bandCount,
    int? analysisRateHz,
    bool? stereoBands,
    bool? visualizerSpectrum,
    int? spectrumBins,
    int? waveformSize,
    double? minHz,
    double? maxHz,
    List<double>? regionEdgesHz,
    double? attackMs,
    double? releaseMs,
    double? peakHoldMs,
    double? peakDecayPerSecond,
    double? noiseFloorDb,
    double? dynamicRangeDb,
    double? minReferenceDb,
    double? normalizationReleaseDbPerSecond,
    double? sensitivityTiltDbPerOctave,
    List<double>? bandSensitivityDb,
    double? onsetSensitivity,
    double? latencyCompensationMs,
    double? contrast,
    double? globalReferenceMix,
    double? levelFloor,
    double? normalizationAttackMs,
  }) =>
      AudioAnalysisConfig(
        fftSize: fftSize ?? this.fftSize,
        bandCount: bandCount ?? this.bandCount,
        analysisRateHz: analysisRateHz ?? this.analysisRateHz,
        stereoBands: stereoBands ?? this.stereoBands,
        visualizerSpectrum: visualizerSpectrum ?? this.visualizerSpectrum,
        spectrumBins: spectrumBins ?? this.spectrumBins,
        waveformSize: waveformSize ?? this.waveformSize,
        minHz: minHz ?? this.minHz,
        maxHz: maxHz ?? this.maxHz,
        regionEdgesHz: regionEdgesHz ?? this.regionEdgesHz,
        attackMs: attackMs ?? this.attackMs,
        releaseMs: releaseMs ?? this.releaseMs,
        peakHoldMs: peakHoldMs ?? this.peakHoldMs,
        peakDecayPerSecond: peakDecayPerSecond ?? this.peakDecayPerSecond,
        noiseFloorDb: noiseFloorDb ?? this.noiseFloorDb,
        dynamicRangeDb: dynamicRangeDb ?? this.dynamicRangeDb,
        minReferenceDb: minReferenceDb ?? this.minReferenceDb,
        normalizationReleaseDbPerSecond: normalizationReleaseDbPerSecond ??
            this.normalizationReleaseDbPerSecond,
        sensitivityTiltDbPerOctave:
            sensitivityTiltDbPerOctave ?? this.sensitivityTiltDbPerOctave,
        bandSensitivityDb: bandSensitivityDb ?? this.bandSensitivityDb,
        onsetSensitivity: onsetSensitivity ?? this.onsetSensitivity,
        latencyCompensationMs:
            latencyCompensationMs ?? this.latencyCompensationMs,
        contrast: contrast ?? this.contrast,
        globalReferenceMix: globalReferenceMix ?? this.globalReferenceMix,
        levelFloor: levelFloor ?? this.levelFloor,
        normalizationAttackMs:
            normalizationAttackMs ?? this.normalizationAttackMs,
      );
}

/// Counters for profiling the engine (see `AudioAnalysisService.readStats`).
class AudioAnalysisStats {
  const AudioAnalysisStats({
    this.framesPublished = 0,
    this.pushCalls = 0,
    this.pushedFrames = 0,
    this.ringOverruns = 0,
    this.activeSources = 0,
    this.running = false,
    this.avgProcessUs = 0,
    this.maxProcessUs = 0,
    this.avgPushUs = 0,
    this.maxPushUs = 0,
    this.cpuPercent = 0,
  });

  /// Analysis frames produced since the engine started.
  final int framesPublished;

  /// PCM buffers received from the player, and the sample frames in them.
  final int pushCalls, pushedFrames;

  /// Times the analysis fell so far behind that audio was skipped.
  final int ringOverruns;

  final int activeSources;
  final bool running;

  /// DSP time per analysis frame (microseconds).
  final double avgProcessUs, maxProcessUs;

  /// Cost of handing one PCM buffer over on the audio thread (microseconds).
  final double avgPushUs, maxPushUs;

  /// CPU time of the analysis thread relative to wall time, in percent.
  final double cpuPercent;

  @override
  String toString() => 'AudioAnalysisStats(frames=$framesPublished, '
      'dsp=${avgProcessUs.toStringAsFixed(1)}us avg/${maxProcessUs.toStringAsFixed(1)}us max, '
      'push=${avgPushUs.toStringAsFixed(2)}us avg/${maxPushUs.toStringAsFixed(1)}us max, '
      'cpu=${cpuPercent.toStringAsFixed(2)}%, overruns=$ringOverruns)';
}
