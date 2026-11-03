import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:provider/provider.dart';
import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'motion/musicfy_motion.dart';
import 'blurred_image.dart';
import 'adaptive_blur.dart';
import '../providers/performance_mode_provider.dart';

/// A beautiful blurred-artwork header for detail screens (album, artist, playlist, folder).
///
/// Shows a full-width blurred artwork image with the title, subtitle and metadata
/// centred on top. Includes a frosted pill badge at the top showing the content
/// type (e.g. ALBUM, ARTIST) and a back button.
///
/// The title + metadata stay visible throughout scrolling — they smoothly
/// crossfade from the large expanded layout into a compact pinned toolbar so
/// there is never a gap where the name disappears.
class DetailHeader extends StatelessWidget {
  final Uint8List? artworkBytes;
  final String? artworkFilePath;
  final String? fallbackAsset;
  final String title;
  final String? subtitle;
  final String? metadata;
  final String badge;
  final Color accentColor;
  final double expandedHeight;
  final List<Widget>? actions;

  const DetailHeader({
    super.key,
    this.artworkBytes,
    this.artworkFilePath,
    this.fallbackAsset,
    required this.title,
    this.subtitle,
    this.metadata,
    required this.badge,
    this.accentColor = Colors.cyan,
    this.expandedHeight = 300,
    this.actions,
  });

