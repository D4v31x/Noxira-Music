import 'dart:async';
import 'dart:ui';

import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/performance_mode_provider.dart';
import '../../../shared/widgets/glassmorphic_dialog.dart';

const _kPrefKey = 'lyrics_translate_target_lang';

/// Languages offered for lyrics translation, named in their own language.
const _languages = <(String, String)>[
  ('ar', 'العربية'),
  ('bg', 'Български'),
  ('bn', 'বাংলা'),
  ('ca', 'Català'),
  ('cs', 'Čeština'),
  ('da', 'Dansk'),
  ('de', 'Deutsch'),
  ('el', 'Ελληνικά'),
  ('en', 'English'),
  ('es', 'Español'),
  ('et', 'Eesti'),
  ('fa', 'فارسی'),
  ('fi', 'Suomi'),
  ('fr', 'Français'),
  ('he', 'עברית'),
  ('hi', 'हिन्दी'),
  ('hr', 'Hrvatski'),
  ('hu', 'Magyar'),
  ('id', 'Bahasa Indonesia'),
  ('it', 'Italiano'),
  ('ja', '日本語'),
  ('ko', '한국어'),
  ('lt', 'Lietuvių'),
  ('lv', 'Latviešu'),
  ('ms', 'Bahasa Melayu'),
  ('nl', 'Nederlands'),
  ('no', 'Norsk'),
  ('pl', 'Polski'),
  ('pt', 'Português'),
  ('ro', 'Română'),
  ('ru', 'Русский'),
  ('sk', 'Slovenčina'),
  ('sl', 'Slovenščina'),
  ('sr', 'Српски'),
  ('sv', 'Svenska'),
  ('ta', 'தமிழ்'),
  ('th', 'ไทย'),
  ('tr', 'Türkçe'),
  ('uk', 'Українська'),
  ('vi', 'Tiếng Việt'),
  ('zh-CN', '简体中文'),
  ('zh-TW', '繁體中文'),
];

/// Shows two small pills next to the translate button: translate into the app
/// language, or pick another one. Returns the language code, or null when
/// dismissed.
Future<String?> chooseLyricsTranslationTarget(
  BuildContext context,
  GlobalKey anchor,
) async {
  final box = anchor.currentContext?.findRenderObject() as RenderBox?;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (box == null || !box.attached || overlay == null) {
    return pickLyricsTranslationLanguage(context);
  }

  final origin = box.localToGlobal(Offset.zero);
  final size = box.size;
  final screenWidth = MediaQuery.sizeOf(context).width;
  final extendLeft = origin.dx + size.width / 2 > screenWidth / 2;
  final appLang = Localizations.localeOf(context).languageCode;
  final l10n = AppLocalizations.of(context);
  final blur = Provider.of<PerformanceModeProvider>(context, listen: false)
      .shouldEnableBlur;

  final result = Completer<bool?>();
  late final OverlayEntry entry;
  void close(bool? chooseOther) {
    if (result.isCompleted) return;
    entry.remove();
    result.complete(chooseOther);
  }

  entry = OverlayEntry(
    builder: (_) => Stack(
      children: [
        // Pointer-down (not a tap) so scrolls and taps on other controls
        // dismiss too; opaque so the touch only closes the pills.
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => close(null),
          ),
        ),
        Positioned(
          top: origin.dy,
          height: size.height,
          left: extendLeft ? null : origin.dx + size.width + 8,
          right: extendLeft ? screenWidth - origin.dx + 8 : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Island(
                label: l10n.translateLyricsAppLanguage,
                icon: Icons.translate_rounded,
                blur: blur,
                delay: 0,
                onTap: () => close(false),
              ),
              const SizedBox(width: 8),
              _Island(
                label: l10n.translateLyricsChooseLanguage,
                icon: Icons.language_rounded,
                blur: blur,
                delay: 60,
                onTap: () => close(true),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  overlay.insert(entry);

  final chooseOther = await result.future;
  if (chooseOther == null) return null;
  if (!chooseOther) return appLang;
  if (!context.mounted) return null;
  return pickLyricsTranslationLanguage(context);
}

class _Island extends StatelessWidget {
  const _Island({
    required this.label,
    required this.icon,
    required this.blur,
    required this.delay,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool blur;
  final int delay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Material(
      color: blur ? Colors.white.withValues(alpha: 0.14) : Colors.grey[900],
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + delay),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: blur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: pill,
              )
            : pill,
      ),
    );
  }
}

/// Asks which language the lyrics should be translated into.
///
/// Starts on the language chosen last time, or the app language. Returns the
/// chosen code, or null when the dialog is dismissed.
Future<String?> pickLyricsTranslationLanguage(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (!context.mounted) return null;
  final appLang = Localizations.localeOf(context).languageCode;
  final current = prefs.getString(_kPrefKey) ?? appLang;

  final picked = await showDialog<String>(
    context: context,
    builder: (ctx) => GlassmorphicDialog(
      title: Text(
        AppLocalizations.of(ctx).translateLyricsTo,
        style: const TextStyle(
          fontFamily: FontConstants.fontFamily,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(ctx).height * 0.5,
        child: ListView(
          children: [
            for (final (code, name) in _languages)
              ListTile(
                dense: true,
                onTap: () => Navigator.pop(ctx, code),
                leading: Icon(
                  code == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: code == current ? Colors.white : Colors.white54,
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: code == current ? Colors.white : Colors.white70,
                    fontSize: 16,
                    fontWeight:
                        code == current ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  if (picked != null) await prefs.setString(_kPrefKey, picked);
  return picked;
}
