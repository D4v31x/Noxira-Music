import 'motion/musicfy_motion.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../main.dart' show pageNavigatorKey;
import '../models/models.dart';
import '../../features/player/player_feature.dart';
import '../services/audio_player_service.dart';
import '../services/artwork_cache_service.dart';
import '../services/background_manager_service.dart';
import '../services/sleep_timer_controller.dart';
import '../utils/responsive_utils.dart';
import '../providers/providers.dart';
import 'adaptive_blur.dart';

/// A beautiful, simple mini player that opens the Now Playing screen.
class ExpandingPlayer extends StatefulWidget {
  const ExpandingPlayer({super.key});

  /// Height of the mini player
  static const double miniPlayerHeight = 72.0;

  /// Mini player height grown to fit the title and artist at the user's font scale.
  static double miniPlayerHeightOf(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final scaler = MediaQuery.textScalerOf(context);
    double lineHeight(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: 'Ag', style: base.merge(style)),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final h = painter.height;
      painter.dispose();
      return h;
    }

    final textBlock =
        lineHeight(_miniTitleStyle) + 3 + lineHeight(_miniArtistStyle);
    // 10px padding above and below the row content.
    return math.max(miniPlayerHeight, textBlock + 20 + 4);
  }

  /// Bottom margin for floating effect
  static const double bottomMargin = 16.0;

  /// Get the total height needed for bottom padding in other screens
  static double getMiniPlayerPaddingHeight(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return miniPlayerHeightOf(context) + bottomMargin + bottomPadding + 8;
  }

  /// Global state holder
  static _ExpandingPlayerState? _state;

  /// Notifier for when now playing screen is open/closed
  static final ValueNotifier<bool> isOpenNotifier = ValueNotifier<bool>(false);

  /// Set to true by screens that should suppress the mini player (e.g. metadata editor)
  static final ValueNotifier<bool> hiddenNotifier = ValueNotifier<bool>(false);

  /// 0 = collapsed mini player, 1 = fully expanded Now Playing page.
  static final ValueNotifier<double> expansionNotifier =
      ValueNotifier<double>(0);

  /// True once the transition is drawing the artwork/title/artist, so the
  /// mini player stops drawing its own copy.
  static final ValueNotifier<bool> shuttleActive = ValueNotifier<bool>(false);

  /// Same as [shuttleActive] but set synchronously while building, so the mini
  /// player can react on its very next rebuild instead of a frame later.
  static bool shuttleReadyNow = false;

  /// Check if player is expanded (now playing screen is open)
  static bool get isExpanded => isOpenNotifier.value;

  /// Minimize the player (close now playing screen)
  static void minimize() {
    if (!isOpenNotifier.value) return;
    final state = _state;
    if (state != null) {
      state._closeAnimated();
    } else {
      pageNavigatorKey.currentState?.maybePop();
    }
  }

  /// Expand the player (open now playing screen)
  static void expand() => _state?._openNowPlaying();

  /// Called by Now Playing while the user pulls its content down at the top.
  /// [dy] is the pixel delta (positive = down).
  static void dismissDragUpdate(double dy) => _state?._dismissUpdate(dy);

  /// Called when that pull ends; [velocity] is in px/s (positive = down).
  static void dismissDragEnd(double velocity) => _state?._dismissEnd(velocity);

  /// True while a pull-down is driving the collapse to the mini player.
  static bool get isDismissDragging => _state?._dismissing ?? false;

  @override
  State<ExpandingPlayer> createState() => _ExpandingPlayerState();
}

class _ExpandingPlayerState extends State<ExpandingPlayer> {
  @override
  void initState() {
    super.initState();
    ExpandingPlayer._state = this;
    // Reset the state in case it got stuck from a previous session
    ExpandingPlayer.isOpenNotifier.value = false;
    ExpandingPlayer.expansionNotifier.value = 0;
    ExpandingPlayer.shuttleActive.value = false;
  }

  @override
  void dispose() {
    if (ExpandingPlayer._state == this) {
      ExpandingPlayer._state = null;
    }
    super.dispose();
  }

