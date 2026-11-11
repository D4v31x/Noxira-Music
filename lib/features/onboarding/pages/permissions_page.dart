import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../widgets/onboarding_kit.dart';

/// Asks for the permissions the app needs, one row each, with the state shown
/// live. Audio (Android 13+) or storage (Android 12-) is required.
class PermissionsPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const PermissionsPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
    with WidgetsBindingObserver {
  bool _audioGranted = false;
  bool _storageGranted = false;
  bool _notificationGranted = false;
  bool _bluetoothGranted = false;
  bool _busy = false;
  bool _showStorage = false; // Android 12 and below
  bool _showBluetooth = false;
  bool _showAudio = false; // Android 13+

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_init());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the system settings: pick up changes.
    if (state == AppLifecycleState.resumed) unawaited(_check());
  }

  Future<void> _init() async {
    await _detectAndroid();
    await _check();
  }

  Future<void> _detectAndroid() async {
    if (!Platform.isAndroid) return;
    try {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (!mounted) return;
      setState(() {
        _showStorage = sdk <= 32;
        _showBluetooth = sdk >= 31;
        _showAudio = sdk >= 33;
      });
    } catch (e) {
      debugPrint('Error checking Android version: $e');
      if (!mounted) return;
      setState(() {
        _showStorage = true;
        _showBluetooth = true;
        _showAudio = true;
      });
    }
  }

  Future<void> _check() async {
    final notification = await Permission.notification.status;
    final bluetooth = await Permission.bluetoothConnect.status;
    final audio = _showAudio ? await Permission.audio.status : null;
    final storage = _showStorage ? await Permission.storage.status : null;
    if (!mounted) return;
    setState(() {
      // Not needed on this Android version counts as granted.
      _audioGranted = audio?.isGranted ?? true;
      _storageGranted = storage?.isGranted ?? true;
      _notificationGranted = notification.isGranted;
      _bluetoothGranted = bluetooth.isGranted;
      _busy = false;
    });
  }

  Future<void> _request(Permission permission) async {
    if (_busy) return;
    setState(() => _busy = true);
    await permission.request();
    if (!mounted) return;
    await _check();
  }

  Future<void> _requestAll() async {
    setState(() => _busy = true);
    if (_showAudio) await Permission.audio.request();
    if (_showStorage) await Permission.storage.request();
    if (_showBluetooth) await Permission.bluetoothConnect.request();
    await Permission.notification.request();
    if (!mounted) return;
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const color = Colors.white;
    final requiredGranted = _showAudio ? _audioGranted : _storageGranted;

    final items = <({
      Widget icon,
      String title,
      String body,
      bool granted,
      bool required,
      Permission permission,
    })>[
      if (_showAudio)
        (
          icon: const iconoir.MusicNote(color: color, width: 24, height: 24),
          title: l10n.onboardingAudioAccess,
          body: l10n.onboardingAudioAccessDesc,
          granted: _audioGranted,
          required: true,
          permission: Permission.audio,
        ),
      if (_showStorage)
        (
          icon: const iconoir.Folder(color: color, width: 24, height: 24),
          title: l10n.onboardingStorageAccess,
          body: l10n.onboardingStorageAccessDesc,
          granted: _storageGranted,
          required: true,
          permission: Permission.storage,
        ),
      (
        icon: const iconoir.Bluetooth(color: color, width: 24, height: 24),
        title: l10n.onboardingBluetooth,
        body: l10n.onboardingBluetoothDesc,
        granted: _bluetoothGranted,
        required: false,
        permission: Permission.bluetoothConnect,
      ),
      (
        icon: const iconoir.Bell(color: color, width: 24, height: 24),
        title: l10n.onboardingNotifications,
        body: l10n.onboardingNotificationsDesc,
        granted: _notificationGranted,
        required: false,
        permission: Permission.notification,
      ),
    ];

    return StepScaffold(
      title: l10n.onboardingPermissionsTitle,
      lead: l10n.onboardingPermissionsSubtitle,
      primaryLabel: requiredGranted
          ? l10n.continueButton
          : (_busy
              ? l10n.onboardingRequesting
              : l10n.onboardingGrantPermissions),
      primaryLoading: _busy,
      onPrimary: requiredGranted ? widget.onContinue : _requestAll,
      onBack: widget.onBack,
      backLabel: l10n.back,
      footnote: requiredGranted
          ? null
          : Text(l10n.onboardingAudioRequired,
              textAlign: TextAlign.center, style: OnboardingText.small),
      children: [
        Column(
          spacing: 12,
          children: [
            for (var i = 0; i < items.length; i++)
              GlassRow(
                order: 2 + i,
                leading: items[i].icon,
                title: items[i].title,
                body: items[i].body,
                selected: items[i].granted,
                onTap: items[i].granted
                    ? null
                    : () => unawaited(_request(items[i].permission)),
                trailing: _PermissionState(
                  granted: items[i].granted,
                  required: items[i].required,
                  allowLabel: l10n.onboardingAllow,
                  requiredLabel: l10n.onboardingRequired,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PermissionState extends StatelessWidget {
  const _PermissionState({
    required this.granted,
    required this.required,
    required this.allowLabel,
    required this.requiredLabel,
  });

  final bool granted;
  final bool required;
  final String allowLabel;
  final String requiredLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: granted
          ? Container(
              key: const ValueKey('granted'),
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  size: 19, color: Colors.black),
            )
          : Column(
              key: const ValueKey('pending'),
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    allowLabel,
                    style: const TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (required) ...[
                  const SizedBox(height: 5),
                  Text(requiredLabel, style: OnboardingText.small),
                ],
              ],
            ),
    );
  }
}
