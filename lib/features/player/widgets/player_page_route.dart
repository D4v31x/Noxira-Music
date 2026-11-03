/// Route for full pages that grow out of the Now Playing screen.
///
/// The page opens out of the card it was launched from (a clip that grows from
/// the card's rect to the full screen), the cover, title and artist fly to
/// their places in the page's header, and the page's rows rise into place. The
/// open has a little give at the end; closing settles without bounce. The page
/// can also be pulled back down with a finger and, on release, carries the
/// finger's speed into the spring.
///
/// Motion model adapted from musicfy's PlayerPageTransition
/// (https://github.com/realidkroo/musicfy, GPL-3.0).
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../core/constants/font_constants.dart';

// MARK: - Springs

/// Samples a spring simulation as an animation curve over [span] seconds.
class SpringCurve extends Curve {
  SpringCurve({
    required double stiffness,
    required double dampingRatio,
    this.span = 0.55,
  }) : _sim = SpringSimulation(
          SpringDescription.withDampingRatio(
            mass: 1,
            stiffness: stiffness,
            ratio: dampingRatio,
          ),
          0,
          1,
          0,
          snapToEnd: true,
        );

  final SpringSimulation _sim;

  /// Spring time (seconds) mapped onto the unit interval.
  final double span;

  @override
  double transformInternal(double t) => _sim.x(t * span);
}

/// A spring from [from] to [to] carrying an initial [velocity], expressed as a
/// curve so it can drive `AnimationController.animateTo`.
class _ReleaseSpring extends Curve {
  _ReleaseSpring({
    required this.from,
    required this.to,
    required double velocity,
    required double stiffness,
    required double dampingRatio,
  }) : _sim = SpringSimulation(
          SpringDescription.withDampingRatio(
            mass: 1,
            stiffness: stiffness,
            ratio: dampingRatio,
          ),
          from,
          to,
          velocity,
          snapToEnd: true,
        );

  final double from;
  final double to;
  final SpringSimulation _sim;

  static const double span = 0.5;
  static const Duration duration = Duration(milliseconds: 500);

  @override
  double transformInternal(double t) {
    final distance = to - from;
    if (distance.abs() < 1e-6) return 1;
    return (_sim.x(t * span) - from) / distance;
  }
}

final Curve _openCurve = SpringCurve(stiffness: 230, dampingRatio: 0.82);
final Curve _closeCurve =
    SpringCurve(stiffness: 280, dampingRatio: 1, span: 0.48);

/// A fling faster than this (progress per second) decides the direction.
const double _kFlingDecides = 1.4;

/// How far ahead a slow release is projected before picking a side.
const double _kReleaseProjectionSec = 0.14;

/// Past this (projected) the page stays open; short of it, it closes.
const double _kOpenThreshold = 0.38;

/// The most fling speed handed to the spring (progress per second).
const double _kMaxCarriedVelocity = 4.5;

/// Fraction of the screen height a full open/close drag travels.
const double _kDragTravelFraction = 0.6;

// MARK: - Shared elements

/// The elements on the launching screen the page grows out of. The launching
/// screen attaches these keys; any that are missing (or off screen) are simply
/// not animated.
class PlayerPageSources {
  PlayerPageSources._();

  static final GlobalKey card = GlobalKey(debugLabel: 'playerPageCard');
  static final GlobalKey queueCard =
      GlobalKey(debugLabel: 'playerPageQueueCard');

  /// The card the open page grew from; other cards ignore the fade values.
  static GlobalKey? activeCard;

  /// [value] if [key] is the card driving the open page (or none is), else 1.
  static double forCard(GlobalKey key, double value) =>
      activeCard == null || activeCard == key ? value : 1;
  static final GlobalKey art = GlobalKey(debugLabel: 'playerPageArt');
  static final GlobalKey title = GlobalKey(debugLabel: 'playerPageTitle');
  static final GlobalKey artist = GlobalKey(debugLabel: 'playerPageArtist');

  /// Styles the launching screen draws title and artist with.
  static TextStyle? titleStyle;
  static TextStyle? artistStyle;

  /// Whether the launching screen centres its title/artist in their boxes.
  static bool centered = true;

  /// How much of the launching card's own content shows: 1 at rest, fading out
  /// as a page opens from the card and back in as it closes.
  static final ValueNotifier<double> cardReveal = ValueNotifier<double>(1);

  /// 1 when the card draws its own background and outline; 0 while a page
  /// opened from it is on screen and draws that frame instead.
  static final ValueNotifier<double> cardChrome = ValueNotifier<double>(1);

