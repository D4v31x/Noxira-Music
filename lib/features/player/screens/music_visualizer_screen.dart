/// Full-screen music visualiser with switchable modes and real-time FFT.
///
/// Modes: Bar Spectrum, Circular Bars, Mirror Bars, Frequency Line, Dot Matrix,
/// Peak Bars, Circular Wave, Aurora Waves, Pulse Rings. The active mode is
/// persisted via SharedPreferences.
/// The PCM engine supplies a full-resolution floating-point spectrum. The
/// level calibration is retained while fractional mapping preserves pitch motion.
library;

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/background_manager_service.dart';
import '../../../shared/services/artist_separator_service.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../../../shared/services/audio_analysis/audio_analysis.dart';
import '../utils/spectrum_analyzer.dart';
import '../utils/visualizer_colors.dart';
import '../widgets/visualizer_styles.dart';
import '../../../shared/providers/performance_mode_provider.dart';
import '../../../shared/widgets/adaptive_blur.dart';

// ── Visualiser modes ──────────────────────────────────────────────────────────

enum VisualizerMode {
  barSpectrum,
  circularBars,
  mirrorBars,
  frequencyLine,
  dotMatrix,
  peakBars,
  circularWave,
  auroraWaves,
  pulseRings;

  String label(AppLocalizations l10n) => switch (this) {
        VisualizerMode.barSpectrum => l10n.visualizerBarSpectrum,
        VisualizerMode.circularBars => l10n.visualizerCircularBars,
        VisualizerMode.mirrorBars => l10n.visualizerMirrorBars,
        VisualizerMode.frequencyLine => l10n.visualizerFrequencyLine,
        VisualizerMode.dotMatrix => l10n.visualizerDotMatrix,
        VisualizerMode.peakBars => l10n.visualizerPeakBars,
        VisualizerMode.circularWave => l10n.visualizerCircularWave,
        VisualizerMode.auroraWaves => l10n.visualizerAuroraWaves,
        VisualizerMode.pulseRings => l10n.visualizerPulseRings,
      };
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// Set from the current performance level before painters are created.
bool _glowBlurEnabled = true;

class MusicVisualizerScreen extends StatefulWidget {
  const MusicVisualizerScreen({super.key});

