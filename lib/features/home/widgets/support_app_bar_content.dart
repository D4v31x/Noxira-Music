import 'package:flutter/material.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/support_goal_service.dart';

/// "Support Noxira!" banner shown on the home app bar from time to time:
/// a monthly goal bar with Support and Close buttons underneath.
class SupportAppBarContent extends StatefulWidget {
  const SupportAppBarContent({
    super.key,
    required this.onSupport,
    required this.onClose,
  });

  final VoidCallback onSupport;
  final VoidCallback onClose;

  @override
  State<SupportAppBarContent> createState() => _SupportAppBarContentState();
}

class _SupportAppBarContentState extends State<SupportAppBarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Future<void> _then(VoidCallback callback) async {
    await _entry.reverse();
    if (mounted) callback();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Align(
            alignment: const Alignment(0, 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.supportNoxiraTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ValueListenableBuilder<SupportGoal>(
                      valueListenable: SupportGoalService.goal,
                      builder: (context, goal, _) => _GoalBar(goal: goal),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _BannerButton(
                            label: l10n.supportButton,
                            background: primary.withValues(alpha: 0.85),
                            foreground: onPrimary,
                            onTap: () => _then(widget.onSupport),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _BannerButton(
                            label: l10n.close,
                            background: Colors.white.withValues(alpha: 0.1),
                            foreground: Colors.white,
                            onTap: () => _then(widget.onClose),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Same shape and feel as the buttons in the app's glass dialogs.
class _BannerButton extends StatelessWidget {
  const _BannerButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: foreground,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A thin white progress line, like the app's other progress indicators.
class _GoalBar extends StatelessWidget {
  const _GoalBar({required this.goal});

  final SupportGoal goal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = (goal.progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: Colors.white.withValues(alpha: 0.15)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: goal.progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: const ColoredBox(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.supportGoalProgress(goal.format(goal.raised), goal.format(goal.goal))}  ·  $percent%',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
