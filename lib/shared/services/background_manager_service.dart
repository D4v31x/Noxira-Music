import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'artwork_cache_service.dart';
import '../utils/performance_optimizations.dart';

/// Extracts background roles and a fuller accent palette for a worker isolate.
/// Background roles retain their original six-color quantization.
@visibleForTesting
Future<({List<int> background, List<int> accents})> computeArtworkPalette(
    ({Uint8List pixels, int width, int height}) args) async {
  final byteData = ByteData.sublistView(args.pixels);
  final palette = await PaletteGenerator.fromByteData(
    EncodedImage(byteData, width: args.width, height: args.height),
    maximumColorCount: 6,
  );
  final accents = await PaletteGenerator.fromByteData(
    EncodedImage(byteData, width: args.width, height: args.height),
    maximumColorCount: 24,
  );
  final population =
      accents.paletteColors.fold(0, (sum, swatch) => sum + swatch.population);
  return (
    background: [
      palette.dominantColor?.color.toARGB32() ?? 0,
      palette.vibrantColor?.color.toARGB32() ?? 0,
      palette.lightVibrantColor?.color.toARGB32() ?? 0,
      palette.darkVibrantColor?.color.toARGB32() ?? 0,
      palette.mutedColor?.color.toARGB32() ?? 0,
      palette.lightMutedColor?.color.toARGB32() ?? 0,
    ],
    accents: accents.paletteColors
        .where((swatch) => swatch.population >= population * 0.005)
        .map((swatch) => swatch.color.toARGB32())
        .toList(growable: false),
  );
}

/// Service that manages background colors and artwork
/// Provides artwork data for blurred backgrounds across the app
///
/// Performance optimizations:
/// - Cached color extraction to avoid redundant palette generation
/// - Throttled updates to prevent excessive rebuilds
/// - Batch notifications to reduce listener calls
class BackgroundManagerService extends ChangeNotifier {
  static const Duration _artworkRetryDelay = Duration(milliseconds: 450);

  final ArtworkCacheService _artworkCache = ArtworkCacheService();

  List<Color> _currentColors = _getDefaultColors();
  List<Color> _artworkColors = const [];
  bool _isDarkMode = true;

  // Artwork data for blurred background
  Uint8List? _currentArtwork;
  Uint8List? _previousArtwork;
  bool _isTransitioning = false;
  SongModel? _currentSong;
  bool _isUpdating = false; // Prevent concurrent updates
  int _updateCounter = 0; // Track update sequence
  // Prevent duplicate delayed artwork retries for the same song.
  int? _retryScheduledForSongId;
  Timer? _artworkRetryTimer;

  // Performance optimizations
  final Map<int, ({List<Color> background, List<Color> accents})> _colorCache =
      {};
  final Throttler _updateThrottler =
      Throttler(interval: const Duration(milliseconds: 300));

  static const Color _defaultDarkPrimary = Color(0xFF1A237E);
  static const Color _defaultDarkSecondary = Color(0xFF311B92);
  static const Color _defaultDarkTertiary = Color(0xFF512DA8);
  static const Color _defaultDarkQuaternary = Color(0xFF7B1FA2);

  /// What a song without artwork shows: plain white, never the colours of the
  /// song before it.
  static const List<Color> _noArtworkColors = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  static const Color _defaultLightPrimary = Color(0xFFE3F2FD);
  static const Color _defaultLightSecondary = Color(0xFFBBDEFB);
  static const Color _defaultLightTertiary = Color(0xFF90CAF9);
  static const Color _defaultLightQuaternary = Color(0xFF64B5F6);

  // Getters
  List<Color> get currentColors => _currentColors;

  /// Untruncated artwork swatches, including small accents absent from the mesh.
  List<Color> get artworkColors => _artworkColors;
  bool get isDarkMode => _isDarkMode;
  Uint8List? get currentArtwork => _currentArtwork;
  Uint8List? get previousArtwork => _previousArtwork;
  bool get isTransitioning => _isTransitioning;
  bool get hasArtwork => _currentArtwork != null && _currentArtwork!.isNotEmpty;
  SongModel? get currentSong => _currentSong;

