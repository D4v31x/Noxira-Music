import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';

/// Feeds the native home screen widget ([AuroraMusicWidgetProvider]) with the
/// current track, progress and recommendations, and relays widget taps that
/// open the app (`noxira://widget/...`) to a handler.
///
/// Data travels through SharedPreferences via the `home_widget` package; the
/// key names must match the Kotlin side.
class HomeScreenWidgetService {
  static const String _androidWidgetName = 'AuroraMusicWidgetProvider';
  static const String _appGroupId = 'com.aurorasoftware.music';

  static const String _keySongTitle = 'widget_song_title';
  static const String _keyArtistName = 'widget_artist_name';
  static const String _keyIsPlaying = 'widget_is_playing';
  static const String _keyArtworkPath = 'widget_artwork_path';
  static const String _keySource = 'widget_source';
  static const String _keyTint = 'widget_bg_color';

  static const int _recommendationCount = 4;
  static const int _defaultTint = 0xFF4F6D8F;

  static final HomeScreenWidgetService _instance =
      HomeScreenWidgetService._internal();
  factory HomeScreenWidgetService() => _instance;
  HomeScreenWidgetService._internal();

  bool _initialized = false;
  StreamSubscription<Uri?>? _clickSubscription;
  String _recommendationSignature = '';

  /// Call once during app startup.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (e) {
      debugPrint('HomeScreenWidgetService: Failed to initialize - $e');
    }
  }

  /// Routes taps on the widget that launched or resumed the app to [handler].
  Future<void> attachLaunchHandler(
      Future<void> Function(Uri uri) handler) async {
    await _clickSubscription?.cancel();
    _clickSubscription = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) unawaited(handler(uri));
    });
    try {
      final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initial != null) unawaited(handler(initial));
    } catch (e) {
      debugPrint('HomeScreenWidgetService: Failed to read launch uri - $e');
    }
  }

  /// Update the widget with the current song.
  Future<void> updateSongInfo({
    required String title,
    required String artist,
    required bool isPlaying,
    int? songId,
    Uint8List? artworkBytes,
    String? source,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>(_keySongTitle, title),
        HomeWidget.saveWidgetData<String>(_keyArtistName, artist),
        HomeWidget.saveWidgetData<bool>(_keyIsPlaying, isPlaying),
        HomeWidget.saveWidgetData<String>(_keySource, source ?? 'Noxira Music'),
      ]);

      if (artworkBytes != null && artworkBytes.isNotEmpty) {
        await _saveArtwork(artworkBytes);
        await _extractAndSaveTint(artworkBytes);
      } else if (songId != null) {
        await _saveArtworkFromQuery(songId);
      } else {
        await Future.wait([
          HomeWidget.saveWidgetData<String?>(_keyArtworkPath, null),
          HomeWidget.saveWidgetData<int>(_keyTint, _defaultTint),
        ]);
      }

      await _updateWidget();
    } catch (e) {
      debugPrint('HomeScreenWidgetService: Failed to update song info - $e');
    }
  }

  /// Update the play/pause state.
  Future<void> updatePlayingState(bool isPlaying) async {
    try {
      await HomeWidget.saveWidgetData<bool>(_keyIsPlaying, isPlaying);
      await _updateWidget();
    } catch (e) {
      debugPrint(
          'HomeScreenWidgetService: Failed to update playing state - $e');
    }
  }

  /// Show the "nothing playing" state (recommendations stay visible).
  Future<void> clearWidget() async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>(_keySongTitle, ''),
        HomeWidget.saveWidgetData<String>(_keyArtistName, ''),
        HomeWidget.saveWidgetData<bool>(_keyIsPlaying, false),
        HomeWidget.saveWidgetData<String?>(_keyArtworkPath, null),
        HomeWidget.saveWidgetData<String>(_keySource, 'Noxira Music'),
        HomeWidget.saveWidgetData<int>(_keyTint, _defaultTint),
      ]);
      await _updateWidget();
    } catch (e) {
      debugPrint('HomeScreenWidgetService: Failed to clear widget - $e');
    }
  }

  /// Publish the songs shown in the widget's "Recommended for you" row.
  Future<void> updateRecommendations(List<SongModel> songs) async {
    final picked = songs.take(_recommendationCount).toList();
    final signature = picked.map((s) => s.id).join(',');
    if (signature == _recommendationSignature) return;
    _recommendationSignature = signature;

    try {
      final directory = await getApplicationDocumentsDirectory();
      for (var i = 0; i < _recommendationCount; i++) {
        final n = i + 1;
        if (i >= picked.length) {
          await Future.wait([
            HomeWidget.saveWidgetData<String>('widget_rec_${n}_id', ''),
            HomeWidget.saveWidgetData<String>('widget_rec_${n}_title', ''),
            HomeWidget.saveWidgetData<String?>('widget_rec_${n}_artwork', null),
          ]);
          continue;
        }

        final song = picked[i];
        String? artworkPath;
        try {
          final artwork = await OnAudioQuery().queryArtwork(
            song.id,
            ArtworkType.AUDIO,
            format: ArtworkFormat.JPEG,
            size: 160,
            quality: 75,
          );
          if (artwork != null && artwork.isNotEmpty) {
            final file = File('${directory.path}/widget_rec_art_$n.jpg');
            await file.writeAsBytes(artwork, flush: true);
            artworkPath = file.path;
          }
        } catch (_) {}

        await Future.wait([
          HomeWidget.saveWidgetData<String>('widget_rec_${n}_id', '${song.id}'),
          HomeWidget.saveWidgetData<String>(
              'widget_rec_${n}_title', song.title),
          HomeWidget.saveWidgetData<String?>(
              'widget_rec_${n}_artwork', artworkPath),
        ]);
      }
      await _updateWidget();
    } catch (e) {
      _recommendationSignature = '';
      debugPrint(
          'HomeScreenWidgetService: Failed to update recommendations - $e');
    }
  }

  Future<void> _saveArtwork(Uint8List artworkBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/widget_artwork.png');
      await file.writeAsBytes(artworkBytes, flush: true);
      if (await file.length() > 0) {
        await HomeWidget.saveWidgetData<String>(_keyArtworkPath, file.path);
      }
    } catch (e) {
      debugPrint('HomeScreenWidgetService: Failed to save artwork - $e');
      await HomeWidget.saveWidgetData<String?>(_keyArtworkPath, null);
    }
  }

  Future<void> _saveArtworkFromQuery(int songId) async {
    try {
      final artwork = await OnAudioQuery().queryArtwork(
        songId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.PNG,
        size: 300,
        quality: 80,
      );
      if (artwork != null && artwork.isNotEmpty) {
        await _saveArtwork(artwork);
        await _extractAndSaveTint(artwork);
      } else {
        await Future.wait([
          HomeWidget.saveWidgetData<String?>(_keyArtworkPath, null),
          HomeWidget.saveWidgetData<int>(_keyTint, _defaultTint),
        ]);
      }
    } catch (e) {
      debugPrint('HomeScreenWidgetService: Failed to query artwork - $e');
    }
  }

  /// The widget washes its glass with the artwork's most characteristic colour.
  Future<void> _extractAndSaveTint(Uint8List artworkBytes) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        MemoryImage(artworkBytes),
        size: const Size(100, 100),
      ).timeout(const Duration(seconds: 5));

      final color = palette.vibrantColor?.color ??
          palette.lightVibrantColor?.color ??
          palette.dominantColor?.color ??
          const Color(_defaultTint);
      await HomeWidget.saveWidgetData<int>(_keyTint, color.toARGB32());
    } catch (e) {
      debugPrint('HomeScreenWidgetService: Failed to extract colors - $e');
      await HomeWidget.saveWidgetData<int>(_keyTint, _defaultTint);
    }
  }

  Future<void> _updateWidget() async {
    try {
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        qualifiedAndroidName: 'com.aurorasoftware.music.$_androidWidgetName',
      );
    } catch (e) {
      debugPrint('HomeScreenWidgetService: Failed to update widget - $e');
    }
  }

  void dispose() {
    _clickSubscription?.cancel();
    _clickSubscription = null;
  }
}
