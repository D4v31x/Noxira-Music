import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/supported_languages.dart';
import '../../../shared/providers/theme_provider.dart';
import '../widgets/onboarding_kit.dart';

/// Last step: a summary of what was set up, and the way into the app.
class CompletionPage extends StatefulWidget {
  final VoidCallback onComplete;

  const CompletionPage({super.key, required this.onComplete});

  @override
  State<CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends State<CompletionPage> {
  String? _language;
  bool? _libraryAllowed;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('languageCode') ?? 'en';
    final language = SupportedLanguages.all
        .where((l) => l.code == code)
        .map((l) => l.nativeName)
        .firstOrNull;
    var allowed = false;
    try {
      allowed = await Permission.audio.isGranted ||
          await Permission.storage.isGranted;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _language = language ?? code;
      _libraryAllowed = allowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Provider.of<ThemeProvider>(context);
    final look = theme.useDynamicColor
        ? l10n.onboardingDynamicColors
        : (theme.selectedPresetIndex >= 0 &&
                theme.selectedPresetIndex < AppThemePreset.presets.length
            ? AppThemePreset.presets[theme.selectedPresetIndex].label(l10n)
            : l10n.accentColor);

    final rows = <({String label, String value, bool good})>[
      (
        label: l10n.onboardingSummaryLanguage,
        value: _language ?? '…',
        good: true,
      ),
      (label: l10n.onboardingSummaryTheme, value: look, good: true),
      (
        label: l10n.onboardingSummaryLibrary,
        value: _libraryAllowed == null
            ? '…'
            : (_libraryAllowed!
                ? l10n.onboardingAllowed
                : l10n.onboardingNotAllowed),
        good: _libraryAllowed ?? true,
      ),
    ];

    return StepScaffold(
      title: l10n.onboardingCompletionTitle,
      lead: l10n.onboardingCompletionSubtitle,
      primaryLabel: l10n.onboardingStartListening,
      onPrimary: widget.onComplete,
      children: [
        Column(
          spacing: 12,
          children: [
            for (var i = 0; i < rows.length; i++)
              GlassRow(
                order: 2 + i,
                title: rows[i].value,
                body: rows[i].label,
                trailing: _PopIn(
                  delay: Duration(milliseconds: 650 + i * 160),
                  child: Icon(
                    rows[i].good
                        ? Icons.check_circle_rounded
                        : Icons.remove_circle_outline_rounded,
                    color: rows[i].good ? Colors.white : Colors.white54,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Pops its child in (scale with a little overshoot) after [delay].
class _PopIn extends StatefulWidget {
  const _PopIn({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _shown ? 1 : 0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      child: widget.child,
    );
  }
}