  /// True while the shuttle draws the elements, so the launching screen
  /// hides its own copies.
  static final ValueNotifier<bool> hidden = ValueNotifier<bool>(false);

  /// Keys on the first rows of the queue preview card.
  static final List<RowKeys> previewRows =
      List.generate(kPlayerPageRows, (_) => RowKeys());
}

/// How many song rows travel from the queue card into the queue page.
const int kPlayerPageRows = 3;

/// Keys on one song row's cover, title and artist.
class RowKeys {
  final GlobalKey art = GlobalKey(debugLabel: 'playerPageRowArt');
  final GlobalKey title = GlobalKey(debugLabel: 'playerPageRowTitle');
  final GlobalKey artist = GlobalKey(debugLabel: 'playerPageRowArtist');
}

/// A song row flying from the queue card to its row in the queue page.
class PlayerPageRowShuttle {
  const PlayerPageRowShuttle({
    required this.image,
    required this.title,
    required this.artist,
  });

  final ImageProvider<Object>? image;
  final String title;
  final String artist;
}

/// Where the cover, title and artist land in the page.
class PlayerPageTargets {
  final GlobalKey art = GlobalKey(debugLabel: 'playerPageTargetArt');
  final GlobalKey title = GlobalKey(debugLabel: 'playerPageTargetTitle');
  final GlobalKey artist = GlobalKey(debugLabel: 'playerPageTargetArtist');
  final List<RowKeys> rows = List.generate(kPlayerPageRows, (_) => RowKeys());
}

/// What the shuttle draws while the elements travel.
class PlayerPageShuttle {
  const PlayerPageShuttle({
    required this.image,
    required this.title,
    required this.artist,
    required this.titleTo,
    required this.artistTo,
  });

  final ImageProvider<Object>? image;
  final String title;
  final String artist;
  final TextStyle titleTo;
  final TextStyle artistTo;
}

// MARK: - Route

class PlayerPageRoute<T> extends PageRoute<T> {
  PlayerPageRoute({
    required this.builder,
    required this.targets,
    this.shuttle,
    this.cardRect,
    this.rows = const [],
  });

  final List<PlayerPageRowShuttle> rows;
  bool get _hasShuttle => shuttle != null || rows.isNotEmpty;

  final WidgetBuilder builder;
  final PlayerPageTargets targets;
  final PlayerPageShuttle? shuttle;

  /// The card the page grows out of, in screen coordinates.
  final Rect? cardRect;

  late final _RouteProgress _progress;
  final ValueNotifier<bool> _shuttleOn = ValueNotifier<bool>(false);
  bool _dragging = false;

  /// Unclamped open progress: 0 closed, 1 open, a hair past 1 as the spring lands.
  ValueListenable<double> get progress => _progress;

  /// True while the page is moving and the shuttle owns the shared elements.
  ValueListenable<bool> get shuttleOn => _shuttleOn;

