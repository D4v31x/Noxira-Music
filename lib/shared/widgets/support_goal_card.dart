import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/font_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../services/donation_service.dart';
import '../services/support_goal_service.dart';
import 'adaptive_blur.dart';
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

  /// A frosted pill bar with a smaller caption, for the app-bar banner where
  /// there is no card around it.
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
          if (compact)
            _GlassBar(progress: goal.progress, accent: primary)
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
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
          SizedBox(height: compact ? 10 : 8),
          Text(
            '${l10n.supportGoalProgress(goal.format(goal.raised), goal.format(goal.goal))}  ·  ${(goal.progress * 100).round()}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white.withValues(alpha: compact ? 0.7 : 0.6),
              fontSize: compact ? 12.5 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// A frosted capsule with the accent filling it from the left.
class _GlassBar extends StatelessWidget {
  const _GlassBar({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const height = 12.0;
    final lowEnd = isBlurDisabled(context);
    final track = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: lowEnd ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(height),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.04, 1.0),
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(height),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: AdaptiveBackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: track,
        ),
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
    this.pill = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  /// A smaller fully-rounded frosted button, for use without a card behind it.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(pill ? 24 : 14);

    final button = Material(
      color: primary
          ? scheme.primary.withValues(alpha: pill ? 0.78 : 0.9)
          : Colors.white.withValues(alpha: pill ? 0.14 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: primary
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.22),
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: pill ? 10 : 12,
            horizontal: pill ? 22 : 0,
          ),
          child: Center(
            widthFactor: pill ? 1 : null,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: primary ? scheme.onPrimary : Colors.white,
                fontSize: pill ? 14 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );

    if (!pill) return button;
    return ClipRRect(
      borderRadius: radius,
      child: AdaptiveBackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: button,
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
