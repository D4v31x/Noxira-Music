/// Cascade follow-through for the lyrics list.
///
/// When the list auto-scrolls, each row below the active line holds back by
/// what just scrolled and then catches up on its own critically damped spring.
/// The further below the active line, the later it arrives, so the list
/// settles in a visible cascade instead of moving as one rigid sheet.
///
/// Motion model adapted from musicfy (https://github.com/realidkroo/musicfy,
/// GPL-3.0).
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Extra catch-up time per row of distance below the active line.
const double kStaggerLagPerRowMs = 55;

/// Rows further down than this all use the same (slowest) lag.
const int kStaggerMaxRows = 9;

class LyricsStagger extends ChangeNotifier {
  LyricsStagger(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick);
  }

  late final Ticker _ticker;
  final Map<int, double> _lags = {};
  final Map<int, double> _velocities = {};
  int _anchor = -1;
  Duration _last = Duration.zero;

  /// How far row [row] currently trails its resting place, in pixels.
  double lagOf(int row) => _lags[row] ?? 0;

  bool get isActive => _lags.isNotEmpty;

  /// Registers [consumed] pixels of scroll; every row in [rows] holds back by
  /// that amount. [anchor] is the active row the cascade is measured from.
  void addScroll(double consumed, Iterable<int> rows, int anchor) {
    if (consumed == 0) return;
    _anchor = anchor;
    for (final row in rows) {
      _lags[row] = (_lags[row] ?? 0) + consumed;
    }
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void clear() {
    _lags.clear();
    _velocities.clear();
    if (_ticker.isActive) _ticker.stop();
    notifyListeners();
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.064);
    _last = elapsed;
    step(dt);
    if (_lags.isEmpty) _ticker.stop();
    notifyListeners();
  }

  /// Advances every lag by [dt] seconds. Exposed for tests.
  @visibleForTesting
  void step(double dt) {
    final done = <int>[];
    for (final entry in _lags.entries.toList()) {
      final row = entry.key;
      final lag = entry.value;
      final k = (row - _anchor).clamp(1, kStaggerMaxRows);
      // Critically damped toward 0, solved exactly (stable at any frame time).
      final omega = 1000 / (kStaggerLagPerRowMs * k);
      final v = _velocities[row] ?? 0;
      final e = math.exp(-omega * dt);
      final tmp = (v + omega * lag) * dt;
      final nextLag = (lag + tmp) * e;
      final nextV = (v - omega * tmp) * e;
      if (nextLag.abs() < 0.3 && nextV.abs() < 4) {
        done.add(row);
      } else {
        _lags[row] = nextLag;
        _velocities[row] = nextV;
      }
    }
    for (final row in done) {
      _lags.remove(row);
      _velocities.remove(row);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
