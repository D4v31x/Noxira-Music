import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/font_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../services/donation_service.dart';
import '../services/support_goal_service.dart';

/// The monthly support goal for settings and other persistent support surfaces.
/// Uses the same cached network goal as the home app-bar banner.
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
    final scheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _entry, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic)),
        child: ValueListenableBuilder<SupportGoal>(
          valueListenable: SupportGoalService.goal,
          builder: (context, goal, _) => Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.supportNoxiraTitle,
                        style: const TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.favorite_outline_rounded,
                        color: scheme.primary, size: 21),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 5,
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
                            child: ColoredBox(color: scheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.supportGoalProgress(goal.format(goal.raised), goal.format(goal.goal))}  ·  ${(goal.progress * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: () =>
                        DonationService.showDonationDialog(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21)),
                    ),
                    child: Text(l10n.supportButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