  static const _openDuration = Duration(milliseconds: 420);
  static const _closeDuration = Duration(milliseconds: 320);

  /// Material 3 emphasized-decelerate: quick start, long soft landing.
  static const _curve = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Opening starts at once and lands softly, like closing.
  static const _openCurve = Cubic(0.2, 0.0, 0.0, 1.0);

  /// [full] scaled by how much of the 0..1 range is left to travel.
  static Duration _scaled(Duration full, double remaining) => Duration(
        milliseconds: math.max(180, (full.inMilliseconds * remaining).round()),
      );

  /// The Now Playing route while it is open or animating.
  _ExpandRoute? _route;

  /// True while a swipe-up on the mini player is driving the route.
  bool _miniDragging = false;

  /// True while a pull-down on Now Playing is driving the route.
  bool _dismissing = false;

  /// Shared-element data for the current route; drawn above the mini frame.
  _ShuttleConfig? _shuttle;

  NavigatorState? get _navigator => pageNavigatorKey.currentState;

  double get _dragRange => math.max(1, MediaQuery.sizeOf(context).height * 0.6);

  Rect _miniRect() {
    final size = MediaQuery.sizeOf(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final isTablet = ResponsiveUtils.isTablet(context);
    final margin = isTablet ? 32.0 : 16.0;
    final miniHeight = ExpandingPlayer.miniPlayerHeightOf(context);
    final width =
        math.min(size.width - margin * 2, isTablet ? 480.0 : size.width);
    return Rect.fromLTWH(
      (size.width - width) / 2,
      size.height - bottom - ExpandingPlayer.bottomMargin - miniHeight,
      width,
      miniHeight,
    );
  }

  /// Pushes the Now Playing route paused at 0; the caller drives its controller.
  _ExpandRoute? _pushRoute() {
    final navigator = _navigator;
    if (navigator == null) return null;
    ExpandingPlayer.shuttleActive.value = false;
    ExpandingPlayer.shuttleReadyNow = false;

    final audioPlayerService =
        Provider.of<AudioPlayerService>(context, listen: false);
    final backgroundManager =
        Provider.of<BackgroundManagerService>(context, listen: false);
    final sleepTimerController =
        Provider.of<SleepTimerController>(context, listen: false);

    final miniRect = _miniRect();
    final artworkKey = GlobalKey();
    final titleKey = GlobalKey();
    final artistKey = GlobalKey();

    ImageProvider<Object>? resolveShuttleImage() {
      final song = audioPlayerService.currentSong;
      return song == null
          ? null
          : ArtworkCacheService().getCachedImageProviderSync(song.id);
    }

    _ShuttleText? resolveShuttleText() {
      final song = audioPlayerService.currentSong;
      return song == null
          ? null
          : (
              title: song.title,
              artist: splitArtists(song.artist ?? 'Unknown').join(', '),
            );
    }

    final useShuttle = resolveShuttleImage() != null;

    final route = _ExpandRoute(
      transitionDuration: _openDuration,
      reverseTransitionDuration: _closeDuration,
      pageBuilder: (_, animation, secondaryAnimation) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioPlayerService>.value(
                value: audioPlayerService),
            ChangeNotifierProvider<BackgroundManagerService>.value(
                value: backgroundManager),
            ChangeNotifierProvider<SleepTimerController>.value(
                value: sleepTimerController),
          ],
          child: Material(
            type: MaterialType.transparency,
            child: NowPlayingScreen(
              onClose: _closeAnimated,
              artworkKey: artworkKey,
              titleKey: titleKey,
              artistKey: artistKey,
              entryAnimation: useShuttle ? animation : null,
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _ExpandTransition(
          animation: animation,
          miniRect: miniRect,
          child: child,
        );
      },
    );

    _route = route;
    ExpandingPlayer.isOpenNotifier.value = true;
    navigator.push<void>(route).then((_) {
      if (_route == route) _route = null;
      ExpandingPlayer.isOpenNotifier.value = false;
    });

    final animation = route.animation;
    if (animation == null) {
      ExpandingPlayer.expansionNotifier.value = 1;
    } else {
      animation.addListener(
          () => ExpandingPlayer.expansionNotifier.value = animation.value);
      animation.addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          ExpandingPlayer.expansionNotifier.value = 0;
          // Dragging back to rest also reports dismissed; only drop the
          // shuttle once the route has really been popped.
          if (mounted && _route != route && _shuttle?.animation == animation) {
            setState(() => _shuttle = null);
          }
        }
      });
      if (useShuttle) {
        setState(() {
          _shuttle = _ShuttleConfig(
            animation: animation,
            miniRect: miniRect,
            artworkKey: artworkKey,
            titleKey: titleKey,
            artistKey: artistKey,
            resolveImage: resolveShuttleImage,
            resolveText: resolveShuttleText,
          );
        });
      }
    }
    return route;
  }

  void _openNowPlaying() {
    if (ExpandingPlayer.isOpenNotifier.value) return;
    HapticFeedback.lightImpact();
    final route = _pushRoute();
    final controller = route?.controller;
    if (route == null || controller == null) return;
    // Setting the value cancels the route's default linear animation. Hold at
    // rest until the shared elements are laid out: the curve moves fast at the
    // start, so animating right away would skip the first part of their flight
    // and leave the mini player's own copies showing in the growing frame.
    controller.value = 0;
    _startOpenWhenReady(route);
  }

  void _startOpenWhenReady(_ExpandRoute route, [int waited = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _route != route) return;
      final ready = _shuttle == null ||
          ExpandingPlayer.shuttleActive.value ||
          waited >= 8;
      if (!ready) {
        _startOpenWhenReady(route, waited + 1);
        WidgetsBinding.instance.scheduleFrame();
        return;
      }
      route.controller
          ?.animateTo(1, duration: _openDuration, curve: _openCurve);
    });
  }

  void _closeAnimated() {
    final route = _route;
    final navigator = _navigator;
    if (route == null || navigator == null || !route.isCurrent) {
      navigator?.maybePop();
      return;
    }
    final controller = route.controller;
    navigator.pop();
    controller?.animateBack(0,
        duration: _scaled(_closeDuration, controller.value), curve: _curve);
  }

  void _settle({required bool open}) {
    final route = _route;
    final controller = route?.controller;
    if (route == null || controller == null) return;
    if (open) {
      controller.animateTo(1,
          duration: _scaled(_openDuration, 1 - controller.value),
          curve: _openCurve);
    } else {
      _closeAnimated();
    }
  }

  // Swipe-up on the mini player: the route follows the finger.
  void _onMiniDragStart(DragStartDetails details) {
    if (ExpandingPlayer.isOpenNotifier.value) return;
    _miniDragging = true;
  }

  void _onMiniDragUpdate(DragUpdateDetails details) {
    if (!_miniDragging) return;
    final delta = details.primaryDelta ?? 0;
    if (_route == null) {
      // Only open on an upward drag.
      if (delta >= 0) return;
      _pushRoute()?.controller?.value = 0;
    }
    final controller = _route?.controller;
    if (controller == null) return;
    controller.value = (controller.value - delta / _dragRange).clamp(0.0, 1.0);
  }

  void _onMiniDragEnd(double velocity) {
    if (!_miniDragging) return;
    _miniDragging = false;
    setState(() {});
    if (_route == null) return;
    final value = _route?.controller?.value ?? 0;
    final open = velocity < -300 || (velocity <= 300 && value > 0.3);
    _settle(open: open);
  }

  // Pull-down on Now Playing: the route follows the finger back to the mini player.
  void _dismissUpdate(double dy) {
    final controller = _route?.controller;
    if (controller == null || !ExpandingPlayer.isOpenNotifier.value) return;
    if (!_dismissing) {
      if (dy <= 0) return;
      _dismissing = true;
    }
    controller.value = (controller.value - dy / _dragRange).clamp(0.0, 1.0);
    // Back at fully open: hand scrolling back to the list.
    if (dy < 0 && controller.value >= 1) _dismissing = false;
  }

  void _dismissEnd(double velocity) {
    if (!_dismissing) return;
    _dismissing = false;
    final value = _route?.controller?.value ?? 1;
    final close = velocity > 700 || (velocity >= -300 && value < 0.75);
    _settle(open: !close);
  }

  @override
  Widget build(BuildContext context) {
    final shuttle = _shuttle;
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMiniPlayer(),
        if (shuttle != null)
          _ShuttleLayer(
            // A new route must get a fresh state; reusing the old one skipped
            // the hand-off flags and left the mini player's copies showing.
            key: ObjectKey(shuttle.animation),
            animation: shuttle.animation,
            miniRect: shuttle.miniRect,
            artworkKey: shuttle.artworkKey,
            titleKey: shuttle.titleKey,
            artistKey: shuttle.artistKey,
            resolveImage: shuttle.resolveImage,
            resolveText: shuttle.resolveText,
          ),
      ],
    );
  }

  Widget _buildMiniPlayer() {
    return ValueListenableBuilder<bool>(
      valueListenable: ExpandingPlayer.isOpenNotifier,
      builder: (context, isOpen, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: ExpandingPlayer.hiddenNotifier,
          builder: (context, isHidden, _) {
            if (isHidden) return const SizedBox.shrink();

            return Selector<AudioPlayerService, SongModel?>(
              selector: (_, service) => service.currentSong,
              builder: (context, currentSong, _) {
                if (currentSong == null) return const SizedBox.shrink();

                return ValueListenableBuilder<double>(
                  valueListenable: ExpandingPlayer.expansionNotifier,
                  builder: (context, expansion, _) {
                    // Once fully expanded the mini player is no longer needed.
                    if (isOpen && expansion >= 0.98 && !_miniDragging) {
                      return const SizedBox.shrink();
                    }
                    return ValueListenableBuilder<bool>(
                      valueListenable: ExpandingPlayer.shuttleActive,
                      builder: (context, shuttle, _) => IgnorePointer(
                        ignoring: expansion > 0.02,
                        child: _MiniPlayerWidget(
                          song: currentSong,
                          expansion: expansion,
                          sharedHidden:
                              (shuttle || ExpandingPlayer.shuttleReadyNow) &&
                                  expansion > 0,
                          onTap: _openNowPlaying,
                          onDragStart: _onMiniDragStart,
                          onDragUpdate: _onMiniDragUpdate,
                          onDragEnd: _onMiniDragEnd,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Page route whose animation controller is driven by drag gestures.
class _ExpandRoute extends PageRouteBuilder<void> {
  _ExpandRoute({
    required super.pageBuilder,
    required super.transitionsBuilder,
    required super.transitionDuration,
    required super.reverseTransitionDuration,
  });

  @override
  AnimationController? get controller => super.controller;
}

const _miniTitleStyle = TextStyle(
  fontFamily: FontConstants.fontFamily,
  color: Colors.white,
  fontSize: 15,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.3,
);

const _miniArtistStyle = TextStyle(
  fontFamily: FontConstants.fontFamily,
  color: Color(0x8CFFFFFF),
  fontSize: 13,
  fontWeight: FontWeight.w400,
);

typedef _ShuttleText = ({String title, String artist});

/// Everything the shared-element layer needs for one open/close of the player.
class _ShuttleConfig {
  final Animation<double> animation;
  final Rect miniRect;
  final GlobalKey artworkKey;
  final GlobalKey titleKey;
  final GlobalKey artistKey;
  final ImageProvider<Object>? Function() resolveImage;
  final _ShuttleText? Function() resolveText;

  const _ShuttleConfig({
    required this.animation,
    required this.miniRect,
    required this.artworkKey,
    required this.titleKey,
    required this.artistKey,
    required this.resolveImage,
    required this.resolveText,
  });
}

/// Reveals the Now Playing page inside the growing mini player frame.
class _ExpandTransition extends StatelessWidget {
  final Animation<double> animation;
  final Rect miniRect;
  final Widget child;

  const _ExpandTransition({
    required this.animation,
    required this.miniRect,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, page) {
            final t = animation.value.clamp(0.0, 1.0);
            final rect = Rect.lerp(miniRect, Offset.zero & size, t)!;
            final radius = 24 * (1 - Curves.easeInCubic.transform(t));
            // The mini player's own frame (drawn above, in the mini player
            // layer) grows in lockstep with this clip. The scrim slot always
            // exists so the page subtree keeps its position (and state).
            return Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: ColoredBox(
                    color:
                        Colors.black.withValues(alpha: t >= 1 ? 0 : 0.45 * t),
                  ),
                ),
                ClipRRect(
                  clipper: _ExpandClipper(rect, radius),
                  clipBehavior: t >= 1 ? Clip.none : Clip.antiAlias,
                  child: Opacity(
                    opacity:
                        Curves.easeOut.transform((t / 0.25).clamp(0.0, 1.0)),
                    // Always present so the page keeps its state; it settles
                    // from a little smaller about the growing frame's centre.
                    child: Transform.scale(
                      scale: 0.95 + 0.05 * t,
                      alignment: Alignment(
                        2 * rect.center.dx / size.width - 1,
                        2 * rect.center.dy / size.height - 1,
                      ),
                      // Isolate the page so growing the clip never repaints it.
                      child: RepaintBoundary(child: page),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ExpandClipper extends CustomClipper<RRect> {
  final Rect rect;
  final double radius;

  const _ExpandClipper(this.rect, this.radius);

  @override
  RRect getClip(Size size) =>
      RRect.fromRectAndRadius(rect, Radius.circular(radius));

  @override
  bool shouldReclip(_ExpandClipper oldClipper) =>
      oldClipper.rect != rect || oldClipper.radius != radius;
}

/// Artwork, title and artist travelling between the mini player and the page.
class _ShuttleLayer extends StatefulWidget {
  final Animation<double> animation;
  final Rect miniRect;
  final GlobalKey artworkKey;
  final GlobalKey titleKey;
  final GlobalKey artistKey;
  final ImageProvider<Object>? Function() resolveImage;
  final _ShuttleText? Function() resolveText;

  const _ShuttleLayer({
    super.key,
    required this.animation,
    required this.miniRect,
    required this.artworkKey,
    required this.titleKey,
    required this.artistKey,
    required this.resolveImage,
    required this.resolveText,
  });

  @override
  State<_ShuttleLayer> createState() => _ShuttleLayerState();
}

typedef _MiniTextGeometry = ({
  Rect title,
  Rect artist,
  bool titleTruncated,
  bool artistTruncated,
});

class _ShuttleLayerState extends State<_ShuttleLayer> {
  /// The state currently drawing; a stale state being disposed must not reset
  /// the flags the new one has set.
  static _ShuttleLayerState? _owner;

  late ImageProvider<Object>? _image = widget.resolveImage();
  late _ShuttleText? _text = widget.resolveText();
  _MiniTextGeometry? _mini;
  bool _rebuildScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mini ??= _measureMiniText();
  }

  @override
  void dispose() {
    _setActive(false);
    super.dispose();
  }

  /// Tells the mini player whether it should stop drawing its own copies.
  void _setActive(bool value) {
    if (value) {
      if (_owner == this && ExpandingPlayer.shuttleReadyNow) return;
      _owner = this;
      ExpandingPlayer.shuttleReadyNow = true;
    } else {
      if (_owner != this) return;
      _owner = null;
      ExpandingPlayer.shuttleReadyNow = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = ExpandingPlayer.shuttleReadyNow;
      if (ExpandingPlayer.shuttleActive.value != now) {
        ExpandingPlayer.shuttleActive.value = now;
      }
    });
  }

  /// What Material gives Text under the mini player and the page; lerping
  /// partial styles would drop its letter spacing and height at the end.
  TextStyle _baseTextStyle() =>
      Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

  /// Where the mini player lays out its title and artist.
  _MiniTextGeometry? _measureMiniText() {
    final text = _text;
    if (text == null) return null;
    final scaler = MediaQuery.textScalerOf(context);
    final controlsWidth = ResponsiveUtils.isTablet(context) ? 90.0 : 46.0;
    // Row: 10 pad + 52 thumb + 14 gap + text + 8 gap + controls + 8 pad.
    final left = widget.miniRect.left + 76;
    final maxWidth = widget.miniRect.width - 92 - controlsWidth;

    TextPainter layout(String s, TextStyle style) => TextPainter(
          text: TextSpan(text: s, style: style),
          maxLines: 1,
          ellipsis: '\u2026',
          textDirection: TextDirection.ltr,
          textScaler: scaler,
        )..layout(maxWidth: maxWidth);

    final title = layout(text.title, _baseTextStyle().merge(_miniTitleStyle));
    final artist =
        layout(text.artist, _baseTextStyle().merge(_miniArtistStyle));
    final columnHeight = title.height + 3 + artist.height;
    final top = widget.miniRect.top +
        10 +
        (widget.miniRect.height - 20 - columnHeight) / 2;
    final result = (
      title: Rect.fromLTWH(left, top, title.width, title.height),
      artist: Rect.fromLTWH(
          left, top + title.height + 3, artist.width, artist.height),
      titleTruncated: title.didExceedMaxLines,
      artistTruncated: artist.didExceedMaxLines,
    );
    title.dispose();
    artist.dispose();
    return result;
  }

  /// The rect of [key]'s box in this widget's coordinate space, once laid out.
  Rect? _rectOf(GlobalKey key) {
    final target = key.currentContext?.findRenderObject();
    final self = context.findRenderObject();
    if (target is! RenderBox ||
        self is! RenderBox ||
        !target.attached ||
        !target.hasSize ||
        !self.hasSize) {
      return null;
    }
    return self.globalToLocal(target.localToGlobal(Offset.zero)) & target.size;
  }

  Widget _flyingText(
    String text,
    TextStyle begin,
    TextStyle end,
    Rect from,
    Rect to,
    bool truncated,
    double t,
  ) {
    final rect = Rect.lerp(from, to, t)!;
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: truncated ? rect.width : null,
      child: Text(
        text,
        style: TextStyle.lerp(begin, end, t),
        maxLines: 1,
        softWrap: false,
        overflow: truncated ? TextOverflow.ellipsis : TextOverflow.visible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This layer sits outside the route's transition, so it has to listen to
    // the route animation itself.
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final t = widget.animation.value.clamp(0.0, 1.0);

    // The song can change while the page is open (no rebuilds happen at t=1),
    // so re-resolve whenever it differs; otherwise the flight would carry the
    // old song's text and artwork over the mini player's new ones.
    final latest = widget.resolveText();
    if (latest != _text) {
      _text = latest;
      _image = widget.resolveImage();
      _mini = _measureMiniText();
    }

    final image = _image;
    final text = _text;
    final mini = _mini;
    final art = _rectOf(widget.artworkKey);
    final titleEnd = _rectOf(widget.titleKey);
    final artistEnd = _rectOf(widget.artistKey);

    if (text == null ||
        mini == null ||
        art == null ||
        titleEnd == null ||
        artistEnd == null) {
      // Nothing is drawn yet, so the mini player must keep its own copies.
      _setActive(false);
      if (!_rebuildScheduled) {
        // The page has not been laid out yet; try again next frame.
        _rebuildScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _rebuildScheduled = false;
          if (mounted) setState(() {});
        });
      }
      return const IgnorePointer(child: SizedBox.expand());
    }

    _setActive(true);
    if (t >= 1 || t <= 0) return const SizedBox.shrink();

    final isTablet = ResponsiveUtils.isTablet(context);
    final base = _baseTextStyle();
    final titleBeginStyle = base.merge(_miniTitleStyle);
    final artistBeginStyle = base.merge(_miniArtistStyle);
    final titleEndStyle = base.merge(TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: isTablet ? 22 : 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ));
    final artistEndStyle = base.merge(TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: isTablet ? 16 : 14,
      color: const Color(0xB3FFFFFF),
    ));

    // Mini player thumbnail: 10px content padding, 52px square, vertically centred.
    final artBegin = Rect.fromLTWH(widget.miniRect.left + 10,
        widget.miniRect.top + (widget.miniRect.height - 52) / 2, 52, 52);
    final artRect = Rect.lerp(artBegin, art, t)!;
    final artRadius = lerpDouble(14, 8, t)!;

    // No Material ancestor here: without one, Text falls back to a yellow
    // double-underlined default style.
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox.expand(
          child: Stack(
            children: [
              if (image != null)
                Positioned.fromRect(
                  rect: artRect,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(artRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2 * t),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(artRadius),
                      child: Image(image: image, fit: BoxFit.cover),
                    ),
                  ),
                ),
              _flyingText(text.title, titleBeginStyle, titleEndStyle,
                  mini.title, titleEnd, mini.titleTruncated, t),
              _flyingText(text.artist, artistBeginStyle, artistEndStyle,
                  mini.artist, artistEnd, mini.artistTruncated, t),
            ],
          ),
        ),
      ),
    );
  }
}

/// The floating mini player. As [expansion] grows its own frame stretches to
/// fill the screen, so the Now Playing page opens out of this same container.
/// Performance-aware: Respects device performance mode for blur effects.
class _MiniPlayerWidget extends StatelessWidget {
  final SongModel song;

  /// 0 = resting mini player, 1 = full screen.
  final double expansion;

  /// True while the transition draws the artwork/title/artist itself.
  final bool sharedHidden;
  final VoidCallback onTap;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final ValueChanged<double> onDragEnd;

  const _MiniPlayerWidget({
    required this.song,
    required this.expansion,
    required this.sharedHidden,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final t = expansion.clamp(0.0, 1.0);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isTablet = ResponsiveUtils.isTablet(context);
    final margin = isTablet ? 32.0 : 16.0;
    final colorScheme = Theme.of(context).colorScheme;

    final performanceProvider =
        Provider.of<PerformanceModeProvider>(context, listen: false);
    final shouldBlur = performanceProvider.shouldEnableBlur;

    // The glass fill and blur give way to the page as the player grows; the
    // outline stays until the frame reaches the screen edges.
    final glass = (1 - t / 0.3).clamp(0.0, 1.0);
    final borderFade = 1 - ((t - 0.7) / 0.3).clamp(0.0, 1.0);
    final radius = 24 * (1 - Curves.easeInCubic.transform(t));
    final controlsOpacity = (1 - t / 0.15).clamp(0.0, 1.0);
    final sharedOpacity = sharedHidden ? 0.0 : 1.0;

    final BoxDecoration playerDecoration;
    if (shouldBlur) {
      playerDecoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15 * glass),
            Colors.white.withValues(alpha: 0.05 * glass),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2 * borderFade),
        ),
      );
    } else {
      playerDecoration = BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: glass),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: colorScheme.outlineVariant.a * borderFade),
        ),
      );
    }

    final miniHeight = ExpandingPlayer.miniPlayerHeightOf(context);
    // The content row (song info + controls) – changes only when the song changes.
    final contentRow = Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      child: Row(
        children: [
          // Artwork
          Opacity(
            opacity: sharedOpacity,
            child: _ArtworkThumbnail(songId: song.id, size: 52),
          ),

          const SizedBox(width: 14),

          // Song info
          Expanded(
            child: Opacity(
              opacity: sharedOpacity,
              // Clips instead of overflowing the fixed 52px row at large font sizes.
              child: ClipRect(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: miniHeight - 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: _miniTitleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          splitArtists(song.artist ?? 'Unknown').join(', '),
                          style: _miniArtistStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Controls - these need to block parent GestureDetector
          Opacity(
            opacity: controlsOpacity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PlayPauseButton(size: 46),
                if (isTablet) ...[
                  const SizedBox(width: 4),
                  _SkipButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // The progress bar lives in its own RepaintBoundary so that its frequent
    // position-stream updates (≈5 x/sec) do not invalidate the blur layer.
    final progressBar = Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Opacity(
        opacity: controlsOpacity,
        child: RepaintBoundary(child: _ProgressBar()),
      ),
    );

    // The mini player's own row keeps its size and stays pinned to the top
    // edge of the growing frame.
    final miniContent = Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: miniHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [contentRow, progressBar],
        ),
      ),
    );

    // The inner child — glassmorphic blur on high-end, solid on low-end.
    final innerStack = Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: playerDecoration,
          child: const SizedBox.expand(),
        ),
        miniContent,
      ],
    );

    // Blur is the costly part: it is only kept while the frame is still small.
    final blurSigma = 20 * (1 - t / 0.12).clamp(0.0, 1.0);

    final innerChild = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: shouldBlur
          ? AdaptiveBackdropFilter(
              enabled: blurSigma > 0,
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: innerStack,
            )
          : innerStack,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final width =
            math.min(size.width - margin * 2, isTablet ? 480.0 : size.width);
        final restingRect = Rect.fromLTWH(
          (size.width - width) / 2,
          size.height -
              bottomPadding -
              ExpandingPlayer.bottomMargin -
              miniHeight,
          width,
          miniHeight,
        );
        final rect = Rect.lerp(restingRect, Offset.zero & size, t)!;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fromRect(
              rect: rect,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                onVerticalDragStart: onDragStart,
                onVerticalDragUpdate: onDragUpdate,
                onVerticalDragEnd: (details) =>
                    onDragEnd(details.primaryVelocity ?? 0),
                onVerticalDragCancel: () => onDragEnd(0),
                child: Material(
                  color: Colors.transparent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      // A blurred shadow on a screen-sized frame is expensive.
                      boxShadow: t >= 0.4
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.4 * (1 - t / 0.4)),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                                spreadRadius: -4,
                              ),
                            ],
                    ),
                    child: innerChild,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Artwork thumbnail with subtle glow effect
