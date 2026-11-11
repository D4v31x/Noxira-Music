import 'dart:typed_data';

import 'package:aurora_music_v01/shared/services/audio_analysis/audio_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

/// Writes a frame the way the native engine lays it out in memory.
Uint8List _buildFrame() {
  final bytes = Uint8List(AudioFrameLayout.size);
  final d = ByteData.sublistView(bytes);
  void i32(int o, int v) => d.setInt32(o, v, Endian.host);
  void f32(int o, double v) => d.setFloat32(o, v, Endian.host);
  d.setInt64(AudioFrameLayout.timestampUs, 1234567, Endian.host);
  d.setInt64(AudioFrameLayout.sequence, 42, Endian.host);
  i32(AudioFrameLayout.structSize, AudioFrameLayout.size);
  i32(AudioFrameLayout.abiVersion, 3);
  i32(AudioFrameLayout.state, AudioAnalysisState.playing.index);
  i32(AudioFrameLayout.sampleRate, 44100);
  i32(AudioFrameLayout.sourceChannels, 6);
  i32(AudioFrameLayout.fftSize, 2048);
  i32(AudioFrameLayout.bandCount, 64);
  i32(AudioFrameLayout.spectrumCount, 512);
  i32(AudioFrameLayout.waveformCount, 256);
  i32(AudioFrameLayout.visualizerSpectrumCount, 512);
  i32(AudioFrameLayout.discontinuityCount, 3);
  i32(
      AudioFrameLayout.flags,
      AudioFrameLayout.flagOnset |
          AudioFrameLayout.flagBeat |
          AudioFrameLayout.flagKick);
  const scalars = <int, double>{
    AudioFrameLayout.rms: 0.25,
    AudioFrameLayout.peak: 0.5,
    AudioFrameLayout.peakHold: 0.75,
    AudioFrameLayout.energy: 0.5,
    AudioFrameLayout.centroidHz: 1500,
    AudioFrameLayout.centroid: 0.625,
    AudioFrameLayout.flux: 0.125,
    AudioFrameLayout.zeroCrossingRate: 0.0625,
    AudioFrameLayout.transient: 0.875,
    AudioFrameLayout.onsetStrength: 0.375,
    AudioFrameLayout.beatConfidence: 0.9375,
    AudioFrameLayout.bpm: 128,
    AudioFrameLayout.kick: 0.5,
    AudioFrameLayout.snare: 0.25,
    AudioFrameLayout.hihat: 0.125,
    AudioFrameLayout.percussion: 0.5,
    AudioFrameLayout.bassActivity: 0.75,
    AudioFrameLayout.stereoWidth: 0.3125,
    AudioFrameLayout.stereoCorrelation: -0.5,
    AudioFrameLayout.stereoBalance: 0.25,
    AudioFrameLayout.rmsLeft: 0.2,
    AudioFrameLayout.rmsRight: 0.4,
    AudioFrameLayout.peakLeft: 0.6,
    AudioFrameLayout.peakRight: 0.8,
  };
  scalars.forEach(f32);
  for (var r = 0; r < AudioFrameLayout.regionCount; r++) {
    f32(AudioFrameLayout.regions + 4 * r, (r + 1) / 8);
    f32(AudioFrameLayout.regionPeaks + 4 * r, (r + 1) / 16);
  }
  for (var i = 0; i < 64; i++) {
    f32(AudioFrameLayout.bands + 4 * i, i / 64);
    f32(AudioFrameLayout.bandsLeft + 4 * i, 0.25);
    f32(AudioFrameLayout.bandsRight + 4 * i, 0.5);
    f32(AudioFrameLayout.bandPeaks + 4 * i, i / 32);
  }
  for (var i = 0; i < 512; i++) {
    f32(AudioFrameLayout.spectrum + 4 * i, i / 512);
  }
  for (var i = 0; i < 256; i++) {
    f32(AudioFrameLayout.waveformLeft + 4 * i, -0.5);
    f32(AudioFrameLayout.waveformRight + 4 * i, 0.5);
  }
  f32(AudioFrameLayout.visualizerSpectrum + 4 * 40, 100.5);
  return bytes;
}

