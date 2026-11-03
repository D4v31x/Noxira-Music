/// Full-screen music visualiser with switchable modes and real-time FFT.
///
/// Modes: Bar Spectrum, Circular Bars, Mirror Bars, Frequency Line. The active mode is persisted via SharedPreferences.
/// On Android the native Visualizer EventChannel ("aurora/visualizer") drives
/// FFT. Falls back to procedural sine animation when unavailable.
library;

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/background_manager_service.dart';
import '../../../shared/services/artist_separator_service.dart';
import '../../../shared/services/artwork_cache_service.dart';
import '../utils/spectrum_analyzer.dart';
import '../../../shared/providers/performance_mode_provider.dart';
import '../../../shared/widgets/adaptive_blur.dart';

// ── Visualiser modes ──────────────────────────────────────────────────────────

enum VisualizerMode {
  barSpectrum,
  circularBars,
  mirrorBars,
  frequencyLine;

  String get label => switch (this) {
        VisualizerMode.barSpectrum => 'Bar Spectrum',
        VisualizerMode.circularBars => 'Circular Bars',
        VisualizerMode.mirrorBars => 'Mirror Bars',
        VisualizerMode.frequencyLine => 'Frequency Line',
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

  static const _kFftChannel = EventChannel('aurora/visualizer');
  static final _artworkService = ArtworkCacheService();

  // ── Animation ──────────────────────────────────────────────────────────────
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  // Bumped when the analyzer output changes; drives repaints directly so the
  // widget tree isn't rebuilt every frame.
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  // ── FFT / energy state ─────────────────────────────────────────────────────
  StreamSubscription<dynamic>? _sessionIdSub;
  StreamSubscription<dynamic>? _fftSub;
  final SpectrumAnalyzer _analyzer = SpectrumAnalyzer();
  // Incremented whenever bar heights or energy change so painters can skip
  // redundant GPU draws via shouldRepaint when nothing changed.
  int _paintGeneration = 0;

  // ── Mode / UI ──────────────────────────────────────────────────────────────
  VisualizerMode _mode = VisualizerMode.barSpectrum;
  bool _micGranted = false;
  bool _isRequestingPermission = false;
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
    _checkAndRequestPermission();
    _loadArtwork();
    _audio.currentSongNotifier.addListener(_onSongChanged);
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

  Future<void> _checkAndRequestPermission() async {
    if (_isRequestingPermission) return;
    _isRequestingPermission = true;
    try {
      final status = await Permission.microphone.request();
      if (!mounted) return;
      final granted = status.isGranted;
      setState(() => _micGranted = granted);
      if (granted) unawaited(_subscribeToSessionId());
    } finally {
      _isRequestingPermission = false;
    }
  }

  Future<void> _subscribeToSessionId() async {
    _sessionIdSub = _audio.audioPlayer.androidAudioSessionIdStream.listen(
      (sessionId) {
        if (sessionId != null && sessionId > 0) _attachVisualizer(sessionId);
      },
      onError: (_) {},
    );
  }

  void _attachVisualizer(int sessionId) {
    _fftSub?.cancel();
    _fftSub = _kFftChannel.receiveBroadcastStream(sessionId).listen(
      (data) {
        if (data is Uint8List) _analyzer.submit(data);
      },
      onError: (_) {},
    );
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (_analyzer.update(dt, playing: _audio.isPlaying)) {
      _paintGeneration++;
      _frame.value = _paintGeneration;
    }
  }

  @override
  void dispose() {
    _audio.currentSongNotifier.removeListener(_onSongChanged);
    _ticker.dispose();
    _frame.dispose();
    _fftSub?.cancel();
    _sessionIdSub?.cancel();
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
        ? (colors.length > 2
            ? colors[2]
            : colors.length > 1
                ? colors[1]
                : dominant)
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
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.60)),
              ),
            ]))
          else
            const ColoredBox(color: Colors.black),

          // ── Visualiser canvas or permission prompt ──────────────────────
          if (!_micGranted)
            _buildPermissionPrompt(context, barColor)
          else
            RepaintBoundary(
              child: ValueListenableBuilder<int>(
                valueListenable: _frame,
                builder: (_, __, ___) => CustomPaint(
                  painter: _buildPainter(barColor, bottomPad),
                  size: Size.infinite,
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
                        _mode.label,
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
        !Provider.of<PerformanceModeProvider>(context, listen: false)
            .isLowEndDevice;
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
    };
  }

  Widget _buildPermissionPrompt(BuildContext context, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 64),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).microphoneAccessNeeded,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: FontConstants.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).microphoneAccessDesc,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: FontConstants.fontFamily,
                color: Color(0xA6FFFFFF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: _isRequestingPermission
                  ? null
                  : () async {
                      setState(() => _isRequestingPermission = true);
                      try {
                        final status = await Permission.microphone.request();
                        if (!mounted) return;
                        final granted = status.isGranted;
                        setState(() => _micGranted = granted);
                        if (granted) {
                          unawaited(_subscribeToSessionId());
                        } else if (status.isPermanentlyDenied) {
                          await openAppSettings();
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isRequestingPermission = false);
                        }
                      }
                    },
              child: Text(AppLocalizations.of(context).grantPermission),
            ),
          ],
        ),
      ),
    );
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
    const int kBars = 48;
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
    const int kBars = 48;
    final center = size.center(Offset.zero);
    final baseR = min(size.width, size.height) * 0.18 + bassEnergy * 20;
    final maxLen = min(size.width, size.height) * 0.28;
    const angleStep = 2 * pi / kBars;

    final solidPaint = Paint()
      ..color = barColor.withValues(alpha: 0.90)
      ..strokeWidth = 4.0
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
    const int kBars = 48;
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
      canvas.drawRRect(upRR, solidPaint);
      canvas.drawRRect(downRR, glowPaint);
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
    canvas.drawPath(strokePath, linePaint);
  }

  @override
  bool shouldRepaint(_FrequencyLinePainter old) =>
      old.paintGeneration != paintGeneration || old.color != color;
}
