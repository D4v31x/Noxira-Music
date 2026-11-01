import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/performance_mode_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../widgets/onboarding_kit.dart';

/// Pick the look. A small player preview changes colour as you choose.
class ThemeSelectionPage extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const ThemeSelectionPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Provider.of<ThemeProvider>(context);

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
                      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(height: 14),
        _BackgroundStyle(theme: theme),
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
      label: preset.name,
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

/// Solid or artwork-based background, depending on the device tier.
class _BackgroundStyle extends StatelessWidget {
  const _BackgroundStyle({required this.theme});

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final perf = Provider.of<PerformanceModeProvider>(context, listen: false);
    final isLowEnd = perf.isLowEndDevice;
    if (!isLowEnd && !perf.shouldEnableBlur) return const SizedBox.shrink();

    final title =
        isLowEnd ? l10n.backgroundLowEndStyle : l10n.backgroundHighEndStyle;
    final body = isLowEnd
        ? l10n.backgroundLowEndStyleDesc
        : l10n.backgroundHighEndStyleDesc;
    final options = isLowEnd
        ? [l10n.backgroundBlobs, l10n.backgroundSolid]
        : [l10n.backgroundBlurredArtwork, l10n.backgroundSolid];
    final selected = isLowEnd
        ? (theme.lowEndBackground == LowEndBackground.blobs ? 0 : 1)
        : (theme.highEndBackground == HighEndBackground.blurredArtwork ? 0 : 1);

    void choose(int i) {
      if (isLowEnd) {
        theme.setLowEndBackground(
            i == 0 ? LowEndBackground.blobs : LowEndBackground.solid);
      } else {
        theme.setHighEndBackground(i == 0
            ? HighEndBackground.blurredArtwork
            : HighEndBackground.solid);
      }
    }

    return GlassPanel(
      order: 4,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => choose(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color:
                              selected == i ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            options[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  selected == i ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
