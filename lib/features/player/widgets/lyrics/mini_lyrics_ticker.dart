/// One-line lyrics ticker: the lyrics page, card-sized.
///
/// Shows the current line with the same word sweep as the lyrics page. A line
/// too long for the space slides left as it is sung, keeping the sweep in
/// view; each new line rolls up from below as the last one leaves, and long
/// instrumental gaps show small dots.
///
/// Motion adapted from musicfy's MiniLyricsTicker
/// (https://github.com/realidkroo/musicfy, GPL-3.0).
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/constants/font_constants.dart';
import '../../../../shared/models/timed_lyrics.dart';
import '../player_page_route.dart';
import 'lyric_interlude_dots.dart';
import 'lyrics_clock.dart';
import 'lyrics_timing.dart';

/// Where the sweep is kept while a long line slides, as a fraction of the
/// width: past the middle, so a little of what is coming stays visible.
const double _kSweepKeepFraction = 0.62;

/// Time the sideways slide takes to catch up with the sweep.
const double _kSlideFollowSec = 0.32;

const double _kEdgeFade = 18;

/// Smallest a line is scaled to fit before it slides instead.
const double _kMinFitScale = 0.78;

const double kMiniLyricsTickerHeight = 28;

final Curve _lineChangeCurve = SpringCurve(stiffness: 200, dampingRatio: 0.86);

@immutable
class _Slot {
  const _Slot(this.isGap, this.index);

  final bool isGap;

  /// Line index; for a gap, the line before it (-1 for an intro).
  final int index;

  @override
  bool operator ==(Object other) =>
      other is _Slot && other.isGap == isGap && other.index == index;

  @override
  int get hashCode => Object.hash(isGap, index);
}

class MiniLyricsTicker extends StatefulWidget {
  const MiniLyricsTicker({
    super.key,
    required this.lyrics,
    required this.player,
    this.onTap,
  });

  final List<TimedLyric> lyrics;
  final AudioPlayer player;
  final VoidCallback? onTap;

  @override
  State<MiniLyricsTicker> createState() => _MiniLyricsTickerState();
}

class _MiniLyricsTickerState extends State<MiniLyricsTicker>
    with SingleTickerProviderStateMixin {
  late final LyricsClock _clock;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;

  List<LyricsInterlude> _interludes = const [];
  List<int> _sungMs = const [];
  late _Slot _slot;

  @override
  void initState() {
    super.initState();
    _clock = LyricsClock(this)..addListener(_onTick);
    _prepare();
    _attach();
  }

  @override
  void didUpdateWidget(MiniLyricsTicker old) {
    super.didUpdateWidget(old);
    if (!identical(old.lyrics, widget.lyrics)) _prepare();
    if (old.player != widget.player) {
      _detach();
      _attach();
    }
  }

  void _prepare() {
    final lyrics = widget.lyrics;
    _interludes = LyricsTiming.interludes(lyrics);
    _sungMs = [
      for (var i = 0; i < lyrics.length; i++) LyricsTiming.sungMs(lyrics, i),
    ];
    _slot = _slotAt(_clock.value);
  }

  void _attach() {
    final player = widget.player;
    void sync() => _clock.sync(
          player.position,
          playing: player.playing,
          speed: player.speed,
        );
    sync();
    _positionSub = player.positionStream.listen((_) => sync());
    _playingSub = player.playingStream.listen((_) => sync());
  }

  void _detach() {
    _positionSub?.cancel();
    _playingSub?.cancel();
  }

  _Slot _slotAt(int ms) {
    final lyrics = widget.lyrics;
    if (lyrics.isEmpty) return const _Slot(false, 0);

    for (final gap in _interludes) {
      if (ms >= gap.startMs && ms < gap.endMs) {
        return _Slot(true, gap.afterLine);
      }
    }
    var lo = 0, hi = lyrics.length - 1, index = 0;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (lyrics[mid].time.inMilliseconds <= ms) {
        index = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return _Slot(false, index);
  }

  void _onTick() {
    final slot = _slotAt(_clock.value);
    if (slot != _slot) setState(() => _slot = slot);
  }

  @override
  void dispose() {
    _detach();
    _clock.dispose();
    super.dispose();
  }

  Widget _content(_Slot slot) {
    final key = ValueKey(slot);
    if (widget.lyrics.isEmpty) return SizedBox(key: key);

    if (slot.isGap) {
      return SizedBox(
        key: key,
        height: kMiniLyricsTickerHeight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 120,
            height: kLyricsInterludeHeight,
            child: LyricInterludeDots(
              startMs: _interludeFor(slot)?.startMs ?? 0,
              endMs: _interludeFor(slot)?.endMs ?? 1,
              clock: _clock,
              accentColor: Colors.white,
              visible: true,
            ),
          ),
        ),
      );
    }

    final lyric = widget.lyrics[slot.index.clamp(0, widget.lyrics.length - 1)];
    return _TickerLine(
      key: key,
      text: lyric.text,
      startMs: lyric.time.inMilliseconds,
      sungMs: _sungMs[slot.index.clamp(0, _sungMs.length - 1)],
      clock: _clock,
    );
  }

  LyricsInterlude? _interludeFor(_Slot slot) {
    for (final gap in _interludes) {
      if (gap.afterLine == slot.index) return gap;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SizedBox(
        height: kMiniLyricsTickerHeight,
        width: double.infinity,
        child: ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 650),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.center,
              children: [...previous, if (current != null) current],
            ),
            transitionBuilder: (child, animation) {
              final incoming = child.key == ValueKey(_slot);
              // The outgoing child's animation runs 1 -> 0, so the same
              // tween carries it up and out.
              final slide = Tween<Offset>(
                begin: incoming ? const Offset(0, 1) : const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: _lineChangeCurve,
                reverseCurve: _lineChangeCurve.flipped,
              ));
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: _content(_slot),
          ),
        ),
      ),
    );
  }
}

