import 'shared/services/permission_guarded_audio_query.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'core/constants/app_config.dart';
import 'shared/services/audio_player_service.dart';
import 'shared/services/online_discovery_service.dart';
import 'shared/models/artist_utils.dart';
import 'shared/services/audio_handler.dart';
import 'shared/services/error_tracking_service.dart';
import 'shared/services/notification_manager.dart';
import 'shared/services/audio_constants.dart';
import 'shared/services/background_manager_service.dart';
import 'shared/services/sleep_timer_controller.dart';
import 'shared/services/artist_separator_service.dart';
import 'shared/services/home_layout_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/features.dart';
import 'features/splash/animated_logo.dart';
import 'l10n/locale_provider.dart';
import 'shared/providers/providers.dart';
import 'shared/utils/app_text_scaler.dart';
import 'shared/widgets/expanding_player.dart';
import 'shared/widgets/motion/musicfy_motion.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'firebase_options.dart';
import 'shared/services/device_performance_service.dart' show PerformanceLevel;
import 'shared/services/artwork_cache_service.dart';
import 'shared/services/audio_analysis/audio_analysis_diagnostics.dart';
import 'shared/services/effect_support.dart';
import 'shared/services/equalizer_service.dart';
import 'shared/services/remote_config_helper.dart';
import 'shared/services/smart_playlist_service.dart';
import 'shared/services/track_tag_service.dart';

/// Global navigator key for the ROOT navigator.
///
/// The root navigator hosts only transient popups that must appear *above* the
/// mini player: dialogs, menus and bottom sheets (the latter via
/// `useRootNavigator: true`). All in-app pages live in [pageNavigatorKey].
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global navigator key for the inner PAGE navigator.
///
/// Hosts every full-screen page (splash, home, detail, settings, now playing).
/// The mini player is painted directly above this navigator but below the root
/// navigator, so it floats over pages yet stays beneath dialogs/menus/sheets.
final GlobalKey<NavigatorState> pageNavigatorKey = GlobalKey<NavigatorState>();

/// Global audio handler instance
late AuroraAudioHandler audioHandler;

/// Global equalizer effect — attached to the player via AudioPipeline
late AndroidEqualizer equalizer;

/// Creates the audio handler (custom, with no stop button in the notification).
Future<AuroraAudioHandler> _initAudioHandler() async {
  final eq = AndroidEqualizer();
  equalizer = eq;
  // A player whose pipeline holds an equalizer fails to start when the device
  // can't create the effect, so the equalizer is only attached when it can.
  await EffectSupport.probe();
  final player = EffectSupport.equalizerAvailable
      ? AudioPlayer(audioPipeline: AudioPipeline(androidAudioEffects: [eq]))
      : AudioPlayer();
  return AudioService.init(
    builder: () => AuroraAudioHandler(player),
    config: const AudioServiceConfig(
      androidNotificationChannelId: AppConfig.androidNotificationChannelId,
      androidNotificationChannelName: AppConfig.androidNotificationChannelName,
      androidStopForegroundOnPause: false,
      // Monochrome status-bar notification icon (white silhouette on transparent).
      androidNotificationIcon: 'drawable/ic_stat_music',
      // Without this, audio_service decodes the full-resolution album art and
      // builds the notification with it on the main thread, which can ANR
      // (FLUTTER-9E) on large embedded covers.
      artDownscaleWidth: 512,
      artDownscaleHeight: 512,
    ),
  );
}

/// Configures caches and transition complexity for a device tier.
void _applyMemoryTuning(PerformanceLevel level) {
  final imageCache = PaintingBinding.instance.imageCache;
  switch (level) {
    case PerformanceLevel.high:
      imageCache.maximumSize = AppConfig.imageCacheMaxSize;
      imageCache.maximumSizeBytes = AppConfig.imageCacheMaxSizeBytes;
    case PerformanceLevel.medium:
      imageCache.maximumSize = 80;
      imageCache.maximumSizeBytes = 56 * 1024 * 1024;
    case PerformanceLevel.low:
      imageCache.maximumSize = 50;
      imageCache.maximumSizeBytes = 32 * 1024 * 1024;
  }
  ArtworkCacheService.applyPerformanceLevel(level);
  MusicfyPageTransitionsBuilder.simple = level == PerformanceLevel.low;
}