  bool get isDragging => _dragging;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 550);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 480);

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  AnimationController? get controller => super.controller;

  @override
  void install() {
    super.install();
    _progress = _RouteProgress(controller!);
    controller!.addStatusListener(_onStatus);
    if (cardRect != null) {
      controller!.addListener(_syncCardReveal);
      _syncCardReveal();
    }
    if (_hasShuttle) _shuttleOn.value = true;
  }

  void _syncCardReveal() {
    PlayerPageSources.cardReveal.value =
        1 - _smoothstep((_progress.value - 0.02) / 0.3);
    PlayerPageSources.cardChrome.value = _progress.value <= 0.012 ? 1 : 0;
  }

  void _onStatus(AnimationStatus status) {
    if (_dragging) return;
    switch (status) {
      case AnimationStatus.completed:
        _shuttleOn.value = false;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        if (_hasShuttle) _shuttleOn.value = true;
      case AnimationStatus.dismissed:
        break;
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _shuttleOn.dispose();
    // Never leave the launching screen's elements hidden.
    PlayerPageSources.hidden.value = false;
    PlayerPageSources.cardReveal.value = 1;
    PlayerPageSources.cardChrome.value = 1;
    PlayerPageSources.activeCard = null;
    super.dispose();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Text built outside a Scaffold would otherwise show the yellow
    // double-underline of a missing Material ancestor while the page moves.
    return PlayerPageScope(
      route: this,
      child: Material(
        type: MaterialType.transparency,
        child: builder(context),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _PlayerPageTransition(route: this, page: child);
  }

  // MARK: Drag

  void beginDrag() {
    if (_dragging || controller == null || navigator == null) return;
    _dragging = true;
    _progress.manual = true;
    controller!.stop();
    navigator!.didStartUserGesture();
    if (_hasShuttle) _shuttleOn.value = true;
  }

  /// Follows the finger. [delta] is in progress units: + opens.
  void dragBy(double delta) {
    if (!_dragging) return;
    controller!.value = (controller!.value + delta).clamp(0.0, 1.0);
  }

  /// Lets go. [velocity] is progress per second, + opening.
  void endDrag(double velocity) {
    if (!_dragging) return;
    _dragging = false;
    final c = controller!;
    final value = c.value;
    final projected = value + velocity * _kReleaseProjectionSec;
    final open = velocity.abs() > _kFlingDecides
        ? velocity > 0
        : projected > _kOpenThreshold;

    final spring = _ReleaseSpring(
      from: value,
      to: open ? 1 : 0,
      velocity: velocity.clamp(-_kMaxCarriedVelocity, _kMaxCarriedVelocity),
      stiffness: open ? 230 : 280,
      dampingRatio: open ? 0.82 : 1,
    );
    final nav = navigator!;

    if (open) {
      c.animateTo(1, duration: _ReleaseSpring.duration, curve: spring);
    } else {
      nav.pop();
      c.animateBack(0, duration: _ReleaseSpring.duration, curve: spring);
    }

    void finish(AnimationStatus status) {
      if (status != AnimationStatus.completed &&
          status != AnimationStatus.dismissed) {
        return;
      }
      c.removeStatusListener(finish);
      _progress.manual = false;
      nav.didStopUserGesture();
      if (open) _shuttleOn.value = false;
    }

    if (c.isAnimating) {
      c.addStatusListener(finish);
    } else {
      finish(open ? AnimationStatus.completed : AnimationStatus.dismissed);
    }
  }
}

/// Gives a page its route: progress, shuttle state and drag handling.
class PlayerPageScope extends InheritedWidget {
  const PlayerPageScope({super.key, required this.route, required super.child});

  final PlayerPageRoute<dynamic> route;

  static PlayerPageScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlayerPageScope>();

  /// Pixels of finger travel that equal one full open/close.
  static double dragTravel(BuildContext context) =>
      MediaQuery.sizeOf(context).height * _kDragTravelFraction;

  @override
  bool updateShouldNotify(PlayerPageScope oldWidget) =>
      route != oldWidget.route;
}

class _RouteProgress extends ChangeNotifier implements ValueListenable<double> {
  _RouteProgress(this._c) {
    _c.addListener(notifyListeners);
  }

  final AnimationController _c;

  /// While dragging or settling after a release the controller value is the
  /// progress itself (the release spring is already baked into it).
  bool manual = false;

  @override
  double get value {
    final t = _c.value;
    if (manual) return t;
    if (_c.status == AnimationStatus.reverse) {
      return 1 - _closeCurve.transform(1 - t);
    }
    return _openCurve.transform(t);
  }

  @override
  void dispose() {
    _c.removeListener(notifyListeners);
    super.dispose();
  }
}

// MARK: - Transition

double _smoothstep(double x) {
  final t = x.clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

class _PlayerPageTransition extends StatelessWidget {
  const _PlayerPageTransition({required this.route, required this.page});

  final PlayerPageRoute<dynamic> route;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      final card = route.cardRect ??
          Rect.fromLTRB(
              26, size.height - 250, size.width - 26, size.height + 100);

      return AnimatedBuilder(
        animation: route.progress,
        child: page,
        builder: (context, page) {
          final e = route.progress.value;
          final t = e.clamp(0.0, 1.0);
          // The frame runs ahead of the flying cover so it already covers the
          // header the cover is heading for.
          final grow = 1 - math.pow(1 - t, 1.7).toDouble();
          final rect = Rect.lerp(card, Offset.zero & size, grow)!;
          final radius = 16 * (1 - grow);
          final dim = 0.22 * math.sin(math.pi * t);

          return Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: ColoredBox(color: Colors.black.withValues(alpha: dim)),
              ),
              ClipRRect(
                clipper: _RectClipper(rect, radius),
                clipBehavior: t >= 0.9995 ? Clip.none : Clip.antiAlias,
                // The card's own preview shows through while the page fades in,
                // and again as it fades out on close.
                child: Opacity(
                  opacity: _smoothstep((t - 0.1) / 0.45),
                  // Always present, so the page keeps its state. The page is
                  // drawn as a miniature that fills the growing frame, so it
                  // shrinks with the card instead of being cropped by it.
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translateByDouble(rect.left, rect.top, 0, 1)
                      ..scaleByDouble(rect.width / size.width,
                          rect.width / size.width, 1, 1),
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: RepaintBoundary(child: page),
                    ),
                  ),
                ),
              ),
              // From here the card draws its own glass again; both at once
              // would flash brighter just before the page is removed.
              if (t > 0.012)
                IgnorePointer(
                  child: CustomPaint(
                    painter:
                        _CardGlassPainter(rect: rect, radius: radius, t: grow),
                  ),
                ),
              if (route._hasShuttle) _ShuttleLayer(route: route, progress: e),
            ],
          );
        },
      );
    });
  }
}

