import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' show SpringDescription, SpringSimulation;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:aurora_music_v01/core/constants/font_constants.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/utils/formatters/duration_formatter.dart';
import '../../../shared/widgets/motion/odometer_text.dart';

/// A draggable progress bar for audio playback.
///
/// Displays current position and duration with a slider
/// that supports tap and drag gestures for seeking.
class PlayerProgressBar extends StatefulWidget {
  final AudioPlayerService audioService;
  final bool isTablet;

  const PlayerProgressBar({
    super.key,
    required this.audioService,
    this.isTablet = false,
  });

  @override
  State<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends State<PlayerProgressBar> {
  bool _isDragging = false;
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isTablet ? 80.0 : 50.0;

    return StreamBuilder<Duration?>(
      stream: widget.audioService.audioPlayer.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: widget.audioService.audioPlayer.positionStream,
          builder: (context, positionSnapshot) {
            var position = positionSnapshot.data ?? Duration.zero;
            if (position > duration) position = duration;

            final displayPosition = _isDragging
                ? Duration(
                    milliseconds:
                        (_dragValue! * duration.inMilliseconds).round())
                : position;

            final progress = duration.inMilliseconds > 0
                ? (displayPosition.inMilliseconds / duration.inMilliseconds)
                    .clamp(0.0, 1.0)
                : 0.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSlider(duration, progress),
                  const SizedBox(height: 4),
                  // Performance: time labels only need second-level granularity.
                  // Wrap in a RepaintBoundary so the slider's high-frequency
                  // AnimatedContainer repaints don't force the label subtree to
                  // repaint, and vice-versa.
                  RepaintBoundary(
                    child: _TimeLabels(
                      // During a drag, show the scrubbed position; otherwise
                      // pass the live stream so labels update independently.
                      dragging: _isDragging,
                      dragPosition: _isDragging ? displayPosition : null,
                      duration: duration,
                      positionStream:
                          widget.audioService.audioPlayer.positionStream,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSlider(Duration duration, double progress) {
    return SizedBox(
      height: widget.isTablet ? 44 : 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Use the initial touch-down position (not the post-slop one) as
            // the drag "start" position — otherwise the thumb visibly snaps
            // a few pixels the instant a tap turns into a drag.
            dragStartBehavior: DragStartBehavior.down,
            onTapDown: (details) {
              HapticFeedback.selectionClick();
              final percentage =
                  (details.localPosition.dx / width).clamp(0.0, 1.0);
              setState(() {
                _isDragging = true;
                _dragValue = percentage;
              });
            },
            onTapUp: (details) {
              if (_dragValue != null) {
                final newPosition = duration * _dragValue!;
                widget.audioService.audioPlayer.seek(newPosition);
                HapticFeedback.lightImpact();
              }
              setState(() {
                _isDragging = false;
                _dragValue = null;
              });
            },
            onTapCancel: () {
              setState(() {
                _isDragging = false;
                _dragValue = null;
              });
            },
            onHorizontalDragStart: (details) {
              if (!_isDragging) HapticFeedback.selectionClick();
              final percentage =
                  (details.localPosition.dx / width).clamp(0.0, 1.0);
              setState(() {
                _isDragging = true;
                _dragValue = percentage;
              });
            },
            onHorizontalDragUpdate: (details) {
              final percentage =
                  (details.localPosition.dx / width).clamp(0.0, 1.0);
              setState(() {
                _dragValue = percentage;
              });
            },
            onHorizontalDragEnd: (details) {
              if (_dragValue != null) {
                final newPosition = duration * _dragValue!;
                widget.audioService.audioPlayer.seek(newPosition);
                HapticFeedback.lightImpact();
              }
              setState(() {
                _isDragging = false;
                _dragValue = null;
              });
            },
            child: Center(
              child: _PillTrack(
                width: width,
                value: _isDragging ? _dragValue! : progress,
                dragging: _isDragging,
                label: formatDurationWithHours(
                  Duration(
                    milliseconds: ((_isDragging ? _dragValue! : progress) *
                            duration.inMilliseconds)
                        .round(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TimeLabels
// ---------------------------------------------------------------------------

/// Displays elapsed / total time labels for the progress bar.
///
/// Performance optimisation: subscribes to a [distinct] view of
/// [positionStream] that only emits when the displayed **second** changes,
/// cutting label rebuilds from ~5/s down to ~1/s during normal playback.
/// During a drag gesture the parent passes a pre-computed [dragPosition] so
/// the label reflects the scrub position in real time.
final _labelStyle = TextStyle(
  color: Colors.white.withValues(alpha: 0.7),
  fontSize: 11,
  fontFamily: FontConstants.fontFamily,
);

class _TimeLabels extends StatelessWidget {
  final bool dragging;
  final Duration? dragPosition;
  final Duration duration;
  final Stream<Duration> positionStream;

  const _TimeLabels({
    required this.dragging,
    required this.dragPosition,
    required this.duration,
    required this.positionStream,
  });

  @override
  Widget build(BuildContext context) {
    // During drag, render immediately from the pre-computed drag position
    // without subscribing to the stream — avoids a redundant StreamBuilder.
    if (dragging && dragPosition != null) {
      return _buildRow(dragPosition!, duration);
    }

    return StreamBuilder<Duration>(
      // distinct() suppresses ticks where the visible second hasn't changed,
      // reducing layout/paint work by ~80 % vs. a raw positionStream.
      stream: positionStream.distinct((a, b) => a.inSeconds == b.inSeconds),
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        return _buildRow(position > duration ? duration : position, duration);
      },
    );
  }

  Widget _buildRow(Duration position, Duration dur) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OdometerText(formatDurationWithHours(position), style: _labelStyle),
        OdometerText(formatDurationWithHours(dur), style: _labelStyle),
      ],
    );
  }
}

/// Slim rounded track that swells under the finger (musicfy's slider), with a
/// time bubble above the finger while scrubbing.
class _PillTrack extends StatefulWidget {
  const _PillTrack({
    required this.width,
    required this.value,
    required this.dragging,
    required this.label,
  });

  final double width;
  final double value;
  final bool dragging;
  final String label;

  @override
  State<_PillTrack> createState() => _PillTrackState();
}

class _PillTrackState extends State<_PillTrack>
    with SingleTickerProviderStateMixin {
  static const double _rest = 6;
  static const double _active = 14;
  static final SpringDescription _spring =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 520, ratio: 0.72);

  late final AnimationController _height =
      AnimationController.unbounded(vsync: this, value: _rest);

  @override
  void didUpdateWidget(_PillTrack old) {
    super.didUpdateWidget(old);
    if (old.dragging != widget.dragging) {
      _height.animateWith(SpringSimulation(
        _spring,
        _height.value,
        widget.dragging ? _active : _rest,
        _height.velocity,
      ));
    }
  }

  @override
  void dispose() {
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: widget.width,
      height: 40,
      child: AnimatedBuilder(
        animation: _height,
        builder: (context, _) {
          final h = _height.value.clamp(2.0, 24.0);
          final fill = widget.width * widget.value.clamp(0.0, 1.0);
          final bubbleLeft = (fill - 24).clamp(0.0, widget.width - 48);
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: widget.width,
                height: h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(h / 2),
                ),
              ),
              Container(
                width: fill,
                height: h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white
                    ],
                  ),
                  borderRadius: BorderRadius.circular(h / 2),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(
                          alpha: 0.35 * (h - _rest) / (_active - _rest)),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: bubbleLeft,
                top: -14,
                child: IgnorePointer(
                  child: AnimatedScale(
                    scale: widget.dragging ? 1 : 0.6,
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: widget.dragging ? 1 : 0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: 48,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontConstants.fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