/// Application entry point
void main() async {
  try {
    // Initialize error tracking
    final errorTracker = ErrorTrackingService();

    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    PermissionGuardedAudioQuery.install();

    // Kick off the slow native initialisations concurrently instead of one
    // after another: on low-end devices they dominate time-to-first-frame.
    // Firebase requires google-services.json at android/app/
    final firebaseInit =
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final audioInit = _initAudioHandler();
    AudioAnalysisDiagnostics.startIfEnabled();

    // Silence all debug output in release builds — kDebugMode is a
    // compile-time constant so the AOT compiler eliminates this in debug.
    if (!kDebugMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }

    // Resolve the device tier before the first frame so the splash and
    // onboarding already use the right effects for this hardware.
    final performanceProvider = PerformanceModeProvider();
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      ArtistSeparatorService().initialize(),
      HomeLayoutService().initialize(),
      performanceProvider.initialize(),
      AnimatedLogo.preload(),
    ]);
    final prefs = results[0] as SharedPreferences;
    final languageCode =
        prefs.getString('languageCode') ?? AppConfig.defaultLanguageCode;

    // Size the decoded-image and artwork caches for this device's tier, and
    // re-tune if the tier changes later (manual choice or runtime step-down).
    _applyMemoryTuning(performanceProvider.currentMode);
    // Switching the interface style applies live. Anything cached at the old
    // tier (decoded images, artwork thumbnails at the old resolution) is
    // dropped so memory and artwork sizes match the new tier straight away.
    var appliedLevel = performanceProvider.currentMode;
    performanceProvider.addListener(() {
      final level = performanceProvider.currentMode;
      _applyMemoryTuning(level);
      if (level == appliedLevel) return;
      appliedLevel = level;
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache
        ..clear()
        ..clearLiveImages();
      ArtworkCacheService().clearCache();
    });

    await firebaseInit;

    // Fetch the Remote Config values early so the announcement, goal and
    // switches are ready by the time the home screen asks for them.
    unawaited(RemoteConfigHelper.instance());

    // Disable performance data collection in debug to keep overhead low
    if (kDebugMode) {
      unawaited(
          FirebasePerformance.instance.setPerformanceCollectionEnabled(false));
    }

    // Route all Flutter framework errors to Sentry + Firebase Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      unawaited(errorTracker.recordError(details.exception, details.stack));
      unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(details));
    };

    // Catch uncaught async errors that escape the Flutter framework
    // (e.g. errors from platform channels, plugin callbacks, isolates).
    // Returning true marks the error as handled and prevents app termination.
    ui.PlatformDispatcher.instance.onError = (error, stack) {
      // Fire-and-forget — onError must be synchronous.
      unawaited(errorTracker.recordError(error, stack));
      unawaited(
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
      return true;
    };

    audioHandler = await audioInit;

    // Launch the application with all required providers
    await SentryFlutter.init((options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      // Tracing/profiling is real work on the UI thread: scale it with the
      // device tier and skip it entirely on weak hardware.
      final tier = performanceProvider.currentMode;
      final lowEnd = tier == PerformanceLevel.low;
      options.tracesSampleRate = lowEnd ? 0.0 : 0.2;
      // ignore: experimental_member_use
      options.profilesSampleRate = switch (tier) {
        PerformanceLevel.high => 0.2,
        PerformanceLevel.medium => 0.05,
        PerformanceLevel.low => 0.0,
      };
      options.enableFramesTracking = !lowEnd;
      options.enableUserInteractionTracing = !lowEnd;
    }, appRunner: () {
      final app = MultiProvider(
        providers: [
          // Use lazy initialization for better startup performance
          ChangeNotifierProvider(create: (_) => AudioPlayerService()),
          ChangeNotifierProvider(create: (_) => ThemeProvider(), lazy: false),
          ChangeNotifierProvider(
              create: (_) => EqualizerService(), lazy: false),
          ChangeNotifierProvider.value(value: performanceProvider),
          ChangeNotifierProvider(
              create: (_) => BackgroundManagerService(), lazy: false),
          ChangeNotifierProvider(
              create: (_) => SleepTimerController(), lazy: true),
          ChangeNotifierProvider.value(value: ArtistSeparatorService()),
          ChangeNotifierProvider.value(value: HomeLayoutService()),
          ChangeNotifierProvider(
              create: (_) => SmartPlaylistService()..load(), lazy: false),
          ChangeNotifierProvider(
              create: (_) => TrackTagService()..load(), lazy: false),
          Provider<ErrorTrackingService>.value(value: errorTracker),
        ],
        child: Builder(
          builder: (context) {
            // Connect the services after providers are initialized
            final audioPlayerService =
                Provider.of<AudioPlayerService>(context, listen: false);
            final backgroundManager =
                Provider.of<BackgroundManagerService>(context, listen: false);

            // Set the background manager in the audio player service
            audioPlayerService.setBackgroundManager(backgroundManager);

            OnlineDiscoveryService.instance.localTracks = (artist) {
              final wanted = artist.toLowerCase();
              return [
                for (final s in audioPlayerService.songs)
                  if (splitArtists(s.artist ?? '')
                      .any((a) => a.toLowerCase() == wanted))
                    OnlineTrack(title: s.title, albumTitle: s.album),
              ];
            };

            // Give the crossfade engine a way to build an equalizer-equipped
            // pipeline for the standby player used during non-gapless
            // crossfade hand-offs (gapless crossfades never swap players, so
            // they always keep the original equalizer pipeline untouched).
            if (EffectSupport.equalizerAvailable) {
              audioPlayerService.attachCrossfadePipelineFactory(
                () => AudioPipeline(androidAudioEffects: [AndroidEqualizer()]),
              );
            }

            // Initialize performance provider and equalizer eagerly
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              performanceProvider.startFrameMonitor();
              final equalizerService =
                  Provider.of<EqualizerService>(context, listen: false);
              if (!equalizerService.initialized) {
                await equalizerService.init(equalizer);
              }
            });

            return MyApp(
              languageCode: languageCode,
            );
          },
        ),
      );
      return runApp(
        SentryWidget(
          child: app,
        ),
      );
    });
  } catch (e, stack) {
    final errorTracker = ErrorTrackingService();
    await errorTracker.recordError(e, stack);
    rethrow;
  }
}

