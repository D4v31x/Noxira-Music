import 'dart:math';
import 'dart:typed_data';

import 'package:aurora_music_v01/features/player/utils/spectrum_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _toneFrame(int binIndex, {int amplitude = 100, int size = 1024}) {
  final data = Uint8List(size + 1);
  data[0] = 1;
  final bd = ByteData.sublistView(data);
  for (var k = binIndex - 2; k <= binIndex + 2; k++) {
    if (k < 1) continue;
    bd.setInt8(1 + 2 * k, amplitude);
  }
  return data;
}

void main() {
  test('live FFT excites the matching bar rather than unrelated bands', () {
    final analyzer = SpectrumAnalyzer();
    for (var i = 0; i < 30; i++) {
      analyzer.submit(_toneFrame(40));
      analyzer.update(1 / 60, playing: true);
    }
    final peak = analyzer.bars.indexOf(analyzer.bars.reduce(max));
    final expected =
        log((40 * 44100 / 1024) / 40) / log(18000 / 40) * analyzer.barCount;
    expect(peak, closeTo(expected, 2));
    expect(analyzer.bars[peak], greaterThan(0.3));
    expect(analyzer.bars.first, lessThan(0.1));
    expect(analyzer.bars.last, lessThan(0.1));
    expect(analyzer.hasRealData, isTrue);
  });

  test('bass responds to FFT data and decays after silence', () {
    final analyzer = SpectrumAnalyzer();
    for (var i = 0; i < 20; i++) {
      analyzer.submit(_toneFrame(2, amplitude: 120));
      analyzer.update(1 / 60, playing: true);
    }
    expect(analyzer.bass, greaterThan(0.3));
    for (var i = 0; i < 90; i++) {
      analyzer.submit(_toneFrame(2, amplitude: 0));
      analyzer.update(1 / 60, playing: true);
    }
    expect(analyzer.bass, lessThan(0.05));
  });

  test('attack is independent of the display frame rate', () {
    final fast = SpectrumAnalyzer();
    final slow = SpectrumAnalyzer();
    for (var i = 0; i < 12; i++) {
      fast.submit(_toneFrame(2));
      fast.update(1 / 120, playing: true);
    }
    for (var i = 0; i < 6; i++) {
      slow.submit(_toneFrame(2));
      slow.update(1 / 60, playing: true);
    }
    expect((fast.bass - slow.bass).abs(), lessThan(0.05));
  });

  test('precomputed Dolby magnitudes use the same analysis as live FFT', () {
    final live = SpectrumAnalyzer();
    final file = SpectrumAnalyzer();
    final packet = _toneFrame(40);
    final magnitudes = Uint8List(512);
    for (var k = 38; k <= 42; k++) {
      magnitudes[k] = 100;
    }
    for (var i = 0; i < 30; i++) {
      live.submit(packet);
      file.submitMagnitudes(magnitudes, 44100);
      live.update(1 / 60, playing: true);
      file.update(1 / 60, playing: true);
    }
    expect(file.bars, orderedEquals(live.bars));
    expect(file.overall, live.overall);
    expect(file.hasRealData, isTrue);
  });

  test('sampling-rate packets remap FFT bins to the correct frequencies', () {
    final analyzer = SpectrumAnalyzer();
    final rate = Uint8List(5)..[0] = 3;
    ByteData.sublistView(rate).setInt32(1, 48000000);
    analyzer.submit(rate);
    for (var i = 0; i < 30; i++) {
      analyzer.submit(_toneFrame(40));
      analyzer.update(1 / 60, playing: true);
    }
    final peak = analyzer.bars.indexOf(analyzer.bars.reduce(max));
    final expected =
        log((40 * 48000 / 1024) / 40) / log(18000 / 40) * analyzer.barCount;
    expect(peak, closeTo(expected, 2));
  });

  test('native float magnitudes preserve the approved FFT calibration', () {
    final old = SpectrumAnalyzer();
    final pcm = SpectrumAnalyzer();
    final packet = _toneFrame(40, amplitude: 70);
    final bytes = ByteData.sublistView(packet);
    final spectrum = Float32List(512);
    for (var k = 38; k <= 42; k++) {
      bytes.setInt8(2 + 2 * k, 45);
      spectrum[k] = sqrt(70 * 70 + 45 * 45);
    }
    for (var i = 0; i < 180; i++) {
      old.submit(packet);
      pcm.submitMagnitudes(spectrum, 44100);
      old.update(1 / 60, playing: true);
      pcm.update(1 / 60, playing: true);
      for (var band = 0; band < old.barCount; band++) {
        expect(pcm.bars[band], closeTo(old.bars[band], 1e-6));
      }
    }
  });

  test('native spectra remap at the minimum supported sample rate', () {
    final analyzer = SpectrumAnalyzer()..allowSimulation = false;
    final magnitudes = Float32List(2048)..[512] = 100;
    for (var i = 0; i < 90; i++) {
      analyzer.submitMagnitudes(magnitudes, 8000);
      analyzer.update(1 / 60, playing: true);
    }
    final peak = analyzer.bars.indexOf(analyzer.bars.reduce(max));
    expect(analyzer.frequenciesHz[peak], closeTo(1000, 100));
    expect(analyzer.bars[peak], greaterThan(0.3));
  });

  for (final (start, end) in [(220.0, 60.0), (2400.0, 600.0)]) {
    test('high-resolution $start-$end Hz glide travels smoothly between bands',
        () {
      final analyzer = SpectrumAnalyzer()..allowSimulation = false;
      double sinc(double x) => x.abs() < 1e-8 ? 1 : sin(pi * x) / (pi * x);
      Float32List spectrum(double hz) {
        final data = Float32List(2048);
        final bin = hz * 4096 / 48000;
        for (var k = max(1, bin.floor() - 4);
            k <= min(data.length - 1, bin.ceil() + 4);
            k++) {
          final d = k - bin;
          data[k] = 100 * (sinc(d) + 0.5 * (sinc(d - 1) + sinc(d + 1))).abs();
        }
        return data;
      }

      for (var i = 0; i < 90; i++) {
        analyzer.submitMagnitudes(spectrum(start), 48000);
        analyzer.update(1 / 60, playing: true);
      }
      final initialPeak = analyzer.bars.indexOf(analyzer.bars.reduce(max));
      var previousCenter = start;
      for (var i = 0; i <= 180; i++) {
        final hz = start + (end - start) * i / 180;
        analyzer.submitMagnitudes(spectrum(hz), 48000);
        analyzer.update(1 / 60, playing: true);
        var sum = 0.0, weightedLogHz = 0.0;
        for (var band = 0; band < analyzer.barCount; band++) {
          sum += analyzer.bars[band];
          weightedLogHz +=
              analyzer.bars[band] * log(analyzer.frequenciesHz[band]);
        }
        expect(sum, greaterThan(0));
        final center = exp(weightedLogHz / sum);
        if (i > 0) {
          expect((log(center / previousCenter)).abs(), lessThan(0.1));
        }
        previousCenter = center;
      }
      final finalPeak = analyzer.bars.indexOf(analyzer.bars.reduce(max));
      expect(initialPeak - finalPeak, greaterThan(8));
      expect(previousCenter, lessThan(end * 1.6));
    });
  }

  test('waiting for Dolby data does not synthesize waves', () {
    final analyzer = SpectrumAnalyzer()..allowSimulation = false;
    for (var i = 0; i < 120; i++) {
      analyzer.update(1 / 60, playing: true);
    }
    expect(analyzer.bars.every((v) => v == 0), isTrue);
  });

  test('pause relaxes real-data bars to zero', () {
    final analyzer = SpectrumAnalyzer();
    for (var i = 0; i < 30; i++) {
      analyzer.submit(_toneFrame(40));
      analyzer.update(1 / 60, playing: true);
    }
    for (var i = 0; i < 240; i++) {
      analyzer.update(1 / 60, playing: false);
    }
    expect(analyzer.bars.every((v) => v == 0), isTrue);
  });

  test('reset permits the previous fallback when native data is unavailable',
      () {
    final analyzer = SpectrumAnalyzer();
    analyzer.submit(_toneFrame(2));
    analyzer.update(1 / 60, playing: true);
    analyzer.resetRealData();
    expect(analyzer.hasRealData, isFalse);
    for (var i = 0; i < 60; i++) {
      analyzer.update(1 / 60, playing: true);
    }
    expect(analyzer.bars.any((v) => v > 0.1), isTrue);
  });
}
