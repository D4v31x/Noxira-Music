import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../splash/animated_logo.dart';

enum _PullState { idle, pulling, armed, refreshing }

/// Pull down at the top of the page to run [onRefresh].
///
/// The page follows your finger down like a curtain, and the Noxira wordmark
/// is drawn stroke by stroke in the gap it opens. Pull far enough and the
/// letters are complete; let go and they flood with white while the page
/// settles back and [onRefresh] reports its progress and result (the home
/// screen shows these in the app bar). Letting go early un-draws the wordmark
/// as the page glides back.
class LibraryPullToRefresh extends StatefulWidget {
  const LibraryPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.topInset = 0,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  /// Status bar height, so the wordmark is drawn below it.
  final double topInset;

  @override
  State<LibraryPullToRefresh> createState() => _LibraryPullToRefreshState();
}

class _LibraryPullToRefreshState extends State<LibraryPullToRefresh>
    with TickerProviderStateMixin {
  /// Raw finger travel (logical px) needed to trigger a refresh.
  static const double _threshold = 120;
  static const double _maxPull = 180;

  /// Share of the wordmark animation used while pulling: strokes finish
  /// drawing here, and the fill (the "go" moment) plays on release.
  static const double _drawnAt = 0.6;

  static const double _logoWidth = 190;

  final ValueNotifier<double> _pull = ValueNotifier(0);
  late final AnimationController _settle; // pull distance, in px
  late final AnimationController _logo; // wordmark timeline, 0..1
  late final AnimationController _fade; // wordmark opacity after release
  _PullState _state = _PullState.idle;

  @override
  void initState() {
    super.initState();
    unawaited(AnimatedLogo.preload());
    _settle = AnimationController(vsync: this, upperBound: _maxPull)
      ..addListener(() => _pull.value = _settle.value);
    _logo = AnimationController(vsync: this, duration: AnimatedLogo.duration);
    _fade = AnimationController(
        vsync: this, value: 1, duration: const Duration(milliseconds: 320));
    _pull.addListener(_syncLogoToPull);
  }

  @override
  void dispose() {
    _pull.removeListener(_syncLogoToPull);
    _settle.dispose();
    _logo.dispose();
    _fade.dispose();
    _pull.dispose();
    super.dispose();
  }

  void _syncLogoToPull() {
    if (_state == _PullState.refreshing) return;
    _logo.value = (_pull.value / _threshold).clamp(0.0, 1.0) * _drawnAt;
  }

  void _setState(_PullState state) {
    if (_state == state) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setState(state);
      });
      return;
    }
    setState(() => _state = state);
  }

  /// Glides the page back from where it is now to [target].
  void _animatePullTo(double target, {int millis = 340}) {
    _settle
      ..stop()
      ..value = _pull.value;
    unawaited(_settle.animateTo(
      target,
      duration: Duration(milliseconds: millis),
      curve: Curves.easeInOutCubic,
    ));
  }

  void _setPull(double value) {
    if (_state == _PullState.refreshing) return;
    // Scroll notifications can arrive while the framework is laying out
    // (e.g. a list changed height); the listeners below rebuild widgets, so
    // those updates have to wait until the frame is done.
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setPull(value);
      });
      return;
    }
    _settle.stop();
    final clamped = value.clamp(0.0, _maxPull);
    _pull.value = clamped;
    if (clamped <= 0) {
      _setState(_PullState.idle);
    } else if (clamped >= _threshold) {
      if (_state != _PullState.armed) {
        unawaited(HapticFeedback.selectionClick());
        _setState(_PullState.armed);
      }
    } else {
      _setState(_PullState.pulling);
    }
  }

  bool _onNotification(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical || _state == _PullState.refreshing) {
      return false;
    }

    final m = n.metrics;
    final atTop = m.pixels <= m.minScrollExtent + 0.5;

    if (n is OverscrollNotification && n.overscroll < 0) {
      // Clamping physics (Android): the drag past the top arrives as overscroll.
      if (n.dragDetails != null) _setPull(_pull.value - n.overscroll);
    } else if (n is ScrollUpdateNotification) {
      if (m.pixels < m.minScrollExtent - 0.5) {
        // Bouncing physics (iOS): the position itself goes negative.
        _setPull(m.minScrollExtent - m.pixels);
      } else if (_pull.value > 0 &&
          n.scrollDelta != null &&
          n.scrollDelta! > 0) {
        // Pushing back up through the pull releases it.
        _setPull(_pull.value - n.scrollDelta!);
      } else if (!atTop && _pull.value > 0) {
        _setPull(0);
      }
    } else if (n is ScrollEndNotification) {
      _release();
    }
    return false;
  }

  /// Finger lifted: refresh if armed, otherwise glide back up.
  void _release() {
    if (_state == _PullState.armed) {
      unawaited(_refresh());
    } else if (_state == _PullState.pulling) {
      _setState(_PullState.idle);
      _animatePullTo(0);
    }
  }

  Future<void> _refresh() async {
    _setState(_PullState.refreshing);
    unawaited(HapticFeedback.mediumImpact());
    _fade.value = 1;
    _animatePullTo(0, millis: 380);

    // The wordmark fills in as the page settles; hold it long enough to read
    // as a deliberate "go", then fade it away.
    final fill = _logo.animateTo(1,
        duration: const Duration(milliseconds: 650), curve: Curves.easeOut);
    try {
      await Future.wait([widget.onRefresh(), fill.orCancel]);
    } catch (_) {
      // onRefresh reports its own errors.
    }
    if (!mounted) return;
    await _fade.animateTo(0);
    if (!mounted) return;
    _logo.value = 0;
    _fade.value = 1;
    _setState(_PullState.idle);
  }

  @override
  Widget build(BuildContext context) {
    final maxShift = widget.topInset + 92;

    return Stack(
      children: [
        // The wordmark sits behind the page, revealed by the gap.
        Positioned(
          top: widget.topInset + 18,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ValueListenableBuilder<double>(
              valueListenable: _pull,
              builder: (context, pull, child) {
                final reveal = (pull / (_threshold * 0.55)).clamp(0.0, 1.0);
                return Opacity(opacity: reveal, child: child);
              },
              child: FadeTransition(
                opacity: _fade,
                child: Center(
                  child: AnimatedLogo(
                    animation: _logo,
                    width: _logoWidth,
                  ),
                ),
              ),
            ),
          ),
        ),
        Listener(
          onPointerUp: (_) => _release(),
          onPointerCancel: (_) => _release(),
          child: NotificationListener<ScrollNotification>(
            onNotification: _onNotification,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(overscroll: false, scrollbars: false),
              child: ValueListenableBuilder<double>(
                valueListenable: _pull,
                builder: (context, pull, child) {
                  // Rubber-band: the page travels less than the finger.
                  final t = (pull / _threshold).clamp(0.0, 1.5);
                  final shift = maxShift * Curves.easeOut.transform(t / 1.5);
                  return Transform.translate(
                    offset: Offset(0, shift),
                    child: child,
                  );
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
