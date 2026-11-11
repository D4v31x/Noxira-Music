/// Maps floating-point PCM spectra (or legacy Android FFT packets) to smooth,
/// music-reactive levels with logarithmic bands, perceptual gain and
/// time-based attack/release.
library;

import 'dart:math';
import 'dart:typed_data';

class SpectrumAnalyzer {
  SpectrumAnalyzer({this.barCount = 64})
      : bars = List.filled(barCount, 0.0),
        _target = List.filled(barCount, 0.0),
        _scratch = List.filled(barCount, 0.0),
        _barCenterHz = List.filled(barCount, 0.0),
        _lo = List.filled(barCount, 0.0),
        _hi = List.filled(barCount, 0.0),
        _tilt = List.filled(barCount, 0.0),
        _barRef = List.filled(barCount, _minRef),
        _attackTau = List.filled(barCount, 0.0),
        _releaseTau = List.filled(barCount, 0.0) {
    _buildMapping(1024);
  }

  static const double _minHz = 40.0;
  static const double _maxHz = 18000.0;
  static const double _bassMaxHz = 150.0;
  static const double _floorDb = -46.0;
  static const double _gate = 0.34;
  static const double _minRef = 0.65;
  static const double _agcHeadroom = 1.08;
  static const double _agcReleaseSec = 8.0;
  static const double _barRefReleaseSec = 6.0;
  static const double _barRefMix = 0.4;
  static const double _contrast = 1.6;
  static const double _tiltDbPerOctave = 3.2;
  static const double _bassAttackTau = 0.035;
  static const double _bassReleaseTau = 0.20;

  final int barCount;

  /// Smoothed bar levels in 0..1, shared by reference with the painters.
  final List<double> bars;
  double bass = 0.0;
  double overall = 0.0;
  List<double> get frequenciesHz => _barCenterHz;
  bool hasRealData = false;
  bool allowSimulation = true;

  final List<double> _target;
  final List<double> _scratch;
  final List<double> _barCenterHz;
  final List<double> _lo;
  final List<double> _hi;
  final List<double> _tilt;
  final List<double> _barRef;
  final List<double> _attackTau;
  final List<double> _releaseTau;

  Float64List _mag = Float64List(0);
  Uint8List? _pending;
  List<num>? _pendingMagnitudes;
  double _sampleRate = 44100.0;
  int _mappedFftLen = 0;
  double _mappedRate = 0.0;
  double _agcRef = _minRef;
  double _bassTarget = 0.0;
  double _simTime = 0.0;

  /// Native FFT packet (0x01) or sampling rate in milliHz (0x03).
  void submit(Uint8List packet) {
    if (packet.length < 5) return;
    switch (packet[0]) {
      case 1:
        _pending = packet;
      case 3:
        final milliHz = ByteData.sublistView(packet).getInt32(1);
        if (milliHz > 8000000) _sampleRate = milliHz / 1000.0;
    }
  }

  /// Capture-scaled linear magnitudes; bin k represents k * sampleRate / FFT size.
  void submitMagnitudes(List<num> magnitudes, int sampleRate) {
    if (sampleRate >= 8000) _sampleRate = sampleRate.toDouble();
    _pendingMagnitudes = magnitudes;
  }

  void resetRealData() {
    hasRealData = false;
    _pending = null;
    _pendingMagnitudes = null;
  }

  /// Advances the levels by [dt] seconds; true if a repaint is needed.
  bool update(double dt, {required bool playing}) {
    dt = dt.clamp(0.0, 0.1);
    if (dt <= 0) return false;

    final frame = _pending;
    final mags = _pendingMagnitudes;
    if (mags != null) {
      _pendingMagnitudes = null;
      _analyzeMagnitudes(mags, dt);
      hasRealData = true;
    } else if (frame != null) {
      _pending = null;
      _analyze(frame, dt);
      hasRealData = true;
    } else if (!hasRealData && playing && allowSimulation) {
      _simTime += dt;
      _simulate();
    }

    if (!playing) {
      _target.fillRange(0, barCount, 0.0);
      _bassTarget = 0.0;
    }
    return _smooth(dt);
  }

  void _analyze(Uint8List frame, double dt) {
    final fftLen = frame.length - 1;
    final numBins = fftLen ~/ 2;
    if (numBins < 8) return;
    if (_mag.length != numBins) _mag = Float64List(numBins);
    // Packet after the type byte: DC, Nyquist, re1, im1, re2, im2, ...
    final bd = ByteData.sublistView(frame);
    for (var k = 1; k < numBins; k++) {
      final re = bd.getInt8(1 + 2 * k).toDouble();
      final im = bd.getInt8(2 + 2 * k).toDouble();
      _mag[k] = sqrt(re * re + im * im);
    }
    _mapBars(numBins, fftLen, dt);
  }

  void _analyzeMagnitudes(List<num> mags, double dt) {
    final numBins = mags.length;
    if (numBins < 8) return;
    if (_mag.length != numBins) _mag = Float64List(numBins);
    for (var k = 1; k < numBins; k++) {
      _mag[k] = mags[k].toDouble();
    }
    _mapBars(numBins, numBins * 2, dt);
  }

