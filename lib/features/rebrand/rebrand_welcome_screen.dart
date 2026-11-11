import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers/performance_mode_provider.dart';
import '../../shared/services/donation_service.dart';
import '../../shared/widgets/expanding_player.dart';
import '../home/screens/home_screen.dart';
import '../onboarding/widgets/onboarding_background.dart';
import '../onboarding/widgets/onboarding_kit.dart';
import '../splash/animated_logo.dart';

const _kPageCount = 8;

/// Shown once on launch to users who updated from a pre-Noxira version.
///
/// Built from the onboarding kit (flow background, glass, staggered
/// entrances) so it reads as part of the same piece.
class RebrandWelcomeScreen extends StatefulWidget {
  /// Opened from Settings: Continue just goes back instead of to Home.
  final bool fromSettings;

  const RebrandWelcomeScreen({super.key, this.fromSettings = false});

  @override
  State<RebrandWelcomeScreen> createState() => _RebrandWelcomeScreenState();
}

class _RebrandWelcomeScreenState extends State<RebrandWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition;
  final _presence = ValueNotifier<double>(1);
  int _page = 0;
  bool _busy = false;

  bool get _isLast => _page == _kPageCount - 1;

  @override
  void initState() {
    super.initState();
    _transition = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1,
    )..addListener(
        () => _presence.value = Curves.easeInOut.transform(_transition.value),
      );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExpandingPlayer.hiddenNotifier.value = true;
    });
  }

  @override
  void dispose() {
    _transition.dispose();
    _presence.dispose();
    super.dispose();
  }

  Future<void> _goTo(int page) async {
    if (_busy || page == _page || page < 0 || page >= _kPageCount) return;
    _busy = true;
    if (onboardingLowEnd(context)) {
      _transition.duration = const Duration(milliseconds: 150);
    }
    await _transition.reverse();
    if (!mounted) return;
    setState(() => _page = page);
    _transition.value = 1;
    _busy = false;
  }

  void _next() => _isLast ? _continue() : unawaited(_goTo(_page + 1));

  void _continue() {
    ExpandingPlayer.hiddenNotifier.value = false;
    if (widget.fromSettings) {
      Navigator.of(context).pop();
      return;
    }
    final lowEnd = context.read<PerformanceModeProvider>().isLowEndDevice;
    unawaited(Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: Duration(milliseconds: lowEnd ? 250 : 500),
      ),
    ));
  }

  Widget _buildPage(AppLocalizations l10n) {
    switch (_page) {
      case 0:
        return _IntroSlide(l10n: l10n);
      case 1:
        return _Slide(
          title: l10n.rebrandSlideLyricsTitle,
          body: l10n.rebrandSlideLyricsBody,
          demo: const _LyricsDemo(),
        );
      case 2:
        return _Slide(
          title: l10n.rebrandSlideWidgetTitle,
          body: l10n.rebrandSlideWidgetBody,
          demo: const _WidgetDemo(),
        );
      case 3:
        return _Slide(
          title: l10n.rebrandSlideQueueTitle,
          body: l10n.rebrandSlideQueueBody,
          demo: const _QueueDemo(),
        );
      case 4:
        return _Slide(
          title: l10n.rebrandSlideOutputTitle,
          body: l10n.rebrandSlideOutputBody,
          demo: const _OutputDemo(),
        );
      case 5:
        return _Slide(
          title: l10n.rebrandSlideLibraryTitle,
          body: l10n.rebrandSlideLibraryBody,
          demo: const _LibraryDemo(),
        );
      case 6:
        return _MoreSlide(l10n: l10n);
      default:
        return _SupportSlide(l10n: l10n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _page == 0 ? _continue() : unawaited(_goTo(_page - 1));
      },
      child: OnboardingBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v < -350) _next();
                if (v > 350) unawaited(_goTo(_page - 1));
              },
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(kOnboardingMargin, 12, 12, 0),
                    child: Row(
                      children: [
                        for (var i = 0; i < _kPageCount; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.only(right: 6),
                            width: i == _page ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: i == _page
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                        const Spacer(),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isLast ? 0 : 1,
                          child: TextButton(
                            onPressed: _isLast
                                ? null
                                : () => unawaited(_goTo(_kPageCount - 1)),
                            child: Text(
                              l10n.skip,
                              style:
                                  OnboardingText.small.copyWith(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: OnboardingExit(
                      presence: _presence,
                      child: KeyedSubtree(
                        key: ValueKey(_page),
                        child: _buildPage(l10n),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        kOnboardingMargin, 8, kOnboardingMargin, 20),
                    child: PrimaryButton(
                      label: _isLast ? l10n.continueButton : l10n.next,
                      onPressed: _next,
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

// ── Slides ───────────────────────────────────────────────────────────────────

final _slideTitle = OnboardingText.headline.copyWith(fontSize: 32);

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Each step lands about 0.6 s after the one before it.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kOnboardingMargin),
      child: LayoutBuilder(
        // Short (landscape) screens scale the whole slide down instead of overflowing.
        builder: (context, box) => FittedBox(
          child: SizedBox(
            width: math.min(box.maxWidth, 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassPanel(
                  order: 0,
                  radius: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  child: Image.asset(
                    'assets/images/logo/aurora_music_logo_old.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const _Arrow(order: 7),
                const GlassPanel(
                  order: 12,
                  radius: 24,
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 26),
                  child: _DrawnWordmark(width: 240, startAfterMs: 1250),
                ),
                const SizedBox(height: 28),
                Reveal(
                  order: 20,
                  child: Text(
                    l10n.rebrandTitle,
                    textAlign: TextAlign.center,
                    style: _slideTitle,
                  ),
                ),
                const SizedBox(height: 10),
                Reveal(
                  order: 22,
                  child: Text(
                    l10n.rebrandSubtitle,
                    textAlign: TextAlign.center,
                    style: OnboardingText.lead.copyWith(fontSize: 16),
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

class _Arrow extends StatelessWidget {
  const _Arrow({required this.order});

  final int order;

  @override
  Widget build(BuildContext context) => Reveal(
        order: order,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Icon(
            Icons.arrow_downward_rounded,
            color: Colors.white.withValues(alpha: 0.7),
            size: 28,
          ),
        ),
      );
}

/// The new wordmark, drawn stroke by stroke once it appears.
class _DrawnWordmark extends StatefulWidget {
  const _DrawnWordmark({required this.width, required this.startAfterMs});

  final double width;
  final int startAfterMs;

  @override
  State<_DrawnWordmark> createState() => _DrawnWordmarkState();
}

class _DrawnWordmarkState extends State<_DrawnWordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AnimatedLogo.duration,
  );
  late final Future<void> _ready = AnimatedLogo.preload();
  Timer? _delay;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (onboardingReduceMotion(context)) {
      _c.value = 1;
      return;
    }
    _delay = Timer(Duration(milliseconds: widget.startAfterMs), () {
      if (mounted) unawaited(_c.forward());
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _ready,
        builder: (context, _) => AnimatedLogo(
          animation: _c,
          width: widget.width,
          ghost: 0.18,
        ),
      );
}

class _Slide extends StatelessWidget {
  const _Slide({required this.title, required this.body, required this.demo});

  final String title;
  final String body;
  final Widget demo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: kOnboardingMargin),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: demo),
              const SizedBox(height: 32),
              Reveal(order: 4, child: Text(title, style: _slideTitle)),
              const SizedBox(height: 10),
              Reveal(order: 5, child: Text(body, style: OnboardingText.lead)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreSlide extends StatelessWidget {
  const _MoreSlide({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.tune_rounded, l10n.rebrandMoreSetup),
      (Icons.palette_outlined, l10n.rebrandMoreLook),
      (Icons.animation_rounded, l10n.rebrandMoreMotion),
      (Icons.chat_bubble_outline_rounded, l10n.rebrandMoreMessages),
      (Icons.speed_rounded, l10n.rebrandMorePerformance),
      (Icons.graphic_eq_rounded, l10n.rebrandMorePlayback),
      (Icons.search_rounded, l10n.rebrandMoreSearch),
      (Icons.build_circle_outlined, l10n.rebrandMoreFixes),
    ];
    // Same breathing room as the onboarding steps (StepScaffold): a tall page
    // still starts a good way down the screen and scrolls when it is longer
    // than the screen.
    final inset = (MediaQuery.sizeOf(context).height * 0.06).clamp(24.0, 72.0);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            kOnboardingMargin, inset, kOnboardingMargin, inset),
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight - inset * 2)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Reveal(
                  child: Text(l10n.rebrandSlideMoreTitle, style: _slideTitle)),
              const SizedBox(height: 20),
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                GlassPanel(
                  order: 2 + i * 2,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(rows[i].$1, color: Colors.white, size: 26),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(rows[i].$2, style: OnboardingText.lead),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportSlide extends StatelessWidget {
  const _SupportSlide({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: kOnboardingMargin),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassPanel(
                order: 0,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 40),
                    const SizedBox(height: 18),
                    Text(l10n.supportAuroraTitle, style: _slideTitle),
                    const SizedBox(height: 10),
                    Text(l10n.supportAuroraMessage, style: OnboardingText.lead),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (DonationService.enabled)
                GlassButton(
                  order: 3,
                  label: l10n.supportAuroraBtn,
                  onPressed: () =>
                      unawaited(DonationService.openBuyMeACoffee()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Interactive demos ────────────────────────────────────────────────────────

const _palette = [
  Color(0xFF7C5CFF),
  Color(0xFFFF6B6B),
  Color(0xFF2EC4B6),
  Color(0xFFFFB84D),
];

Widget _bar(double width, {double height = 10, double a = .3}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: a),
        borderRadius: BorderRadius.circular(height),
      ),
    );

/// Lyric lines that light up in turn; tap one to jump to it. The active line
/// carries its translation underneath, like translated lyrics do.
class _LyricsDemo extends StatefulWidget {
  const _LyricsDemo();

  @override
  State<_LyricsDemo> createState() => _LyricsDemoState();
}

class _LyricsDemoState extends State<_LyricsDemo> {
  static const _widths = [0.7, 0.5, 0.85, 0.6, 0.75];
  int _active = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) setState(() => _active = (_active + 1) % _widths.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      order: 0,
      padding: const EdgeInsets.all(22),
      child: SizedBox(
        width: 280,
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: _TranslateBadge(),
            ),
            for (var i = 0; i < _widths.length; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => _active = i);
                  _restart();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          width: 280 * _widths[i] * (i == _active ? 1 : 0.94),
                          height: i == _active ? 22 : 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white
                                .withValues(alpha: i == _active ? 0.95 : 0.2),
                          ),
                        ),
                        // The translated line, shown under the active one.
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topLeft,
                          child: i == _active
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    width: 280 * _widths[i] * 0.78,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A small pill with the translate icon and a few changing characters, hinting
/// that the lyrics below can be shown in another language.
class _TranslateBadge extends StatefulWidget {
  const _TranslateBadge();

  @override
  State<_TranslateBadge> createState() => _TranslateBadgeState();
}

class _TranslateBadgeState extends State<_TranslateBadge> {
  static const _languages = ['EN', 'ES', 'DE', 'हि', 'РУ', 'CZ', '日本'];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (mounted) setState(() => _index = (_index + 1) % _languages.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.translate_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              _languages[_index],
              key: ValueKey(_index),
              style: OnboardingText.small.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A mock of the new widget: the controls change the track and tint.
class _WidgetDemo extends StatefulWidget {
  const _WidgetDemo();

  @override
  State<_WidgetDemo> createState() => _WidgetDemoState();
}

class _WidgetDemoState extends State<_WidgetDemo> {
  int _track = 0;
  bool _playing = true;

  void _skip(int delta) =>
      setState(() => _track = (_track + delta) % _palette.length);

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      order: 0,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        width: 270,
        child: Column(
          children: [
            Row(
              children: [
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: _palette[_track]),
                  duration: const Duration(milliseconds: 450),
                  builder: (context, color, _) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color!, color.withValues(alpha: 0.45)],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(120, height: 12, a: .85),
                      const SizedBox(height: 8),
                      _bar(76, a: .4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: () => _skip(_palette.length - 1),
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                IconButton.filled(
                  iconSize: 32,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => setState(() => _playing = !_playing),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      key: ValueKey(_playing),
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: () => _skip(1),
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A small queue: drag the handle to reorder, swipe a row to remove it.
class _QueueDemo extends StatefulWidget {
  const _QueueDemo();

  @override
  State<_QueueDemo> createState() => _QueueDemoState();
}

class _QueueDemoState extends State<_QueueDemo> {
  List<int> _items = [0, 1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      order: 0,
      child: SizedBox(
        width: 300,
        height: 4 * 64.0,
        child: ReorderableListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _items.length,
          onReorderItem: (from, to) =>
              setState(() => _items.insert(to, _items.removeAt(from))),
          proxyDecorator: (child, _, __) => Material(
            color: Colors.transparent,
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            child: child,
          ),
          itemBuilder: (context, index) {
            final id = _items[index];
            return Dismissible(
              key: ValueKey(id),
              onDismissed: (_) {
                setState(() => _items.remove(id));
                if (_items.isEmpty) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) setState(() => _items = [0, 1, 2, 3]);
                  });
                }
              },
              child: Container(
                height: 56,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _palette[id % _palette.length],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bar(100, a: .75),
                          const SizedBox(height: 7),
                          _bar(60, height: 8, a: .35),
                        ],
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.drag_handle_rounded,
                            color: Colors.white60),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

const _accentGreen = Color(0xFF10B981);
const _accentAmber = Color(0xFFFFB74D);

/// The audio output picker: the highlighted row moves between a headset, the
/// phone and a watch; tap a row to send the sound there.
class _OutputDemo extends StatefulWidget {
  const _OutputDemo();

  @override
  State<_OutputDemo> createState() => _OutputDemoState();
}

class _OutputDemoState extends State<_OutputDemo> {
  int _selected = 0;
  Timer? _timer;

  static Widget _icon(int row, Color color) => switch (row) {
        0 => iconoir.Headset(color: color, width: 22, height: 22),
        1 => iconoir.SmartphoneDevice(color: color, width: 22, height: 22),
        _ => iconoir.Bluetooth(color: color, width: 22, height: 22),
      };

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (mounted) setState(() => _selected = (_selected + 1) % 3);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      order: 0,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 280,
        child: Column(
          children: [
            Row(
              children: [
                const iconoir.SoundHigh(
                    color: Colors.white, width: 22, height: 22),
                const SizedBox(width: 10),
                _bar(110, height: 12, a: .85),
              ],
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() => _selected = i);
                  _restart();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: i == _selected
                        ? _accentGreen.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: i == _selected
                          ? _accentGreen.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      _icon(i, i == _selected ? _accentGreen : Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _bar(i == 1 ? 96 : 120,
                              a: i == _selected ? .8 : .45),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: i == _selected ? 1 : 0,
                        child: const iconoir.Check(
                            color: _accentGreen, width: 20, height: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The duplicate-tracks review (tap a copy to keep it) above the new
/// playlist tiles.
class _LibraryDemo extends StatefulWidget {
  const _LibraryDemo();

  @override
  State<_LibraryDemo> createState() => _LibraryDemoState();
}

class _LibraryDemoState extends State<_LibraryDemo> {
  int _keep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      if (mounted) setState(() => _keep = (_keep + 1) % 2);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _copy(int index) {
    final selected = index == _keep;
    return GestureDetector(
      onTap: () {
        setState(() => _keep = index);
        _restart();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            selected
                ? const iconoir.CheckCircle(
                    color: _accentAmber, width: 20, height: 20)
                : const iconoir.Circle(
                    color: Colors.white38, width: 20, height: 20),
            const SizedBox(width: 10),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _palette[index],
              ),
            ),
            const SizedBox(width: 10),
            _bar(index == 0 ? 90 : 70, a: .6),
          ],
        ),
      ),
    );
  }

  Widget _tile(int index) => Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(14)),
                gradient: LinearGradient(
                  colors: [
                    _palette[index],
                    _palette[index].withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _bar(52, a: .55)),
            const SizedBox(width: 10),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      order: 0,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 280,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: _accentAmber.withValues(alpha: 0.12),
                border: Border.all(color: _accentAmber.withValues(alpha: 0.45)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const iconoir.Copy(
                          color: _accentAmber, width: 22, height: 22),
                      const SizedBox(width: 10),
                      _bar(120, height: 12, a: .85),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _copy(0),
                  const SizedBox(height: 6),
                  _copy(1),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _tile(0)),
                const SizedBox(width: 8),
                Expanded(child: _tile(1)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _tile(2)),
                const SizedBox(width: 8),
                Expanded(child: _tile(3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
