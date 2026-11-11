part of '../audio_player_service.dart';

@visibleForTesting
Future<Map<String, dynamic>?> readAudioSettings(File file) async {
  if (!await file.exists()) return null;
  final contents = await file.readAsString();
  try {
    final value = jsonDecode(contents);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Audio settings must be an object');
    }
    for (final key in [
      'gaplessPlayback',
      'volumeNormalization',
      'pitchWithSpeed',
      'mediaControls',
      'crossfadeEnabled',
      'automixEnabled',
    ]) {
      if (value[key] != null && value[key] is! bool) {
        throw FormatException('Invalid boolean audio setting: $key');
      }
    }
    for (final key in ['playbackSpeed', 'pitch']) {
      final setting = value[key];
      if (setting != null &&
          (setting is! num || !setting.isFinite || setting <= 0)) {
        throw FormatException('Invalid numeric audio setting: $key');
      }
    }
    for (final key in ['cacheSize', 'crossfadeDurationMs']) {
      if (value[key] != null && value[key] is! int) {
        throw FormatException('Invalid integer audio setting: $key');
      }
    }
    if (value['defaultSortOrder'] != null &&
        value['defaultSortOrder'] is! String) {
      throw const FormatException('Invalid sort order audio setting');
    }
    return value;
  } on FormatException catch (error, stack) {
    LoggingService.error(
        'Corrupt audio settings; quarantining and using defaults',
        'AudioSettings',
        error,
        stack);
    await file.rename('${file.path}.corrupt');
    return null;
  }
}

extension AudioSettingsManagerExtension on AudioPlayerService {
  Future<void> _loadSettings() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/settings.json');