  /// Blurs [artworkBytes] ahead of time, so a header first built with them
  /// draws a ready bitmap instead of running a live full-size blur. Call it
  /// while the page is still opening, and hand the same [Uint8List] to the
  /// header afterwards. Does nothing where blur is off (low-end devices).
  static Future<void> precacheArtwork(
    BuildContext context,
    Uint8List artworkBytes, {
    double expandedHeight = 300,
  }) {
    final lowEnd = Provider.of<PerformanceModeProvider>(context, listen: false)
        .isLowEndDevice;
    if (lowEnd) return Future.value();
    // The blur is sized by the header's longest side (see BlurredImage).
    final extent = math.max(
      MediaQuery.sizeOf(context).width,
      expandedHeight + MediaQuery.paddingOf(context).top,
    );
    return BlurredImage.precache(MemoryImage(artworkBytes),
        sigma: 30, extent: extent);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final collapsedHeight = kToolbarHeight + topPadding;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: expandedHeight,
      pinned: true,
      automaticallyImplyLeading: false,
      leading: _buildBackButton(context),
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final currentHeight = constraints.biggest.height;
            // 0 = fully expanded, 1 = fully collapsed
            final collapseProgress =
                ((expandedHeight + topPadding - currentHeight) /
                        (expandedHeight + topPadding - collapsedHeight))
                    .clamp(0.0, 1.0);

            return Stack(
              fit: StackFit.expand,
              children: [
                // ── Blurred artwork background ──
                // Scrolls away like musicfy's cover: zooms in, dims, then dissolves.
                Opacity(
                  opacity: (1.0 - smoothstep(0.2, 0.85, collapseProgress))
                      .clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 1 + 0.22 * collapseProgress,
                    alignment: const Alignment(0, -0.3),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ArtworkHeroTarget(
                          radius: 10,
                          ready:
                              artworkBytes != null || artworkFilePath != null,
                          child: _buildBlurredBackground(context),
                        ),
                        ColoredBox(
                          color: Colors.black
                              .withValues(alpha: 0.22 * collapseProgress),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Solid dark background for collapsed state ──
                Opacity(
                  opacity: collapseProgress,
                  child: Container(
                    color: Colors.black,
                  ),
                ),

                // ── Gradient overlay ──
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      stops: const [0.0, 0.35, 0.7, 1.0],
                    ),
                  ),
                ),

                // ── Expanded content (badge, title, subtitle, metadata) ──
                // Centered vertically, fades out as the bar collapses
                Opacity(
                  opacity: (1.0 - collapseProgress * 2.0).clamp(0.0, 1.0),
                  child: _RouteReveal(
                    child: SafeArea(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Badge pill
                              _buildBadgePill(),
                              const SizedBox(height: 16),
                              // Title
                              _buildTitleText(fontSize: 32),
                              // Subtitle
                              _lateLine(
                                subtitle,
                                top: 6,
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // Metadata
                              _lateLine(
                                metadata,
                                top: 4,
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Collapsed toolbar title ──
                // Fades in once the expanded content starts disappearing
                if (collapseProgress > 0.3)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: topPadding,
                    height: kToolbarHeight,
                    child: Opacity(
                      opacity: ((collapseProgress - 0.3) / 0.4).clamp(0.0, 1.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 1),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────── Sub-widgets ───────────────────────────

  /// A line that may only be known after loading: it grows in and fades in
  /// instead of popping into the layout.
  Widget _lateLine(String? text,
      {required double top, required TextStyle style}) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: text == null
            ? const SizedBox(key: ValueKey('none'), width: 0, height: 0)
            : Padding(
                key: ValueKey(text),
                padding: EdgeInsets.only(top: top),
                child: Text(text, style: style, textAlign: TextAlign.center),
              ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    // PERF: No BackdropFilter – the back button is a leading widget in a
    // SliverAppBar that has scrolling content behind it, causing expensive
    // blur recomputation on every scroll frame.
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: const iconoir.NavArrowLeft(
            color: Colors.white,
            width: 26,
            height: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleText({required double fontSize}) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBadgePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        badge.toUpperCase(),
        style: TextStyle(
          fontFamily: FontConstants.fontFamily,
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildBlurredBackground(BuildContext context) {
    Widget imageWidget;
    ImageProvider provider;

    if (artworkBytes != null) {
      provider = MemoryImage(artworkBytes!);
      imageWidget = Image.memory(
        artworkBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Heavily blurred anyway; a full-size decode only costs time and memory.
        cacheWidth: 640,
        gaplessPlayback: true,
      );
    } else if (artworkFilePath != null) {
      provider = FileImage(File(artworkFilePath!));
      imageWidget = Image.file(
        File(artworkFilePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: 640,
      );
    } else if (fallbackAsset != null) {
      provider = AssetImage(fallbackAsset!);
      imageWidget = Image.asset(
        fallbackAsset!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      // Gradient fallback
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.4),
              Colors.black87,
              Colors.black,
            ],
          ),
        ),
      );
    }

    // Always blur the header artwork – this is a design requirement,
    // not gated by performance mode.
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          BlurredImage(
            provider: provider,
            sigma: 30,
            fallback: AdaptiveImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: imageWidget,
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}

/// Fades and lifts its child in with the page's route animation. If the header
/// is built after the transition has finished (the screen loaded its data
/// first), it plays the same reveal on its own instead of appearing at once.
class _RouteReveal extends StatefulWidget {
  const _RouteReveal({required this.child});

  final Widget child;

  @override
  State<_RouteReveal> createState() => _RouteRevealState();
}

class _RouteRevealState extends State<_RouteReveal>
    with SingleTickerProviderStateMixin {
  /// The text waits until the flying artwork has all but landed.
  static const double _startAt = 0.8;

  late final AnimationController _own = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
    reverseDuration: const Duration(milliseconds: 160),
  );
  late final Animation<double> _reveal =
      _own.drive(CurveTween(curve: Curves.easeOutCubic));
  Animation<double>? _route;
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    final route = ModalRoute.of(context)?.animation;
    if (route == null) {
      _own.forward();
      return;
    }
    // A route's animation reads "completed" until its first frame, so the
    // real state is only known after this one.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (route.status == AnimationStatus.completed) {
        _own.forward();
      } else {
        _route = route..addListener(_onRoute);
        _onRoute();
      }
    });
  }

  void _onRoute() {
    final route = _route!;
    if (route.status == AnimationStatus.reverse) {
      if (_own.status != AnimationStatus.reverse && _own.value > 0) {
        _own.reverse();
      }
    } else if (route.value >= _startAt &&
        _own.status != AnimationStatus.forward &&
        _own.value < 1) {
      _own.forward();
    }
  }

  @override
  void dispose() {
    _route?.removeListener(_onRoute);
    _own.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reveal = _reveal;
    return FadeTransition(
      opacity: reveal,
      child: SlideTransition(
        position: reveal.drive(
          Tween(begin: const Offset(0, 0.08), end: Offset.zero),
        ),
        child: widget.child,
      ),
    );
  }
}