class _ArtworkThumbnail extends StatelessWidget {
  final int songId;
  final double size;

  const _ArtworkThumbnail({
    required this.songId,
    required this.size,
  });

  static final _artworkService = ArtworkCacheService();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _artworkService.buildCachedArtwork(songId, size: size),
      ),
    );
  }
}

/// Progress bar at the bottom of mini player
class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);

    // KEY PERF FIX: Use Selector so that only the color value is watched from
    // BackgroundManagerService. When a new color arrives the Selector rebuilds,
    // producing a new StreamBuilder widget with the updated colour captured in
    // its builder closure. The StreamBuilder element is reused (same stream,
    // same position in tree) and simply re-renders with the latest position
    // snapshot – all without making _ProgressBar.build subscribe to every
    // notifyListeners() call from BackgroundManagerService.
    return Selector<BackgroundManagerService, Color>(
      selector: (context, bm) => bm.currentColors.length > 2
          ? bm.currentColors[2]
          : (bm.currentColors.isNotEmpty
              ? bm.currentColors.first
              : Theme.of(context).colorScheme.primary),
      builder: (context, progressColor, _) {
        return StreamBuilder<Duration>(
          stream: audioService.audioPlayer.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = audioService.audioPlayer.duration ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? (position.inMilliseconds / duration.inMilliseconds)
                    .clamp(0.0, 1.0)
                : 0.0;

            return SizedBox(
              height: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 3,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Play/Pause button
class _PlayPauseButton extends StatelessWidget {
  final double size;

  const _PlayPauseButton({this.size = 48});

  @override
  Widget build(BuildContext context) {
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);

    return ValueListenableBuilder<bool>(
      valueListenable: audioService.isPlayingNotifier,
      builder: (context, isPlaying, _) {
        return SpringPress(
            child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            isPlaying ? audioService.pause() : audioService.resume();
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: size * 0.55,
            ),
          ),
        ));
      },
    );
  }
}

/// Skip button for tablets
class _SkipButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);

    return SpringPress(
        child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        audioService.skip();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.skip_next_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    ));
  }
}
