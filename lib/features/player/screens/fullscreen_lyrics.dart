import 'dart:async';
import 'dart:math' as math;
import 'package:aurora_music_v01/core/constants/font_constants.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/models.dart';
import '../widgets/lyrics/lyrics_widgets.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/notification_manager.dart';
import '../../../shared/services/lyrics_service.dart';
import '../../../shared/services/lyrics_providers/lyrics_provider.dart';
import '../../../shared/services/lyrics_translation_service.dart';
import '../widgets/translate_language_picker.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glassmorphic_dialog.dart';
import '../widgets/player_page_header.dart';
import '../widgets/player_page_route.dart';
import 'lyrics_editor_screen.dart';

enum _TranslationState { idle, loading, done, error }

class FullscreenLyricsScreen extends StatefulWidget {
  final void Function(List<TimedLyric>)? onLyricsChanged;

  /// Where the shared cover/title/artist land when the page is opened with
  /// the shared-element transition.
  final PlayerPageTargets? targets;

  const FullscreenLyricsScreen({
    super.key,
    this.onLyricsChanged,
    this.targets,
  });

  @override
  State<FullscreenLyricsScreen> createState() => _FullscreenLyricsScreenState();
}

class _FullscreenLyricsScreenState extends State<FullscreenLyricsScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  int _currentLyricIndex = 0;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _playingSubscription;
  late final LyricsClock _clock;
  late final LyricsStagger _stagger;
  late final AnimationController _recenterCtl;
  late final AnimationController _immersionCtl;
  final PlayerPageTargets _fallbackTargets = PlayerPageTargets();
  PlayerPageTargets get _targets => widget.targets ?? _fallbackTargets;

  /// Chrome (header and controls) tucked away so the lyrics have the screen.
  bool _immersive = false;
  Timer? _immersiveTimer;
  bool _autoHideChrome = false;
  bool _userScrolling = false;
  double _lastScrollPixels = 0;
  double _recenterFrom = 0;
  double _recenterTo = 0;
  double _recenterLastPixels = 0;
  int _recenterAnchorRow = 0;

  /// The first positioning after lyrics load puts the line straight at its
  /// resting place; animating there from the top would scroll through the
  /// whole song.
  bool _placeInstantly = false;
  bool _refiningPlacement = false;

  // Rows are the sung lines interleaved with instrumental-gap dot rows.
  List<LyricsRow> _rows = [];
  Map<int, int> _lineRow = {};
  int? _activeInterludeRow;
  bool _blurEnabled = true;
  StreamSubscription<SongModel?>? _songChangeSubscription;

  // Auto-scroll-to-current-lyric is paused while the user is manually
  // scrolling, and resumes a short while after they stop.
  bool _autoFollowPaused = false;
  Timer? _resumeAutoFollowTimer;

  final GlobalKey _scrollKey = GlobalKey();
  Map<int, GlobalKey> _rowKeys = {};

  List<TimedLyric>? _currentLyrics;
  int? _lastSongId;
  bool _isLoadingLyrics = false;

  // Translation
  _TranslationState _translationState = _TranslationState.idle;
  List<String?> _translatedLines = [];
  bool _showTranslated = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // Settings
  double _fontSize = 1.0; // Multiplier: 0.8, 1.0, 1.2, 1.4
  int _syncOffset = 0; // In milliseconds

  static const String _fontSizeKey = 'lyrics_font_size';
  static const String _syncOffsetKey = 'lyrics_sync_offset';
  static const String _blurKey = 'lyrics_blur_enabled';
  static const String _autoHideKey = 'lyrics_auto_hide_chrome';

  /// Idle time before the header and controls tuck away.
  static const Duration _immersiveDelay = Duration(milliseconds: 3500);

  /// Where the active line rests, as a fraction of the viewport height; never
  /// less than one lyric row so the line just sung stays in view above it.
  static const double _restFraction = 0.44;
  static const double _minRestPx = 72;

  @override
  void initState() {
    super.initState();
    _clock = LyricsClock(this)..addListener(_onClockTick);
    _stagger = LyricsStagger(this);
    _recenterCtl = AnimationController(
      vsync: this,
      duration: kLyricsRecenterDuration,
    )..addListener(_onRecenterTick);
    _immersionCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _loadSettings();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioService =
          Provider.of<AudioPlayerService>(context, listen: false);
      _loadLyricsForCurrentSong(audioService);

      final player = audioService.audioPlayer;
      void syncClock() => _clock.sync(player.position,
          playing: player.playing, speed: player.speed);
      syncClock();
      _positionSubscription = player.positionStream.listen((_) {
        if (mounted) syncClock();
      });
      _playingSubscription = player.playingStream.listen((_) {
        if (mounted) syncClock();
      });

      _songChangeSubscription = audioService.currentSongStream.listen((song) {
        if (mounted && song != null && song.id != _lastSongId) {
          _loadLyricsForCurrentSong(audioService);
        }
      });

      TimedLyricsService()
          .lyricsRevisionNotifier
          .addListener(_onLyricsRevisionChanged);
    });
  }

  void _onLyricsRevisionChanged() {
    if (!mounted) return;
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);
    if (audioService.currentSong == null) return;
    // Force a reload for the current song even though its id hasn't
    // changed — the lyrics content itself was just edited.
    setState(() => _lastSongId = null);
    _loadLyricsForCurrentSong(audioService);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble(_fontSizeKey) ?? 1.0;
      _syncOffset = prefs.getInt(_syncOffsetKey) ?? 0;
      _blurEnabled = prefs.getBool(_blurKey) ?? true;
      _autoHideChrome = prefs.getBool(_autoHideKey) ?? false;
      _clock.offsetMs = _syncOffset;
    });
    if (_autoHideChrome) _scheduleImmersive();
  }

  Future<void> _toggleAutoHide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoHideKey, !_autoHideChrome);
    if (!mounted) return;
    setState(() => _autoHideChrome = !_autoHideChrome);
    if (_autoHideChrome) {
      _scheduleImmersive();
    } else {
      _immersiveTimer?.cancel();
      _setImmersive(false);
    }
  }

  Future<void> _toggleBlur() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_blurKey, !_blurEnabled);
    if (mounted) setState(() => _blurEnabled = !_blurEnabled);
  }

  Future<void> _saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
    setState(() => _fontSize = size);
  }

  Future<void> _saveSyncOffset(int offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_syncOffsetKey, offset);
    setState(() {
      _syncOffset = offset;
      _clock.offsetMs = offset;
    });
  }

  /// Identifies the newest load; an older one that finishes later must not
  /// replace (or blank out) what a newer one already showed.
  int _lyricsLoadSeq = 0;

  Future<void> _loadLyricsForCurrentSong(
      AudioPlayerService audioService) async {
    final song = audioService.currentSong;
    if (song == null) return;

    if (_lastSongId == song.id && _currentLyrics != null) return;
    final loadSeq = ++_lyricsLoadSeq;

    setState(() {
      _isLoadingLyrics = true;
      _lastSongId = song.id;
    });

    final timedLyricsService = TimedLyricsService();
    final artistRaw = song.artist ?? '';
    final titleRaw = song.title;
    final artist = artistRaw.trim().isEmpty ? 'Unknown' : artistRaw.trim();
    final title = titleRaw.trim().isEmpty ? 'Unknown' : titleRaw.trim();

    final songDuration = (song.duration ?? 0) > 0
        ? Duration(milliseconds: song.duration!)
        : audioService.audioPlayer.duration;
    // Whatever is cached was accepted when it was saved (or picked by the
    // user), so it is shown as is rather than re-judged against the song.
    var lyrics = await timedLyricsService.loadLyricsFromFile(artist, title);
    if (!mounted ||
        loadSeq != _lyricsLoadSeq ||
        audioService.currentSong?.id != song.id) {
      return;
    }

    lyrics ??= await timedLyricsService.fetchTimedLyrics(
      artist,
      title,
      songDuration: songDuration,
      audioPath: song.data,
      album: song.album,
    );
    if (!mounted ||
        loadSeq != _lyricsLoadSeq ||
        audioService.currentSong?.id != song.id) {
      return;
    }

    // Reset translation whenever new lyrics are loaded for a different song.
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _currentLyrics = lyrics;
      _isLoadingLyrics = false;
      _translationState = _TranslationState.idle;
      _translatedLines = [];
      _showTranslated = false;
      _rebuildRows();
    });

    _recenterCtl.stop();
    _stagger.clear();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    // New song — resume auto-follow even if paused from the previous song.
    _resumeAutoFollowTimer?.cancel();
    _autoFollowPaused = false;
  }

  void _rebuildRows() {
    final lyrics = _currentLyrics ?? const <TimedLyric>[];
    _rows = LyricsTiming.buildRows(lyrics);
    _lineRow = {};
    _rowKeys = {};
    for (var i = 0; i < _rows.length; i++) {
      _rowKeys[i] = GlobalKey();
      if (!_rows[i].isInterlude) _lineRow[_rows[i].lineIndex] = i;
    }
    _currentLyricIndex = 0;
    _activeInterludeRow = null;
    _placeInstantly = true;
    // Pick the right line straight away, even while paused.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onClockTick();
    });
  }

  int get _focusRow => _activeInterludeRow ?? _lineRow[_currentLyricIndex] ?? 0;

  void _onClockTick() {
    final lyrics = _currentLyrics;
    if (lyrics == null || lyrics.isEmpty) return;
    final ms = _clock.value;

    // Binary search: find the last lyric whose time <= position.
    int lo = 0, hi = lyrics.length - 1, newIndex = 0;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (lyrics[mid].time.inMilliseconds <= ms) {
        newIndex = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }

    int? interlude;
    for (var i = 0; i < _rows.length; i++) {
      final gap = _rows[i].interlude;
      if (gap != null && ms >= gap.startMs && ms < gap.endMs) {
        interlude = i;
        break;
      }
    }

    final changed =
        newIndex != _currentLyricIndex || interlude != _activeInterludeRow;
    if (changed) {
      setState(() {
        _currentLyricIndex = newIndex;
        _activeInterludeRow = interlude;
      });
    }
    if ((changed || _placeInstantly) && !_autoFollowPaused) {
      // After a state change the focused row's widget exists next frame.
      if (_placeInstantly) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToCurrentLyric();
        });
      } else {
        _scrollToCurrentLyric();
      }
    }
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      // User-initiated drag — stop fighting them for scroll control.
      _resumeAutoFollowTimer?.cancel();
      _immersiveTimer?.cancel();
      _recenterCtl.stop();
      _userScrolling = true;
      _lastScrollPixels = notification.metrics.pixels;
      if (!_autoFollowPaused) setState(() => _autoFollowPaused = true);
    } else if (notification is ScrollUpdateNotification && _userScrolling) {
      // Scrolling down tucks the chrome away, scrolling up brings it back.
      final delta = notification.metrics.pixels - _lastScrollPixels;
      if (delta.abs() > 6) {
        _lastScrollPixels = notification.metrics.pixels;
        _setImmersive(delta > 0);
      }
    } else if (notification is ScrollEndNotification) {
      _userScrolling = false;
      _resumeAutoFollowTimer?.cancel();
      _resumeAutoFollowTimer = Timer(_immersiveDelay, () {
        if (!mounted) return;
        setState(() => _autoFollowPaused = false);
        _scrollToCurrentLyric();
      });
      if (!_immersive) _scheduleImmersive();
    }
  }

  void _scheduleImmersive() {
    _immersiveTimer?.cancel();
    if (!_autoHideChrome) return;
    _immersiveTimer = Timer(_immersiveDelay, () {
      if (mounted && !_userScrolling) _setImmersive(true);
    });
  }

  void _setImmersive(bool value) {
    if (_immersive == value) return;
    _immersive = value;
    if (value) {
      _immersionCtl.animateTo(1, curve: const Cubic(0.4, 0, 0.2, 1));
    } else {
      _immersionCtl.animateBack(0, curve: const Cubic(0.4, 0, 0.2, 1));
      _scheduleImmersive();
    }
  }

  /// Recentres the focused row: it rests near the top of the list, one row
  /// below the edge, with the line just sung still visible above it.
  void _scrollToCurrentLyric() {
    if (!_scrollController.hasClients) return;

    final row = _focusRow;
    final renderBox =
        _rowKeys[row]?.currentContext?.findRenderObject() as RenderBox?;
    final scrollBox =
        _scrollKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollBox == null) return;

    if (renderBox == null) {
      // Row not built yet (far down the list): get close, then refine once
      // it exists.
      if (_refiningPlacement || _rows.isEmpty) return;
      _refiningPlacement = true;
      final position = _scrollController.position;
      _scrollController.jumpTo(
        (position.maxScrollExtent * row / _rows.length)
            .clamp(0.0, position.maxScrollExtent),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refiningPlacement = false;
        if (mounted) _scrollToCurrentLyric();
      });
      return;
    }

    var top = renderBox.localToGlobal(Offset.zero, ancestor: scrollBox).dy;

    if (row > 0 && _rows[row - 1].isInterlude) {
      // The dots above are collapsing in this same scroll, which lifts the
      // row by their height on its own; scroll only the rest.
      final above =
          _rowKeys[row - 1]?.currentContext?.findRenderObject() as RenderBox?;
      if (above != null) top -= above.size.height;
    }

    final rest = math.max(
        (scrollBox.size.height - renderBox.size.height) / 2, _minRestPx);
    final position = _scrollController.position;
    final target = (_scrollController.offset + top - rest)
        .clamp(0.0, position.maxScrollExtent);

    if (_placeInstantly) {
      _placeInstantly = false;
      _recenterCtl.stop();
      _scrollController.jumpTo(target);
      return;
    }

    _recenterFrom = position.pixels;
    _recenterTo = target;
    _recenterLastPixels = position.pixels;
    _recenterAnchorRow = row;
    _recenterCtl
      ..stop()
      ..value = 0
      ..forward();
  }

  double _restOffset(double viewportHeight) =>
      math.max(viewportHeight * _restFraction, _minRestPx);

  void _onRecenterTick() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final t = kLyricsRecenterCurve.transform(_recenterCtl.value);
    final next = (_recenterFrom + (_recenterTo - _recenterFrom) * t)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    _scrollController.jumpTo(next);

    final consumed = position.pixels - _recenterLastPixels;
    _recenterLastPixels = position.pixels;
    if (consumed != 0) {
      // Rows below the active line hold back by what just scrolled, then
      // catch up on their own: the further down, the later.
      _stagger.addScroll(
        consumed,
        [
          for (var r = _recenterAnchorRow + 1;
              r <= _recenterAnchorRow + 16 && r < _rows.length;
              r++)
            r,
        ],
        _recenterAnchorRow,
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playingSubscription?.cancel();
    _songChangeSubscription?.cancel();
    _clock.dispose();
    _resumeAutoFollowTimer?.cancel();
    _immersiveTimer?.cancel();
    _recenterCtl.dispose();
    _immersionCtl.dispose();
    _stagger.dispose();
    TimedLyricsService()
        .lyricsRevisionNotifier
        .removeListener(_onLyricsRevisionChanged);
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);

    if (audioService.currentSong != null &&
        audioService.currentSong!.id != _lastSongId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadLyricsForCurrentSong(audioService);
        }
      });
    }

    final route = PlayerPageScope.maybeOf(context)?.route;
    final topInset = MediaQuery.paddingOf(context).top;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            if (!_immersive) _scheduleImmersive();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _chrome(
                      route: route,
                      fromTop: true,
                      child: _buildHeader(audioService, route),
                    ),
                    Expanded(
                      child: _isLoadingLyrics
                          ? _buildLoadingView()
                          : (_currentLyrics == null || _currentLyrics!.isEmpty)
                              ? _buildNoLyricsView(audioService)
                              : _buildLyricsView(),
                    ),
                    _chrome(
                      route: route,
                      fromTop: false,
                      child: _buildControls(audioService),
                    ),
                  ],
                ),
              ),

              // While the chrome is tucked away, a tap at the top brings it back.
              AnimatedBuilder(
                animation: _immersionCtl,
                builder: (context, _) => _immersionCtl.value > 0.5
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: topInset + 72,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _setImmersive(false),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Translate button — bottom-right, above controls
              if (_currentLyrics != null && _currentLyrics!.isNotEmpty)
                Positioned(
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 152,
                  child: AnimatedBuilder(
                    animation: _immersionCtl,
                    builder: (context, child) => Opacity(
                      opacity: 1 - _immersionCtl.value,
                      child: IgnorePointer(
                        ignoring: _immersionCtl.value > 0.5,
                        child: child,
                      ),
                    ),
                    child: _buildFloatingTranslateButton(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header/controls: fades in as the page opens, and collapses away (with
  /// the lyrics growing into the space) in immersive mode.
  Widget _chrome({
    required PlayerPageRoute<dynamic>? route,
    required bool fromTop,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _immersionCtl,
        if (route != null) route.progress,
      ]),
      child: child,
      builder: (context, child) {
        final imm = _immersionCtl.value;
        final enter = route == null
            ? 1.0
            : _smoothstep((route.progress.value - 0.22) / 0.5);
        return ClipRect(
          child: Align(
            alignment: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
            heightFactor: (1 - imm).clamp(0.0, 1.0),
            child: Opacity(
              opacity: ((1 - imm) * enter).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (fromTop ? -24 : 24) * imm),
                child: IgnorePointer(ignoring: imm > 0.5, child: child),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    AudioPlayerService audioService,
    PlayerPageRoute<dynamic>? route,
  ) {
    return PlayerPageHeader(
      song: audioService.currentSong,
      targets: _targets,
      route: route,
      onCoverTap: () {
        if (_immersive) {
          _setImmersive(false);
        } else if (mounted) {
          Navigator.pop(context);
        }
      },
      trailing: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
          color: Colors.grey.shade900,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) => _handleMenuAction(value, audioService),
          itemBuilder: (context) => [
            _buildMenuItem(Icons.refresh,
                AppLocalizations.of(context).refreshLyrics, 'refresh'),
            _buildMenuItem(Icons.search,
                AppLocalizations.of(context).searchLyrics, 'search'),
            _buildMenuItem(Icons.timer_outlined,
                AppLocalizations.of(context).adjustSync, 'sync'),
            _buildMenuItem(Icons.text_fields,
                AppLocalizations.of(context).fontSize, 'font_size'),
            _buildMenuItem(
                Icons.blur_on_rounded,
                _blurEnabled
                    ? AppLocalizations.of(context).lyricsBlurOn
                    : AppLocalizations.of(context).lyricsBlurOff,
                'toggle_blur'),
            _buildMenuItem(
                Icons.fullscreen_rounded,
                _autoHideChrome
                    ? AppLocalizations.of(context).lyricsAutoHideOn
                    : AppLocalizations.of(context).lyricsAutoHideOff,
                'toggle_auto_hide'),
            _buildMenuItem(Icons.edit_note_rounded,
                AppLocalizations.of(context).lyricsEditCreate, 'edit_lyrics'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      IconData icon, String text, String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, AudioPlayerService audioService) {
    switch (action) {
      case 'refresh':
        setState(() {
          _lastSongId = null;
        });
        _loadLyricsForCurrentSong(audioService);
        break;
      case 'search':
        _showSearchLyricsDialog(audioService);
        break;
      case 'sync':
        _showSyncAdjustDialog();
        break;
      case 'font_size':
        _showFontSizeDialog();
        break;
      case 'toggle_blur':
        _toggleBlur();
        break;
      case 'toggle_auto_hide':
        _toggleAutoHide();
        break;
      case 'edit_lyrics':
        _openLyricsEditor(audioService);
        break;
    }
  }

  void _openLyricsEditor(AudioPlayerService audioService) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LyricsEditorScreen(
          onSaved: () {
            if (mounted) {
              setState(() => _lastSongId = null);
              _loadLyricsForCurrentSong(audioService);
            }
          },
        ),
      ),
    );
  }

  final _translateAnchorKey = GlobalKey();

  Future<void> _handleTranslateButton({bool pickLanguage = false}) async {
    if (!mounted) return;
    final lyrics = _currentLyrics;
    if (lyrics == null || lyrics.isEmpty) return;

    // Already translated — just toggle visibility.
    if (_translationState == _TranslationState.done && !pickLanguage) {
      setState(() => _showTranslated = !_showTranslated);
      return;
    }

    if (_translationState == _TranslationState.loading) return;

    final targetLang = pickLanguage
        ? await pickLyricsTranslationLanguage(context)
        : await chooseLyricsTranslationTarget(context, _translateAnchorKey);
    if (targetLang == null || !mounted) return;

    setState(() => _translationState = _TranslationState.loading);
    unawaited(_pulseController.repeat(reverse: true));

    try {
      final audioService =
          Provider.of<AudioPlayerService>(context, listen: false);
      final song = audioService.currentSong;
      final lyricsTexts = lyrics.map((l) => l.text).toList();
      final lyricsFingerprint = lyricsTexts.join().hashCode;
      final cacheKey =
          '${song?.artist ?? ""}|${song?.title ?? ""}|$lyricsFingerprint';

      final translated = await LyricsTranslationService.translateLines(
        texts: lyricsTexts,
        targetLang: targetLang,
        cacheKey: cacheKey,
      );

      if (!mounted) return;
      setState(() {
        _translatedLines = translated;
        _translationState = _TranslationState.done;
        _showTranslated = true;
      });
    } on SameLanguageException catch (e) {
      if (!mounted) return;
      setState(() => _translationState = _TranslationState.idle);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).lyricsCantTranslateSameLanguage(
                e.detectedLanguage.toUpperCase()),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _translationState = _TranslationState.error);
      unawaited(Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _translationState == _TranslationState.error) {
          setState(() => _translationState = _TranslationState.idle);
        }
      }));
    } finally {
      // The screen may have been closed while translating; the controller is
      // already disposed then, and stopping it would throw.
      if (mounted) {
        _pulseController
          ..stop()
          ..reset();
      }
    }
  }

  static const String _lrclibId = 'lrclib';

  Future<void> _showSearchLyricsDialog(AudioPlayerService audioService) async {
    final song = audioService.currentSong;
    final artistController = TextEditingController(text: song?.artist ?? '');
    final titleController = TextEditingController(text: song?.title ?? '');
    // LRCLIB (full result list) plus every secondary source the user hasn't
    // switched off in Settings > Playback > Lyrics sources.
    final sources = <({String id, String name})>[
      (id: _lrclibId, name: 'LRCLIB'),
      for (final p in await LyricsProviders.enabled()) (id: p.id, name: p.name),
    ];
    if (!mounted) return;
    var selectedSource = _lrclibId;

    await showDialog<void>(
      context: context,
      builder: (context) => GlassmorphicDialog(
        title: Text(
          AppLocalizations.of(context).searchLyrics,
          style: const TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: artistController,
              style: const TextStyle(
                  color: Colors.white, fontFamily: FontConstants.fontFamily),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).artists,
                labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontFamily: FontConstants.fontFamily),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              style: const TextStyle(
                  color: Colors.white, fontFamily: FontConstants.fontFamily),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).title,
                labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontFamily: FontConstants.fontFamily),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            if (sources.length > 1) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context).lyricsSource,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setSourceState) => Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final source in sources)
                        ChoiceChip(
                          label: Text(source.name),
                          selected: selectedSource == source.id,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: selectedSource == source.id
                                ? Colors.black
                                : Colors.white,
                          ),
                          selectedColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          onSelected: (_) =>
                              setSourceState(() => selectedSource = source.id),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: const TextStyle(
                  color: Colors.white70, fontFamily: FontConstants.fontFamily),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final artist = artistController.text.trim();
              final title = titleController.text.trim();
              if (artist.isNotEmpty && title.isNotEmpty) {
                unawaited(_performLyricsSearch(artist, title, selectedSource));
              }
            },
            child: Text(
              AppLocalizations.of(context).search,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: FontConstants.fontFamily,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// GETs the lrclib search endpoint with a timeout, retrying once with a
  /// longer timeout if the first attempt times out. lrclib.net is a free
  /// public API that occasionally responds slowly under load (surfacing as
  /// an HTTP 408 in logs) — a single retry avoids spurious "search failed"
  /// results without blocking the UI indefinitely.
  Future<http.Response> _getLyricsSearchResponse(Uri url) async {
    const headers = {
      'Accept': 'application/json',
      'User-Agent': 'AuroraMusic v0.0.85',
    };
    const timeout = Duration(seconds: 6);
    const retryTimeout = Duration(seconds: 10);
    final client = TimedLyricsService.httpClient;
    try {
      final response = await client
          .get(url, headers: headers)
          .timeout(timeout, onTimeout: () => http.Response('', 408));
      if (response.statusCode != 408) return response;
    } catch (_) {
      // fall through to retry below
    }
    return client
        .get(url, headers: headers)
        .timeout(retryTimeout, onTimeout: () => http.Response('', 408));
  }

  /// Asks one secondary provider for the song and presents its single match
  /// in the same results dialog LRCLIB uses.
  Future<void> _performProviderSearch(
      String artist, String title, String providerId) async {
    if (!mounted) return;
    setState(() => _isLoadingLyrics = true);

    try {
      final provider =
          LyricsProviders.all.firstWhere((p) => p.id == providerId);
      final song =
          Provider.of<AudioPlayerService>(context, listen: false).currentSong;
      final album = song?.album;
      final durationMs = song?.duration;
      final raw = await provider
          .fetchLrc(
            LyricsQuery(
              title: title,
              artist: artist,
              album: (album == null ||
                      album.trim().isEmpty ||
                      album == '<unknown>')
                  ? null
                  : album.trim(),
              durationSeconds:
                  durationMs == null ? null : (durationMs / 1000).round(),
            ),
            TimedLyricsService.httpClient,
          )
          .timeout(const Duration(seconds: 15), onTimeout: () => null);

      if (!mounted) return;
      setState(() => _isLoadingLyrics = false);

      final lrc = raw == null ? null : sanitizeLrc(raw);
      if (lrc == null || TimedLyricsService().parseLrcContent(lrc).isEmpty) {
        NotificationManager.showMessage(
          context,
          AppLocalizations.of(context).noLyricsFound,
        );
        return;
      }

      _showLyricsResultsDialog([
        {
          'trackName': title,
          'artistName': artist,
          'albumName': provider.name,
          'syncedLyrics': lrc,
        }
      ]);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingLyrics = false);
      NotificationManager.showMessage(
        context,
        AppLocalizations.of(context).searchFailed,
      );
    }
  }

  Future<void> _performLyricsSearch(
      String artist, String title, String providerId) async {
    if (providerId != _lrclibId) {
      return _performProviderSearch(artist, title, providerId);
    }
    if (!mounted) return;
    setState(() => _isLoadingLyrics = true);

    // Fetch search results from the API
    try {
      final searchUrl =
          Uri.parse('https://lrclib.net/api/search').replace(queryParameters: {
        'artist_name': artist,
        'track_name': title,
      });

      final response = await _getLyricsSearchResponse(searchUrl);

      if (response.statusCode == 200) {
        final List results = json.decode(utf8.decode(response.bodyBytes));
        final syncedResults =
            results.where((r) => r['syncedLyrics'] != null).toList();

        if (!mounted) return;

        if (syncedResults.isEmpty) {
          setState(() => _isLoadingLyrics = false);
          NotificationManager.showMessage(
            context,
            AppLocalizations.of(context).noLyricsFound,
          );
          return;
        }

        // Show results dialog
        setState(() => _isLoadingLyrics = false);
        _showLyricsResultsDialog(syncedResults.cast<Map<String, dynamic>>());
      } else {
        setState(() => _isLoadingLyrics = false);
        if (mounted) {
          NotificationManager.showMessage(
            context,
            AppLocalizations.of(context).searchFailed,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoadingLyrics = false);
      if (mounted) {
        NotificationManager.showMessage(
          context,
          AppLocalizations.of(context).searchFailed,
        );
      }
    }
  }

  void _showLyricsResultsDialog(List<Map<String, dynamic>> results) {
    showDialog(
      context: context,
      builder: (context) => GlassmorphicDialog(
        title: Text(
          '${AppLocalizations.of(context).results} (${results.length})',
          style: const TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final trackName = result['trackName'] ?? 'Unknown';
              final artistName = result['artistName'] ?? 'Unknown';
              final albumName = result['albumName'] ?? '';
              final duration =
                  _parseLyricsDuration(result['syncedLyrics'] as String?);

              return Card(
                color: Colors.white.withValues(alpha: 0.1),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () => _selectLyricsResult(context, result),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    trackName,
                    style: const TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        artistName,
                        style: const TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (albumName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          albumName,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: const TextStyle(
                  color: Colors.white70, fontFamily: FontConstants.fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  String _parseLyricsDuration(String? syncedLyrics) {
    if (syncedLyrics == null || syncedLyrics.isEmpty) return '--:--';

    final lines = syncedLyrics.split('\n');
    Duration lastTime = Duration.zero;

    for (final line in lines.reversed) {
      final match = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]').firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        lastTime = Duration(minutes: minutes, seconds: seconds);
        break;
      }
    }

    final mins = lastTime.inMinutes;
    final secs = lastTime.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectLyricsResult(
      BuildContext dialogContext, Map<String, dynamic> result) {
    if (!mounted) return;
    Navigator.pop(dialogContext);

    final lrcContent = result['syncedLyrics'] as String;
    final timedLyricsService = TimedLyricsService();
    final lyrics = timedLyricsService.parseLrcContent(lrcContent);

    setState(() {
      _currentLyrics = lyrics;
      _rebuildRows();
    });

    // Save to cache for future use
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);
    final song = audioService.currentSong;
    if (song != null) {
      final artistRaw = song.artist ?? '';
      final artist = artistRaw.trim().isEmpty ? 'Unknown' : artistRaw.trim();
      final title = song.title.trim().isEmpty ? 'Unknown' : song.title.trim();
      // Same key the loader uses, or the saved lyrics would never be found.
      timedLyricsService.saveLyricsToCache(artist, title, lrcContent);
      if (mounted) {
        NotificationManager.showMessage(
          context,
          AppLocalizations.of(context).lyricsAdded(song.title),
        );
      }
    }

    // Notify now-playing screen so it updates its mini lyrics view
    widget.onLyricsChanged?.call(lyrics);
  }

  void _showSyncAdjustDialog() {
    int tempOffset = _syncOffset;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => GlassmorphicDialog(
          title: Text(
            AppLocalizations.of(context).adjustSync,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tempOffset >= 0 ? '+' : ''}${tempOffset}ms',
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tempOffset > 0
                    ? AppLocalizations.of(context).lyricsAhead
                    : tempOffset < 0
                        ? AppLocalizations.of(context).lyricsBehind
                        : AppLocalizations.of(context).lyricsSynced,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSyncButton(
                      '-500', () => setDialogState(() => tempOffset -= 500)),
                  _buildSyncButton(
                      '-100', () => setDialogState(() => tempOffset -= 100)),
                  _buildSyncButton(
                      '+100', () => setDialogState(() => tempOffset += 100)),
                  _buildSyncButton(
                      '+500', () => setDialogState(() => tempOffset += 500)),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setDialogState(() => tempOffset = 0),
                child: Text(
                  AppLocalizations.of(context).reset,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: FontConstants.fontFamily),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context).cancel,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: FontConstants.fontFamily),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveSyncOffset(tempOffset);
              },
              child: Text(
                AppLocalizations.of(context).save,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: FontConstants.fontFamily,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton(String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => GlassmorphicDialog(
        title: Text(
          AppLocalizations.of(context).fontSize,
          style: const TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption(AppLocalizations.of(context).small, 0.8),
            _buildFontSizeOption(AppLocalizations.of(context).medium, 1.0),
            _buildFontSizeOption(AppLocalizations.of(context).large, 1.2),
            _buildFontSizeOption(AppLocalizations.of(context).extraLarge, 1.4),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String label, double size) {
    final isSelected = (_fontSize - size).abs() < 0.01;
    return ListTile(
      onTap: () {
        if (!mounted) return;
        Navigator.pop(context);
        _saveFontSize(size);
      },
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Colors.white : Colors.white54,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: FontConstants.fontFamily,
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLyricsView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return RepaintBoundary(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [0.0, 0.10, 0.62, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _handleScrollNotification(notification);
                return false;
              },
              child: ListView.builder(
                scrollCacheExtent: const ScrollCacheExtent.pixels(1000),
                key: _scrollKey,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: _restOffset(height),
                  bottom: height * 0.55,
                ),
                itemCount: _rows.length + (_showTranslated ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_showTranslated && index == 0) {
                    return _buildTranslationDisclaimerHeader();
                  }
                  return _buildRow(_showTranslated ? index - 1 : index);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Per-row motion layered over the list: the cascade lag while auto-scrolling
  /// and the rise into place as the page opens out of its card.
  Widget _rowFx(int row, Widget child) {
    final route = PlayerPageScope.maybeOf(context)?.route;
    final rowsBelow = (row - _focusRow).clamp(0, 8);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _stagger,
        if (route != null) route.progress,
      ]),
      child: child,
      builder: (context, child) {
        var dy = _stagger.lagOf(row);
        var alpha = 1.0;
        if (route != null) {
          final e = route.progress.value;
          if ((e - 1).abs() > 0.0005) {
            // Short, staggered rise that starts once the card's own text has
            // faded, so the two never overlap.
            dy += (36 + 10 * rowsBelow) * (1 - e);
            alpha = _smoothstep((e - 0.18) / 0.45);
          }
        }
        return Opacity(
          opacity: alpha,
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
      },
    );
  }

  Widget _buildFloatingTranslateButton() {
    final isActive =
        _translationState == _TranslationState.done && _showTranslated;
    final isLoading = _translationState == _TranslationState.loading;
    final isError = _translationState == _TranslationState.error;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Opacity(
        opacity: isLoading ? _pulseAnim.value : 1.0,
        child: child,
      ),
      child: Tooltip(
        message: isError
            ? AppLocalizations.of(context).translateFailedTapToRetry
            : isActive
                ? AppLocalizations.of(context).translateShowOriginal
                : _translationState == _TranslationState.done
                    ? AppLocalizations.of(context).translateShowTranslation
                    : AppLocalizations.of(context).translateLyrics,
        child: AnimatedContainer(
          key: _translateAnchorKey,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.85)
                : Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isError
                  ? Colors.orangeAccent.withValues(alpha: 0.6)
                  : isActive
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.0)
                      : Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
                )
              : InkWell(
                  onTap: _handleTranslateButton,
                  onLongPress: () => _handleTranslateButton(pickLanguage: true),
                  borderRadius: BorderRadius.circular(22),
                  child: Center(
                    child: Icon(
                      isError
                          ? Icons.warning_amber_rounded
                          : Icons.translate_rounded,
                      size: 20,
                      color: isError ? Colors.orangeAccent : Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTranslationDisclaimerHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 12, color: Colors.white30),
          const SizedBox(width: 5),
          Text(
            AppLocalizations.of(context).lyricsAiTranslatedNote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 11,
              color: Colors.white30,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int row) {
    final entry = _rows[row];
    final interlude = entry.interlude;
    if (interlude != null) {
      return KeyedSubtree(
        key: _rowKeys[row],
        child: _rowFx(
          row,
          LyricInterludeDots(
            startMs: interlude.startMs,
            endMs: interlude.endMs,
            clock: _clock,
            accentColor: Theme.of(context).colorScheme.primary,
            visible: row == _activeInterludeRow,
          ),
        ),
      );
    }

    final index = entry.lineIndex;
    final lyric = _currentLyrics![index];
    final translatedText = (_showTranslated && index < _translatedLines.length)
        ? _translatedLines[index]
        : null;

    return KeyedSubtree(
      key: _rowKeys[row],
      child: _rowFx(
        row,
        LyricLineWidget(
          text: translatedText ?? lyric.text,
          subtitle: translatedText != null ? lyric.text : null,
          isActive: row == _focusRow,
          distance: (row - _focusRow).abs(),
          isPast: row < _focusRow,
          fontSize: _fontSize,
          blurEnabled: _blurEnabled && !_autoFollowPaused,
          words: translatedText == null ? lyric.words : null,
          clock: _clock,
          onTap: () {
            _setImmersive(false);
            _seekToLyric(index);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildNoLyricsView(AudioPlayerService audioService) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lyrics_outlined,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noLyrics,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).noLyricsDesc,
            style: const TextStyle(
              fontFamily: FontConstants.fontFamily,
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          // Surface the .lrc import / manual lyrics entry front-and-center
          // instead of leaving it hidden behind the overflow menu.
          OutlinedButton.icon(
            onPressed: () => _openLyricsEditor(audioService),
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: Text(AppLocalizations.of(context).lyricsAddLyrics),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              textStyle: const TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(AudioPlayerService audioService) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 8, 50, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar matching now playing design
          StreamBuilder<Duration?>(
            stream: audioService.audioPlayer.durationStream,
            builder: (context, durationSnapshot) {
              final duration = durationSnapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: audioService.audioPlayer.positionStream,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  final progress = duration.inMilliseconds > 0
                      ? (position.inMilliseconds / duration.inMilliseconds)
                          .clamp(0.0, 1.0)
                      : 0.0;

                  return Column(
                    children: [
                      SizedBox(
                        height: 20,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTapDown: (details) {
                                final tapPos = details.localPosition;
                                final percentage =
                                    (tapPos.dx / width).clamp(0.0, 1.0);
                                final newPosition = duration * percentage;
                                audioService.audioPlayer.seek(newPosition);
                              },
                              child: Center(
                                child: SizedBox(
                                  width: width,
                                  height: 3.0,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: width,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(1.5),
                                        ),
                                      ),
                                      Container(
                                        width: width * progress,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          // Controls - plain icons without background circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: audioService.back,
              ),
              ValueListenableBuilder<bool>(
                valueListenable: audioService.isPlayingNotifier,
                builder: (context, isPlaying, _) => IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      audioService.pause();
                    } else {
                      audioService.resume();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: audioService.skip,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _seekToLyric(int index) {
    if (_currentLyrics == null || index >= _currentLyrics!.length) return;
    final audioService =
        Provider.of<AudioPlayerService>(context, listen: false);
    audioService.audioPlayer.seek(_currentLyrics![index].time);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

double _smoothstep(double x) {
  final t = x.clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}