/// Root application widget
class MyApp extends StatefulWidget {
  final String languageCode;

  const MyApp({super.key, required this.languageCode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ui.Locale _locale;
  StreamSubscription<bool>? _notificationClickSub;

  @override
  void initState() {
    super.initState();
    _locale = ui.Locale(widget.languageCode);
    WidgetsBinding.instance.addObserver(this);

    // Listen for notification clicks to expand the player
    _notificationClickSub = AudioService.notificationClicked.listen((clicked) {
      if (clicked) {
        // Expand the mini player to show Now Playing screen
        ExpandingPlayer.expand();
      }
    });

    // Sync liked playlist name with the current locale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final audioService =
            Provider.of<AudioPlayerService>(context, listen: false);
        audioService.updateLikedPlaylistName(
            lookupAppLocalizations(_locale).favoriteSongs);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _notificationClickSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes back to foreground, sync playback state
    // This ensures UI reflects any changes made via lock screen controls
    if (state == AppLifecycleState.resumed) {
      try {
        final audioService =
            Provider.of<AudioPlayerService>(context, listen: false);
        audioService.syncPlaybackState();
        // Two-way sync playlists with the configured folder (no-op if unset).
        unawaited(audioService.syncPlaylistsWithFolder());
      } catch (e) {
        // Ignore errors if context is not available
      }
    }

    // When app is detached (swiped from recents), stop audio and clean up
    if (state == AppLifecycleState.detached) {
      _cleanupAndExit();
    }
  }

  Future<void> _cleanupAndExit() async {
    try {
      final audioService =
          Provider.of<AudioPlayerService>(context, listen: false);
      await audioService.stop();
    } catch (e) {
      // Ignore errors during cleanup
    }
  }

  /// Updates the application locale and persists the selection
  void setLocale(ui.Locale locale) {
    setState(() {
      _locale = locale;
    });

    // Update liked playlist name for the new locale
    try {
      final audioService =
          Provider.of<AudioPlayerService>(context, listen: false);
      audioService.updateLikedPlaylistName(
          lookupAppLocalizations(locale).favoriteSongs);
    } catch (_) {}

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('languageCode', locale.languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final lowEnd =
        context.select<PerformanceModeProvider, bool>((p) => p.isLowEndDevice);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Update theme provider with dynamic colors
        if (lightDynamic != null || darkDynamic != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            themeProvider.setDynamicColorSchemes(lightDynamic, darkDynamic);
          });
        }

        return LocaleProvider(
          locale: _locale,
          setLocale: setLocale,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            locale: _locale,
            themeMode: ThemeMode.dark,
            darkTheme: themeProvider.darkThemeFor(accentSolids: lowEnd),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              final l10n = AppLocalizations.of(context);
              MediaFallbackLabels.unknownArtist = l10n.unknownArtist;
              MediaFallbackLabels.unknownAlbum = l10n.unknownAlbum;
              audioHandler.setBrowseTitles(
                songs: l10n.songs,
                albums: l10n.albums,
                artists: l10n.artists,
                playlists: l10n.playlists,
              );
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: AppTextScaler(media.textScaler),
                ),
                child: HeroControllerScope(
                  controller: HeroController(
                    createRectTween: (Rect? begin, Rect? end) {
                      return MaterialRectCenterArcTween(begin: begin, end: end);
                    },
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            // The root navigator's single page is the app shell: an inner page
            // navigator with the mini player painted directly above it. Dialogs,
            // menus and sheets are pushed onto the root navigator (sheets use
            // `useRootNavigator: true`), so they render above the mini player,
            // while normal pages — hosted by the inner navigator — render below
            // it. This separation is what keeps the mini player layered
            // correctly without fighting the navigator's overlay ordering.
            home: _AppShell(observers: [
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
            ]),
          ),
        );
      },
    );
  }
}

