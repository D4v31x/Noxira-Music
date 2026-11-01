import 'dart:typed_data';

import 'package:aurora_music_v01/features/player/utils/spectrum_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a native-style FFT packet with a tone spread over bins around
/// [binIndex] (a pure single-bin tone is unrealistic and is mostly smoothed
/// away by design).
Uint8List _toneFrame(int binIndex, {int amplitude = 100, int size = 1024}) {
  final data = Uint8List(size + 1);
  data[0] = 1;
  final bd = ByteData.sublistView(data);
  for (int k = binIndex - 2; k <= binIndex + 2; k++) {
    if (k < 1) continue;
    bd.setInt8(1 + 2 * k, amplitude);
  }
  return data;
}

void main() {
  test('tone excites the matching bar and not the far end', () {
    final a = SpectrumAnalyzer();
    // Bin 40 @ 44.1 kHz / 1024 ≈ 1.7 kHz.
    for (int i = 0; i < 30; i++) {
      a.submit(_toneFrame(40));
      a.update(1 / 60, playing: true);
    }
    final peak = a.bars.indexOf(a.bars.reduce((x, y) => x > y ? x : y));
    expect(a.bars[peak], greaterThan(0.3));
    expect(peak, inInclusiveRange(20, 36));
    expect(a.bars.first, lessThan(0.1));
    expect(a.bars.last, lessThan(0.1));
  });

  test('bass tone drives bass energy and decays after silence', () {
    final a = SpectrumAnalyzer();
    for (int i = 0; i < 20; i++) {
      a.submit(_toneFrame(2, amplitude: 120));
      a.update(1 / 60, playing: true);
    }
    expect(a.bass, greaterThan(0.3));
    for (int i = 0; i < 90; i++) {
      a.submit(_toneFrame(2, amplitude: 0));
      a.update(1 / 60, playing: true);
    }
    expect(a.bass, lessThan(0.05));
  });

  test('attack is fast regardless of frame rate', () {
    final fast = SpectrumAnalyzer();
    final slow = SpectrumAnalyzer();
    for (int i = 0; i < 12; i++) {
      fast.submit(_toneFrame(2));
      fast.update(1 / 120, playing: true);
    }
    for (int i = 0; i < 6; i++) {
      slow.submit(_toneFrame(2));
      slow.update(1 / 60, playing: true);
    }
    expect((fast.bass - slow.bass).abs(), lessThan(0.05));
  });
}
