import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/font_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../services/donation_service.dart';
import '../services/support_goal_service.dart';
import 'glassmorphic_dialog.dart';

/// The monthly goal as a thin accent bar with "€12 of €50 this month · 24%"
/// underneath. Shared by the settings card and the home app-bar banner.
class SupportGoalProgress extends StatelessWidget {
  const SupportGoalProgress({
    super.key,
    this.centered = false,
    this.compact = false,
  });

  final bool centered;

  /// A hairline bar and smaller caption, for places that should stay quiet.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return ValueListenableBuilder<SupportGoal>(
      valueListenable: SupportGoalService.goal,
      builder: (context, goal, _) => Column(
        crossAxisAlignment:
            centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: compact ? 3 : 6,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: Colors.white.withValues(alpha: 0.14)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: goal.progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: ColoredBox(color: primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.supportGoalProgress(goal.format(goal.raised), goal.format(goal.goal))}  ·  ${(goal.progress * 100).round()}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white.withValues(alpha: compact ? 0.55 : 0.6),
              fontSize: compact ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Button in the shape and feel of the app's glass dialogs: [primary] is the
/// accent action, the other is a frosted secondary one.
class SupportGlassButton extends StatelessWidget {
  const SupportGlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(14);

    return Material(
      color: primary
          ? scheme.primary.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: primary
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: primary ? scheme.onPrimary : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Title row shared by both surfaces: the title and a heart in the accent.
class SupportGoalTitle extends StatelessWidget {
  const SupportGoalTitle({super.key, this.fontSize = 19});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.supportNoxiraTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.favorite_rounded, color: primary, size: 20),
      ],
    );
  }
}

/// The monthly support goal for settings: a frosted glass card (solid on
/// low-end devices) with the goal bar and a Support button.
class SupportGoalCard extends StatefulWidget {
  const SupportGoalCard({super.key});

  @override
  State<SupportGoalCard> createState() => _SupportGoalCardState();
}

class _SupportGoalCardState extends State<SupportGoalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  @override
  void initState() {
    super.initState();
    unawaited(SupportGoalService.refreshGoal());
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: CurvedAnimation(parent: _entry, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GlassDialogSurface(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SupportGoalTitle(),
                const SizedBox(height: 14),
                const SupportGoalProgress(),
                const SizedBox(height: 16),
                SupportGlassButton(
                  primary: true,
                  label: l10n.supportButton,
                  onTap: () => DonationService.showDonationDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
