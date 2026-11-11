import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/home_layout_service.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/expanding_player.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glassmorphic_dialog.dart';
import '../widgets/settings_tile_builders.dart';

/// Settings screen for customizing home tab layout and section order
class HomeLayoutSettingsScreen extends StatefulWidget {
  const HomeLayoutSettingsScreen({super.key});

  @override
  State<HomeLayoutSettingsScreen> createState() =>
      _HomeLayoutSettingsScreenState();
}

class _HomeLayoutSettingsScreenState extends State<HomeLayoutSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: iconoir.NavArrowLeft(
              color: isDark ? Colors.white : Colors.black,
              width: 28,
              height: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.customizeHomeTab,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            Consumer<HomeLayoutService>(
              builder: (context, layoutService, _) {
                if (layoutService.isCustomLayout) {
                  return IconButton(
                    icon: const iconoir.Undo(
                      color: Colors.white,
                      width: 24,
                      height: 24,
                    ),
                    tooltip: l10n.resetToDefault,
                    onPressed: () => _showResetDialog(context, layoutService),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<HomeLayoutService>(
          builder: (context, layoutService, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instructions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SettingsTiles.buildGlassRow(
                    context,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const iconoir.Menu(
                            color: Colors.white,
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              l10n.dragToReorder,
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Section list
                Expanded(
                  child: ReorderableListView.builder(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: ExpandingPlayer.bottomInsetFor(context, idle: 16),
                    ),
                    itemCount: layoutService.sectionOrder.length,
                    onReorderItem: (oldIndex, newIndex) {
                      HapticFeedback.mediumImpact();
                      layoutService.reorderSections(oldIndex, newIndex);
                    },
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final double elevation =
                              Curves.easeInOut.transform(animation.value) * 8;
                          return Material(
                            elevation: elevation,
                            borderRadius: BorderRadius.circular(16),
                            shadowColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.3),
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final section = layoutService.sectionOrder[index];
                      final isVisible = layoutService.isSectionVisible(section);

                      return _SectionTile(
                        key: ValueKey(section),
                        section: section,
                        isVisible: isVisible,
                        isDark: isDark,
                        onVisibilityChanged: (visible) {
                          HapticFeedback.lightImpact();
                          layoutService.setSectionVisibility(section, visible);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, HomeLayoutService layoutService) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => GlassmorphicDialog(
        title: Text(
          l10n.resetLayoutConfirm,
          style: const TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.resetLayoutMessage,
          style: const TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: Colors.white70,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              layoutService.resetToDefault();
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            child: Text(
              l10n.resetToDefault,
              style: const TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final HomeSection section;
  final bool isVisible;
  final bool isDark;
  final ValueChanged<bool> onVisibilityChanged;

  const _SectionTile({
    super.key,
    required this.section,
    required this.isVisible,
    required this.isDark,
    required this.onVisibilityChanged,
  });

  Widget _sectionIcon(Color color) {
    const size = 22.0;
    switch (section) {
      case HomeSection.forYou:
        return iconoir.Sparks(color: color, width: size, height: size);
      case HomeSection.suggestedArtists:
        return iconoir.User(color: color, width: size, height: size);
      case HomeSection.recentlyPlayed:
        return iconoir.ClockRotateRight(
            color: color, width: size, height: size);
      case HomeSection.mostPlayed:
        return iconoir.StatsUpSquare(color: color, width: size, height: size);
      case HomeSection.listeningHistory:
        return iconoir.StatsReport(color: color, width: size, height: size);
      case HomeSection.recentlyAdded:
        return iconoir.PlusCircle(color: color, width: size, height: size);
      case HomeSection.libraryStats:
        return iconoir.MusicDoubleNote(color: color, width: size, height: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SettingsTiles.buildGlassRow(
        context,
        active: isVisible,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: SizedBox(
              width: 28,
              child: Center(
                  child: _sectionIcon(
                isVisible
                    ? Colors.white
                    : (isDark ? Colors.white38 : Colors.black26),
              ))),
          title: Text(
            section.localizedName(l10n),
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isVisible
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Visibility toggle
              SettingsTiles.glassSwitchTheme(
                context,
                Switch(
                  value: isVisible,
                  onChanged: onVisibilityChanged,
                ),
              ),
              const SizedBox(width: 8),
              // Drag handle
              ReorderableDragStartListener(
                index: HomeLayoutService().sectionOrder.indexOf(section),
                child: iconoir.Menu(
                  color: isDark ? Colors.white38 : Colors.black26,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