    final json = await readAudioSettings(file);
    if (json != null) {
      _gaplessPlayback = json['gaplessPlayback'] ?? true;
      _volumeNormalization = json['volumeNormalization'] ?? false;
      _playbackSpeed = (json['playbackSpeed'] ?? 1.0).toDouble();
      _pitchWithSpeed = json['pitchWithSpeed'] ?? false;
      _pitch = ((json['pitch'] ?? 1.0) as num).toDouble().clamp(0.5, 2.0);
      _defaultSortOrder = json['defaultSortOrder'] ?? 'title';
      _cacheSize = json['cacheSize'] ?? 100;
      _mediaControls = json['mediaControls'] ?? true;
      _crossfadeEnabled = json['crossfadeEnabled'] ?? false;
      _crossfadeDurationMs = json['crossfadeDurationMs'] ?? 6000;
      _automixEnabled = json['automixEnabled'] ?? false;

      // Apply settings to audio player
      await _applySettings();
    }
  }

  Future<void> _saveSettings() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/settings.json');

    final json = {
      'gaplessPlayback': _gaplessPlayback,
      'volumeNormalization': _volumeNormalization,
      'playbackSpeed': _playbackSpeed,
      'pitchWithSpeed': _pitchWithSpeed,
      'pitch': _pitch,
      'defaultSortOrder': _defaultSortOrder,
      'cacheSize': _cacheSize,
      'mediaControls': _mediaControls,
      'crossfadeEnabled': _crossfadeEnabled,
      'crossfadeDurationMs': _crossfadeDurationMs,
      'automixEnabled': _automixEnabled,
    };

    await writeStringAtomic(file, jsonEncode(json));
  }

  Future<void> _applySettings() async {
    // Apply playback speed
    await _audioPlayer.setSpeed(_playbackSpeed);
    await _audioPlayer.setPitch(effectivePitch);

    // Volume normalization is applied per-song via a currentSongNotifier
    // listener registered in _init().  Reset to 1.0 when disabled.
    if (!_volumeNormalization) {
      await _audioPlayer.setVolume(1.0);
    }
  }

  // Settings update methods
  Future<void> setGaplessPlayback(bool value) async {
    _gaplessPlayback = value;
    await _saveSettings();
    _scheduleNotify();
  }

  /// Enables or disables true timed crossfade between tracks. Cancels any
  /// in-progress crossfade ramp immediately when disabled.
  Future<void> setCrossfadeEnabled(bool value) async {
    _crossfadeEnabled = value;
    if (!value && !_automixEnabled) {
      await cancelCrossfadeIfActive();
    }
    await _saveSettings();
    _scheduleNotify();
  }

  /// Sets the crossfade duration in milliseconds, clamped to a sensible
  /// 1-12 second range.
  Future<void> setCrossfadeDurationMs(int value) async {
    _crossfadeDurationMs = value.clamp(1000, 12000);
    await _saveSettings();
    _scheduleNotify();
  }

  /// Enables or disables Automix — a one-tap "seamless flow" mode that
  /// crossfades every transition using an automatically-picked duration,
  /// independent of the manual Crossfade toggle/duration.
  Future<void> setAutomixEnabled(bool value) async {
    _automixEnabled = value;
    if (!value && !_crossfadeEnabled) {
      await cancelCrossfadeIfActive();
    }
    await _saveSettings();
    _scheduleNotify();
  }

  Future<void> setVolumeNormalization(bool value) async {
    _volumeNormalization = value;
    _scheduleNotify();
    if (value) {
      await _applyNormalizationForCurrentSong();
    } else {
      await _audioPlayer.setVolume(1.0);
    }
    await _saveSettings();
  }

  /// Reads the REPLAYGAIN_TRACK_GAIN tag for the current song and applies
  /// the corresponding volume to the audio player.
  /// No-ops when no song is loaded or when the song changes before the
  /// async file read completes.
  Future<void> _applyNormalizationForCurrentSong() async {
    final song = currentSong;
    if (song == null) return;
    final songId = song.id;
    final volume = await ReplayGainReader.getVolumeMultiplier(song.data);
    // Guard: only apply if the same song is still playing
    if (currentSong?.id == songId) {
      await _audioPlayer.setVolume(volume);
    }
  }

  Future<void> setPlaybackSpeed(double value) async {
    _playbackSpeed = value;
    await _audioPlayer.setSpeed(_playbackSpeed);
    await _audioPlayer.setPitch(effectivePitch);
    await _saveSettings();
    _scheduleNotify();
  }

  Future<void> setPitchWithSpeed(bool value) async {
    _pitchWithSpeed = value;
    // Re-apply pitch immediately
    await _audioPlayer.setPitch(effectivePitch);
    await _saveSettings();
    _scheduleNotify();
  }

  /// Sets the independent pitch ratio (0.5-2.0). It takes effect while pitch
  /// is not linked to speed.
  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.5, 2.0);
    if (!_pitchWithSpeed) await _audioPlayer.setPitch(_pitch);
    await _saveSettings();
    _scheduleNotify();
  }

  Future<void> setDefaultSortOrder(String value) async {
    _defaultSortOrder = value;
    await _saveSettings();
    _sortPlaylist();
    _scheduleNotify();
  }

  Future<void> setCacheSize(int value) async {
    _cacheSize = value;
    await _saveSettings();
    unawaited(_manageCacheSize()); // Don't block on cache management
  }

  Future<void> setMediaControls(bool value) async {
    _mediaControls = value;
    await _saveSettings();

    // Update the audio session configuration.
    // Both branches use the same long-running music config so that
    // audio focus type (GAIN) is never accidentally downgraded.
    final session = await AudioSession.instance;
    if (!_mediaControls) {
      // Disable media notifications (audio focus config stays the same)
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidWillPauseWhenDucked: true,
      ));
    } else {
      // Enable media notifications
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidWillPauseWhenDucked: true,
      ));

      // Re-initialize the audio service if needed
      if (_audioPlayer.playing) {
        // Update the current media item to refresh the notification
        final currentSong = this.currentSong;
        if (currentSong != null) {
          final mediaItem = await _createMediaItem(currentSong);
          await _audioPlayer.setAudioSource(
            AudioSource.uri(
              Uri.parse(currentSong.data),
              tag: mediaItem,
            ),
          );
        }
      }
    }
    // No need for notifyListeners - UI doesn't depend on this setting directly
  }

  Future<void> _manageCacheSize() async {
    final directory = await getApplicationDocumentsDirectory();
    // Directory listing and per-file stats are blocking I/O: keep them off the
    // UI isolate.
    await compute(
      _trimCacheDirs,
      _CacheTrimRequest(
        artworkDir: '${directory.path}/artwork_cache',
        documentsDir: directory.path,
        maxBytes: _cacheSize * 1024 * 1024,
      ),
    );
  }
}

class _CacheTrimRequest {
  const _CacheTrimRequest({
    required this.artworkDir,
    required this.documentsDir,
    required this.maxBytes,
  });

  final String artworkDir;
  final String documentsDir;
  final int maxBytes;
}

/// Runs in a background isolate. Deletes the least recently accessed files
/// until the caches fit in [_CacheTrimRequest.maxBytes].
void _trimCacheDirs(_CacheTrimRequest request) {
  var totalSize = 0;

  void trim(List<FileSystemEntity> entries) {
    totalSize += entries.fold<int>(
        0, (sum, e) => sum + (e is File ? e.lengthSync() : 0));
    if (totalSize <= request.maxBytes) return;

    // Stat each entry once instead of inside the sort comparator.
    final accessed = <String, DateTime>{
      for (final e in entries) e.path: e.statSync().accessed,
    };
    entries.sort((a, b) => accessed[a.path]!.compareTo(accessed[b.path]!));

    var currentSize = totalSize;
    for (final entry in entries) {
      if (currentSize <= request.maxBytes) break;
      if (entry is File) {
        try {
          final size = entry.lengthSync();
          entry.deleteSync();
          currentSize -= size;
        } catch (_) {}
      }
    }
  }

  final artworkDir = Directory(request.artworkDir);
  if (artworkDir.existsSync()) trim(artworkDir.listSync());

  final documentsDir = Directory(request.documentsDir);
  if (documentsDir.existsSync()) {
    trim([
      for (final e in documentsDir.listSync())
        if (e is File && e.path.endsWith('.mp3')) e,
    ]);
  }
}