/// The current line; slides sideways while it is sung when it does not fit.
class _TickerLine extends StatefulWidget {
  const _TickerLine({
    super.key,
    required this.text,
    required this.startMs,
    required this.sungMs,
    required this.clock,
  });

  final String text;
  final int startMs;
  final int sungMs;
  final LyricsClock clock;

  @override
  State<_TickerLine> createState() => _TickerLineState();
}

class _TickerLineState extends State<_TickerLine> {
  static const TextStyle _style = TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  final ValueNotifier<double> _scroll = ValueNotifier<double>(0);
  double _textWidth = 0;
  double _viewport = 0;
  int _lastMs = -1;
  bool _primed = false;

  /// A line only a little too wide is scaled down to fit instead of sliding.
  bool get _shrinks =>
      _textWidth > _viewport && _viewport / _textWidth >= _kMinFitScale;

  @override
  void initState() {
    super.initState();
    widget.clock.addListener(_follow);
  }

  @override
  void dispose() {
    widget.clock.removeListener(_follow);
    _scroll.dispose();
    super.dispose();
  }

  void _measure(double viewport, TextScaler scaler) {
    _viewport = viewport;
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: _style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    _textWidth = painter.width;
    painter.dispose();
  }

  /// Critically damped follow of the sweep, so a seek still glides. The line
  /// rests a fade-width inside the edges at both ends, so its first and last
  /// words are never dimmed.
  void _follow() {
    final overflow = _shrinks ? 0.0 : math.max(0.0, _textWidth - _viewport);
    if (overflow == 0) {
      if (_scroll.value != 0) _scroll.value = 0;
      return;
    }
    final now = widget.clock.value;
    final dt = _lastMs < 0 ? 0.016 : ((now - _lastMs) / 1000).clamp(0.0, 0.064);
    final first = _lastMs < 0;
    _lastMs = now;

    final progress =
        ((now - widget.startMs) / math.max(1, widget.sungMs)).clamp(0.0, 1.0);
    final along = (progress * _textWidth - _viewport * _kSweepKeepFraction)
        .clamp(0.0, overflow);
    final target = -_kEdgeFade + along / overflow * (overflow + 2 * _kEdgeFade);
    if (first) {
      _scroll.value = target;
      return;
    }
    final k = 1 - math.exp(-dt / (_kSlideFollowSec / 3));
    _scroll.value += (target - _scroll.value) * k;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(builder: (context, constraints) {
      _measure(constraints.maxWidth, scaler);
      if (_shrinks) {
        return Align(
          child: SizedBox(
            width: constraints.maxWidth,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(widget.text,
                  style: _style, maxLines: 1, softWrap: false),
            ),
          ),
        );
      }
      final overflowing = _textWidth > constraints.maxWidth;
      final overflow = math.max(0.0, _textWidth - constraints.maxWidth);
      if (overflowing && !_primed) {
        // Place the line even when the clock is not ticking (paused).
        _primed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _follow();
        });
      }

      final line = ValueListenableBuilder<double>(
        valueListenable: _scroll,
        builder: (context, scroll, child) {
          final slid = OverflowBox(
            alignment: overflowing ? Alignment.centerLeft : Alignment.center,
            minWidth: 0,
            maxWidth: double.infinity,
            child:
                Transform.translate(offset: Offset(-scroll, 0), child: child),
          );
          if (!overflowing) return slid;
          // An edge only fades once the line has moved past it, so the first
          // and last words are fully readable at rest.
          final left = (scroll / _kEdgeFade).clamp(0.0, 1.0);
          final right =
              ((overflow + _kEdgeFade - scroll) / _kEdgeFade).clamp(0.0, 1.0);
          return ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 1 - left),
                Colors.white,
                Colors.white,
                Colors.white.withValues(alpha: 1 - right),
              ],
              stops: [
                0,
                _kEdgeFade / bounds.width,
                1 - _kEdgeFade / bounds.width,
                1,
              ],
            ).createShader(bounds),
            child: slid,
          );
        },
        child: Text(widget.text, style: _style, maxLines: 1, softWrap: false),
      );

      return Align(child: line);
    });
  }
}