  @override
  State<MusicVisualizerScreen> createState() => _MusicVisualizerScreenState();
}

class _MusicVisualizerScreenState extends State<MusicVisualizerScreen>
    with SingleTickerProviderStateMixin {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const String _kPrefKey = 'visualizer_mode';

  static final _artworkService = ArtworkCacheService();

  // ── Animation ──────────────────────────────────────────────────────────────
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  // Bumped when the analyzer output changes; drives repaints directly so the
  // widget tree isn't rebuilt every frame.
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  // ── FFT / energy state ─────────────────────────────────────────────────────
  final SpectrumAnalyzer _analyzer = SpectrumAnalyzer()
    ..allowSimulation = false;
  final AudioAnalysisService _analysis = AudioAnalysisService.instance;
  AudioAnalysisLease? _nativeLease;
  int _lastNativeSequence = -1;
  final ValueNotifier<AudioAnalysisState?> _captureStatus = ValueNotifier(null);
  double _waitingSeconds = 0;
  // Falling peak markers for the Peak Bars style.
  late final List<double> _peaks = List.filled(_analyzer.barCount, 0.0);
  // Incremented whenever bar heights or energy change so painters can skip
  // redundant GPU draws via shouldRepaint when nothing changed.
  int _paintGeneration = 0;

  // ── Mode / UI ──────────────────────────────────────────────────────────────
  VisualizerMode _mode = VisualizerMode.barSpectrum;
  ImageProvider? _artworkProvider;
  int? _loadedSongId;

  late final AudioPlayerService _audio;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _audio = context.read<AudioPlayerService>();

    _ticker = createTicker(_onTick)..start();

    _loadMode();
    _loadArtwork();
    _audio.currentSongNotifier.addListener(_onSongChanged);
    _nativeLease = _analysis.requestAnalysis(
      config:
          const AudioAnalysisConfig(fftSize: 4096, visualizerSpectrum: true),
    );
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPrefKey);
    if (saved != null && mounted) {
      final idx = VisualizerMode.values.indexWhere((m) => m.name == saved);
      if (idx != -1) setState(() => _mode = VisualizerMode.values[idx]);
    }
  }

  Future<void> _saveMode(VisualizerMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, mode.name);
  }

  void _switchMode(int delta) {
    final next = VisualizerMode
        .values[(_mode.index + delta) % VisualizerMode.values.length];
    setState(() => _mode = next);
    unawaited(_saveMode(next));
  }

  void _onSongChanged() {
    final song = _audio.currentSong;
    final newId = song?.id;
    if (newId == _loadedSongId) return;
    // Clear stale artwork immediately so the old song's art doesn't flash.
    if (mounted) setState(() => _artworkProvider = null);
    _loadArtwork();
  }

  Future<void> _loadArtwork() async {
    final song = _audio.currentSong;
    if (song == null) {
      _loadedSongId = null;
      return;
    }
    final targetId = song.id;
    try {
      final provider = await _artworkService.getCachedImageProvider(song.id);
      if (mounted && _audio.currentSong?.id == targetId) {
        setState(() {
          _artworkProvider = provider;
          _loadedSongId = targetId;
        });
      }
    } catch (_) {
      if (mounted && _audio.currentSong?.id == targetId) {
        setState(() {
          _artworkProvider = null;
          _loadedSongId = targetId;
        });
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    var changed = _readCapture(dt);
    if (_mode == VisualizerMode.peakBars && _updatePeaks(dt)) changed = true;
    if (changed) {
      _paintGeneration++;
      _frame.value = _paintGeneration;
    }
  }

  bool _readCapture(double dt) {
    final frame = _analysis.latestFrame;
    final available = _analysis.isSupported && _analysis.isRunning;
    final waiting = available &&
        (frame.sequence == 0 || frame.state == AudioAnalysisState.waiting);
    _waitingSeconds = waiting ? _waitingSeconds + dt : 0;
    _captureStatus.value = !available || _waitingSeconds > 2
        ? AudioAnalysisState.unsupported
        : waiting
            ? AudioAnalysisState.waiting
            : null;
    if (available &&
        frame.sequence != _lastNativeSequence &&
        frame.sampleRate > 0) {
      _lastNativeSequence = frame.sequence;
      _analyzer.submitMagnitudes(frame.visualizerSpectrum, frame.sampleRate);
    }
    final levelsChanged = _analyzer.update(dt,
        playing: available && frame.state == AudioAnalysisState.playing);
    return levelsChanged;
  }

  /// Peaks jump up with the bars and fall back at a steady pace. Returns true
  /// while any of them is still moving.
  bool _updatePeaks(double dt) {
    var moving = false;
    final fall = dt * 0.45;
    for (var i = 0; i < _peaks.length; i++) {
      final level = _analyzer.bars[i];
      if (level >= _peaks[i]) {
        if (level != _peaks[i]) moving = true;
        _peaks[i] = level;
      } else if (_peaks[i] > 0) {
        _peaks[i] = max(level, _peaks[i] - fall);
        moving = true;
      }
    }
    return moving;
  }

  @override
  void dispose() {
    _audio.currentSongNotifier.removeListener(_onSongChanged);
    _ticker.dispose();
    _frame.dispose();
    _captureStatus.dispose();
    _nativeLease?.release();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bg = context.watch<BackgroundManagerService>();
    final colors = bg.currentColors;
    final hasArtwork = _artworkProvider != null;
    final dominant = colors.isNotEmpty ? colors[0] : const Color(0xFF6200EE);
    // When there is no artwork show white bars and text on a solid black bg.
    final vibrant =
        hasArtwork ? (colors.length > 1 ? colors[1] : dominant) : Colors.white;
    final barColor = hasArtwork
        ? VisualizerColors.fromArtwork(
            bg.artworkColors,
            dominantColor: dominant,
          )
        : Colors.white;
    final song = _audio.currentSong;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Blurred album art background ────────────────────────────────
          // Isolated so the blur isn't re-rasterised on every visualiser frame.
          if (_artworkProvider != null)
            RepaintBoundary(
                child: Stack(fit: StackFit.expand, children: [
              Image(
                image: _artworkProvider!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Colors.black),
              ),
              AdaptiveBackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: ColoredBox(
                  color: Colors.black.withValues(
                    alpha: VisualizerColors.backgroundOpacity,
                  ),
                ),
              ),
            ]))
          else
            const ColoredBox(color: Colors.black),

          // ── Visualiser canvas ───────────────────────────────────────────
          RepaintBoundary(
            child: ValueListenableBuilder<int>(
              valueListenable: _frame,
              builder: (_, __, ___) => CustomPaint(
                painter: _buildPainter(barColor, bottomPad),
                size: Size.infinite,
              ),
            ),
          ),
          Positioned(
            top: topPad + 64,
            left: 24,
            right: 24,
            child: ValueListenableBuilder<AudioAnalysisState?>(
              valueListenable: _captureStatus,
              builder: (context, status, _) => status == null
                  ? const SizedBox.shrink()
                  : Semantics(
                      liveRegion: true,
                      child: Text(
                        status == AudioAnalysisState.waiting
                            ? AppLocalizations.of(context)
                                .visualizerWaitingForAudio
                            : AppLocalizations.of(context)
                                .visualizerUnavailable,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: FontConstants.fontFamily,
                        ),
                      ),
                    ),
            ),
          ),

          // ── Song info ──────────────────────────────────────────────────
          if (song != null)
            Positioned(
              bottom: bottomPad + 36,
              left: 32,
              right: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontConstants.fontFamily,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ArtistSeparatorService()
                        .splitArtists(song.artist ?? '')
                        .join(', '),
                    style: TextStyle(
                      color: vibrant.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontFamily: FontConstants.fontFamily,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // ── Top chrome: close + mode switcher ─────────────────────────
          Positioned(
            top: topPad,
            left: 0,
            right: 0,
            child: Row(
              children: [
                // Close button
                IconButton(
                  icon: const iconoir.NavArrowDown(
                      color: Colors.white, width: 28, height: 28),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppLocalizations.of(context).closeVisualiser,
                ),
                // Mode switcher centred in remaining space
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const iconoir.NavArrowLeft(
                            color: Colors.white, width: 22, height: 22),
                        onPressed: () => _switchMode(-1),
                        tooltip: AppLocalizations.of(context).previousMode,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _mode.label(AppLocalizations.of(context)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontConstants.fontFamily,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const iconoir.NavArrowRight(
                            color: Colors.white, width: 22, height: 22),
                        onPressed: () => _switchMode(1),
                        tooltip: AppLocalizations.of(context).nextMode,
                      ),
                    ],
                  ),
                ),
                // Spacer matching close button width so title stays centred
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  CustomPainter _buildPainter(Color barColor, double bottomInset) {
    // Soft glow is a per-bar blur every frame: solid bars only on low-end.
    _glowBlurEnabled =
        !Provider.of<PerformanceModeProvider>(context).isLowEndDevice;
    return switch (_mode) {
      VisualizerMode.barSpectrum => _BarSpectrumPainter(
          barHeights: _analyzer.bars,
          barColor: barColor,
          bottomInset: bottomInset,
          paintGeneration: _paintGeneration),
      VisualizerMode.circularBars => _CircularBarsPainter(
          barHeights: _analyzer.bars,
          barColor: barColor,
          bassEnergy: _analyzer.bass,
          paintGeneration: _paintGeneration),
      VisualizerMode.mirrorBars => _MirrorBarsPainter(
          barHeights: _analyzer.bars,
          barColor: barColor,
          bottomInset: bottomInset,
          paintGeneration: _paintGeneration),
      VisualizerMode.frequencyLine => _FrequencyLinePainter(
          barHeights: _analyzer.bars,
          color: barColor,
          bottomInset: bottomInset,
          paintGeneration: _paintGeneration),
      VisualizerMode.dotMatrix => DotMatrixPainter(
          levels: _analyzer.bars,
          color: barColor,
          bottomInset: bottomInset,
          paintGeneration: _paintGeneration),
      VisualizerMode.peakBars => PeakBarsPainter(
          levels: _analyzer.bars,
          peaks: _peaks,
          color: barColor,
          bottomInset: bottomInset,
          paintGeneration: _paintGeneration),
      VisualizerMode.circularWave => CircularWavePainter(
          levels: _analyzer.bars,
          bass: _analyzer.bass,
          color: barColor,
          glow: _glowBlurEnabled,
          paintGeneration: _paintGeneration),
      VisualizerMode.auroraWaves => AuroraWavesPainter(
          levels: _analyzer.bars,
          color: barColor,
          bottomInset: bottomInset,
          paintGeneration: _paintGeneration),
      VisualizerMode.pulseRings => PulseRingsPainter(
          levels: _analyzer.bars,
          bass: _analyzer.bass,
          overall: _analyzer.overall,
          color: barColor,
          glow: _glowBlurEnabled,
          paintGeneration: _paintGeneration),
    };
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

/// 1 · Bar Spectrum — vertical rounded bars from the bottom.
class _BarSpectrumPainter extends CustomPainter {
  final List<double> barHeights;
  final Color barColor;
  final double bottomInset;
  final int paintGeneration;

  const _BarSpectrumPainter({
    required this.barHeights,
    required this.barColor,
    required this.bottomInset,
    required this.paintGeneration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final kBars = barHeights.length;
    const double hPad = 20.0;
    const double gapFactor = 0.4;
    const double topReserve = 110.0;

    final available = size.width - hPad * 2;
    final barWidth = available / (kBars + (kBars - 1) * gapFactor);
    final gap = barWidth * gapFactor;
    final bottomY = size.height - 200.0 - bottomInset;
    final maxH = (bottomY - topReserve).clamp(50.0, double.infinity);

    final solidPaint = Paint()
      ..color = barColor.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;
    final backingPaint = Paint()..color = VisualizerColors.markBackground;
    final glowPaint = Paint()
      ..color = barColor.withValues(alpha: 0.28)
      ..maskFilter =
          _glowBlurEnabled ? const MaskFilter.blur(BlurStyle.normal, 7) : null
      ..style = PaintingStyle.fill;

    for (int i = 0; i < kBars; i++) {
      final h = (barHeights[i] * maxH).clamp(2.0, maxH);
      final x = hPad + i * (barWidth + gap);
      final topY = bottomY - h;
      final r = Radius.circular(barWidth / 2);
      final rr = RRect.fromLTRBAndCorners(x, topY, x + barWidth, bottomY,
          topLeft: r, topRight: r);
      canvas.drawRRect(rr, glowPaint);
      canvas.drawRRect(rr, backingPaint);
      canvas.drawRRect(rr, solidPaint);
    }
  }

  @override
  bool shouldRepaint(_BarSpectrumPainter old) =>
      old.paintGeneration != paintGeneration || old.barColor != barColor;
}

/// 2 · Circular Bars — bars radiating outward in a ring around the center.
class _CircularBarsPainter extends CustomPainter {
  final List<double> barHeights;
  final Color barColor;
  final double bassEnergy;
  final int paintGeneration;

  const _CircularBarsPainter({
    required this.barHeights,
    required this.barColor,
    required this.bassEnergy,
    required this.paintGeneration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final kBars = barHeights.length;
    final center = size.center(Offset.zero);
    final baseR = min(size.width, size.height) * 0.18 + bassEnergy * 20;
    final maxLen = min(size.width, size.height) * 0.28;
    final angleStep = 2 * pi / kBars;

    final solidPaint = Paint()
      ..color = barColor.withValues(alpha: 0.90)
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final backingPaint = Paint()
      ..color = VisualizerColors.markBackground
      ..strokeWidth = solidPaint.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = barColor.withValues(alpha: 0.30)
      ..strokeWidth = 10.0
      ..maskFilter =
          _glowBlurEnabled ? const MaskFilter.blur(BlurStyle.normal, 8) : null
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < kBars; i++) {
      final angle = i * angleStep - pi / 2;
      final barLen = (barHeights[i] * maxLen).clamp(4.0, maxLen);
      final x0 = center.dx + cos(angle) * baseR;
      final y0 = center.dy + sin(angle) * baseR;
      final x1 = center.dx + cos(angle) * (baseR + barLen);
      final y1 = center.dy + sin(angle) * (baseR + barLen);
      canvas.drawLine(Offset(x0, y0), Offset(x1, y1), glowPaint);
      canvas.drawLine(Offset(x0, y0), Offset(x1, y1), backingPaint);
      canvas.drawLine(Offset(x0, y0), Offset(x1, y1), solidPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularBarsPainter old) =>
      old.paintGeneration != paintGeneration || old.barColor != barColor;
}

/// 4 · Mirror Bars — bars that grow both up and down from the center line.
class _MirrorBarsPainter extends CustomPainter {
  final List<double> barHeights;
  final Color barColor;
  final double bottomInset;
  final int paintGeneration;

  const _MirrorBarsPainter({
    required this.barHeights,
    required this.barColor,
    required this.bottomInset,
    required this.paintGeneration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final kBars = barHeights.length;
    const double hPad = 20.0;
    const double gapFactor = 0.4;

    final available = size.width - hPad * 2;
    final barWidth = available / (kBars + (kBars - 1) * gapFactor);
    final gap = barWidth * gapFactor;
    final cy = size.height * 0.46;
    final maxH = (cy - 90.0).clamp(40.0, double.infinity);

    final solidPaint = Paint()
      ..color = barColor.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final backingPaint = Paint()..color = VisualizerColors.markBackground;
    final glowPaint = Paint()
      ..color = barColor.withValues(alpha: 0.25)
      ..maskFilter =
          _glowBlurEnabled ? const MaskFilter.blur(BlurStyle.normal, 7) : null
      ..style = PaintingStyle.fill;

    for (int i = 0; i < kBars; i++) {
      final h = (barHeights[i] * maxH).clamp(2.0, maxH);
      final x = hPad + i * (barWidth + gap);
      final r = Radius.circular(barWidth / 2);

      // Upper half
      final upRR = RRect.fromLTRBAndCorners(x, cy - h, x + barWidth, cy,
          topLeft: r, topRight: r);
      // Lower half
      final downRR = RRect.fromLTRBAndCorners(x, cy, x + barWidth, cy + h,
          bottomLeft: r, bottomRight: r);

      canvas.drawRRect(upRR, glowPaint);
      canvas.drawRRect(downRR, glowPaint);
      canvas.drawRRect(upRR, backingPaint);
      canvas.drawRRect(downRR, backingPaint);
      canvas.drawRRect(upRR, solidPaint);
      canvas.drawRRect(downRR, solidPaint);
    }
  }

  @override
  bool shouldRepaint(_MirrorBarsPainter old) =>
      old.paintGeneration != paintGeneration || old.barColor != barColor;
}

/// 6 · Frequency Line — smooth filled curve connecting all FFT bins.
class _FrequencyLinePainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;
  final double bottomInset;
  final int paintGeneration;

  const _FrequencyLinePainter({
    required this.barHeights,
    required this.color,
    required this.bottomInset,
    required this.paintGeneration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (barHeights.isEmpty) return;

    const double topReserve = 110.0;
    final double bottomY = size.height - 200.0 - bottomInset;
    final double maxH = (bottomY - topReserve).clamp(40.0, double.infinity);
    final double xStep = size.width / (barHeights.length - 1);

    // Build a smooth cubic path
    final path = Path();
    for (int i = 0; i < barHeights.length; i++) {
      final x = i * xStep;
      final y = bottomY - barHeights[i] * maxH;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * xStep;
        final prevY = bottomY - barHeights[i - 1] * maxH;
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    // Close fill down to the baseline
    path.lineTo(size.width, bottomY);
    path.lineTo(0, bottomY);
    path.close();

    // Fill gradient
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, topReserve),
        Offset(0, bottomY),
        [
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0.05),
        ],
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Stroke the top line
    final strokePath = Path();
    for (int i = 0; i < barHeights.length; i++) {
      final x = i * xStep;
      final y = bottomY - barHeights[i] * maxH;
      if (i == 0) {
        strokePath.moveTo(x, y);
      } else {
        final prevX = (i - 1) * xStep;
        final prevY = bottomY - barHeights[i - 1] * maxH;
        final cpX = (prevX + x) / 2;
        strokePath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      strokePath,
      Paint()
        ..color = VisualizerColors.markBackground
        ..strokeWidth = linePaint.strokeWidth
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(strokePath, linePaint);
  }

  @override
  bool shouldRepaint(_FrequencyLinePainter old) =>
      old.paintGeneration != paintGeneration || old.color != color;
}
