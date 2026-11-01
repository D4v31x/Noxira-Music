import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/locale_provider.dart';
import '../../../l10n/supported_languages.dart';
import '../widgets/onboarding_kit.dart';

/// Pick the app language. The whole onboarding re-translates as you tap.
class LanguageSelectionPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const LanguageSelectionPage({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selected = 'en';
  final List<SupportedLanguage> _languages = SupportedLanguages.all;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCurrent());
  }

  Future<void> _loadCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _selected = prefs.getString('languageCode') ?? 'en');
  }

  Future<void> _setLanguage(String code) async {
    if (code == _selected) return;
    setState(() => _selected = code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
    if (!mounted) return;
    LocaleProvider.of(context)?.setLocale(ui.Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StepScaffold(
      title: l10n.onboardingChooseLanguage,
      lead: l10n.onboardingSelectLanguage,
      primaryLabel: l10n.onboardingContinue,
      onPrimary: widget.onContinue,
      onBack: widget.onBack,
      backLabel: l10n.onboardingBack,
      footnote: Text(
        l10n.translationDisclaimerNote,
        textAlign: TextAlign.center,
        style: OnboardingText.small,
      ),
      children: [
        Column(
          spacing: 12,
          children: [
            for (var i = 0; i < _languages.length; i++)
              GlassRow(
                order: 2 + i,
                title: _languages[i].nativeName,
                body: _languages[i].nativeName == _languages[i].englishName
                    ? null
                    : _languages[i].englishName,
                selected: _selected == _languages[i].code,
                onTap: () => _setLanguage(_languages[i].code),
                trailing: _Check(visible: _selected == _languages[i].code),
              ),
          ],
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1 : 0.4,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 26,
          height: 26,
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 18, color: Colors.black),
        ),
      ),
    );
  }
}