/// The app shell: an inner page [Navigator] with the mini player painted on
/// top of it. The inner navigator hosts every full-screen page; the mini
/// player floats above those pages. Because dialogs/menus/sheets are pushed
/// onto the *root* navigator (above this whole shell), they always cover the
/// mini player.
class _AppShell extends StatefulWidget {
  final List<NavigatorObserver> observers;

  const _AppShell({required this.observers});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  // The inner navigator needs its own hero controller so hero animations work
  // between pages (the root navigator has a separate one from MaterialApp).
  final HeroController _heroController = HeroController(
    createRectTween: (Rect? begin, Rect? end) =>
        MaterialRectCenterArcTween(begin: begin, end: end),
  );
  StreamSubscription<PlaybackError>? _playbackErrorSub;

  @override
  void initState() {
    super.initState();
    // Surface playback errors (e.g. a corrupted/unplayable file) as a toast —
    // previously this stream had no listener anywhere, so failures were silent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final audioService =
          Provider.of<AudioPlayerService>(context, listen: false);
      _playbackErrorSub = audioService.errorStream.listen((error) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        final title = error.title;
        final message = switch (error.kind) {
          PlaybackErrorKind.invalidPlaylist => l10n.playbackInvalidPlaylist,
          PlaybackErrorKind.couldNotPlaySkipping => title != null
              ? l10n.playbackCouldNotPlayTitleSkipping(title)
              : l10n.playbackCouldNotPlaySkipping,
          PlaybackErrorKind.couldNotPlay => title != null
              ? l10n.playbackCouldNotPlayTitle(title)
              : l10n.playbackFailed,
          PlaybackErrorKind.playbackFailed => l10n.playbackFailed,
          PlaybackErrorKind.setPlaylistFailed =>
            l10n.playbackSetPlaylistFailed(error.detail ?? ''),
          PlaybackErrorKind.updatePlaylistFailed =>
            l10n.playbackUpdatePlaylistFailed(error.detail ?? ''),
        };
        NotificationManager.showMessage(context, message);
      });
    });
  }

  @override
  void dispose() {
    _playbackErrorSub?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Page layer — every full-screen route lives here, below the mini player.
        Positioned.fill(
          child: NavigatorPopHandler(
            // System back: when the root navigator has nothing to pop (no
            // dialog/sheet open), forward the gesture to the inner navigator.
            onPopWithResult: (_) => pageNavigatorKey.currentState?.maybePop(),
            child: HeroControllerScope(
              controller: _heroController,
              child: Navigator(
                key: pageNavigatorKey,
                observers: widget.observers,
                onGenerateRoute: (settings) => MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => const SplashScreen(),
                ),
              ),
            ),
          ),
        ),
        // Mini player layer — floats above pages, below root-navigator popups.
        const Positioned.fill(child: ExpandingPlayer()),
      ],
    );
  }
}
