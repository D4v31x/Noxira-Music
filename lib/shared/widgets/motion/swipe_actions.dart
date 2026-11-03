import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../../core/constants/font_constants.dart';

/// Swipe a row sideways to reveal a quick action, then spring back (musicfy's
/// SwipeActions). The row never leaves the list.
class SwipeActions extends StatefulWidget {
  const SwipeActions({
    super.key,
    required this.child,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.rightIcon = Icons.playlist_play_rounded,
    this.leftIcon = Icons.queue_music_rounded,
    this.rightLabel,
    this.leftLabel,
    this.borderRadius = 10,
  });

  final Widget child;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeLeft;
  final IconData rightIcon;
  final IconData leftIcon;
  final String? rightLabel;
  final String? leftLabel;
  final double borderRadius;

  @override
  State<SwipeActions> createState() => _SwipeActionsState();
}

class _SwipeActionsState extends State<SwipeActions>
    with SingleTickerProviderStateMixin {
  static const double _threshold = 72;
  static const double _maxDrag = 120;
  static final SpringDescription _spring =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 500, ratio: 0.6);

  late final AnimationController _dx =
      AnimationController.unbounded(vsync: this);
  bool _armed = false;

  bool get _canRight => widget.onSwipeRight != null;
  bool get _canLeft => widget.onSwipeLeft != null;

  void _update(DragUpdateDetails d) {
    _dx.stop();
    var next =
        _dx.value + d.delta.dx * (1 - (_dx.value.abs() / (_maxDrag * 1.5)));
    if (!_canRight && next > 0) next = 0;
    if (!_canLeft && next < 0) next = 0;
    _dx.value = next.clamp(-_maxDrag, _maxDrag);
    final armed = _dx.value.abs() >= _threshold;
    if (armed != _armed) {
      _armed = armed;
      if (armed) HapticFeedback.selectionClick();
    }
  }

  void _end(DragEndDetails d) {
    if (_armed) {
      HapticFeedback.mediumImpact();
      (_dx.value > 0 ? widget.onSwipeRight : widget.onSwipeLeft)?.call();
    }
    _armed = false;
    _dx.animateWith(
        SpringSimulation(_spring, _dx.value, 0, d.velocity.pixelsPerSecond.dx));
  }

  @override
  void dispose() {
    _dx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _update,
      onHorizontalDragEnd: _end,
      child: AnimatedBuilder(
        animation: _dx,
        child: widget.child,
        builder: (context, child) {
          final dx = _dx.value;
          final p = (dx.abs() / _threshold).clamp(0.0, 1.0);
          final right = dx > 0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: p,
                    child: Container(
                      color: scheme.primary.withValues(alpha: 0.22),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment:
                          right ? Alignment.centerLeft : Alignment.centerRight,
                      child: Transform.scale(
                        scale:
                            0.6 + 0.4 * p + (dx.abs() >= _threshold ? 0.15 : 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(right ? widget.rightIcon : widget.leftIcon,
                                color: scheme.primary, size: 24),
                            if ((right
                                    ? widget.rightLabel
                                    : widget.leftLabel) !=
                                null) ...[
                              const SizedBox(width: 8),
                              Text(
                                (right ? widget.rightLabel : widget.leftLabel)!,
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(offset: Offset(dx, 0), child: child),
              ],
            ),
          );
        },
      ),
    );
  }
}
