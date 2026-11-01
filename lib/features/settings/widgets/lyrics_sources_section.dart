import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/lyrics_providers/lyrics_provider.dart';
import 'settings_tile_builders.dart';

/// Switches for the online lyrics services tried after LRCLIB.
class LyricsSourcesSection extends StatefulWidget {
  const LyricsSourcesSection({super.key});

  @override
  State<LyricsSourcesSection> createState() => _LyricsSourcesSectionState();
}

class _LyricsSourcesSectionState extends State<LyricsSourcesSection> {
  final Map<String, bool> _enabled = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = {
      for (final p in LyricsProviders.all)
        p.id: await LyricsProviders.isEnabled(p.id),
    };
    if (mounted) setState(() => _enabled.addAll(values));
  }

  Future<void> _toggle(LyricsProvider provider, bool value) async {
    setState(() => _enabled[provider.id] = value);
    await LyricsProviders.setEnabled(provider.id, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        SettingsTiles.buildSectionHeader(context, l10n.settingsLyricsSources),
        SettingsTiles.buildGlassmorphicCard(context, children: [
          for (var i = 0; i < LyricsProviders.all.length; i++)
            SettingsTiles.buildSwitchTile(
              context,
              icon: iconoir.TextSize(color: primary, width: 20, height: 20),
              title: LyricsProviders.all[i].name,
              subtitle: l10n.lyricsProviderDesc,
              value: _enabled[LyricsProviders.all[i].id] ?? true,
              onChanged: (v) => _toggle(LyricsProviders.all[i], v),
              isFirst: i == 0,
            ),
        ]),
      ],
    );
  }
}
