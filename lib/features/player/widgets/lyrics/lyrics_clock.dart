/// Frame-accurate playback clock for lyrics animation.
///
/// The player's position stream only ticks a few times a second, which makes
/// progress sweeps visibly steppy. This clock extrapolates between samples and
/// notifies once per frame, but only while playback is running.
library;

import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

class LyricsClock extends ValueNotifier<int> {
  LyricsClock(TickerProvider vsync) : super(0) {
    _ticker = vsync.createTicker((_) => _publish());
  }

  late final Ticker _ticker;
  final Stopwatch _sinceSample = Stopwatch();

  int _baseMs = 0;
  double _speed = 1.0;
  bool _playing = false;

  /// Added to every reading (user sync adjustment).
  int offsetMs = 0;

  int get _extrapolated =>
      _baseMs + (_sinceSample.elapsedMilliseconds * _speed).round();

  /// Feeds a new sample from the player.
  void sync(Duration position, {required bool playing, double speed = 1.0}) {
    final sample = position.inMilliseconds;
    // Small disagreements are just stream jitter; keep the smooth estimate.
    final keep = _playing &&
        playing &&
        speed == _speed &&
        (sample - _extrapolated).abs() < 150;
    if (!keep) {
      _baseMs = sample;
      _sinceSample
        ..reset()
        ..start();
    }
    _speed = speed;
    _setPlaying(playing);
    _publish();
  }

  void _setPlaying(bool playing) {
    _playing = playing;
    if (playing) {
      if (!_ticker.isActive) _ticker.start();
      _sinceSample.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
      _sinceSample.stop();
    }
  }

  void _publish() {
    final next = _extrapolated + offsetMs;
    if (next != value) value = next;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
