/// Support settings sub-screen — ways to help, the monthly goal as a percent
/// and the people who already did.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:provider/provider.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/donation_service.dart';
import '../../../shared/services/support_goal_service.dart';
import '../../../shared/services/supporter_service.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/expanding_player.dart';
import '../../../shared/widgets/support_goal_card.dart';
import '../../onboarding/widgets/onboarding_kit.dart';
import '../widgets/settings_tile_builders.dart';

class SupportSettingsScreen extends StatefulWidget {
  const SupportSettingsScreen({super.key, this.refresh = true});

  /// Re-reads the supporters and goal from Remote Config when opened.
  final bool refresh;

  @override
  State<SupportSettingsScreen> createState() => _SupportSettingsScreenState();
}

class _SupportSettingsScreenState extends State<SupportSettingsScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.refresh) return;
    unawaited(SupporterService.load());
    unawaited(SupportGoalService.refreshGoal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const iconoir.NavArrowLeft(
              color: Colors.white,
              width: 28,
              height: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.settingsSupport,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Selector<AudioPlayerService, bool>(
          selector: (_, s) => s.currentSong != null,
          builder: (context, hasCurrentSong, _) =>
              ValueListenableBuilder<List<Supporter>>(
            valueListenable: SupporterService.supporters,
            builder: (context, supporters, _) => ListView(
              padding: EdgeInsets.only(
                top: 6,
                bottom: hasCurrentSong
                    ? ExpandingPlayer.getMiniPlayerPaddingHeight(context)
                    : MediaQuery.of(context).padding.bottom + 24,
              ),
              children: [
                const _SupportHero(),
                SettingsTiles.buildSectionHeader(
                    context, l10n.supportSupporters),
                if (supporters.isEmpty)
                  const _EmptySupporters()
                else
                  _SupporterNames(supporters: supporters),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _SupportHero extends StatelessWidget {
  const _SupportHero();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassSurface(
        blur: false,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary.withValues(alpha: 0.35),
                        Colors.pinkAccent.withValues(alpha: 0.25),
                      ],
                    ),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.22)),
                  ),
                  child: const Center(
                    child: iconoir.HeartSolid(
                      color: Colors.pinkAccent,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.supportAuroraTitle,
                    style: OnboardingText.rowTitle.copyWith(fontSize: 21),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(l10n.supportAuroraMessage, style: OnboardingText.rowBody),
            if (DonationService.enabled) ...[
              const SizedBox(height: 20),
              const _GoalPercent(),
              const SizedBox(height: 22),
              SupportGlassButton(
                label: l10n.buyMeACoffee,
                primary: true,
                onTap: () => unawaited(DonationService.openBuyMeACoffee()),
              ),
              const SizedBox(height: 10),
              SupportGlassButton(
                label: l10n.kofi,
                onTap: () => unawaited(DonationService.openKofi()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The monthly goal as one large percent with a glowing bar under it.
class _GoalPercent extends StatelessWidget {
  const _GoalPercent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return ValueListenableBuilder<SupportGoal>(
      valueListenable: SupportGoalService.goal,
      builder: (context, goal, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 10,
                children: [
                  _AnimatedPercent(value: goal.progress),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text(
                      l10n.supportOfMonthlyGoal,
                      style: OnboardingText.rowBody,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _PercentBar(value: goal.progress, color: primary, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedPercent extends StatelessWidget {
  const _AnimatedPercent({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '${(v * 100).round()}%',
        style: const TextStyle(
          fontFamily: FontConstants.fontFamily,
          fontSize: 46,
          height: 1,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.5,
          color: Colors.white,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// A frosted capsule filled from the left with a soft glow.
class _PercentBar extends StatelessWidget {
  const _PercentBar({
    required this.value,
    required this.color,
    required this.height,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(height),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
            duration:
                reduce ? Duration.zero : const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v <= 0 ? 0 : v.clamp(0.03, 1.0),
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height),
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.75),
                        Color.lerp(color, Colors.white, 0.35)!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Supporters ───────────────────────────────────────────────────────────────

/// Everyone who agreed to be listed, as a wrapping cloud of name pills.
class _SupporterNames extends StatelessWidget {
  const _SupporterNames({required this.supporters});

  final List<Supporter> supporters;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassSurface(
        blur: false,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final supporter in supporters)
              _NamePill(name: supporter.name, color: primary),
          ],
        ),
      ),
    );
  }
}

class _NamePill extends StatelessWidget {
  const _NamePill({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 32 - 32 - 4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.55),
                      color.withValues(alpha: 0.25),
                    ],
                  ),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: OnboardingText.rowTitle.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySupporters extends StatelessWidget {
  const _EmptySupporters();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassSurface(
        blur: false,
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            iconoir.HeartSolid(
              color: Colors.white.withValues(alpha: 0.5),
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l10n.supportNoSupportersYet,
                style: OnboardingText.rowBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
