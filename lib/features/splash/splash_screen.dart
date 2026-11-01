import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/services/audio_player_service.dart';
import '../../shared/services/artist_aggregator_service.dart';
import '../../shared/services/artwork_cache_service.dart';
import '../../shared/services/user_preferences.dart';
import '../../shared/services/logging_service.dart';
import '../../core/constants/font_constants.dart';
import 'animated_logo.dart';
import 'splash_backdrop.dart';
import '../onboarding/screens/onboarding_screen.dart';
import '../home/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/performance_mode_provider.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../shared/widgets/expanding_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _transitionController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundFadeAnimation;
  String _versionNumber = '';
  String _codeName = '';
  bool _isDataLoaded = false;
  bool _isAnimationComplete = false;
  bool _isTransitioning = false;
  bool _didInitialize = false;
  String _currentTask = '';
  final List<String> _completedTasks = [];
  double _progress = 0.0;
  final List<String> _warnings = [];
  static const Duration _minimumSplashDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    ExpandingPlayer.hiddenNotifier.value = true;
    _initializeAnimations();
    _loadVersionInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didInitialize) {
      _didInitialize = true;

      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    try {
      final startedAt = DateTime.now();
      final tasks = <(String, Future<void> Function())>[
        ('Initializing Services', _initializeServices),
        ('Loading Library', _loadAppData),
        ('Preparing Home', _prepareHomeData),
        ('Caching Artwork', _preloadImages),
        ('Final Preparations', _finalizeInitialization),
      ];

      for (int i = 0; i < tasks.length; i++) {
        if (!mounted) return;

        final task = tasks[i];
        // Batch update: progress, current task, and completed tasks together
        setState(() {
          _currentTask = task.$1;
          _progress = i / tasks.length;
        });

        try {
          await task.$2();
          if (mounted) {
            // Batch completed task update
            setState(() {
              _completedTasks.add(task.$1);
            });
          }
        } catch (e) {
          LoggingService.error('Task failed: ${task.$1}', 'SplashScreen', e);
          // Only show warnings for critical errors
          if (task.$1 != 'Setting up Analytics') {
            if (mounted) {
              // Batch update: warnings and connectivity issues together
              setState(() {
                _warnings.add('Issue with ${task.$1.toLowerCase()}');
              });
            }
          }
          continue;
        }
      }

      await _waitForMinimumSplashDuration(startedAt);

      if (mounted) {
        // Batch final state update
        setState(() {
          _currentTask = 'Complete';
          _progress = 1.0;
          _isDataLoaded = true;
        });
        // Check if animation is also complete, then transition
        _checkAndTransition();
      }
    } catch (e) {
      LoggingService.error('Initialization error', 'SplashScreen', e);
      if (!_warnings.contains('Some features may be limited')) {
        _warnings.add('Some features may be limited');
      }
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
        _checkAndTransition();
      }
    }
  }

  Future<void> _initializeServices() async {
    try {
      // Check network interface connectivity without pinging external hosts
      try {
        final result = await Connectivity().checkConnectivity();
        if (result.isEmpty ||
            result.every((r) => r == ConnectivityResult.none)) {
          throw Exception('No internet connection');
        }
      } catch (e) {
        // Batch update for connectivity warnings
        setState(() {
          _warnings.add('No internet connection');
          _warnings.add('Offline mode active');
        });
        return;
      }
    } catch (e) {
      if (!_warnings.contains('Some features may be limited')) {
        // Batch update for error warnings
        setState(() {
          _warnings.add('Some features may be limited');
        });
      }
    }
  }

  Future<void> _loadAppData() async {
    try {
      if (!mounted) return;
      final audioPlayerService = context.read<AudioPlayerService>();
      await audioPlayerService.initializeMusicLibrary();
    } catch (e) {
      debugPrint('Error in splash screen: $e');
    }
  }

  Future<void> _prepareHomeData() async {
    if (!mounted) return;

    final audioPlayerService = context.read<AudioPlayerService>();
    if (!audioPlayerService.isLibraryInitialized ||
        audioPlayerService.songs.isEmpty) {
      return;
    }

    await Future.wait<void>([
      _boundedPreparation(
        audioPlayerService.getSuggestedTracks().then((_) {}),
      ),
      _boundedPreparation(
        audioPlayerService.getSuggestedArtists(count: 5).then((_) {}),
      ),
      _boundedPreparation(
        ArtistAggregatorService().getAllArtists().then((_) {}),
      ),
    ]);
  }

  Future<void> _boundedPreparation(Future<void> future) async {
    try {
      await future.timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  Future<void> _preloadImages() async {
    if (!mounted) return;

    try {
      final artworkService = ArtworkCacheService();
      final audioPlayerService = context.read<AudioPlayerService>();

      // For Windows, we'll only preload static images
      if (Platform.isWindows) {
        final staticImages = ['assets/images/logo/default_art.png'];

        for (final image in staticImages) {
          if (!mounted) return;
          await precacheImage(AssetImage(image), context);
        }
        return;
      }

      if (audioPlayerService.songs.isNotEmpty) {
        final songsToPreload = [
          if (audioPlayerService.currentSong != null)
            audioPlayerService.currentSong!,
          ...audioPlayerService.songs.take(18),
        ];
        final seenIds = <int>{};
        final uniqueSongs = songsToPreload
            .where((song) => seenIds.add(song.id))
            .toList(growable: false);

        for (var i = 0; i < uniqueSongs.length; i += 4) {
          if (!mounted) return;
          final chunk = uniqueSongs.skip(i).take(4);
          await Future.wait(
              chunk.map((song) => artworkService.preloadArtwork(song.id)));
        }
      }

      // Don't query for artists directly - removed artist preloading
      // This prevents permission errors

      // Load static images
      final staticImages = ['assets/images/logo/default_art.png'];

      for (final image in staticImages) {
        if (!mounted) return;
        await precacheImage(AssetImage(image), context);
      }
    } catch (_) {}
  }

  Future<void> _finalizeInitialization() async {
    // Pre-warm home screen components for smooth transition
    await _preWarmHomeScreen();
  }

  Future<void> _waitForMinimumSplashDuration(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  /// Pre-warm home screen components to prevent transition lag
  Future<void> _preWarmHomeScreen() async {
    if (!mounted) return;

    try {
      // Pre-cache essential images
      final homeImages = [
        'assets/images/UI/liked.png',
        'assets/images/logo/default_art.png',
      ];

      for (final image in homeImages) {
        if (!mounted) return;
        try {
          await precacheImage(AssetImage(image), context);
        } catch (e) {
          // Continue if individual image fails
        }
      }

      // Pre-initialize providers that home screen will need
      if (mounted) {
        final audioService = context.read<AudioPlayerService>();
        // Ensure the service is ready
        audioService.toString(); // Just access it to ensure it's initialized
      }
    } catch (e) {
      // Don't block transition if pre-warming fails
    }
  }

  Future<void> _loadVersionInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    const String codeName =
        String.fromEnvironment('CODE_NAME', defaultValue: 'Unknown');

    setState(() {
      _versionNumber = packageInfo.version;
      _codeName = codeName;
    });
  }

  void _initializeAnimations() {
    // Primary controller drives the self-drawing logo animation.
    _fadeController = AnimationController(
      duration: AnimatedLogo.duration,
      vsync: this,
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.linear,
    );

    // Transition controller for exit
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Logo shrinks slightly on exit
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInCubic,
    ));

    // Whole splash fades out on exit
    _backgroundFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeIn,
    ));

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() => _isAnimationComplete = true);
          _checkAndTransition();
        }
      }
    });

    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _performActualTransition();
      }
    });

    // Start drawing the logo as soon as the SVG has been parsed.
    AnimatedLogo.preload().whenComplete(() {
      if (mounted) _fadeController.forward();
    });
  }

  void _checkAndTransition() {
    // Only transition when BOTH conditions are met:
    // 1. Lottie animation has completed
    // 2. App data/initialization is finished
    if (_isAnimationComplete && _isDataLoaded && !_isTransitioning) {
      setState(() {
        _isTransitioning = true;
      });
      _transitionController.forward();
    }
  }

  Future<void> _performActualTransition() async {
    final bool isFirstTime = await UserPreferences.isFirstTimeUser();

    if (mounted) {
      if (isFirstTime) {
        _navigateToScreenWithHero(const OnboardingScreen());
      } else {
        _navigateToScreenWithHero(const HomeScreen());
      }
    }
  }

  void _navigateToScreenWithHero(Widget screen) {
    if (screen is HomeScreen) ExpandingPlayer.hiddenNotifier.value = false;
    if (context.read<PerformanceModeProvider>().isLowEndDevice) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Smooth crossfade with zoom-in effect
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
          ));

          final scaleAnimation = Tween<double>(
            begin: 1.15,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ));

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 900),
        reverseTransitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF080B14),
      body: AnimatedBuilder(
        animation: _transitionController,
        builder: (context, _) {
          final fade = _backgroundFadeAnimation.value;
          return Opacity(
            opacity: fade,
            child: Stack(
              children: [
                // ── Background ──────────────────────────────────────────────
                const Positioned.fill(child: SplashBackdrop()),

                // ── Logo (centre) ─────────────────────────────────────────
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Hero(
                      tag: 'app_logo_hero',
                      child: AnimatedLogo(
                        animation: _logoFadeAnimation,
                        width: size.width * 0.7,
                      ),
                    ),
                  ),
                ),

                // ── Bottom area: progress + version ──────────────────────
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: 56,
                  child: AnimatedOpacity(
                    opacity: _isTransitioning ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Task label
                        if (_currentTask.isNotEmpty && _progress < 1.0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _currentTask,
                              style: const TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                color: Color(0xFF6B7080),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Progress bar — matches the library refresh line, but thicker
                        _GlassProgressBar(progress: _progress),

                        const SizedBox(height: 20),

                        // Version chip
                        if (_versionNumber.isNotEmpty)
                          _VersionChip(
                            version: _versionNumber,
                            codeName: _codeName,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Splash progress bar ───────────────────────────────────────────────────────
class _GlassProgressBar extends StatelessWidget {
  final double progress;
  const _GlassProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: double.infinity,
          height: 8,
          child: CustomPaint(
            painter: _SplashProgressPainter(
              progress: value,
              lineColor: Colors.white,
              lineHeight: 6,
            ),
          ),
        );
      },
    );
  }
}

class _SplashProgressPainter extends CustomPainter {
  final double progress;
  final Color lineColor;
  final double lineHeight;

  const _SplashProgressPainter({
    required this.progress,
    required this.lineColor,
    required this.lineHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final inset = lineHeight / 2;
    final start = Offset(inset, y);
    final end = Offset(size.width - inset, y);
    final usableWidth = (size.width - lineHeight).clamp(0.0, double.infinity);

    final backgroundPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineHeight
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, backgroundPaint);

    if (progress <= 0) return;

    final foregroundPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineHeight
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      start,
      Offset(inset + usableWidth * progress.clamp(0.0, 1.0), y),
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(_SplashProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.lineHeight != lineHeight;
  }
}

// ── Version chip ──────────────────────────────────────────────────────────────
class _VersionChip extends StatelessWidget {
  final String version;
  final String codeName;
  const _VersionChip({required this.version, required this.codeName});

  @override
  Widget build(BuildContext context) {
    final label = codeName.isNotEmpty ? 'v$version · $codeName' : 'v$version';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: FontConstants.fontFamily,
          color: Color(0xFF5A5F74),
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
