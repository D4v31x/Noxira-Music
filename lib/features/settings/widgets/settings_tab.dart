import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/donation_service.dart';
import '../../../shared/services/remote_config_helper.dart';
import '../../../shared/services/version_service.dart';
import '../../../shared/widgets/expanding_player.dart';
import '../../../shared/services/notification_manager.dart';
import '../screens/appearance_settings_screen.dart';
import '../screens/folder_filter_settings_screen.dart';
import '../screens/playback_settings_screen.dart';
import '../screens/storage_settings_screen.dart';
import '../screens/about_settings_screen.dart';
import '../screens/insights_settings_screen.dart';
import '../screens/support_settings_screen.dart';
import 'settings_tile_builders.dart';

/// A glassmorphic settings tab with translations.
class SettingsTab extends StatefulWidget {
  final VoidCallback? onUpdateCheck;
  final NotificationManager notificationManager;
  final VoidCallback? onResetSetup;

  const SettingsTab({
    super.key,
    this.onUpdateCheck,
    required this.notificationManager,
    this.onResetSetup,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _currentVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
    RemoteConfigHelper.updates.addListener(_onRemoteConfigUpdated);
  }

  @override
  void dispose() {
    RemoteConfigHelper.updates.removeListener(_onRemoteConfigUpdated);
    super.dispose();
  }

  void _onRemoteConfigUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadVersionInfo() async {
    final version = await VersionService.getCurrentVersion();
    if (mounted) {
      setState(() => _currentVersion = version);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: _buildSectionWidgets(),
      ),
    );
  }

  Widget _buildSectionWidgets() {
    final l10n = AppLocalizations.of(context);

    void open(Widget screen) => unawaited(
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)));

    final rows = <({
      Widget Function(Color) icon,
      String title,
      String subtitle,
      VoidCallback onTap
    })>[
      (
        icon: (c) => iconoir.Palette(color: c, width: 22, height: 22),
        title: l10n.settingsAppearance,
        subtitle: l10n.settingsAppearanceSubtitle,
        onTap: () => open(const AppearanceSettingsScreen()),
      ),
      (
        icon: (c) => iconoir.Play(color: c, width: 22, height: 22),
        title: l10n.settingsPlayback,
        subtitle: l10n.settingsPlaybackSubtitle,
        onTap: () => open(const PlaybackSettingsScreen()),
      ),
      (
        icon: (c) => iconoir.StatsReport(color: c, width: 22, height: 22),
        title: l10n.settingsInsights,
        subtitle: l10n.settingsInsightsSubtitle,
        onTap: () => open(const InsightsSettingsScreen()),
      ),
      (
        icon: (c) => iconoir.Database(color: c, width: 22, height: 22),
        title: l10n.settingsStorage,
        subtitle: l10n.settingsStorageSubtitle,
        onTap: () => open(StorageSettingsScreen(
              notificationManager: widget.notificationManager,
            )),
      ),
      (
        icon: (c) => iconoir.Folder(color: c, width: 22, height: 22),
        title: l10n.settingsLibraryFolders,
        subtitle: l10n.settingsLibraryFoldersSubtitle,
        onTap: () => open(const FolderFilterSettingsScreen()),
      ),
      (
        icon: (c) => iconoir.InfoCircle(color: c, width: 22, height: 22),
        title: l10n.settingsAbout,
        subtitle: l10n.settingsAboutSubtitle,
        onTap: () => open(AboutSettingsScreen(
              currentVersion: _currentVersion,
              notificationManager: widget.notificationManager,
              onResetSetup: widget.onResetSetup,
            )),
      ),
      (
        icon: (c) => iconoir.HeartSolid(color: c, width: 22, height: 22),
        title: l10n.settingsSupport,
        subtitle: l10n.settingsSupportSubtitle,
        onTap: () => open(const SupportSettingsScreen()),
      ),
    ];

    // Each group is its own card, with a heading and room around it.
    final groups = <(String, List<int>)>[
      (l10n.settingsGroupExperience, [0, 1]),
      (l10n.settingsGroupLibrary, [4, 3, 2]),
      (l10n.settingsGroupApp, [if (DonationService.enabled) 6, 5]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (title, indexes) in groups) ...[
          SettingsTiles.buildSectionHeader(context, title),
          SettingsTiles.buildGlassmorphicCard(
            context,
            children: [
              for (var i = 0; i < indexes.length; i++) ...[
                if (i > 0) SettingsTiles.divider(context),
                _categoryRow(
                  rows[indexes[i]],
                  first: i == 0,
                  last: i == indexes.length - 1,
                ),
              ],
            ],
          ),
        ],
        SizedBox(height: ExpandingPlayer.bottomInsetFor(context, idle: 32)),
      ],
    );
  }

  Widget _categoryRow(
    ({
      Widget Function(Color) icon,
      String title,
      String subtitle,
      VoidCallback onTap
    }) row, {
    required bool first,
    required bool last,
  }) {
    return InkWell(
      onTap: row.onTap,
      borderRadius: BorderRadius.vertical(
        top: first ? const Radius.circular(24) : Radius.zero,
        bottom: last ? const Radius.circular(24) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            SizedBox(width: 28, child: Center(child: row.icon(Colors.white))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontConstants.fontFamily,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: FontConstants.fontFamily,
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
            iconoir.NavArrowRight(
              color: Colors.white.withValues(alpha: 0.4),
              width: 18,
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}
