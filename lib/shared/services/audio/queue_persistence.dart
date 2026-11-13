part of '../audio_player_service.dart';

/// What the background isolate hands back when the saved queue is read.
class _DecodedQueueState {
  const _DecodedQueueState(this.json, this.queueExists, this.originalExists);

  final Map<String, dynamic> json;
  final List<bool> queueExists;
  final List<bool> originalExists;
}

/// Runs in a background isolate: decodes the saved queue and checks which of
/// its files are still there. For a big queue that is thousands of file
/// checks and a multi-MB document, which on the UI isolate delays start-up.
_DecodedQueueState _decodeQueueState(String contents) {
  final json = jsonDecode(contents) as Map<String, dynamic>;
  List<bool> exist(Object? maps) => [
        for (final m in (maps as List? ?? const [])) _songFileExists(m),
      ];
  return _DecodedQueueState(
      json, exist(json['queue']), exist(json['originalQueue']));
}

bool _songFileExists(Object? songMap) {
  try {
    return File((songMap as Map)['_data'] as String).existsSync();
  } catch (_) {
    return false;
  }
}

extension AudioQueuePersistenceExtension on AudioPlayerService {
  // MARK: - Queue State Persistence

  /// Persists the current queue (songs, index, position, shuffle/repeat state)
  /// to disk so it can be restored on the next app launch.
  ///
  /// Called on every track change and queue edit. Writing means encoding the
  /// whole queue (twice, with the original order), which is real work on the
  /// UI isolate and would run at each skip, so changes that follow each other
  /// share one write a moment later.
  Future<void> saveQueueState() async {
    _saveQueueTimer?.cancel();
    _saveQueueTimer = Timer(const Duration(milliseconds: 1500), () {
      unawaited(_writeQueueState());
    });
  }

  Future<void> _writeQueueState() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$kQueueStateFileName');

      final json = {
        'queue': _playlist.map((song) => song.getMap).toList(),
        'originalQueue': _originalPlaylist.map((song) => song.getMap).toList(),
        'currentIndex': _currentIndex,
        'queueCount': _queueCount,
        'positionMs': _audioPlayer.position.inMilliseconds,
        'isShuffle': _isShuffle,
        'loopMode': _loopMode.name,
      };

      await writeStringAtomic(file, jsonEncode(json));
    } catch (e) {
      debugPrint('Error saving queue state: $e');
    }
  }

  /// Restores the queue state that was saved by [saveQueueState].
  /// Only restores metadata — playback is NOT automatically started.
  Future<void> loadQueueState() async {
    if (_disposed) return;
    final initialPlaylist = _playlist;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$kQueueStateFileName');

      if (!await file.exists()) return;

      final contents = await file.readAsString();
      // A small queue is quicker to decode in place than to hand to an
      // isolate; a big one (thousands of songs) is what the isolate is for.
      final decodedState = contents.length > 64 * 1024
          ? await compute(_decodeQueueState, contents)
          : _decodeQueueState(contents);
      final json = decodedState.json;
      if (_disposed || !identical(_playlist, initialPlaylist)) {
        LoggingService.debug(
            'Queue restore superseded by playback', 'QueueRestore');
        return;
      }

      final queueMaps = json['queue'] as List? ?? [];
      if (queueMaps.isEmpty) return;

      // Reconstruct songs, leaving out any whose file no longer exists (the
      // isolate already checked which).
      List<SongModel> buildQueueFromMaps(List maps, List<bool> exists) {
        return [
          for (var i = 0; i < maps.length; i++)
            if (i < exists.length && exists[i])
              SongModel(Map<String, dynamic>.from(maps[i] as Map)),
        ];
      }

      final queue = buildQueueFromMaps(queueMaps, decodedState.queueExists);
      if (queue.isEmpty) return;

      final originalQueueMaps = json['originalQueue'] as List? ?? [];
      final originalQueue =
          buildQueueFromMaps(originalQueueMaps, decodedState.originalExists);

      final savedIndex =
          (json['currentIndex'] as int? ?? 0).clamp(0, queue.length - 1);
      final isShuffle = json['isShuffle'] as bool? ?? false;
      final loopModeName = json['loopMode'] as String? ?? '';
      final loopMode = LoopMode.values.firstWhere(
        (m) => m.name == loopModeName,
        orElse: () => LoopMode.off,
      );

      _playlist = queue;
      _originalPlaylist = originalQueue;
      _currentIndex = savedIndex;
      _queueCount = (json['queueCount'] as int? ?? 0).clamp(0, queue.length);
      _isShuffle = isShuffle;
      _loopMode = loopMode;

      isShuffleNotifier.value = _isShuffle;
      loopModeNotifier.value = _loopMode;

      // Update current song notifiers without starting playback.
      final song = _playlist[_currentIndex];
      _currentSongController.add(song);
      currentSongNotifier.value = song;
      unawaited(_updateBackgroundColors());

      debugPrint(
          'Queue state restored: ${_playlist.length} songs, index: $_currentIndex, '
          'shuffle: $_isShuffle, loopMode: $_loopMode');

      // Prime the audio source so that tapping Play immediately works.
      // We load the source at the saved position but do NOT call play().
      await _primeAudioSourceAfterRestore(
          savedIndex, Duration(milliseconds: json['positionMs'] as int? ?? 0));

      _scheduleNotify();
    } catch (e) {
      debugPrint('Error loading queue state: $e');
    }
  }

  /// Loads the audio source into the player after a queue-state restore,
  /// positioned at [savedIndex] / [savedPosition], without starting playback.
  /// This ensures the first tap on Play works immediately.
  Future<void> _primeAudioSourceAfterRestore(
      int savedIndex, Duration savedPosition) async {
    final restoredPlaylist = _playlist;
    bool superseded() => _disposed || !identical(_playlist, restoredPlaylist);
    try {
      if (_gaplessPlayback) {
        final mediaItems =
            _playlist.map((s) => _createMediaItemSync(s)).toList();
        final source = _playlist
            .asMap()
            .entries
            .map((e) => AudioSource.uri(
                  Uri.parse(e.value.uri ?? e.value.data),
                  tag: mediaItems[e.key],
                ))
            .toList();
        await _audioPlayer.setAudioSources(
          source,
          initialIndex: savedIndex,
          initialPosition: savedPosition,
        );
        if (superseded()) return;
        // Pause immediately so we don't auto-play on restore.
        await _audioPlayer.pause();
        unawaited(_loadRemainingArtworkInBackground(_playlist));
      } else {
        // Non-gapless: prime with just the current song.
        final song = _playlist[savedIndex];
        final mediaItem = _createMediaItemSync(song);
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(song.uri ?? song.data),
            tag: mediaItem,
          ),
          initialPosition: savedPosition,
        );
        if (superseded()) return;
        await _audioPlayer.pause();
      }
      // The restored loop mode must reach the player too, or repeat-one
      // shows as active while the player still advances.
      await _audioPlayer.setLoopMode(_loopMode);
      if (superseded()) return;
      // Notify the audio handler so the lock-screen / notification
      // shows the restored song without starting playback.
      audioHandler.updateNotificationMediaItem(
          _createMediaItemSync(_playlist[savedIndex]));
      debugPrint('Audio source primed after queue restore.');
    } on PlayerInterruptedException {
      LoggingService.debug(
          'Queue priming interrupted by a newer request', 'QueueRestore');
    } catch (e, stack) {
      // Non-fatal: if priming fails the user will see an error when they tap
      // Play, but the rest of the app is still usable.
      LoggingService.error('Error priming audio source after queue restore',
          'QueueRestore', e, stack);
    }
  }
}