void main() {
  group('AudioFrameLayout', () {
    test('arrays do not overlap and fit the frame', () {
      const arrays = <(int, int)>[
        (AudioFrameLayout.regions, AudioFrameLayout.regionCount),
        (AudioFrameLayout.regionPeaks, AudioFrameLayout.regionCount),
        (AudioFrameLayout.bands, AudioFrameLayout.maxBands),
        (AudioFrameLayout.bandsLeft, AudioFrameLayout.maxBands),
        (AudioFrameLayout.bandsRight, AudioFrameLayout.maxBands),
        (AudioFrameLayout.bandPeaks, AudioFrameLayout.maxBands),
        (AudioFrameLayout.spectrum, AudioFrameLayout.maxSpectrum),
        (AudioFrameLayout.waveformLeft, AudioFrameLayout.maxWaveform),
        (AudioFrameLayout.waveformRight, AudioFrameLayout.maxWaveform),
        (AudioFrameLayout.visualizerSpectrum, AudioFrameLayout.visualizerBins),
      ];
      var end = 0;
      for (final (offset, count) in arrays) {
        expect(offset >= end, isTrue, reason: 'array at $offset overlaps');
        expect(offset % 4, 0);
        end = offset + 4 * count;
      }
      expect(end <= AudioFrameLayout.size, isTrue);
    });
  });

  group('AudioFrame', () {
    test('reads every documented field at its offset', () {
      final f = AudioFrame.view(_buildFrame());
      expect(f.timestampUs, 1234567);
      expect(f.sequence, 42);
      expect(f.state, AudioAnalysisState.playing);
      expect(f.sampleRate, 44100);
      expect(f.sourceChannels, 6);
      expect(f.fftSize, 2048);
      expect(f.bandCount, 64);
      expect(f.spectrumCount, 512);
      expect(f.waveformCount, 256);
      expect(f.discontinuityCount, 3);

      expect(f.isOnset, isTrue);
      expect(f.isBeat, isTrue);
      expect(f.isKickHit, isTrue);
      expect(f.isSnareHit, isFalse);
      expect(f.isHihatHit, isFalse);
      expect(f.isSilent, isFalse);

      expect(f.rms, 0.25);
      expect(f.peak, 0.5);
      expect(f.peakHold, 0.75);
      expect(f.energy, 0.5);
      expect(f.centroidHz, 1500);
      expect(f.centroid, 0.625);
      expect(f.flux, 0.125);
      expect(f.zeroCrossingRate, 0.0625);
      expect(f.transient, 0.875);
      expect(f.onsetStrength, 0.375);
      expect(f.beatConfidence, 0.9375);
      expect(f.bpm, 128);
      expect(f.kick, 0.5);
      expect(f.snare, 0.25);
      expect(f.hihat, 0.125);
      expect(f.percussion, 0.5);
      expect(f.bassActivity, 0.75);
      expect(f.stereoWidth, 0.3125);
      expect(f.stereoCorrelation, -0.5);
      expect(f.stereoBalance, 0.25);
      expect(f.rmsLeft, closeTo(0.2, 1e-6));
      expect(f.rmsRight, closeTo(0.4, 1e-6));
      expect(f.peakLeft, closeTo(0.6, 1e-6));
      expect(f.peakRight, closeTo(0.8, 1e-6));
    });

    test('exposes the seven frequency regions independently', () {
      final f = AudioFrame.view(_buildFrame());
      expect(f.subBass, 1 / 8);
      expect(f.bass, 2 / 8);
      expect(f.lowMid, 3 / 8);
      expect(f.midrange, 4 / 8);
      expect(f.upperMid, 5 / 8);
      expect(f.presence, 6 / 8);
      expect(f.high, 7 / 8);
      for (final r in AudioRegion.values) {
        expect(f.region(r), (r.index + 1) / 8);
      }
      expect(f.regions.length, 7);
      expect(f.regionPeaks[3], 4 / 16);
    });

    test('array getters return correctly sized views', () {
      final f = AudioFrame.view(_buildFrame());
      expect(f.bands.length, 64);
      expect(f.bandsLeft.length, 64);
      expect(f.bandsRight.length, 64);
      expect(f.bandPeaks.length, 64);
      expect(f.spectrum.length, 512);
      expect(f.waveformLeft.length, 256);
      expect(f.waveformRight.length, 256);
      expect(f.bands[32], 0.5);
      expect(f.bandsLeft[10], 0.25);
      expect(f.bandsRight[10], 0.5);
      expect(f.bandPeaks[32], 1.0);
      expect(f.spectrum[256], 0.5);
      expect(f.waveformLeft.first, -0.5);
      expect(f.waveformRight.last, 0.5);
      expect(f.visualizerSpectrum.length, 512);
      expect(f.visualizerSpectrum[40], 100.5);
    });

    test('array getters are zero-copy and cached', () {
      final bytes = _buildFrame();
      final f = AudioFrame.view(bytes);
      final bands = f.bands;
      expect(identical(bands, f.bands), isTrue);
      ByteData.sublistView(bytes)
          .setFloat32(AudioFrameLayout.bands, 0.99, Endian.host);
      expect(bands[0], closeTo(0.99, 1e-6));
    });

    test('views follow a changing band count', () {
      final bytes = _buildFrame();
      final f = AudioFrame.view(bytes);
      expect(f.bands.length, 64);
      ByteData.sublistView(bytes)
          .setInt32(AudioFrameLayout.bandCount, 128, Endian.host);
      expect(f.bands.length, 128);
      ByteData.sublistView(bytes)
          .setInt32(AudioFrameLayout.bandCount, 9999, Endian.host);
      expect(f.bands.length, AudioFrameLayout.maxBands); // clamped
    });

    test('snapshot is independent of the source memory', () {
      final bytes = _buildFrame();
      final live = AudioFrame.view(bytes);
      final copy = live.snapshot();
      ByteData.sublistView(bytes)
          .setFloat32(AudioFrameLayout.rms, 0.9, Endian.host);
      expect(live.rms, closeTo(0.9, 1e-6));
      expect(copy.rms, 0.25);
      expect(copy.sequence, 42);
      expect(copy.bands[32], 0.5);
    });

    test('empty frames carry their state and all-zero data', () {
      final f = AudioFrame.empty(AudioAnalysisState.unsupported);
      expect(f.state, AudioAnalysisState.unsupported);
      expect(f.energy, 0);
      expect(f.bandCount, 0);
      expect(f.bands, isEmpty);
      expect(f.isBeat, isFalse);
      expect(AudioFrame.empty().state, AudioAnalysisState.inactive);
    });

    test('rejects memory that is too small', () {
      expect(() => AudioFrame.view(Uint8List(100)), throwsArgumentError);
    });

    test('maps native states', () {
      for (final s in AudioAnalysisState.values) {
        expect(AudioAnalysisState.fromNative(s.index), s);
      }
      expect(AudioAnalysisState.fromNative(-1), AudioAnalysisState.inactive);
      expect(AudioAnalysisState.fromNative(99), AudioAnalysisState.inactive);
    });
  });

  group('AudioAnalysisConfig', () {
    test('defaults match the documented engine defaults', () {
      const c = AudioAnalysisConfig();
      expect(c.fftSize, 2048);
      expect(c.bandCount, 64);
      expect(c.analysisRateHz, 60);
      expect(c.attackMs, 40);
      expect(c.releaseMs, 200);
      expect(c.minReferenceDb, -18);
      expect(c.dynamicRangeDb, 48);
      expect(c.globalReferenceMix, 1);
      expect(c.sensitivityTiltDbPerOctave, 0);
      expect(c.levelFloor, 0);
      expect(c.contrast, 1);
      expect(c.normalizationAttackMs, 0);
      expect(c.visualizerSpectrum, isFalse);
      expect(c.regionEdgesHz, [20, 60, 250, 500, 2000, 4000, 8000, 20000]);
    });

    test('copyWith overrides only what is given', () {
      final c =
          const AudioAnalysisConfig().copyWith(fftSize: 4096, bandCount: 128);
      expect(c.fftSize, 4096);
      expect(c.bandCount, 128);
      expect(c.analysisRateHz, 60);
    });

    test('rejects unsupported discrete values', () {
      expect(() => AudioAnalysisConfig(fftSize: 3000), throwsAssertionError);
      expect(() => AudioAnalysisConfig(bandCount: 50), throwsAssertionError);
      expect(
          () => AudioAnalysisConfig(analysisRateHz: 500), throwsAssertionError);
    });
  });

  group('AudioAnalysisService on unsupported platforms', () {
    test('reports unsupported and never emits frames', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final service = AudioAnalysisService.instance; // host VM, not Android
      expect(service.isSupported, isFalse);
      expect(service.state, AudioAnalysisState.unsupported);
      final lease = service.requestAnalysis();
      expect(lease.isActive, isFalse);
      expect(service.isRunning, isFalse);
      expect(service.latestFrame.state, AudioAnalysisState.unsupported);
      expect(service.readStats().framesPublished, 0);
      lease.release();
      lease.release(); // idempotent
    });
  });
}