  /// Directly push artwork and song to the background without any guards.
  /// Called from the audio service whenever artwork is successfully fetched so
  /// the background always updates, regardless of [_isUpdating] state.
  void pushArtwork(Uint8List? artwork, SongModel song) {
    // Invalidate any in-progress update — its result will be discarded
    // by the stale-update counter check when it eventually finishes.
    _updateCounter++;
    _isUpdating = false;

    _previousArtwork = _currentArtwork;
    _currentArtwork = artwork;
    _artworkColors = const [];
    _currentSong = song;
    _isTransitioning = artwork != null;
    final hasArtwork = artwork != null && artwork.isNotEmpty;
    // Without artwork there is nothing to take colours from; drop the previous
    // song's colours at once instead of leaving them in place.
    if (!hasArtwork) _currentColors = _noArtworkColors;
    if (kDebugMode) {
      debugPrint(
          '🎨 [BG_MGR] pushArtwork: "${song.title}" (id: ${song.id}) — artwork: ${artwork != null ? '${artwork.length} bytes' : 'null'}, notifying listeners');
    }
    notifyListeners();

    // Clean up transition state after animation
    if (hasArtwork) {
      Future.delayed(const Duration(milliseconds: 900), () {
        _isTransitioning = false;
        _previousArtwork = null;
      });
      // Extract palette colors in background (does not affect the blurred artwork display)
      unawaited(updateColorsFromArtwork(artwork));
    }
  }

  /// Force refresh artwork for current song
  Future<void> refreshArtwork() async {
    if (_currentSong != null) {
      final artwork = await _artworkCache.getArtwork(_currentSong!.id);
      if (artwork != null && artwork.isNotEmpty) {
        _currentArtwork = artwork;
        notifyListeners();
        await updateColorsFromArtwork(artwork);
      }
    }
  }

  /// Set the theme mode
  void setDarkMode(bool darkMode) {
    if (_isDarkMode != darkMode) {
      _isDarkMode = darkMode;
      // If no artwork colors are set, use default colors for the new theme
      if (_isUsingDefaultColors()) {
        _currentColors = _getDefaultColors();
        notifyListeners();
      }
    }
  }

  /// Update colors based on artwork
  Future<void> updateColorsFromArtwork(Uint8List? artworkData) async {
    // The song this palette belongs to: if another one has started by the
    // time it is ready (or even before it runs), the result is thrown away.
    final updateId = _updateCounter;
    // Throttle updates to prevent excessive rebuilds
    _updateThrottler.call(() async {
      await _updateColorsFromArtworkSilent(artworkData, updateId: updateId);
      if (updateId == _updateCounter) notifyListeners();
    });
  }

