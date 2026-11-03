import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/performance_mode_provider.dart';
import '../../services/online_discovery_service.dart';
import '../../utils/responsive_utils.dart';
import '../glassmorphic_card.dart';
import '../shimmer_loading.dart';
import '../motion/musicfy_motion.dart';
import '../motion/touch_and_reveal.dart';

String _compact(int n) {
  if (n >= 1000000) {
    return '${(n / 1000000).toStringAsFixed(n >= 10000000 ? 0 : 1)}M';
  }
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}K';
  return '$n';
}

Future<void> _open(String? url) async {
  if (url == null) return;
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

BoxDecoration _cardDecoration(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final isLowEnd = Provider.of<PerformanceModeProvider>(context, listen: false)
      .isLowEndDevice;
  return isLowEnd
      ? BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        )
      : BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
        );
}

/// Builds [builder] only while online suggestions are enabled.
class _OnlineGate extends StatefulWidget {
  const _OnlineGate({required this.builder});

  final WidgetBuilder builder;

  @override
  State<_OnlineGate> createState() => _OnlineGateState();
}

class _OnlineGateState extends State<_OnlineGate> {
  @override
  void initState() {
    super.initState();
    OnlineDiscoveryService.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: OnlineDiscoveryService.instance.enabled,
      builder: (context, on, _) =>
          on ? widget.builder(context) : const SizedBox.shrink(),
    );
  }
}

class _NetImage extends StatelessWidget {
  const _NetImage(
      {required this.url, required this.size, this.circular = false});

  final String? url;
  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Colors.white.withValues(alpha: 0.08),
      child: Icon(
        circular ? Icons.person_rounded : Icons.music_note_rounded,
        color: Colors.white.withValues(alpha: 0.3),
        size: size * 0.45,
      ),
    );
    final image = url == null
        ? placeholder
        : Image.network(
            url!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            frameBuilder: coverFadeFrameBuilder,
            errorBuilder: (_, __, ___) => placeholder,
          );
    return SizedBox(
      width: size,
      height: size,
      child: circular
          ? ClipOval(child: image)
          : ClipRRect(borderRadius: BorderRadius.circular(10), child: image),
    );
  }
}

/// Short bio, fan count and a Wikipedia link for [artistName].
class OnlineAboutCard extends StatelessWidget {
  const OnlineAboutCard({super.key, required this.artistName});

  final String artistName;

  @override
  Widget build(BuildContext context) {
    return _OnlineGate(
      builder: (context) => FutureBuilder<OnlineArtistProfile?>(
        future: OnlineDiscoveryService.instance.profile(artistName),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _AboutSkeleton(),
            );
          }
          final profile = snap.data;
          if (profile == null ||
              (profile.bio == null && profile.artist.fans == null)) {
            return const SizedBox.shrink();
          }
          return RevealOnAppear(
            revealKey: 'about_${artistName.toLowerCase()}',
            waitForRoute: false,
            cascade: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _AboutBody(profile: profile),
            ),
          );
        },
      ),
    );
  }
}

class _AboutSkeleton extends StatelessWidget {
  const _AboutSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 120, height: 18),
          SizedBox(height: 14),
          ShimmerLoading(height: 12),
          SizedBox(height: 8),
          ShimmerLoading(height: 12),
          SizedBox(height: 8),
          ShimmerLoading(height: 12),
          SizedBox(height: 8),
          ShimmerLoading(width: 160, height: 12),
        ],
      ),
    );
  }
}

class _AboutBody extends StatefulWidget {
  const _AboutBody({required this.profile});

  final OnlineArtistProfile profile;

  @override
  State<_AboutBody> createState() => _AboutBodyState();
}

