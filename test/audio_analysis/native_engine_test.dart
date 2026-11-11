// Integration tests of the Dart <-> native path: FFI bindings, the service's
// lifecycle handling and real frame delivery. They run on the host against a
// locally built libnoxira_audio.so:
//
//   cmake -S android/app/src/main/cpp -B build/noxira_host \
//         -DCMAKE_BUILD_TYPE=Release -DNOXIRA_BUILD_TESTS=ON -G Ninja
//   cmake --build build/noxira_host
//   flutter test test/audio_analysis
//
// (Override the library with NOXIRA_NATIVE_LIB.) Without the library the
// tests are skipped.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:aurora_music_v01/shared/services/audio_analysis/audio_analysis.dart';
import 'package:aurora_music_v01/shared/services/audio_analysis/native_audio_analysis.dart';
import 'package:aurora_music_v01/features/player/utils/spectrum_analyzer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

final String _libPath = Platform.environment['NOXIRA_NATIVE_LIB'] ??
    'build/noxira_host/libnoxira_audio.so';
final bool _hasLib = File(_libPath).existsSync();

/// Streams a sine wave into [source] at real-time pace.
Future<void> _feedSine(
  NativeAudioAnalysis native,
  int source, {
  required double hz,
  required double seconds,
  double amplitude = 0.5,
  int sampleRate = 48000,
  int channels = 2,
}) async {
  const chunkMs = 10;
  final chunk = sampleRate * chunkMs ~/ 1000;
  final watch = Stopwatch()..start();
  var n = 0;
  for (var c = 0; c < seconds * 1000 ~/ chunkMs; c++) {
    final pcm = Int16List(chunk * channels);
    for (var i = 0; i < chunk; i++, n++) {
      final v = (32767 * amplitude * sin(2 * pi * hz * n / sampleRate)).round();
      for (var ch = 0; ch < channels; ch++) {
        pcm[i * channels + ch] = v;
      }
    }
    native.pushPcm16(source, pcm, channels);
    final due = (c + 1) * chunkMs;
    final wait = due - watch.elapsedMilliseconds;
    if (wait > 0) await Future<void>.delayed(Duration(milliseconds: wait));
  }
}

