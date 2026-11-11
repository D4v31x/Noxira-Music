import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/performance_mode_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/services/device_performance_service.dart';
import '../widgets/onboarding_kit.dart';

/// Lets tests start from a fresh run (see [_ThemeSelectionPageState]).
@visibleForTesting
void resetRecommendationForTests() =>
    _ThemeSelectionPageState._recommendationApplied = false;

/// Pick the look. A small player preview changes colour as you choose, and the
/// interface and background choices say which option suits this device.
class ThemeSelectionPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const ThemeSelectionPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  /// Applied once per run, so coming back to this step never overrides what
  /// the user chose in the meantime.
  static bool _recommendationApplied = false;

  /// What the device's specs call for, independent of what is selected now.
  PerformanceLevel? _recommended;

  @override
  void initState() {
    super.initState();
    unawaited(_detect());
  }

  Future<void> _detect() async {
    final level = await DevicePerformanceService.instance.getPerformanceLevel();
    if (!mounted) return;
    if (!_recommendationApplied) {
      _recommendationApplied = true;
      // A device short of the top tier starts on the plain background; the
      // heavier artwork background stays one tap away.
      final theme = Provider.of<ThemeProvider>(context, listen: false);
      if (level != PerformanceLevel.high &&
          theme.highEndBackground == HighEndBackground.blurredArtwork) {
        unawaited(theme.setHighEndBackground(HighEndBackground.solid));
      }
    }
    setState(() => _recommended = level);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Provider.of<ThemeProvider>(context);
    final onContinue = widget.onContinue;
    final onBack = widget.onBack;

    return StepScaffold(
      title: l10n.onboardingThemeTitle,
      lead: l10n.onboardingThemeSubtitle,
      primaryLabel: l10n.continueButton,
      onPrimary: onContinue,
      onBack: onBack,
      backLabel: l10n.back,
      children: [
        const _PlayerPreview(),
        const SizedBox(height: 14),
        GlassRow(
          order: 3,
          title: l10n.onboardingDynamicColors,
          body: l10n.onboardingDynamicColorsDesc,
          onTap: theme.toggleDynamicColor,
          trailing: _Toggle(value: theme.useDynamicColor),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: theme.useDynamicColor
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: GlassPanel(
                    order: 1,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(l10n.accentColor, style: OnboardingText.rowTitle),
                        const SizedBox(height: 4),
                        Text(l10n.accentColorDesc,
                            textAlign: TextAlign.center,
                            style: OnboardingText.rowBody),
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (var i = 0;
                                i < AppThemePreset.presets.length;
                                i++)
                              _Swatch(
                                preset: AppThemePreset.presets[i],
                                selected: theme.customSeedColor.toARGB32() ==
                                    AppThemePreset.presets[i].seedColor
                                        .toARGB32(),
                                onTap: () => theme.setPreset(i),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        if (_recommended != null) ...[
          const SizedBox(height: 14),
          _InterfaceStyle(recommended: _recommended!),
          _BackgroundStyle(theme: theme, recommended: _recommended!),
        ],
      ],
    );
  }
}

/// A miniature now-playing card that always shows the current accent; its
/// progress bar keeps moving so it reads as a live player.
class _PlayerPreview extends StatefulWidget {
  const _PlayerPreview();

  @override
  State<_PlayerPreview> createState() => _PlayerPreviewState();
}

class _PlayerPreviewState extends State<_PlayerPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _progress
        ..stop()
        ..value = 0.42;
    } else if (!_progress.isAnimating) {
      unawaited(_progress.repeat());
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GlassPanel(
      order: 2,
      padding: const EdgeInsets.all(16),
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: scheme.primary),
        duration: const Duration(milliseconds: 420),
        builder: (context, accent, _) {
          final primary = accent ?? scheme.primary;
          return Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.music_note_rounded, color: primary, size: 34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Bar(width: 120, height: 12, alpha: 0.9),
                    const SizedBox(height: 8),
                    const _Bar(width: 80, height: 9, alpha: 0.4),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        height: 4,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                                color: Colors.white.withValues(alpha: 0.16)),
                            AnimatedBuilder(
                              animation: _progress,
                              builder: (context, _) => FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progress.value,
                                child: ColoredBox(color: primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(color: primary, shape: BoxShape.circle),
                child: Icon(Icons.play_arrow_rounded,
                    color: scheme.onPrimary, size: 28),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height, required this.alpha});

  final double width;
  final double height;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 54,
      height: 32,
      padding: const EdgeInsets.all(4),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value ? Colors.white : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? Colors.black : Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: preset.label(AppLocalizations.of(context)),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: preset.seedColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
          child: AnimatedScale(
            scale: selected ? 1 : 0,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            child: const Icon(Icons.check_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// High-end (glass and animation) or lightweight (solid) interface. Starts on
/// what the device was detected as; the other one is offered as a trial.
class _InterfaceStyle extends StatelessWidget {
  const _InterfaceStyle({required this.recommended});

  final PerformanceLevel recommended;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final perf = Provider.of<PerformanceModeProvider>(context);
    final labels = [l10n.onboardingUiHighEnd, l10n.onboardingUiLowEnd];
    final recommendedIndex = recommended == PerformanceLevel.low ? 1 : 0;
    final selected = perf.isLowEndDevice ? 1 : 0;

    void choose(int i) {
      if (i == 1) {
        unawaited(perf.setPerformanceMode(PerformanceLevel.low));
      } else if (perf.isLowEndDevice) {
        // A device that was detected as weak gets the gentlest glass level.
        unawaited(perf.setPerformanceMode(
          recommended == PerformanceLevel.low
              ? PerformanceLevel.medium
              : recommended,
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _ChoicePanel(
        order: 4,
        title: l10n.onboardingUiModeTitle,
        body: l10n.onboardingUiModeDesc,
        options: labels,
        selected: selected,
        recommendedIndex: recommendedIndex,
        notes: [
          selected == recommendedIndex
              ? l10n.onboardingRecommendedForDevice
              : l10n.onboardingTryNote(
                  labels[recommendedIndex], labels[selected]),
        ],
        onChoose: choose,
      ),
    );
  }
}

/// Artwork or solid background for the high-end interface. The lightweight
/// interface always uses the plain background, so there is nothing to choose.
class _BackgroundStyle extends StatelessWidget {
  const _BackgroundStyle({required this.theme, required this.recommended});

  final ThemeProvider theme;
  final PerformanceLevel recommended;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final perf = Provider.of<PerformanceModeProvider>(context);
    final show = !perf.isLowEndDevice && perf.shouldEnableBlur;

    return AnimatedSize(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child:
          show ? _panel(context, l10n) : const SizedBox(width: double.infinity),
    );
  }

  Widget _panel(BuildContext context, AppLocalizations l10n) {
    final labels = [l10n.backgroundBlurredArtwork, l10n.backgroundSolid];
    final recommendedIndex = recommended == PerformanceLevel.high ? 0 : 1;
    final selected =
        theme.highEndBackground == HighEndBackground.blurredArtwork ? 0 : 1;

    return _ChoicePanel(
      order: 5,
      title: l10n.backgroundHighEndStyle,
      body: l10n.backgroundHighEndStyleDesc,
      options: labels,
      selected: selected,
      recommendedIndex: recommendedIndex,
      notes: [
        if (selected == recommendedIndex)
          l10n.onboardingRecommendedForDevice
        else
          l10n.onboardingTryNote(labels[recommendedIndex], labels[selected]),
        // Artwork is the heaviest background: say so on devices it suits less.
        if (selected == 0 && recommendedIndex == 1)
          l10n.onboardingHeaviestNote(labels[0]),
      ],
      onChoose: (i) => unawaited(theme.setHighEndBackground(
          i == 0 ? HighEndBackground.blurredArtwork : HighEndBackground.solid)),
    );
  }
}

/// A glass panel with a two-way segmented choice. The option that suits the
/// device carries a "Recommended" tag, and [notes] explain the selection.
class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.order,
    required this.title,
    required this.body,
    required this.options,
    required this.selected,
    required this.recommendedIndex,
    required this.notes,
    required this.onChoose,
  });

  final int order;
  final String title;
  final String body;
  final List<String> options;
  final int selected;
  final int recommendedIndex;
  final List<String> notes;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GlassPanel(
      order: order,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(title, style: OnboardingText.rowTitle),
          const SizedBox(height: 4),
          Text(body,
              textAlign: TextAlign.center, style: OnboardingText.rowBody),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                for (var i = 0; i < options.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected == i,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChoose(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 6),
                          decoration: BoxDecoration(
                            color: selected == i
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                options[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: selected == i
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              if (i == recommendedIndex) ...[
                                const SizedBox(height: 2),
                                Text(
                                  l10n.onboardingRecommendedBadge,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FontConstants.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: selected == i
                                        ? Colors.black54
                                        : Colors.white60,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  for (final note in notes)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        note,
                        textAlign: TextAlign.center,
                        style: OnboardingText.rowBody,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
