import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/font_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import './glassmorphic_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'adaptive_blur.dart';

/// Model class representing a package dependency
class PackageInfo {
  final String name;
  final String version;
  final String Function(AppLocalizations l10n) description;
  final String? url;

  const PackageInfo({
    required this.name,
    required this.version,
    required this.description,
    this.url,
  });
}

/// Dialog showing all packages used in the application
class PackagesDialog extends StatelessWidget {
  const PackagesDialog({super.key});

  /// List of all packages used in Noxira Music
  static final List<PackageInfo> packages = [
    PackageInfo(
      name: 'just_audio',
      version: '^0.10.4',
      description: (l) => l.pkgJustAudio,
      url: 'https://pub.dev/packages/just_audio',
    ),
    PackageInfo(
      name: 'audio_service',
      version: '^0.18.15',
      description: (l) => l.pkgAudioService,
      url: 'https://pub.dev/packages/audio_service',
    ),
    PackageInfo(
      name: 'audio_session',
      version: 'any',
      description: (l) => l.pkgAudioSession,
      url: 'https://pub.dev/packages/audio_session',
    ),
    PackageInfo(
      name: 'on_audio_query',
      version: '^2.9.0',
      description: (l) => l.pkgOnAudioQuery,
      url: 'https://pub.dev/packages/on_audio_query',
    ),
    PackageInfo(
      name: 'haudiotagger',
      version: '^3.1.0',
      description: (l) => l.pkgHaudiotagger,
      url: 'https://pub.dev/packages/haudiotagger',
    ),
    PackageInfo(
      name: 'provider',
      version: '^6.1.2',
      description: (l) => l.pkgProvider,
      url: 'https://pub.dev/packages/provider',
    ),
    PackageInfo(
      name: 'shared_preferences',
      version: '^2.3.4',
      description: (l) => l.pkgSharedPreferences,
      url: 'https://pub.dev/packages/shared_preferences',
    ),
    PackageInfo(
      name: 'path_provider',
      version: '^2.1.3',
      description: (l) => l.pkgPathProvider,
      url: 'https://pub.dev/packages/path_provider',
    ),
    PackageInfo(
      name: 'permission_handler',
      version: '^12.0.0+1',
      description: (l) => l.pkgPermissionHandler,
      url: 'https://pub.dev/packages/permission_handler',
    ),
    PackageInfo(
      name: 'dynamic_color',
      version: '^1.7.0',
      description: (l) => l.pkgDynamicColor,
      url: 'https://pub.dev/packages/dynamic_color',
    ),
    PackageInfo(
      name: 'palette_generator',
      version: '^0.3.3+4',
      description: (l) => l.pkgPaletteGenerator,
      url: 'https://pub.dev/packages/palette_generator',
    ),
    PackageInfo(
      name: 'flutter_staggered_animations',
      version: '^1.1.1',
      description: (l) => l.pkgStaggeredAnimations,
      url: 'https://pub.dev/packages/flutter_staggered_animations',
    ),
    PackageInfo(
      name: 'http',
      version: '^1.2.1',
      description: (l) => l.pkgHttp,
      url: 'https://pub.dev/packages/http',
    ),
    PackageInfo(
      name: 'url_launcher',
      version: '^6.2.6',
      description: (l) => l.pkgUrlLauncher,
      url: 'https://pub.dev/packages/url_launcher',
    ),
    PackageInfo(
      name: 'share_plus',
      version: '^10.0.3',
      description: (l) => l.pkgSharePlus,
      url: 'https://pub.dev/packages/share_plus',
    ),
    PackageInfo(
      name: 'package_info_plus',
      version: '^8.0.0',
      description: (l) => l.pkgPackageInfoPlus,
      url: 'https://pub.dev/packages/package_info_plus',
    ),
    PackageInfo(
      name: 'device_info_plus',
      version: '^11.4.0',
      description: (l) => l.pkgDeviceInfoPlus,
      url: 'https://pub.dev/packages/device_info_plus',
    ),
    PackageInfo(
      name: 'flutter_dotenv',
      version: '^5.1.0',
      description: (l) => l.pkgFlutterDotenv,
      url: 'https://pub.dev/packages/flutter_dotenv',
    ),
    PackageInfo(
      name: 'crypto',
      version: '^3.0.6',
      description: (l) => l.pkgCrypto,
      url: 'https://pub.dev/packages/crypto',
    ),
    PackageInfo(
      name: 'intl',
      version: 'any',
      description: (l) => l.pkgIntl,
      url: 'https://pub.dev/packages/intl',
    ),
    PackageInfo(
      name: 'pub_semver',
      version: '^2.1.4',
      description: (l) => l.pkgPubSemver,
      url: 'https://pub.dev/packages/pub_semver',
    ),
    PackageInfo(
      name: 'clarity_flutter',
      version: '^1.6.0',
      description: (l) => l.pkgClarityFlutter,
      url: 'https://pub.dev/packages/clarity_flutter',
    ),
    PackageInfo(
      name: 'flutter_hooks',
      version: '^0.21.3+1',
      description: (l) => l.pkgFlutterHooks,
      url: 'https://pub.dev/packages/flutter_hooks',
    ),
  ];

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: AdaptiveBackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: GlassmorphicContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context).openSourcePackages,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontConstants.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)
                              .packagesUsedCount(packages.length),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontFamily: FontConstants.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Package List
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: packages.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withValues(alpha: 0.1),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        return _PackageTile(
                          package: package,
                          onTap: package.url != null
                              ? () => _launchURL(package.url!)
                              : null,
                        );
                      },
                    ),
                  ),

                  // Footer with acknowledgment
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context).packagesThanks,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontFamily: FontConstants.fontFamily,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context).close,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: FontConstants.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual package tile widget
class _PackageTile extends StatelessWidget {
  final PackageInfo package;
  final VoidCallback? onTap;

  const _PackageTile({
    required this.package,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.extension,
                color: Colors.blue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Package info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          package.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontConstants.fontFamily,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          package.version,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontFamily: FontConstants.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.description(AppLocalizations.of(context)),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontFamily: FontConstants.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.open_in_new,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
