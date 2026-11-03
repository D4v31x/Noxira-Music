import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/performance_mode_provider.dart';
import '../providers/theme_provider.dart';
import 'blurred_image.dart';
import 'adaptive_blur.dart';

/// A beautiful animated background that displays heavily blurred artwork
/// with smooth transitions.
/// Performance-aware: Respects device performance mode for blur effects.
///
/// Optimized for:
/// - Reduced GPU load by wrapping blur layers in RepaintBoundary
/// - Throttled artwork updates to prevent excessive rebuilds
/// - Cached image providers to reduce memory churn
class AnimatedArtworkBackground extends StatefulWidget {
  final Uint8List? currentArtwork;
  final Widget child;
  final Color? fallbackColor;

  const AnimatedArtworkBackground({
    super.key,
    this.currentArtwork,
    Uint8List? previousArtwork, // Ignored - managed internally
    bool isTransitioning = false, // Ignored - managed internally
    required this.child,
    this.fallbackColor,
  });

  @override
  State<AnimatedArtworkBackground> createState() =>
      _AnimatedArtworkBackgroundState();
}

class _AnimatedArtworkBackgroundState extends State<AnimatedArtworkBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _crossfadeController;
  late Animation<double> _crossfadeAnimation;
  Uint8List? _previousArtworkCache;
  // What is actually drawn; it follows the widget only once the blur is ready.
  Uint8List? _shown;

  @override
  void initState() {
    super.initState();
    _shown = widget.currentArtwork;
    _crossfadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      value: widget.currentArtwork != null ? 1.0 : 0.0,
      vsync: this,
    );
    _crossfadeAnimation = CurvedAnimation(
      parent: _crossfadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(AnimatedArtworkBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only animate if artwork actually changed (check by reference or hash)
    final bool artworkChanged =
        !_areArtworksEqual(widget.currentArtwork, oldWidget.currentArtwork);

    if (artworkChanged) {
      if (oldWidget.currentArtwork == null && widget.currentArtwork != null) {
        // No animation when appearing for first time
        if (mounted) {
          setState(() {
            _shown = widget.currentArtwork;
            _crossfadeController.value = 1.0;
            _previousArtworkCache = null;
          });
        }
      } else if (widget.currentArtwork != null) {
        unawaited(_transitionTo(widget.currentArtwork!));
      } else {
        // Artwork removed - fade out
        if (mounted) {
          setState(() {
            _previousArtworkCache = oldWidget.currentArtwork;
            _shown = null;
          });
          _crossfadeController.reverse(from: 1.0).then((_) {
            if (mounted) {
              setState(() {
                _previousArtworkCache = null;
              });
            }
          });
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Route got covered mid-fade: finish it now rather than on return.
    if (!TickerMode.valuesOf(context).enabled &&
        _crossfadeController.isAnimating) {
      _crossfadeController.value = 1.0;
      _previousArtworkCache = null;
    }
  }

  /// Blurs [next] off-screen first, so the crossfade starts on a ready bitmap
  /// instead of a live full-screen blur.
  Future<void> _transitionTo(Uint8List next) async {
    final shouldBlur =
        Provider.of<PerformanceModeProvider>(context, listen: false)
            .shouldEnableBlur;
    if (shouldBlur) {
      final sigma =
          Provider.of<ThemeProvider>(context, listen: false).blurIntensity;
      final extent = MediaQuery.sizeOf(context).longestSide;
      try {
        await BlurredImage.precache(MemoryImage(next),
                sigma: sigma, extent: extent)
            .timeout(const Duration(milliseconds: 600));
      } catch (_) {
        // The live blur is the fallback.
      }
    }
    if (!mounted || !identical(widget.currentArtwork, next)) return;
    // Covered routes have muted tickers; a fade started now would replay on return.
    if (!TickerMode.valuesOf(context).enabled) {
      setState(() {
        _shown = next;
        _previousArtworkCache = null;
        _crossfadeController.value = 1.0;
      });
      return;
    }
    setState(() {
      _previousArtworkCache = _shown;
      _shown = next;
    });
    unawaited(_crossfadeController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _previousArtworkCache = null);
    }));
  }

  // Helper to check if artworks are equal (by reference)
  bool _areArtworksEqual(Uint8List? a, Uint8List? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    // Use identical for performance - BackgroundManagerService should reuse instances
    return identical(a, b);
  }

  @override
  void dispose() {
    _crossfadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.fallbackColor ?? Theme.of(context).colorScheme.surface;

    // Check if blur should be enabled based on performance mode
    final performanceProvider =
        Provider.of<PerformanceModeProvider>(context, listen: false);
    final shouldBlur = performanceProvider.shouldEnableBlur;
    final isLowEndMode = !shouldBlur;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final blurIntensity = themeProvider.blurIntensity;
    final overlayOpacity = themeProvider.overlayOpacity;

    // High-end: if user chose solid background, skip blurred artwork
    if (shouldBlur &&
        themeProvider.highEndBackground == HighEndBackground.solid) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: backgroundColor),
          widget.child,
        ],
      );
    }

    // Low-end mode: a plain surface colour instead of artwork
    if (isLowEndMode && widget.currentArtwork != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: backgroundColor),
          widget.child,
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base layer - solid surface color (always visible as fallback)
        Container(
          color: backgroundColor,
        ),

        // Previous artwork (fading out) - only show during transition
        if (_previousArtworkCache != null && _crossfadeController.isAnimating)
          AnimatedBuilder(
            animation: _crossfadeAnimation,
            builder: (context, child) => Opacity(
              opacity: (1.0 - _crossfadeAnimation.value).clamp(0.0, 1.0),
              child: child!,
            ),
            child: _buildBlurredArtwork(
                _previousArtworkCache!, shouldBlur, blurIntensity),
          ),

        // Current artwork (always visible once loaded, no animation wrapper when stable)
        if (_shown != null)
          _crossfadeController.isAnimating
              ? AnimatedBuilder(
                  animation: _crossfadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _crossfadeAnimation.value.clamp(0.0, 1.0),
                    child: child!,
                  ),
                  child: RepaintBoundary(
                    child: _buildBlurredArtwork(
                        _shown!, shouldBlur, blurIntensity),
                  ),
                )
              : RepaintBoundary(
                  child:
                      _buildBlurredArtwork(_shown!, shouldBlur, blurIntensity),
                ),

        // Overlay for better text readability
        Container(
          color: shouldBlur
              ? Colors.black.withValues(alpha: overlayOpacity)
              : Colors.black
                  .withValues(alpha: (overlayOpacity + 0.3).clamp(0.0, 1.0)),
        ),

        // Vignette effect for depth - only apply in high-end mode
        if (shouldBlur)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),

        // Child content
        widget.child,
      ],
    );
  }

  Widget _buildBlurredArtwork(
      Uint8List artworkData, bool shouldBlur, double blurIntensity) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (shouldBlur)
            BlurredImage(
              provider: MemoryImage(artworkData),
              sigma: blurIntensity,
              fallback: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    artworkData,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    cacheWidth: 512,
                    gaplessPlayback: true,
                  ),
                  AdaptiveBackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurIntensity,
                      sigmaY: blurIntensity,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ],
              ),
            )
          else
            Image.memory(
              artworkData,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
            ),
          // Tint over the blur, or the low-end stand-in for it.
          Container(
            color: Colors.black.withValues(alpha: shouldBlur ? 0.2 : 0.6),
          ),
        ],
      ),
    );
  }
}