class _AboutBodyState extends State<_AboutBody> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final p = widget.profile;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.onlineAboutArtist,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (p.artist.fans != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.onlineFansCount(_compact(p.artist.fans!)),
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (p.bio != null) ...[
            const SizedBox(height: 10),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Text(
                p.bio!,
                maxLines: _expanded ? null : 4,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? l10n.onlineShowLess : l10n.onlineReadMore,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: scheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (p.wikiUrl != null)
                  GestureDetector(
                    onTap: () => _open(p.wikiUrl),
                    child: Text(
                      l10n.onlineWikipedia,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onlineBioDisclaimer,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Fans also like": artists similar to [artistName], from Deezer.
class SimilarArtistsRow extends StatelessWidget {
  const SimilarArtistsRow({
    super.key,
    required this.artistName,
    this.centeredTitle = false,
  });

  final String artistName;

  /// Centered 20pt headline, like the other Now Playing sections.
  final bool centeredTitle;

  @override
  Widget build(BuildContext context) {
    return _OnlineGate(
      builder: (context) => FutureBuilder<List<OnlineArtist>>(
        future: OnlineDiscoveryService.instance.relatedArtists(artistName),
        builder: (context, snap) {
          final artists = snap.data ?? const <OnlineArtist>[];
          if (artists.isEmpty) return const SizedBox.shrink();
          return RevealOnAppear(
            revealKey: 'similar_${artistName.toLowerCase()}',
            waitForRoute: false,
            cascade: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: centeredTitle
                      ? const EdgeInsets.fromLTRB(20, 0, 20, 12)
                      : const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      AppLocalizations.of(context).onlineFansAlsoLike,
                      textAlign:
                          centeredTitle ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: centeredTitle ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: GlassmorphicCard.listHeight(context,
                      artworkSize: _SimilarArtistCard._width),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: artists.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => _SimilarArtistCard(
                      artist: artists[i],
                      onTap: () => showOnlineArtistSheet(context, artists[i]),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Same glass card as the library's artist cards: square artwork on top,
/// name and fan count below.
class _SimilarArtistCard extends StatelessWidget {
  const _SimilarArtistCard({required this.artist, required this.onTap});

  static const double _width = 140;

  final OnlineArtist artist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = ResponsiveUtils.scaledArtwork(context, _width);
    final placeholder = ColoredBox(
      color: Colors.white.withValues(alpha: 0.08),
      child: Icon(
        Icons.person_rounded,
        color: Colors.white.withValues(alpha: 0.3),
        size: width * 0.4,
      ),
    );
    final url = artist.pictureUrl;
    return Press3D(
      opensPage: false,
      child: GestureDetector(
        onTap: onTap,
        child: RepaintBoundary(
          child: Container(
            width: width,
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: width,
                    height: width,
                    child: url == null
                        ? placeholder
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            frameBuilder: coverFadeFrameBuilder,
                            errorBuilder: (_, __, ___) => placeholder,
                          ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (artist.fans != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.onlineFansCount(_compact(artist.fans!)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Top tracks for [artistName]; tapping one opens it on Deezer.
class OnlinePopularTracks extends StatelessWidget {
  const OnlinePopularTracks({super.key, required this.artistName});

  final String artistName;

  @override
  Widget build(BuildContext context) {
    return _OnlineGate(
      builder: (context) => FutureBuilder<List<OnlineTrack>>(
        future: OnlineDiscoveryService.instance.topTracks(artistName),
        builder: (context, snap) {
          final tracks = snap.data ?? const <OnlineTrack>[];
          if (tracks.isEmpty) return const SizedBox.shrink();
          return RevealOnAppear(
            revealKey: 'popular_${artistName.toLowerCase()}',
            waitForRoute: false,
            cascade: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      AppLocalizations.of(context).onlinePopularTracks,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final t in tracks) _OnlineTrackRow(track: t),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnlineTrackRow extends StatelessWidget {
  const _OnlineTrackRow({required this.track});

  final OnlineTrack track;

  @override
  Widget build(BuildContext context) {
    return RoundedHighlight(
      cornerRadius: 10,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: () => _open(track.link),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              _NetImage(url: track.coverUrl, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (track.albumTitle != null)
                      Text(
                        track.albumTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded,
                  size: 16, color: Colors.white.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with bio and popular tracks for an artist not in the library.
Future<void> showOnlineArtistSheet(BuildContext context, OnlineArtist artist) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, controller) => DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _NetImage(
                    url: artist.pictureUrl, size: 120, circular: true),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  artist.name,
                  style: const TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OnlineAboutCard(artistName: artist.name),
              OnlinePopularTracks(artistName: artist.name),
            ],
          ),
        ),
      );
    },
  );
}