class _RectClipper extends CustomClipper<RRect> {
  const _RectClipper(this.rect, this.radius);

  final Rect rect;
  final double radius;

  @override
  RRect getClip(Size size) =>
      RRect.fromRectAndRadius(rect, Radius.circular(radius));

  @override
  bool shouldReclip(_RectClipper old) =>
      old.rect != rect || old.radius != radius;
}

/// The card's glass over the growing page, thinning out as it fills the
/// screen so the hand-over from the card is invisible.
class _CardGlassPainter extends CustomPainter {
  const _CardGlassPainter({
    required this.rect,
    required this.radius,
    required this.t,
  });

  final Rect rect;
  final double radius;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 0.9995) return;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final fill = 0.1 * (1 - _smoothstep((t - 0.3) / 0.65));
    if (fill > 0.002) {
      canvas.drawRRect(
        rrect,
        Paint()..color = Colors.white.withValues(alpha: fill),
      );
    }
    final border = 0.15 * (1 - _smoothstep(t / 0.55));
    if (border > 0.002) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: border),
      );
    }
  }

  @override
  bool shouldRepaint(_CardGlassPainter old) =>
      old.rect != rect || old.radius != radius || old.t != t;
}

// MARK: - Shuttle

/// Cover, title and artist travelling between the launching screen and the
/// page header.
class _ShuttleLayer extends StatefulWidget {
  const _ShuttleLayer({required this.route, required this.progress});

  final PlayerPageRoute<dynamic> route;
  final double progress;

  @override
  State<_ShuttleLayer> createState() => _ShuttleLayerState();
}

class _ShuttleLayerState extends State<_ShuttleLayer> {
  bool _hidingSources = false;

  /// Unconstrained text widths; laying text out on every frame of the flight
  /// is the costly part of it.
  final Map<int, double> _naturalWidths = {};

  @override
  void dispose() {
    _setHiding(false);
    super.dispose();
  }

  void _setHiding(bool value) {
    if (_hidingSources == value) return;
    _hidingSources = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (PlayerPageSources.hidden.value != value) {
        PlayerPageSources.hidden.value = value;
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.route.shuttleOn,
      builder: (context, on, _) {
        if (!on) {
          _setHiding(false);
          return const SizedBox.shrink();
        }
        return _buildShuttle(context);
      },
    );
  }