/// Optimized blurred background for when performance is critical.
/// Performance-aware: Respects device performance mode for blur effects.
class SimpleBlurredBackground extends StatelessWidget {
  final Uint8List? artwork;
  final double blurIntensity;
  final Color overlayColor;
  final Widget child;

  const SimpleBlurredBackground({
    super.key,
    this.artwork,
    this.blurIntensity = 45.0,
    this.overlayColor = const Color(0x4D1A1A2E),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;

    if (artwork == null) {
      return ColoredBox(
        color: surfaceColor,
        child: child,
      );
    }

    // Check if blur should be enabled based on performance mode
    final performanceProvider =
        Provider.of<PerformanceModeProvider>(context, listen: false);
    final shouldBlur = performanceProvider.shouldEnableBlur;
    final isLowEndMode = !shouldBlur;

    // High-end: if user chose solid background, show surface color
    if (shouldBlur) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (themeProvider.highEndBackground == HighEndBackground.solid) {
        return ColoredBox(
          color: surfaceColor,
          child: child,
        );
      }
    }

    // Low-end mode: plain surface colour
    if (isLowEndMode) {
      return ColoredBox(
        color: surfaceColor,
        child: child,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred artwork
        RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              BlurredImage(
                provider: MemoryImage(artwork!),
                sigma: blurIntensity,
                fallback: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      artwork!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      gaplessPlayback: true,
                    ),
                    AdaptiveBackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: blurIntensity,
                        sigmaY: blurIntensity,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ],
                ),
              ),
              Container(color: overlayColor),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
