import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../widgets/onboarding_kit.dart';

/// First step: a large welcome that cycles through the app's languages.
class WelcomePage extends StatefulWidget {
  final VoidCallback onContinue;

  const WelcomePage({super.key, required this.onContinue});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  static const _welcomeTexts = [
    (
      title: 'Welcome to Noxira Music',
      subtitle: "Let's set up your experience",
    ),
    (
      title: 'Vítejte v Noxira Music',
      subtitle: 'Pojďme nastavit váš zážitek',
    ),
    (
      title: 'Willkommen bei Noxira Music',
      subtitle: 'Lass uns dein Erlebnis einrichten',
    ),
    (
      title: 'Bienvenido a Noxira Music',
      subtitle: 'Configuremos tu experiencia',
    ),
    (
      title: 'Noxira Music में आपका स्वागत है',
      subtitle: 'आइए आपका अनुभव सेट करें',
    ),
    (
      title: 'Добро пожаловать в Noxira Music',
      subtitle: 'Давайте настроим ваш опыт',
    ),
  ];

  /// One cycle per language: rise in and settle, hold, then fly up and fade.
  static const _cycle = Duration(milliseconds: 4600);
  static const _rise = 34.0;

  late final AnimationController _c =
      AnimationController(vsync: this, duration: _cycle);
  int _index = 0;
  Timer? _reducedMotionTimer;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _index = (_index + 1) % _welcomeTexts.length);
        unawaited(_c.forward(from: 0));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 0.5;
      _reducedMotionTimer ??= Timer.periodic(const Duration(seconds: 4), (_) {
        if (mounted) {
          setState(() => _index = (_index + 1) % _welcomeTexts.length);
        }
      });
    } else if (!_c.isAnimating) {
      // Let the page's own entrance finish before the first language starts.
      unawaited(_c.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _reducedMotionTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  /// Opacity and vertical offset of a line at cycle position [t] (0..1),
  /// [delay] later than the title so the subtitle follows it.
  (double, double) _phase(double t, {double delay = 0}) {
    final x = (t - delay).clamp(0.0, 1.0);
    const inEnd = 0.2;
    const outStart = 0.74;
    const outEnd = 0.93;
    if (x < inEnd) {
      final k = Curves.easeOutCubic.transform(x / inEnd);
      return (k, (1 - k) * _rise);
    }
    if (x < outStart) return (1, 0);
    if (x < outEnd) {
      final k =
          Curves.easeInCubic.transform((x - outStart) / (outEnd - outStart));
      return (1 - k, -k * _rise * 0.7);
    }
    return (0, -_rise * 0.7);
  }

  Widget _line(String text, TextStyle style, double delay) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final (opacity, dy) = MediaQuery.disableAnimationsOf(context)
            ? (1.0, 0.0)
            : _phase(_c.value, delay: delay);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
      },
      child: Text(text, textAlign: TextAlign.center, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _welcomeTexts[_index];
    final scaler = MediaQuery.textScalerOf(context);
    // Room for three lines of the largest title so nothing below it jumps
    // while the language changes.
    final titleHeight = scaler.scale(54) * 1.04 * 3;

    const titleStyle = TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: 54,
      height: 1.04,
      fontWeight: FontWeight.w600,
      letterSpacing: -2.2,
      color: Colors.white,
    );

    return StepScaffold(
      title: '',
      primaryLabel: l10n.onboardingGetStarted,
      onPrimary: widget.onContinue,
      children: const [],
      // The heading is custom here, so it is built below via [custom].
      custom: [
        Reveal(
          child: SizedBox(
            height: titleHeight,
            child: Align(
              alignment: Alignment.center,
              child: _line(text.title, titleStyle, 0),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Reveal(
          order: 1,
          child: SizedBox(
            height: scaler.scale(17) * 1.45 * 2,
            child: Align(
              alignment: Alignment.topCenter,
              child: _line(text.subtitle, OnboardingText.lead, 0.05),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _Fact(
              order: 3,
              icon: iconoir.Folder(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 18,
                  height: 18),
              label: l10n.onboardingLocalMusic,
            ),
            _Fact(
              order: 4,
              icon: iconoir.TextSize(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 18,
                  height: 18),
              label: l10n.onboardingLyricsSupport,
            ),
            _Fact(
              order: 5,
              icon: iconoir.Palette(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 18,
                  height: 18),
              label: l10n.onboardingMaterialDesign,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.order});

  final Widget icon;
  final String label;
  final int order;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 22,
      order: order,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