  Widget _buildShuttle(BuildContext context) {
    final children = <Widget>[
      if (widget.route.shuttle != null) ..._mainChildren(context),
      ..._rowChildren(context),
    ];
    _setHiding(children.isNotEmpty);
    if (children.isEmpty) return const SizedBox.shrink();
    // No Material ancestor here: without one, Text falls back to a yellow
    // double-underlined default style.
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(fit: StackFit.expand, children: children),
      ),
    );
  }

  /// The queue card's first rows flying to their rows in the queue page.
  List<Widget> _rowChildren(BuildContext context) {
    final route = widget.route;
    final e = widget.progress;
    final viewport = Offset.zero & MediaQuery.sizeOf(context);
    const titleStyle = TextStyle(
      fontFamily: FontConstants.fontFamily,
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    final artistStyle = TextStyle(
      fontFamily: FontConstants.fontFamily,
      color: Colors.white.withValues(alpha: 0.6),
      fontSize: 13,
      height: 1.3,
    );

    final out = <Widget>[];
    for (var j = 0; j < route.rows.length && j < kPlayerPageRows; j++) {
      final row = route.rows[j];
      final from = PlayerPageSources.previewRows[j];
      final to = route.targets.rows[j];
      final artFrom = _rectOf(from.art);
      final artTo = _rectOf(to.art);
      final titleFrom = _rectOf(from.title);
      final titleTo = _rectOf(to.title);
      final artistFrom = _rectOf(from.artist);
      final artistTo = _rectOf(to.artist);
      if (artFrom == null ||
          artTo == null ||
          titleFrom == null ||
          titleTo == null ||
          artistFrom == null ||
          artistTo == null ||
          !artFrom.overlaps(viewport)) {
        continue;
      }
      if (row.image != null) {
        out.add(Positioned.fromRect(
          rect: Rect.lerp(artFrom, artTo, e)!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image(
              image: row.image!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        ));
      }
      Widget text(String value, Rect a, Rect b, TextStyle style) {
        final r = Rect.lerp(a, b, e)!;
        return Positioned(
          left: r.left,
          top: r.top,
          width: math.max(r.width, 1) + 2,
          child: Text(
            value,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        );
      }

      out.add(text(row.title, titleFrom, titleTo, titleStyle));
      out.add(text(row.artist, artistFrom, artistTo, artistStyle));
    }
    return out;
  }

  List<Widget> _mainChildren(BuildContext context) {
    final shuttle = widget.route.shuttle!;
    final targets = widget.route.targets;
    final e = widget.progress;
    final screen = MediaQuery.sizeOf(context);
    final viewport = Offset.zero & screen;

    final artTo = _rectOf(targets.art);
    final titleTo = _rectOf(targets.title);
    final artistTo = _rectOf(targets.artist);
    if (artTo == null || titleTo == null || artistTo == null) {
      return const [];
    }

    Rect? source(GlobalKey key) {
      final r = _rectOf(key);
      return (r != null && r.overlaps(viewport)) ? r : null;
    }

    // A source that is missing or scrolled out of view (the lyrics card sits
    // far down the player) has nothing to fly from: that element eases in
    // from just above its place instead, so the header is never left empty.
    const rise = Offset(0, -48);
    final artSource = source(PlayerPageSources.art);
    final titleSource = source(PlayerPageSources.title);
    final artistSource = source(PlayerPageSources.artist);
    final artFrom = artSource ?? artTo.shift(rise);
    final titleFrom = titleSource ?? titleTo.shift(rise);
    final artistFrom = artistSource ?? artistTo.shift(rise);
    double fadeIn(bool hasSource) =>
        hasSource ? 1.0 : _smoothstep((e - 0.25) / 0.55);

    final children = <Widget>[];

    if (shuttle.image != null) {
      final rect = Rect.lerp(artFrom, artTo, e)!;
      final radius = 8.0 + (10 - 8.0) * e;
      children.add(Positioned.fromRect(
        rect: rect,
        child: Opacity(
          opacity: fadeIn(artSource != null),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image(
              image: shuttle.image!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        ),
      ));
    }

    final textScaler = MediaQuery.textScalerOf(context);
    Widget text(
      String value,
      Rect from,
      Rect to,
      TextStyle? styleFrom,
      TextStyle styleTo, {
      required bool hasSource,
    }) {
      final style =
          TextStyle.lerp(styleFrom ?? styleTo, styleTo, e.clamp(0.0, 1.0))!;
      double natural(TextStyle s, double max) {
        final key = Object.hash(value, s, textScaler);
        final width = _naturalWidths.putIfAbsent(key, () {
          final p = TextPainter(
            text: TextSpan(text: value, style: s),
            maxLines: 1,
            textDirection: TextDirection.ltr,
            textScaler: textScaler,
          )..layout();
          final w = p.width;
          p.dispose();
          return w;
        });
        return math.min(width, max);
      }

      final fromStyle = styleFrom ?? styleTo;
      final wFrom = natural(fromStyle, from.width);
      final wTo = natural(styleTo, to.width);
      final heightFrom =
          (fromStyle.fontSize ?? 14) * (fromStyle.height ?? 1.25);
      final heightTo = (styleTo.fontSize ?? 14) * (styleTo.height ?? 1.25);

      // The header's text is start-aligned; the source's may be centred.
      final rectFrom = Rect.fromLTWH(
        hasSource && PlayerPageSources.centered
            ? from.center.dx - wFrom / 2
            : from.left,
        from.center.dy - heightFrom / 2,
        wFrom,
        heightFrom,
      );
      final rectTo = Rect.fromLTWH(
        to.left,
        to.center.dy - heightTo / 2,
        wTo,
        heightTo,
      );
      final rect = Rect.lerp(rectFrom, rectTo, e)!;
      return Positioned(
        left: rect.left,
        top: rect.top,
        width: math.max(rect.width, 1) + 2,
        child: Opacity(
          opacity: fadeIn(hasSource),
          child: Text(
            value,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      );
    }

    children.add(text(shuttle.title, titleFrom, titleTo,
        PlayerPageSources.titleStyle, shuttle.titleTo,
        hasSource: titleSource != null));
    children.add(text(shuttle.artist, artistFrom, artistTo,
        PlayerPageSources.artistStyle, shuttle.artistTo,
        hasSource: artistSource != null));

    return children;
  }
}
