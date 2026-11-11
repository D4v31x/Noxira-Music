/// Shared tile-building helpers used by all settings sub-screens.
///
/// All methods are static and accept [BuildContext] as first argument so
/// they can be called from any [State] without inheritance.
library;

import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../../../core/constants/font_constants.dart';
import '../../onboarding/widgets/onboarding_glass.dart';

class SettingsTiles {
  const SettingsTiles._();

  // ── Section header ──────────────────────────────────────────────────────────

  static Widget buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 28, 22, 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.3,
          height: 1.2,
          fontFamily: FontConstants.fontFamily,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  // ── Glass card ──────────────────────────────────────────────────────────────

  /// The onboarding glass without its own blur (the page background is
  /// already blurred; a plain solid surface on low-end devices), holding
  /// [children].
  static Widget buildGlassmorphicCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassSurface(
        blur: false,
        child: Material(
          type: MaterialType.transparency,
          child: Column(children: children),
        ),
      ),
    );
  }

  /// A single glass row (for lists of cards such as folders or home sections).
  /// Inactive rows are dimmed.
  static Widget buildGlassRow(
    BuildContext context, {
    required Widget child,
    bool active = true,
    double radius = 22,
  }) {
    return Opacity(
      opacity: active ? 1 : 0.55,
      child: GlassSurface(
        blur: false,
        radius: radius,
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }

  /// Gives a [Switch] / [SwitchListTile] below it a plain look: a white thumb
  /// on a white-tinted track that fills with the accent colour when on.
  static Widget glassSwitchTheme(BuildContext context, Widget child) {
    final primary = Theme.of(context).colorScheme.primary;
    return Theme(
      data: Theme.of(context).copyWith(
        switchTheme: SwitchThemeData(
          thumbColor: const WidgetStatePropertyAll(Colors.white),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? primary
                : Colors.white.withValues(alpha: 0.18),
          ),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      child: child,
    );
  }

  static Widget divider(BuildContext context) => _divider(context);

  /// A tile's leading icon: just the icon, white (or [color]), like the
  /// onboarding rows.
  static Widget iconChip(BuildContext context, Widget icon, Color color) =>
      _iconChip(context, icon, color);

  // ── Switch tile ─────────────────────────────────────────────────────────────

  static Widget buildSwitchTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        if (!isFirst) _divider(context),
        glassSwitchTheme(
          context,
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            secondary: _iconChip(context, icon, Colors.white),
            title: _tileTitle(title),
            subtitle:
                subtitle != null ? _tileSubtitle(context, subtitle) : null,
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ── Action tile ─────────────────────────────────────────────────────────────

  static Widget buildActionTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool isFirst = false,
    Color? iconColor,
  }) {
    final effectiveColor = iconColor ?? Colors.white;
    return Column(
      children: [
        if (!isFirst) _divider(context),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: _iconChip(context, icon, effectiveColor),
          title: _tileTitle(title),
          subtitle: subtitle != null ? _tileSubtitle(context, subtitle) : null,
          trailing: trailing ??
              iconoir.NavArrowRight(
                color: Colors.white.withValues(alpha: 0.4),
                width: 18,
                height: 18,
              ),
          onTap: onTap,
        ),
      ],
    );
  }

  // ── Slider tile ─────────────────────────────────────────────────────────────

  static Widget buildSliderTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    String? subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
    String Function(double)? valueFormatter,
    bool isFirst = false,
    double? defaultValue,
    bool showArrows = false,
    double arrowStep = 0.05,
    bool enabled = true,
  }) {
    final draft = <double?>[null];
    return Opacity(
        opacity: enabled ? 1.0 : 0.65,
        child: StatefulBuilder(
          builder: (context, setLocal) => _buildSliderContent(
            context,
            icon: icon,
            title: title,
            subtitle: subtitle,
            value: value,
            draft: draft[0],
            min: min,
            max: max,
            onChanged: (v) {
              setLocal(() => draft[0] = v);
              onChanged(v);
            },
            onChangeEnd: (v) {
              setLocal(() => draft[0] = null);
              onChangeEnd?.call(v);
            },
            valueFormatter: valueFormatter,
            isFirst: isFirst,
            defaultValue: defaultValue,
            showArrows: showArrows,
            arrowStep: arrowStep,
            enabled: enabled,
          ),
        ));
  }

  static Widget _buildSliderContent(
    BuildContext context, {
    required Widget icon,
    required String title,
    String? subtitle,
    required double value,
    double? draft,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
    String Function(double)? valueFormatter,
    bool isFirst = false,
    double? defaultValue,
    bool showArrows = false,
    double arrowStep = 0.05,
    bool enabled = true,
  }) {
    final display = valueFormatter?.call(draft ?? value) ??
        (draft ?? value).toStringAsFixed(1);
    final snap = defaultValue != null ? (max - min) * 0.025 : 0.0;

    ValueChanged<double> wrapChange(ValueChanged<double> fn) =>
        defaultValue == null
            ? fn
            : (v) => fn((v - defaultValue).abs() <= snap ? defaultValue : v);

    final wrappedOnChanged = wrapChange(onChanged);
    final wrappedOnChangeEnd =
        onChangeEnd == null ? null : wrapChange(onChangeEnd);

    return Column(
      children: [
        if (!isFirst) _divider(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: _iconChip(context, icon, Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tileTitle(title),
                        Text(
                          display,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontConstants.fontFamily,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null) _tileSubtitle(context, subtitle),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor:
                            Colors.white.withValues(alpha: 0.18),
                        disabledActiveTrackColor:
                            Colors.white.withValues(alpha: 0.45),
                        disabledInactiveTrackColor:
                            Colors.white.withValues(alpha: 0.10),
                        thumbColor: Colors.white,
                        disabledThumbColor: Colors.white.withValues(alpha: 0.6),
                        overlayColor: Colors.white.withValues(alpha: 0.12),
                        trackHeight: 4,
                        trackShape: const RoundedRectSliderTrackShape(),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                            elevation: 0,
                            pressedElevation: 0),
                      ),
                      child: _buildSliderWidget(
                        context,
                        value: draft ?? value,
                        min: min,
                        max: max,
                        defaultValue: defaultValue,
                        onChanged: enabled ? wrappedOnChanged : null,
                        onChangeEnd: enabled ? wrappedOnChangeEnd : null,
                        showArrows: showArrows && enabled,
                        arrowStep: arrowStep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildSliderWidget(
    BuildContext context, {
    required double value,
    required double min,
    required double max,
    double? defaultValue,
    required ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeEnd,
    required bool showArrows,
    required double arrowStep,
  }) {
    Widget slider;
    if (defaultValue != null) {
      slider = LayoutBuilder(
        builder: (context, constraints) {
          const double pad = 24.0;
          final tw = constraints.maxWidth - pad * 2;
          final frac = (defaultValue - min) / (max - min);
          final markerLeft = pad + frac * tw;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
              ),
              Positioned(
                left: markerLeft - 1,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 2,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      slider = Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      );
    }

    if (!showArrows) return slider;

    final arrowColor = Colors.white.withValues(alpha: 0.7);
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            final v = (value - arrowStep).clamp(min, max);
            onChanged?.call(v);
            onChangeEnd?.call(v);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child:
                iconoir.NavArrowLeft(color: arrowColor, width: 20, height: 20),
          ),
        ),
        Expanded(child: slider),
        GestureDetector(
          onTap: () {
            final v = (value + arrowStep).clamp(min, max);
            onChanged?.call(v);
            onChangeEnd?.call(v);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child:
                iconoir.NavArrowRight(color: arrowColor, width: 20, height: 20),
          ),
        ),
      ],
    );
  }

  // ── Segmented choice tile ───────────────────────────────────────────────────

  static Widget buildSegmentedChoiceTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    required String subtitle,
    required List<String> options,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        if (!isFirst) _divider(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _iconChip(context, icon, Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tileTitle(title),
                        const SizedBox(height: 2),
                        _tileSubtitle(context, subtitle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(options.length, (i) {
                  final sel = i == selectedIndex;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: i == options.length - 1 ? 0 : 8),
                      child: SettingsChoiceChip(
                        label: options[i],
                        selected: sel,
                        onTap: () => onChanged(i),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Animated visibility ─────────────────────────────────────────────────────

  static Widget buildAnimatedTile(
      {required bool visible, required Widget child}) {
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
      ),
    );
  }

  // ── Shared micro-helpers ────────────────────────────────────────────────────

  static Widget _divider(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 62, right: 16),
        child: Divider(
          height: 1,
          thickness: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      );

  static Widget _iconChip(BuildContext context, Widget icon, Color color) =>
      SizedBox(
        width: 28,
        child: Center(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            child: icon,
          ),
        ),
      );

  static Widget _tileTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: FontConstants.fontFamily,
          color: Colors.white,
        ),
      );

  static Widget _tileSubtitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            fontFamily: FontConstants.fontFamily,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
      );
}

// ── Shared choice chip ────────────────────────────────────────────────────────

class SettingsChoiceChip extends StatelessWidget {
  const SettingsChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.white.withValues(alpha: selected ? 0.2 : 0.06),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.5 : 0.12),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontFamily: FontConstants.fontFamily,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