  void _mapBars(int numBins, int fftLen, double dt) {
    if (fftLen != _mappedFftLen || _sampleRate != _mappedRate) {
      _buildMapping(fftLen);
    }
    var frameMax = 0.0;
    for (var i = 0; i < barCount; i++) {
      final lo = _lo[i];
      final hi = _hi[i];
      double m;
      if (hi - lo < 1.0) {
        final c = (lo + hi) * 0.5;
        final k0 = c.floor().clamp(1, numBins - 2);
        final f = (c - k0).clamp(0.0, 1.0);
        m = _mag[k0] * (1 - f) + _mag[k0 + 1] * f;
      } else {
        final k0 = (lo - 0.5).floor().clamp(1, numBins - 1);
        final k1 = (hi + 0.5).ceil().clamp(k0, numBins - 1);
        double peak = 0.0, power = 0.0, weight = 0.0;
        for (var k = k0; k <= k1; k++) {
          final overlap = (min(hi, k + 0.5) - max(lo, k - 0.5)).clamp(0.0, 1.0);
          if (overlap == 0) continue;
          final v = _mag[k];
          peak = max(peak, v * overlap);
          power += v * v * overlap;
          weight += overlap;
        }
        m = weight > 0 ? 0.3 * peak + 0.7 * sqrt(power / weight) : 0.0;
      }
      final db = 20.0 * log(m / 128.0 + 1e-4) / ln10;
      final level = ((db - _floorDb) / -_floorDb + _tilt[i]).clamp(0.0, 1.0);
      _scratch[i] = level;
      if (level > frameMax) frameMax = level;
    }

    _agcRef = max(
      frameMax * _agcHeadroom,
      _minRef + (_agcRef - _minRef) * exp(-dt / _agcReleaseSec),
    );
    final barDecay = exp(-dt / _barRefReleaseSec);
    for (var i = 0; i < barCount; i++) {
      final level = _scratch[i];
      _barRef[i] = max(
        level * _agcHeadroom,
        _minRef + (_barRef[i] - _minRef) * barDecay,
      );
      final ref = _agcRef * (1 - _barRefMix) + _barRef[i] * _barRefMix;
      final v = ((level - _gate) / max(ref - _gate, 0.1)).clamp(0.0, 1.0);
      _scratch[i] = pow(v, _contrast).toDouble();
    }

    double bassSum = 0.0;
    var bassCount = 0;
    for (var i = 0; i < barCount; i++) {
      final prev = _scratch[i > 0 ? i - 1 : i];
      final next = _scratch[i < barCount - 1 ? i + 1 : i];
      _target[i] = 0.25 * prev + 0.50 * _scratch[i] + 0.25 * next;
      if (_barCenterHz[i] <= _bassMaxHz) {
        bassSum += _scratch[i];
        bassCount++;
      }
    }
    _bassTarget = bassCount > 0 ? bassSum / bassCount : _target[0];
  }

  void _buildMapping(int fftLen) {
    _mappedFftLen = fftLen;
    _mappedRate = _sampleRate;
    final binHz = _sampleRate / fftLen;
    final maxHz = min(_maxHz, _sampleRate * 0.5 * 0.95);
    final ratio = maxHz / _minHz;
    for (var i = 0; i < barCount; i++) {
      final f0 = _minHz * pow(ratio, i / barCount);
      final f1 = _minHz * pow(ratio, (i + 1) / barCount);
      _lo[i] = f0 / binHz;
      _hi[i] = f1 / binHz;
      final center = sqrt(f0 * f1);
      _barCenterHz[i] = center;
      _tilt[i] = (_tiltDbPerOctave * log(center / 1000.0) / ln2) / -_floorDb;
      final t = i / (barCount - 1);
      _attackTau[i] = 0.045 + 0.020 * (1 - t);
      _releaseTau[i] = 0.34 - 0.14 * t;
    }
  }

  static const _simFreqs = [0.55, 0.90, 1.40, 2.10, 3.00];
  static const _simAmps = [0.30, 0.25, 0.20, 0.15, 0.10];

  void _simulate() {
    for (var i = 0; i < barCount; i++) {
      var h = 0.0;
      for (var j = 0; j < _simFreqs.length; j++) {
        h += _simAmps[j] *
            sin(_simTime * _simFreqs[j] * 2 * pi + i * 0.9 + j * 0.7);
      }
      final v = (h + 1.0) / 2.0;
      _target[i] = v * v;
    }
    _bassTarget = (_target[0] + _target[1]) / 2.0;
  }

  bool _smooth(double dt) {
    var changed = false;
    var total = 0.0;
    for (var i = 0; i < barCount; i++) {
      final cur = bars[i];
      final tgt = _target[i];
      final tau = tgt > cur ? _attackTau[i] : _releaseTau[i];
      var next = cur + (tgt - cur) * (1 - exp(-dt / tau));
      if (next < 0.001) next = 0.0;
      if (next != cur) changed = true;
      bars[i] = next;
      total += next;
    }
    final bTau = _bassTarget > bass ? _bassAttackTau : _bassReleaseTau;
    var nb = bass + (_bassTarget - bass) * (1 - exp(-dt / bTau));
    if (nb < 0.001) nb = 0.0;
    if (nb != bass) changed = true;
    bass = nb;
    overall += (total / barCount - overall) * (1 - exp(-dt / 0.15));
    return changed;
  }
}
