import 'dart:ui' as ui;

import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../providers/performance_mode_provider.dart';
import '../services/audio_output_service.dart';
import '../services/bluetooth_service.dart';
import '../services/device_performance_service.dart';
import '../services/notification_manager.dart';
import 'glass_fill.dart';
import 'glass_panel.dart';

const Color _kAccent = Color(0xFF10B981);

/// Tag shared by the app bar's Bluetooth island and the "Current Device" card.
const String audioOutputIslandHeroTag = 'audio_output_island';

/// Opens the audio output picker.
///
/// Pass [heroTag] (the origin widget wrapped in a [Hero] with the same tag) to
/// morph that widget into the "Current Device" card. This only happens on
/// high-end devices; other tiers get a plain fade/scale.
Future<void> showAudioOutputDialog(BuildContext context, {String? heroTag}) {
  final isHighEnd = context.read<PerformanceModeProvider>().currentMode ==
      PerformanceLevel.high;
  final label = MaterialLocalizations.of(context).modalBarrierDismissLabel;

  if (heroTag != null && isHighEnd) {
    // Heroes only fly between PageRoutes, so the dialog is a transparent one.
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: label,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => _AudioOutputDialog(heroTag: heroTag),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
    );
  }

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: label,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => const _AudioOutputDialog(),
    transitionBuilder: (_, animation, __, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Display name of [output] ("Phone Speaker" for the built-in speaker).
String audioOutputLabel(AppLocalizations l10n, AudioOutput output) {
  switch (output.kind) {
    case AudioOutputKind.speaker:
      return l10n.audioOutputPhoneSpeaker;
    case AudioOutputKind.wired:
      return output.name.isEmpty ? l10n.audioOutputWired : output.name;
    case AudioOutputKind.usb:
      return output.name.isEmpty ? l10n.audioOutputUsb : output.name;
    case AudioOutputKind.bluetooth:
    case AudioOutputKind.other:
      return output.name.isEmpty ? l10n.audioOutputOther : output.name;
  }
}

/// Colour used for outputs that are not the phone itself.
const Color audioOutputAccent = _kAccent;

Widget audioOutputIcon(
  AudioOutputKind kind, {
  required Color color,
  double size = 24,
}) {
  switch (kind) {
    case AudioOutputKind.bluetooth:
      return iconoir.Bluetooth(color: color, width: size, height: size);
    case AudioOutputKind.speaker:
      return iconoir.SmartphoneDevice(color: color, width: size, height: size);
    case AudioOutputKind.wired:
      return iconoir.Headset(color: color, width: size, height: size);
    case AudioOutputKind.usb:
      return iconoir.Usb(color: color, width: size, height: size);
    case AudioOutputKind.other:
      return iconoir.SoundHigh(color: color, width: size, height: size);
  }
}

/// Shuttle that morphs the island into the panel: a glass surface whose
/// corner radius, fill and outline animate with the flight, while the island's
/// content fades out and the panel's content fades in (revealed as the surface
/// grows, so it appears with the transition instead of after it).
Widget audioOutputHeroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  final isPush = direction == HeroFlightDirection.push;
  final panelContext = isPush ? toContext : fromContext;
  final islandContext = isPush ? fromContext : toContext;

  final panelChild = (panelContext.widget as Hero).child;
  final islandChild = (islandContext.widget as Hero).child;
  final panelSize = (panelContext.findRenderObject() as RenderBox?)?.size;
  final content = panelChild is _AudioOutputPanel ? panelChild.content : null;

  // The island's own outline (white on the phone, green on another device),
  // so the flight starts from what is actually on screen.
  var islandBorder = BorderSide(
    color: Colors.white.withValues(alpha: 0.22),
    width: 1.3,
  );
  final islandDecoration =
      islandChild is AnimatedContainer ? islandChild.decoration : null;
  if (islandDecoration is BoxDecoration &&
      islandDecoration.border is Border &&
      (islandDecoration.border as Border).top.style == BorderStyle.solid) {
    islandBorder = (islandDecoration.border as Border).top;
  }

  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final t = Curves.easeInOut.transform(animation.value);
      final radiusValue = ui.lerpDouble(20, 28, t)!;
      final radius = BorderRadius.circular(radiusValue);
      final panelOpacity =
          const Interval(0.35, 1, curve: Curves.easeOut).transform(t);
      final islandOpacity =
          1 - const Interval(0, 0.35, curve: Curves.easeIn).transform(t);
      final outlineOpacity =
          1 - const Interval(0, 0.6, curve: Curves.easeOut).transform(t);

      // Material gives the island's text a text style (no underline).
      return Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: radius,
          // Same glass as the finished panel (blur, sheen and light edge) from
          // the first frame, so nothing changes when the flight lands.
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: CustomPaint(
              foregroundPainter:
                  GlassEdgePainter(radius: radiusValue, alpha: 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.17),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (outlineOpacity > 0)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(
                            color: islandBorder.color.withValues(
                                alpha: islandBorder.color.a * outlineOpacity),
                            width: islandBorder.width,
                          ),
                        ),
                      ),
                    if (islandOpacity > 0)
                      Opacity(
                        opacity: islandOpacity,
                        child: Center(child: islandChild),
                      ),
                    if (content != null &&
                        panelSize != null &&
                        panelOpacity > 0)
                      Opacity(
                        opacity: panelOpacity,
                        // Laid out at its final size and clipped by the growing
                        // surface.
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minWidth: panelSize.width,
                          maxWidth: panelSize.width,
                          minHeight: panelSize.height,
                          maxHeight: panelSize.height,
                          child: content,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// The glass panel. Kept as its own type so the hero shuttle can reuse its
/// [content] without doubling the glass surface.
class _AudioOutputPanel extends StatelessWidget {
  const _AudioOutputPanel({required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) => GlassPanel(radius: 28, child: content);
}

class _AudioOutputDialog extends StatefulWidget {
  const _AudioOutputDialog({this.heroTag});

  final String? heroTag;

  @override
  State<_AudioOutputDialog> createState() => _AudioOutputDialogState();
}

class _AudioOutputDialogState extends State<_AudioOutputDialog> {
  final _service = AudioOutputService.instance;
  final _bluetooth = BluetoothService();
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    _service.refresh();
    _bluetooth.addListener(_service.refresh);
  }

  @override
  void dispose() {
    _bluetooth.removeListener(_service.refresh);
    super.dispose();
  }

  /// Used until (or if) the native side returns the real list.
  List<AudioOutput> _fallbackOutputs() {
    final bluetoothOn = _bluetooth.isBluetoothConnected;
    return [
      if (bluetoothOn)
        AudioOutput(
          id: 'bluetooth',
          name: _bluetooth.connectedDeviceName,
          kind: AudioOutputKind.bluetooth,
          selected: true,
        ),
      AudioOutput(
        id: 'speaker',
        name: '',
        kind: AudioOutputKind.speaker,
        selected: !bluetoothOn,
      ),
    ];
  }

  String _label(AppLocalizations l10n, AudioOutput output) =>
      audioOutputLabel(l10n, output);

  Future<void> _onSelect(AudioOutput output) async {
    if (_switching) return;
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messengerContext = navigator.context;

    if (output.selected) {
      navigator.pop();
      return;
    }
    setState(() => _switching = true);
    final ok = await _service.select(output);
    if (!mounted) return;
    setState(() => _switching = false);
    if (ok) {
      navigator.pop();
    } else if (messengerContext.mounted) {
      NotificationManager.showMessage(
          messengerContext, l10n.audioOutputSwitchFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListenableBuilder(
              listenable: Listenable.merge([_service, _bluetooth]),
              builder: (context, _) {
                final outputs = _service.outputs.isNotEmpty
                    ? _service.outputs
                    : _fallbackOutputs();
                final current = outputs.cast<AudioOutput?>().firstWhere(
                      (o) => o!.selected,
                      orElse: () => null,
                    );

                final content = Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(context, l10n),
                      if (current != null) _currentSection(l10n, current),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final output in outputs) ...[
                              _row(l10n, output),
                              const SizedBox(height: 8),
                            ],
                            if (outputs.length <= 1)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 6, bottom: 4),
                                child: Text(
                                  l10n.audioOutputNoOthers,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: FontConstants.fontFamily,
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                final panel = _AudioOutputPanel(content: content);

                final tag = widget.heroTag;
                if (tag == null) return panel;
                return Hero(
                  tag: tag,
                  flightShuttleBuilder: audioOutputHeroShuttle,
                  child: panel,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
      child: Row(
        children: [
          const iconoir.SoundHigh(color: Colors.white, width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.audioOutput,
              style: const TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: l10n.close,
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
            icon: const iconoir.Xmark(
                color: Colors.white70, width: 20, height: 20),
          ),
        ],
      ),
    );
  }

  /// Highlighted strip inside the panel showing where audio plays right now.
  Widget _currentSection(AppLocalizations l10n, AudioOutput current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _kAccent.withValues(alpha: 0.28),
              _kAccent.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(color: _kAccent.withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.audioOutputCurrentDevice,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: _kAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _label(l10n, current),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              audioOutputIcon(current.kind, color: _kAccent, size: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(AppLocalizations l10n, AudioOutput output) {
    final selected = output.selected;
    final isBluetooth = output.kind == AudioOutputKind.bluetooth;
    final subtitle = isBluetooth ? l10n.audioOutputBluetoothDevice : null;

    return Material(
      color: selected
          ? _kAccent.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected
              ? _kAccent.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _switching ? null : () => _onSelect(output),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (selected ? _kAccent : Colors.white)
                      .withValues(alpha: selected ? 0.2 : 0.1),
                ),
                child: Center(
                  child: audioOutputIcon(
                    output.kind,
                    color: selected ? _kAccent : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(l10n, output),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: selected ? _kAccent : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (selected)
                const iconoir.Check(color: _kAccent, width: 20, height: 20)
              else if (_switching)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white38),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero tag of the island on the Now Playing screen (the app bar island has
/// its own, so the two never share a tag).
const String audioOutputPlayerIslandHeroTag = 'audio_output_island_player';

/// Compact glass island for the Now Playing screen: shows where audio is
/// playing (icon and device name) and opens the output picker on tap.
class AudioOutputIsland extends StatelessWidget {
  const AudioOutputIsland({super.key, this.maxWidth = 200});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final bluetooth = BluetoothService();
    final outputs = AudioOutputService.instance;
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([bluetooth, outputs]),
      builder: (context, _) {
        final current = outputs.current;
        final kind = current?.kind ??
            (bluetooth.isBluetoothConnected
                ? AudioOutputKind.bluetooth
                : AudioOutputKind.speaker);
        final label = current != null
            ? audioOutputLabel(l10n, current)
            : bluetooth.isBluetoothConnected
                ? bluetooth.connectedDeviceName
                : l10n.audioOutputPhoneSpeaker;
        // Green while the sound goes to another device, white on the phone.
        final onDevice = kind != AudioOutputKind.speaker;
        final color = onDevice ? _kAccent : Colors.white;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showAudioOutputDialog(context,
              heroTag: audioOutputPlayerIslandHeroTag),
          child: Hero(
            tag: audioOutputPlayerIslandHeroTag,
            flightShuttleBuilder: audioOutputHeroShuttle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              constraints: BoxConstraints(maxWidth: maxWidth, minHeight: 38),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: onDevice
                      ? _kAccent.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.22),
                  width: 1.3,
                ),
              ),
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: color),
                duration: const Duration(milliseconds: 300),
                builder: (context, animated, _) {
                  final shade = animated ?? color;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      audioOutputIcon(kind, color: shade, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            label,
                            key: ValueKey(label),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: shade,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