  /// Update colors without notifying listeners (internal use). With an
  /// [updateId], nothing is applied once a newer update has begun.
  Future<void> _updateColorsFromArtworkSilent(Uint8List? artworkData,
      {int? updateId}) async {
    bool stale() => updateId != null && updateId != _updateCounter;

    if (stale()) return;
    if (artworkData == null || artworkData.isEmpty) {
      _currentColors = _noArtworkColors;
      _artworkColors = const [];
      return;
    }

    // Performance: use song ID as the cache key instead of artworkData.hashCode.
    // Uint8List.hashCode in Dart is identity-based (not content-based), so it
    // returns a different value for every new buffer object even when the pixel
    // data is identical — making the old cache 100 % miss-prone in practice.
    final cacheKey = _currentSong?.id;
    if (cacheKey != null && _colorCache.containsKey(cacheKey)) {
      final cached = _colorCache[cacheKey]!;
      _currentColors = cached.background;
      _artworkColors = cached.accents;
      return;
    }

    try {
      // Decode and scale the image on the main thread (requires Flutter rendering).
      final codec = await ui.instantiateImageCodec(
        artworkData,
        targetWidth: 112,
        targetHeight: 112,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final imageWidth = image.width;
      final imageHeight = image.height;
      final rawPixels = await image.toByteData();
      image.dispose();
      codec.dispose();

      if (rawPixels == null) {
        if (!stale()) {
          _currentColors = _getDefaultColors();
          _artworkColors = const [];
        }
        return;
      }

      // Run heavy color quantization in a background isolate so it cannot
      // block the UI thread and cause frame drops during song transitions.
      final extracted = await compute(
        computeArtworkPalette,
        (
          pixels: rawPixels.buffer
              .asUint8List(rawPixels.offsetInBytes, rawPixels.lengthInBytes),
          width: imageWidth,
          height: imageHeight,
        ),
      );

      // A newer song may have started while the palette was being computed.
      if (stale()) return;

      // Reconstruct Color objects from isolate-returned ARGB ints.
      // The order matches computeArtworkPalette's background roles:
      // [dominant, vibrant, lightVibrant, darkVibrant, muted, lightMuted].
      final colors = <Color>[];
      for (final argb in extracted.background) {
        if (argb != 0) colors.add(Color(argb));
        if (colors.length == 4) break; // max 4 colours
      }
      _artworkColors = extracted.accents.map(Color.new).toList(growable: false);

      // Ensure at least 2 colors.
      if (colors.length == 1) {
        colors
            .add(_adjustColorBrightness(colors.first, _isDarkMode ? 0.7 : 1.3));
      }

      if (colors.length >= 2) {
        _currentColors = colors;
        // Cache by song ID so subsequent calls for the same song are O(1).
        if (cacheKey != null) {
          _colorCache[cacheKey] = (background: colors, accents: _artworkColors);

          // Limit cache size to prevent memory leaks.
          if (_colorCache.length > 50) {
            final keysToRemove =
                _colorCache.keys.take(_colorCache.length - 50).toList();
            for (final key in keysToRemove) {
              _colorCache.remove(key);
            }
          }
        }
      } else {
        _currentColors = _getDefaultColors();
      }
    } catch (e) {
      debugPrint('BackgroundManager palette error: $e');
      if (!stale()) {
        _currentColors = _getDefaultColors();
        _artworkColors = const [];
      }
    }
  }

  /// Extract and update colors from song artwork
  /// Also updates the artwork for blurred background
  Future<void> updateColorsFromSong(SongModel? song) async {
    if (song == null) {
      if (kDebugMode) {
        debugPrint('🎨 [BG_MGR] Song is null, clearing artwork/background');
      }
      _clearArtwork();
      _useDefaultColors();
      return;
    }

    // Skip if same song AND we already have artwork
    if (_currentSong?.id == song.id && _currentArtwork != null) {
      if (kDebugMode) {
        debugPrint(
            '🎨 [BG_MGR] Skip update for same song id ${song.id}, artwork already available (${_currentArtwork?.length ?? 0} bytes)');
      }
      return;
    }

    // Only block concurrent updates when the in-progress update is for the
    // SAME song. A different song should always proceed — the stale-update
    // counter will discard the old result once it finishes.
    if (_isUpdating && _currentSong?.id == song.id) {
      if (kDebugMode) {
        debugPrint(
            '🎨 [BG_MGR] Same-song update already running, skipping song id ${song.id}');
      }
      return;
    }

    // Invalidate any in-progress update for a different song so its result
    // is discarded once it reaches the stale-update check.
    if (_isUpdating) {
      _updateCounter++;
      if (kDebugMode) {
        debugPrint(
            '🎨 [BG_MGR] Invalidating previous update, counter now $_updateCounter');
      }
    }

    try {
      _isUpdating = true;
      _currentSong = song;
      _artworkColors = const [];
      final currentUpdateId = ++_updateCounter;
      if (kDebugMode) {
        debugPrint(
            '🎨 [BG_MGR] Start background update #$currentUpdateId for "${song.title}" (id: ${song.id})');
      }

      // Start transition animation
      _previousArtwork = _currentArtwork;
      _isTransitioning = true;

      // Try to get artwork with multiple retries and increasing delays
      Uint8List? artworkData;
      for (int attempt = 1; attempt <= 3; attempt++) {
        if (kDebugMode) {
          debugPrint(
              '🎨 [BG_MGR] Fetch artwork attempt $attempt/3 for song id ${song.id}');
        }
        artworkData = await _artworkCache.getArtwork(song.id);

        if (artworkData != null && artworkData.isNotEmpty) {
          if (kDebugMode) {
            debugPrint(
                '🎨 [BG_MGR] Artwork fetched for song id ${song.id} (${artworkData.length} bytes)');
          }
          break;
        }
        if (kDebugMode) {
          debugPrint(
              '🎨 [BG_MGR] Artwork not available yet for song id ${song.id}');
        }

        if (attempt < 3) {
          // Shorter delays: 100ms, 200ms
          await Future.delayed(Duration(milliseconds: 100 * attempt));
        }
      }

      // Check if this update is still current
      if (currentUpdateId != _updateCounter || _currentSong?.id != song.id) {
        if (kDebugMode) {
          debugPrint(
              '🎨 [BG_MGR] Discard stale update #$currentUpdateId for song id ${song.id}');
        }
        _isUpdating = false;
        return;
      }

      // Update artwork for blurred background (only if valid)
      if (artworkData != null && artworkData.isNotEmpty) {
        _currentArtwork = artworkData;
        _retryScheduledForSongId = null;
        _artworkRetryTimer?.cancel();
        if (kDebugMode) {
          debugPrint(
              '🎨 [BG_MGR] Apply artwork to background for song id ${song.id} (${artworkData.length} bytes)');
        }
      } else {
        _currentArtwork = null;
        _artworkColors = const [];
        if (kDebugMode) {
          debugPrint(
              '🎨 [BG_MGR] No artwork resolved for song id ${song.id}, using fallback/background colors');
        }
        _artworkRetryTimer?.cancel();
        if (_retryScheduledForSongId != song.id) {
          final songId = song.id;
          _retryScheduledForSongId = songId;
          if (kDebugMode) {
            debugPrint(
                '🎨 [BG_MGR] Schedule delayed retry in ${_artworkRetryDelay.inMilliseconds}ms for song id $songId');
          }
          _artworkRetryTimer = Timer(_artworkRetryDelay, () {
            final currentSong = _currentSong;
            if (_retryScheduledForSongId == songId &&
                currentSong?.id == songId &&
                !_isUpdating) {
              if (kDebugMode) {
                debugPrint('🎨 [BG_MGR] Run delayed retry for song id $songId');
              }
              updateColorsFromSong(currentSong!);
            }
          });
        }
      }

      // Update colors WITHOUT notifying yet
      await _updateColorsFromArtworkSilent(artworkData,
          updateId: currentUpdateId);

      // Single notify after everything is ready
      if (kDebugMode) {
        debugPrint(
            '🎨 [BG_MGR] Notify listeners for song id ${song.id} (hasArtwork: ${_currentArtwork != null})');
      }
      notifyListeners();

      // Clean up transition state after animation (no notify needed - internal state only)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (currentUpdateId == _updateCounter && _currentSong?.id == song.id) {
          _isTransitioning = false;
          _previousArtwork = null;
        }
      });
    } catch (e) {
      debugPrint('BackgroundManager error: $e');
      _clearArtwork();
      _useDefaultColors();
    } finally {
      _isUpdating = false;
    }
  }

  /// Clear artwork data
  void _clearArtwork() {
    _previousArtwork = _currentArtwork;
    _currentArtwork = null;
    _artworkColors = const [];
    _currentSong = null;
    _isTransitioning = true;
    final clearUpdateId = ++_updateCounter;
    notifyListeners();

    // Clean up transition state after animation (no notify needed - internal state only)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (clearUpdateId == _updateCounter && _currentArtwork == null) {
        _isTransitioning = false;
        _previousArtwork = null;
      }
    });
  }

  /// Extract colors from palette generator
  /// Adjust color brightness
  Color _adjustColorBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final adjustedLightness = (hsl.lightness * factor).clamp(0.0, 1.0);
    return hsl.withLightness(adjustedLightness).toColor();
  }

  /// Use default colors
  void _useDefaultColors() {
    _currentColors = _getDefaultColors();
    _artworkColors = const [];
    notifyListeners();
  }

  /// Get default colors based on theme
  static List<Color> _getDefaultColors() {
    return [
      _defaultDarkPrimary,
      _defaultDarkSecondary,
      _defaultDarkTertiary,
      _defaultDarkQuaternary,
    ];
  }

  /// Check if currently using default colors
  bool _isUsingDefaultColors() {
    final defaultColors = _getDefaultColors();
    if (_currentColors.length != defaultColors.length) return false;

    for (int i = 0; i < _currentColors.length; i++) {
      if (_currentColors[i] != defaultColors[i]) return false;
    }
    return true;
  }

  /// Get colors suitable for light theme
  List<Color> getLightThemeColors() {
    return [
      _defaultLightPrimary,
      _defaultLightSecondary,
      _defaultLightTertiary,
      _defaultLightQuaternary,
    ];
  }

  /// Get colors suitable for dark theme
  List<Color> getDarkThemeColors() {
    return [
      _defaultDarkPrimary,
      _defaultDarkSecondary,
      _defaultDarkTertiary,
      _defaultDarkQuaternary,
    ];
  }

  /// Set custom colors directly for the mesh gradient
  /// This method allows setting colors from palette generators or other sources
  void setCustomColors(List<Color> colors) {
    if (colors.isEmpty) {
      _useDefaultColors();
      return;
    }

    // Take up to 9 colors for the mesh (3x3 grid)
    _currentColors = colors.take(9).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _artworkRetryTimer?.cancel();
    _updateThrottler.dispose();
    _colorCache.clear();
    super.dispose();
  }
}
