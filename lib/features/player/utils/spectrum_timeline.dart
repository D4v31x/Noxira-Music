/// Cached, chunked file analysis for Dolby tracks that cannot safely use
/// Android's Visualizer effect.
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SpectrumTimeline {
  SpectrumTimeline._(this.songId, this.path);

  static const _channel = MethodChannel('aurora/media_actions');
  static final Map<int, SpectrumTimeline> _recent = {};

  static SpectrumTimeline forSong(int songId, String path) {
    final timeline = _recent.remove(songId) ?? SpectrumTimeline._(songId, path);
    _recent[songId] = timeline;
    while (_recent.length > 3) {
      _recent.remove(_recent.keys.first);
    }
    return timeline;
  }

  static const int framesPerChunk = 300;
  static const int _lookaheadChunks = 90;
  static const int _maxChunks = 120;
  static const int _maxFailures = 3;

  final int songId;
  final String path;
  int sampleRate = 48000;
  int frameRate = 30;
  int _bins = 512;
  bool failed = false;

  final Map<int, Uint8List> _chunks = {};
  int? _lastChunk;
  int _focusChunk = 0;
  bool _busy = false;
  int _failures = 0;
  Float64List _sum = Float64List(0);
  int _sumCount = 0;
  Float32List _gains = Float32List(0);

  void focus(int frame) {
    _focusChunk = max(0, frame) ~/ framesPerChunk;
    if (!_busy && !failed) unawaited(_pump());
  }

  Uint8List? frame(int index) {
    if (index < 0 || _gains.length != _bins) return null;
    final chunk = index ~/ framesPerChunk;
    final data = _chunks[chunk];
    if (data == null) return null;
    final base = (index - chunk * framesPerChunk) * _bins;
    if (base + _bins > data.length) return null;
    final out = Uint8List(_bins);
    for (var k = 0; k < _bins; k++) {
      out[k] = min(255.0, data[base + k] * _gains[k]).round();
    }
    return out;
  }

  int? _nextWanted() {
    for (var c = _focusChunk; c <= _focusChunk + _lookaheadChunks; c++) {
      if (_lastChunk != null && c > _lastChunk!) break;
      if (!_chunks.containsKey(c)) return c;
    }
    if (_chunks.length >= _maxChunks) return null;
    for (var c = _focusChunk - 1;
        c >= 0 && _focusChunk - c <= _lookaheadChunks;
        c--) {
      if (!_chunks.containsKey(c)) return c;
    }
    return null;
  }

  Future<void> _pump() async {
    _busy = true;
    try {
      while (!failed) {
        final chunk = _nextWanted();
        if (chunk == null) break;
        await _decode(chunk);
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _decode(int chunk) async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>(
        'analyzeSpectrum',
        {
          'path': path,
          'startFrame': chunk * framesPerChunk,
          'frameCount': framesPerChunk,
        },
      );
      if (res == null) throw StateError('Spectrum decode returned no data');
      sampleRate = res['sampleRate'] as int;
      frameRate = res['frameRate'] as int;
      _bins = res['bins'] as int;
      final data = res['data'] as Uint8List;
      final frames = data.length ~/ _bins;
      final durationUs = res['durationUs'] as int;
      if (durationUs > 0) {
        final totalFrames =
            durationUs * frameRate / Duration.microsecondsPerSecond;
        _lastChunk ??= (totalFrames / framesPerChunk).ceil() - 1;
      }
      if (frames < framesPerChunk) {
        if (frames == 0 && chunk == 0) throw StateError('No audio to analyze');
        _lastChunk = frames == 0 ? chunk - 1 : chunk;
      }
      if (frames > 0) {
        _chunks[chunk] = data;
        _accumulate(data, frames);
      }
      _failures = 0;
    } on PlatformException catch (error) {
      await _decodeFailed(error);
    } on StateError catch (error) {
      await _decodeFailed(error);
    }
  }

  Future<void> _decodeFailed(Object error) async {
    debugPrint('[visualizer] Dolby spectrum decode failed: $error');
    if (++_failures >= _maxFailures) {
      failed = true;
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }

  static const _refHz = [80.0, 280.0, 1000.0, 3500.0, 10000.0];
  static const _refLevel = [41.0, 27.0, 13.0, 4.0, 1.1];
  static const _maxGain = 16.0;
  static const _minGain = 0.25;

  void _accumulate(Uint8List data, int frames) {
    if (_sum.length != _bins) {
      _sum = Float64List(_bins);
      _sumCount = 0;
    }
    for (var f = 0; f < frames; f += 2) {
      final base = f * _bins;
      for (var k = 0; k < _bins; k++) {
        _sum[k] += data[base + k];
      }
      _sumCount++;
    }
    _gains = _computeGains();
  }

  static double _reference(double hz) {
    if (hz <= _refHz.first) return _refLevel.first;
    if (hz >= _refHz.last) return _refLevel.last;
    for (var i = 1; i < _refHz.length; i++) {
      if (hz <= _refHz[i]) {
        final t = (log(hz) - log(_refHz[i - 1])) /
            (log(_refHz[i]) - log(_refHz[i - 1]));
        return _refLevel[i - 1] + (_refLevel[i] - _refLevel[i - 1]) * t;
      }
    }
    return _refLevel.last;
  }

  Float32List _computeGains() {
    final prefix = Float64List(_bins + 1);
    for (var k = 0; k < _bins; k++) {
      prefix[k + 1] = prefix[k] + (_sumCount > 0 ? _sum[k] / _sumCount : 0.0);
    }
    final binHz = sampleRate / (_bins * 2);
    final gains = Float32List(_bins);
    for (var k = 1; k < _bins; k++) {
      final lo = max(1, min(k - 1, (k * 0.8).floor()));
      final hi = min(_bins - 1, max(k + 1, (k * 1.25).ceil()));
      final avg = (prefix[hi + 1] - prefix[lo]) / (hi - lo + 1);
      gains[k] = (_reference(k * binHz) / max(avg, 1e-3))
          .clamp(_minGain, _maxGain)
          .toDouble();
    }
    return gains;
  }
}