int _argmax(Float32List v) {
  var best = 0;
  for (var i = 1; i < v.length; i++) {
    if (v[i] > v[best]) best = i;
  }
  return best;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final skip = _hasLib ? null : 'native library not built: $_libPath';

  late NativeAudioAnalysis native;
  late AudioAnalysisService service;

  setUp(() {
    if (!_hasLib) return;
    native = NativeAudioAnalysis.tryLoad(libraryPath: _libPath)!;
    native.stop();
    service = AudioAnalysisService.forTesting(native);
  });

  tearDown(() {
    if (!_hasLib) return;
    service.dispose();
    native.stop();
  });

  test('library loads and the ABI matches the Dart layout', () {
    expect(NativeAudioAnalysis.tryLoad(libraryPath: _libPath), isNotNull);
    expect(native.abiVersion, 3);
    expect(native.frameSize, AudioFrameLayout.size);
    expect(NativeAudioAnalysis.tryLoad(libraryPath: '/nonexistent/lib.so'),
        isNull);
  }, skip: skip);

  test('analysis runs only while a lease is held (ref counted, idempotent)',
      () {
    expect(native.isRunning, isFalse);
    final a = service.requestAnalysis();
    expect(service.isRunning, isTrue);
    expect(native.isRunning, isTrue);
    final b = service.requestAnalysis();
    a.release();
    expect(native.isRunning, isTrue, reason: 'second lease still holds it');
    b.release();
    expect(native.isRunning, isFalse);
    expect(service.isRunning, isFalse);
    b.release(); // double release is harmless
    final c = service.requestAnalysis();
    expect(native.isRunning, isTrue);
    c.release();
    expect(native.isRunning, isFalse);
  }, skip: skip);

  test('delivers analysed frames for a played sine wave', () async {
    final lease = service.requestAnalysis(
      config: const AudioAnalysisConfig(
        fftSize: 4096,
        bandCount: 128,
        stereoBands: true,
      ),
    );
    native.setPlaybackState(AudioAnalysisState.playing);
    final source = native.acquireSource();
    expect(source, greaterThanOrEqualTo(0));
    native.configureSource(source, 48000, 2);

    final seen = <int>{};
    var count = 0;
    var firstSeq = -1, lastSeq = -1;
    final sub = service.frames.listen((f) {
      seen.add(identityHashCode(f));
      firstSeq = firstSeq < 0 ? f.sequence : firstSeq;
      lastSeq = f.sequence;
      count++;
    });

    await _feedSine(native, source, hz: 1000, seconds: 1.5);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final f = service.latestFrame;

    expect(f.state, AudioAnalysisState.playing);
    expect(f.sampleRate, 48000);
    expect(f.sourceChannels, 2);
    expect(f.fftSize, 4096);
    expect(f.bandCount, 128);
    expect(f.bands.length, 128);
    // 1 kHz on a 20 Hz..20 kHz log scale with 128 bands: index ~72.5
    expect(_argmax(f.bands), inInclusiveRange(70, 75));
    expect(f.bands[_argmax(f.bands)], greaterThan(0.8));
    expect(f.region(AudioRegion.midrange), greaterThan(0.8));
    expect(f.region(AudioRegion.subBass), lessThan(0.1));
    expect(f.rms, closeTo(0.5 / sqrt2, 0.03));
    expect(f.peak, closeTo(0.5, 0.02));
    expect(f.centroidHz, closeTo(1000, 120));
    expect(f.stereoCorrelation, greaterThan(0.99));
    expect(f.stereoBalance.abs(), lessThan(0.03));
    expect(f.energy, greaterThan(0.3));
    expect(f.bandsLeft.length, 128);
    expect(f.bandsLeft[_argmax(f.bands)], greaterThan(0.8));
    expect(f.waveformLeft.length, 512);
    expect(f.waveformLeft.any((s) => s.abs() > 0.3), isTrue);
    expect(f.spectrum.length, 512);
    expect(f.timestampUs, greaterThan(1000000));

    // ~60 frames per second, delivered as a handful of reused objects.
    expect(count, inInclusiveRange(60, 110)); // 1.5 s
    expect(lastSeq - firstSeq + 1, greaterThanOrEqualTo(count));
    expect(seen.length, lessThanOrEqualTo(3));

    await sub.cancel();
    native.releaseSource(source);
    lease.release();
  }, skip: skip);

  test('pause decays to zero, resume plays again, seek is a discontinuity',
      () async {
    final lease = service.requestAnalysis();
    native.setPlaybackState(AudioAnalysisState.playing);
    final source = native.acquireSource();
    native.configureSource(source, 44100, 2);

    await _feedSine(native, source, hz: 2000, seconds: 1.0, sampleRate: 44100);
    final disc = service.latestFrame.discontinuityCount;

    native.flushSource(source); // seek
    await _feedSine(native, source, hz: 500, seconds: 0.5, sampleRate: 44100);
    expect(service.latestFrame.discontinuityCount, greaterThan(disc));
    expect(service.latestFrame.timestampUs, lessThan(700000));

    native.setPlaybackState(AudioAnalysisState.paused);
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    expect(service.latestFrame.state, AudioAnalysisState.paused);
    expect(service.latestFrame.bands.every((v) => v == 0), isTrue);
    expect(service.latestFrame.energy, 0);

    native.setPlaybackState(AudioAnalysisState.playing);
    await _feedSine(native, source, hz: 500, seconds: 0.6, sampleRate: 44100);
    expect(service.latestFrame.state, AudioAnalysisState.playing);
    expect(service.latestFrame.bands.any((v) => v > 0.5), isTrue);

    native.releaseSource(source);
    lease.release();
  }, skip: skip);

  test('PCM spectrum drives the approved visualiser without Android effects',
      () async {
    final lease = service.requestAnalysis(
        config:
            const AudioAnalysisConfig(fftSize: 4096, visualizerSpectrum: true));
    final source = native.acquireSource();
    native.configureSource(source, 48000, 2);
    native.setPlaybackState(AudioAnalysisState.playing);
    final display = SpectrumAnalyzer()..allowSimulation = false;
    final sub = service.frames.listen((frame) {
      display.submitMagnitudes(frame.visualizerSpectrum, frame.sampleRate);
      display.update(1 / 60,
          playing: frame.state == AudioAnalysisState.playing);
    });
    await _feedSine(native, source, hz: 1500, seconds: 1.0);
    final raw = service.latestFrame.visualizerSpectrum;
    expect(raw.length, 2048);
    expect(_argmax(raw), 128); // 1500 Hz at 48000 / 4096 Hz per bin
    expect(raw[128], greaterThan(100));
    expect(display.bars.reduce(max), greaterThan(0.3));
    expect(display.bars.first, lessThan(0.05));
    expect(display.bars.last, lessThan(0.05));
    await sub.cancel();
    native.releaseSource(source);
    lease.release();
  }, skip: skip);

  test('a newer lease reconfigures the running engine, releasing restores',
      () async {
    final base = service.requestAnalysis();
    final source = native.acquireSource();
    native.configureSource(source, 48000, 2);
    native.setPlaybackState(AudioAnalysisState.playing);
    await _feedSine(native, source, hz: 440, seconds: 0.4);
    expect(service.latestFrame.fftSize, 2048);

    final wide = service.requestAnalysis(
        config: const AudioAnalysisConfig(fftSize: 1024, bandCount: 32));
    await _feedSine(native, source, hz: 440, seconds: 0.5);
    expect(service.latestFrame.fftSize, 1024);
    expect(service.latestFrame.bandCount, 32);

    wide.release();
    await _feedSine(native, source, hz: 440, seconds: 0.5);
    expect(service.latestFrame.fftSize, 2048);
    expect(service.latestFrame.bandCount, 64);

    native.releaseSource(source);
    base.release();
  }, skip: skip);

  test('stops in the background unless a lease keeps it alive', () {
    final normal = service.requestAnalysis();
    expect(native.isRunning, isTrue);
    service.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(native.isRunning, isFalse, reason: 'no analysis while backgrounded');
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(native.isRunning, isTrue, reason: 'resumes with the app');
    normal.release();
    expect(native.isRunning, isFalse);

    final persistent = service.requestAnalysis(keepAliveInBackground: true);
    service.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(native.isRunning, isTrue);
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    persistent.release();
    expect(native.isRunning, isFalse);
  }, skip: skip);

  test('no frames are produced when no lease is held', () async {
    // Counters belong to the last run, so compare against the start value.
    final framesBefore = native.readStats().framesPublished;
    final source = native.acquireSource();
    native.configureSource(source, 48000, 2);
    await _feedSine(native, source, hz: 1000, seconds: 0.3);
    final stats = native.readStats();
    expect(stats.running, isFalse);
    expect(stats.framesPublished, framesBefore);
    expect(native.pushPcm16(source, Int16List(960 * 2), 2), 0,
        reason: 'PCM is ignored while analysis is off');
    native.releaseSource(source);
  }, skip: skip);

  test('reports profiling counters', () async {
    final lease = service.requestAnalysis();
    final slotsBefore = service.readStats().activeSources;
    final source = native.acquireSource();
    native.configureSource(source, 48000, 2);
    native.setPlaybackState(AudioAnalysisState.playing);
    await _feedSine(native, source, hz: 1000, seconds: 1.0);
    final stats = service.readStats();
    expect(stats.running, isTrue);
    expect(stats.framesPublished, greaterThan(30));
    expect(stats.pushCalls, greaterThan(50));
    expect(stats.avgProcessUs, greaterThan(0));
    expect(stats.avgProcessUs, lessThan(2000));
    expect(stats.cpuPercent, lessThan(10));
    expect(stats.activeSources, slotsBefore + 1);
    // ignore: avoid_print
    print(stats);
    native.releaseSource(source);
    lease.release();
  }, skip: skip);

  group('player state mapping', () {
    test('maps just_audio states for the engine', () {
      AudioAnalysisState map(bool playing, ProcessingState p) =>
          AudioAnalysisService.mapPlayerState(PlayerState(playing, p));
      expect(map(true, ProcessingState.ready), AudioAnalysisState.playing);
      expect(map(false, ProcessingState.ready), AudioAnalysisState.paused);
      expect(
          map(true, ProcessingState.buffering), AudioAnalysisState.buffering);
      expect(map(true, ProcessingState.loading), AudioAnalysisState.buffering);
      expect(map(false, ProcessingState.loading), AudioAnalysisState.paused);
      expect(map(true, ProcessingState.completed), AudioAnalysisState.ended);
      expect(map(false, ProcessingState.idle), AudioAnalysisState.ended);
    });
  });
}
