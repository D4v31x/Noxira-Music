# Graph Report - Aurora-Music  (2026-10-14)

## Corpus Check
- 250 files · ~311,956 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 88 file(s) not represented in the graph (top: .xml 38, .ttf 10, (none) 6)

## Summary
- 9880 nodes · 13094 edges · 220 communities (178 shown, 42 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 33 edges (avg confidence: 0.91)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `687933fb`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app_localizations.dart
- app_localizations_en.dart
- app_localizations_cs.dart
- audio_player_service.dart
- listening_recap_screen.dart
- home_screen.dart
- AudioPlayerService
- artwork_cache_service.dart
- metadata_detail_screen.dart
- home_screen_widget_service.dart
- recently_played_section.dart
- responsive_utils.dart
- smart_suggestions_service.dart
- music_visualizer_screen.dart
- equalizer_screen.dart
- fullscreen_lyrics.dart
- listening_insights_screen.dart
- splash_screen.dart
- artists_screen.dart
- PerformanceModeProvider
- expanding_player.dart
- albums_screen.dart
- tracks_screen.dart
- background_manager_service.dart
- now_playing.dart
- optimized_tiles.dart
- album_detail_screen.dart
- song_context_menu.dart
- theme_provider.dart
- home_layout_settings.dart
- List
- cache_manager.dart
- lyrics_section.dart
- search_tab.dart
- animation_constants.dart
- responsive_scaffold.dart
- main.dart
- for_you_section.dart
- animated_artwork_background.dart
- package:aurora_music_v01/core/constants/font_constants.dart
- StatelessWidget
- playlists_screen.dart
- artist_detail_screen.dart
- folders_screen.dart
- package:provider/provider.dart
- lyrics_service.dart
- welcome_page.dart
- playlist_detail_screen.dart
- batch_download_service.dart
- replay_gain_reader.dart
- app_config.dart
- permissions_page.dart
- storage_settings_screen.dart
- app_localizations_hi.dart
- README.md
- local_caching_service.dart
- library_tab.dart
- app_localizations_de.dart
- app_localizations_es.dart
- fullscreen_artwork.dart
- Aurora Music App Icon Design
- artist_separator_service.dart
- feedback_popup_widget.dart
- play_count_service.dart
- optimized_widgets.dart
- equalizer_service.dart
- app_localizations_ru.dart
- audio_handler.dart
- folder_filter_settings_screen.dart
- player_dialogs.dart
- toast_notification.dart
- performance_manager.dart
- music_stats_card.dart
- artist_card.dart
- audio_constants.dart
- donation_service.dart
- error_tracking_service.dart
- audio_properties_reader.dart
- artist_separator_settings.dart
- folder_detail_screen.dart
- library_screen_header.dart
- Aurora Music App Icon - Composed Adaptive Icon
- home_tab.dart
- performance_optimizations.dart
- notification_manager.dart
- static const String
- lyrics_constants.dart
- home_layout_service.dart
- glassmorphic_dialog.dart
- playlist_persistence_service.dart
- widgets.dart
- MainActivity.kt
- performance_mode_provider.dart
- device_performance_service.dart
- artist_aggregator_service.dart
- liked_songs_service.dart
- appearance_settings_screen.dart
- app_info_page.dart
- language_selection_page.dart
- sleep_timer_widgets.dart
- bluetooth_service.dart
- settings_tab.dart
- audio_settings_service.dart
- song_like_button.dart
- detail_header.dart
- theme_selection_page.dart
- insights_promo_service.dart
- album_card.dart
- VoidCallback
- insights_aurora_banner.dart
- download_progress_monitor.dart
- library_manager.dart
- translation_contribution_page.dart
- share_clip_service.dart
- onboarding_screen.dart
- pill_button.dart
- share_clip_sheet.dart
- Aurora Music — Website Brief
- glassmorphic_card.dart
- scrolling_text.dart
- player_controls.dart
- audio_validators.dart
- player_progress_bar.dart
- frame_rate_monitor.dart
- smart_playlist_model.dart
- Color
- smart_playlist_editor_screen.dart
- CustomPainter
- lazy_loading_mixin.dart
- about_settings_screen.dart
- AuroraMusicWidgetProvider.kt
- now_playing_artwork.dart
- package:flutter/material.dart
- track_tag_editor_screen.dart
- metadata_service.dart
- play_counts.dart
- lyric_line_widget.dart
- track_tag_service.dart
- ../../l10n/generated/app_localizations.dart
- dart:convert
- dart:io
- Timer?
- music_metadata_widget.dart
- Metadata Generation Command arm64-v8a
- settings_manager.dart
- track_tags_section.dart
- smart_playlist_service.dart
- bool get
- String?
- queue_manager.dart
- Aurora Music Brand Logo (Stylized Music Note)
- logging_service.dart
- supported_languages.dart
- Duration
- playlist_m3u_sync.dart
- Aurora Music - Project Structure
- crossfade_controller.dart
- playback_controller.dart
- feedback_reminder_service.dart
- Core Features
- Android NDK 27.0.12077973
- duration_formatter.dart
- FlutterMultiDexApplication.java
- .application
- dart:async
- Localization System (ARB + flutter gen-l10n)
- Contributing Translations to Aurora Music
- AppLocalizations
- media_artwork.dart
- Aurora Music
- TrackTagService
- _
- queue_persistence.dart
- SmartPlaylistService
- EqualizerService
- _ExpandClipper
- ic_stat_music1 xhdpi
- Splash Screen xhdpi
- widget_test.dart
- LaunchImage.imageset/README.md
- _InteractiveCurveState
- SmartPlaylistField
- BuildContext
- ic_stat_music xhdpi
- file_size_formatter.dart
- _ExpandRoute
- Default Album Art Placeholder
- _ShuttleLayer
- SliverGridDelegateWithMaxCrossAxisExtent
- Liked Playlist Cover Asset
- widgetBackgroundCallback
- copilot-instructions.md
- App Background Drawable (Dark)
- TargetDirectories arm64-v8a
- TargetDirectories armeabi-v7a
- iOS Launch Image README

## God Nodes (most connected - your core abstractions)
1. `AudioPlayerService` - 209 edges
2. `PerformanceModeProvider` - 104 edges
3. `_state` - 85 edges
4. `list` - 60 edges
5. `ThemeProvider` - 49 edges
6. `_` - 28 edges
7. `Aurora Music App Icon Design` - 24 edges
8. `_timer` - 21 edges
9. `_animation` - 21 edges
10. `ArtworkCacheService` - 19 edges

## Surprising Connections (you probably didn't know these)
- `didChangeDependencies` --references--> `AudioPlayerService`  [EXTRACTED]
  lib/features/library/screens/album_detail_screen.dart → lib/shared/services/audio_player_service.dart
- `didChangeDependencies` --references--> `AudioPlayerService`  [EXTRACTED]
  lib/features/library/screens/artist_detail_screen.dart → lib/shared/services/audio_player_service.dart
- `didChangeDependencies` --references--> `AudioPlayerService`  [EXTRACTED]
  lib/features/library/screens/folder_detail_screen.dart → lib/shared/services/audio_player_service.dart
- `build` --references--> `ThemeProvider`  [EXTRACTED]
  lib/features/onboarding/pages/app_info_page.dart → lib/shared/providers/theme_provider.dart
- `build` --references--> `ThemeProvider`  [EXTRACTED]
  lib/features/onboarding/pages/completion_page.dart → lib/shared/providers/theme_provider.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Aurora Music Core Feature Set** — feature_local_library, feature_background_playback, feature_synced_lyrics, feature_smart_recommendations, feature_dynamic_theming, feature_metadata_editor [EXTRACTED 1.00]
- **Localization Pipeline (l10n.yaml + Crowdin + ARB files + AppLocalizations)** — l10n, crowdin, contributing_translations, concept_app_localizations, concept_l10n_system [EXTRACTED 1.00]
- **Playback Stack (just_audio + audio_service + Background Playback Feature)** — dep_just_audio, dep_audio_service, feature_background_playback [INFERRED 0.95]
- **Dynamic Theming Stack (dynamic_color + palette_generator + Dynamic Theming Feature)** — dep_dynamic_color, dep_palette_generator, feature_dynamic_theming [INFERRED 0.95]

## Communities (220 total, 42 thin omitted)

### Community 0 - "app_localizations.dart"
Cohesion: 0.00
Nodes (703): aboutArtist, accentColor, accentColorDesc, add, addedToNamedPlaylist, addedToPlaylist, addExclusion, addRule (+695 more)

### Community 1 - "app_localizations_en.dart"
Cohesion: 0.00
Nodes (695): aboutArtist, accentColor, accentColorDesc, add, addedToNamedPlaylist, addedToPlaylist, addExclusion, addRule (+687 more)

### Community 2 - "app_localizations_cs.dart"
Cohesion: 0.00
Nodes (695): aboutArtist, accentColor, accentColorDesc, add, addedToNamedPlaylist, addedToPlaylist, addExclusion, addRule (+687 more)

### Community 3 - "audio_player_service.dart"
Cohesion: 0.02
Nodes (99): _addError, _albumPlayCounts, _artistPlayCounts, _artworkCache, _audioQuery, _automixEnabled, _backgroundManager, _bindCorePlayerListeners (+91 more)

### Community 4 - "listening_recap_screen.dart"
Cohesion: 0.02
Nodes (81): _anim, artistArtworks, artists, artwork, artworks, bigNumber, build, _buildEmpty (+73 more)

### Community 5 - "home_screen.dart"
Cohesion: 0.03
Nodes (59): albums, _animationController, _appBarTextController, _artistAggregator, artists, _artistService, _audioServiceRef, _auroraCtrl (+51 more)

### Community 6 - "AudioPlayerService"
Cohesion: 0.03
Nodes (102): AudioLibraryManagerExtension, AudioMediaArtworkExtension, AudioPlaybackControllerExtension, AudioPlayCountsExtension, AudioPlaylistM3uExtension, AudioQueueManagerExtension, AudioQueuePersistenceExtension, AudioSettingsManagerExtension (+94 more)

### Community 7 - "artwork_cache_service.dart"
Cohesion: 0.03
Nodes (67): _albumAccessOrder, _albumArtworkCache, albumId, _albumImageProviderCache, _artistAccessOrder, _artistArtworkCache, _artistImageProviderCache, artistName (+59 more)

### Community 8 - "metadata_detail_screen.dart"
Cohesion: 0.03
Nodes (59): _albumController, _applyingIndex, _applyMetadata, _artistController, _artworkService, _audioQuery, _autoTagIsLoading, _autoTagResults (+51 more)

### Community 9 - "home_screen_widget_service.dart"
Cohesion: 0.03
Nodes (56): _androidWidgetName, _appGroupId, clearWidget, command, dispose, _extractAndSaveColors, _formatDuration, _getArtistName (+48 more)

### Community 10 - "recently_played_section.dart"
Cohesion: 0.05
Nodes (31): _artworkService, build, _buildEmptyState, _buildNowPlayingCard, ListeningHistoryCard, _artworkService, build, _getDisplaySongs (+23 more)

### Community 11 - "responsive_utils.dart"
Cohesion: 0.04
Nodes (54): build, cardColumns, child, childAspectRatio, children, crossAxisSpacing, DeviceType, fontScale (+46 more)

### Community 12 - "smart_suggestions_service.dart"
Cohesion: 0.04
Nodes (51): _artistPlayCounts, artistPlayCountsForPeriod, artists, _audioQuery, _computeSuggestedTracks, estimatedMinutesForPeriod, firstListenTime, fromJson (+43 more)

### Community 13 - "music_visualizer_screen.dart"
Cohesion: 0.04
Nodes (52): _artworkProvider, _artworkService, _attachVisualizer, _audio, _barBinEnd, _barBinStart, barColor, _barHeights (+44 more)

### Community 14 - "equalizer_screen.dart"
Cohesion: 0.04
Nodes (46): _activeBand, bands, _BandValueRow, botPad, build, color, createState, _curveDragging (+38 more)

### Community 15 - "fullscreen_lyrics.dart"
Cohesion: 0.04
Nodes (51): _autoFollowPaused, _buildControls, _buildFloatingTranslateButton, _buildFontSizeOption, _buildHeader, _buildLoadingView, _buildLyricLine, _buildLyricsView (+43 more)

### Community 16 - "listening_insights_screen.dart"
Cohesion: 0.04
Nodes (53): accentColor, _anim, _artwork, _artworkService, build, _buildBody, color, count (+45 more)

### Community 17 - "splash_screen.dart"
Cohesion: 0.04
Nodes (44): _backgroundFadeAnimation, _boundedPreparation, build, _buildBackground, _checkAndTransition, _codeName, _completedTasks, createState (+36 more)

### Community 18 - "artists_screen.dart"
Cohesion: 0.04
Nodes (46): _allArtists, _applySorting, _artistAggregator, _artistImages, ArtistSortOption, ArtistsScreen, _ArtistsScreenState, _artworkService (+38 more)

### Community 19 - "PerformanceModeProvider"
Cohesion: 0.06
Nodes (72): HomeScreen, _HomeScreenState, _HomeTabBar, _HomeTabBarState, _RecapAppBarContent, _RecapAppBarContentState, _GenreRow, _GenreRowState (+64 more)

### Community 20 - "expanding_player.dart"
Cohesion: 0.02
Nodes (75): animation, artistKey, artworkKey, _artworkService, _baseTextStyle, bottomMargin, _buildContent, _buildMiniPlayer (+67 more)

### Community 21 - "albums_screen.dart"
Cohesion: 0.04
Nodes (53): _addAlbumToQueue, AlbumSortOption, AlbumsScreen, _AlbumsScreenState, _allAlbums, _applySorting, _artworkService, _audioQuery (+45 more)

### Community 22 - "tracks_screen.dart"
Cohesion: 0.04
Nodes (47): _allSongs, _applySorting, _artworkService, ascending, _audioQuery, _audioServiceRef, build, buildBody (+39 more)

### Community 23 - "background_manager_service.dart"
Cohesion: 0.04
Nodes (42): _adjustColorBrightness, _artworkCache, _artworkRetryDelay, _artworkRetryTimer, byteData, _clearArtwork, _colorCache, _computePaletteColors (+34 more)

### Community 24 - "now_playing.dart"
Cohesion: 0.03
Nodes (56): applyBoundaryConditions, applyTo, artistKey, artists, _artistService, artworkKey, _artworkNotifier, _artworkService (+48 more)

### Community 25 - "optimized_tiles.dart"
Cohesion: 0.04
Nodes (45): FieldNotifier, amplitude, _amplitudeController, _artworkService, _barPhases, _barsPerGroup, _barWidth, build (+37 more)

### Community 26 - "album_detail_screen.dart"
Cohesion: 0.04
Nodes (42): AlbumDetailScreen, albumName, _allSongs, _artistName, _artworkBytes, _artworkService, _audioQuery, _audioServiceRef (+34 more)

### Community 27 - "song_context_menu.dart"
Cohesion: 0.08
Nodes (20): _addToPlaylist, _addToQueue, _artworkService, build, _buildHeader, _channel, _clearCachedLyrics, _deleteSong (+12 more)

### Community 28 - "theme_provider.dart"
Cohesion: 0.04
Nodes (40): AppThemePreset, _blurIntensity, _blurIntensityKey, _buildDarkTheme, _cachedDarkTheme, _customSeedColor, _customSeedColorKey, _darkDynamicColorScheme (+32 more)

### Community 29 - "home_layout_settings.dart"
Cohesion: 0.14
Nodes (11): build, createState, _getSectionIcon, HomeLayoutSettingsScreen, _HomeLayoutSettingsScreenState, isDark, isVisible, onVisibilityChanged (+3 more)

### Community 30 - "List"
Cohesion: 0.03
Nodes (58): _artworkService, _audioPlayerService, build, createState, didChangeDependencies, _displaySongs, dispose, _fullPlaylist (+50 more)

### Community 31 - "cache_manager.dart"
Cohesion: 0.05
Nodes (40): _artworkCache, _cache, CacheManager, clear, clearAllCaches, clearArtworkCache, clearLyricsCache, clearMetadataCache (+32 more)

### Community 32 - "lyrics_section.dart"
Cohesion: 0.04
Nodes (48): audioPlayerService, build, _buildAnimatedLyricLines, _buildExpandButton, _buildLyricLine, _buildLyricsContainer, _buildLyricsContent, _buildNoLyricsPlaceholder (+40 more)

### Community 33 - "search_tab.dart"
Cohesion: 0.04
Nodes (48): OnboardingScreen, albums, artist, artists, _artworkService, build, _buildSearchResults, _buildSectionHeader (+40 more)

### Community 34 - "animation_constants.dart"
Cohesion: 0.05
Nodes (41): AnimationConstants, bounceIn, decelerate, dimOpacity, easeInOut, easeInOutCubic, easeInOutCurve, easeOutQuart (+33 more)

### Community 35 - "responsive_scaffold.dart"
Cohesion: 0.05
Nodes (38): appBar, backgroundColor, body, bottomNavigationBar, build, _buildDefaultPlaceholder, _buildSingleColumn, _buildTwoColumn (+30 more)

### Community 36 - "main.dart"
Cohesion: 0.05
Nodes (23): _analytics, _analyticsObserver, _AppShell, _AppShellState, audioHandler, build, createState, dispose (+15 more)

### Community 37 - "for_you_section.dart"
Cohesion: 0.05
Nodes (37): artistName, artistService, _artworkService, _audioService, _buildArtwork, _buildFavoriteContent, _buildForYouItems, _buildPlaylistArtwork (+29 more)

### Community 38 - "animated_artwork_background.dart"
Cohesion: 0.05
Nodes (37): _areArtworksEqual, _areColorsEqual, artwork, _blobRegions, blurIntensity, _buildBlurredArtwork, _buildColorGradientBackground, child (+29 more)

### Community 39 - "package:aurora_music_v01/core/constants/font_constants.dart"
Cohesion: 0.07
Nodes (20): build, _controller, createState, dispose, FeedbackDialog, _FeedbackDialogState, _send, _sending (+12 more)

### Community 40 - "StatelessWidget"
Cohesion: 0.04
Nodes (56): _BlurredNavBar, _AxisLabel, _GenreCard, _HourActivityCard, _QuickStat, _TopItemsCard, _WeekdayActivityCard, _ArtistListSlide (+48 more)

### Community 41 - "playlists_screen.dart"
Cohesion: 0.04
Nodes (55): build, build, _handleItemTap, _buildContent, _navigateToAlbumDetail, _buildAlbumsList, _showAlbumOptions, _navigateToArtistDetail (+47 more)

### Community 42 - "artist_detail_screen.dart"
Cohesion: 0.05
Nodes (38): _addAllToQueue, _albums, _albumSongs, _allSongs, ArtistDetailsScreen, _ArtistDetailsScreenState, artistImagePath, artistName (+30 more)

### Community 43 - "folders_screen.dart"
Cohesion: 0.05
Nodes (34): _allFolders, _applySorting, build, createState, _currentPage, _debounce, _displayedFolders, dispose (+26 more)

### Community 44 - "package:provider/provider.dart"
Cohesion: 0.05
Nodes (38): build, _buildInfoCard, _contentFadeAnimation, _contentSlideAnimation, _controller, createState, dispose, _exitController (+30 more)

### Community 45 - "lyrics_service.dart"
Cohesion: 0.06
Nodes (32): _addToMemoryCache, apiBaseUrl, _apiTimeout, _apiTimeoutRetry, _artistSimilarity, _cleanTitleForSearch, _client, deleteCachedLyricsForSong (+24 more)

### Community 46 - "welcome_page.dart"
Cohesion: 0.06
Nodes (35): _buttonFadeAnimation, _controller, _countTextLines, createState, _currentLanguageIndex, _cycleText, dispose, _exitController (+27 more)

### Community 47 - "playlist_detail_screen.dart"
Cohesion: 0.04
Nodes (44): _artworkBytes, _artworkService, _audioServiceRef, _autoPlaylistName, build, _buildActionRow, _buildEmptyState, _buildOptionTile (+36 more)

### Community 48 - "batch_download_service.dart"
Cohesion: 0.06
Nodes (34): actions, _artworkService, _audioQuery, completed, _completedCount, currentItem, currentStatus, dispose (+26 more)

### Community 49 - "replay_gain_reader.dart"
Cohesion: 0.06
Nodes (33): _cache, _cacheMaxSize, clearCache, db, _decodeUtf16, getTrackGainDb, getVolumeMultiplier, key (+25 more)

### Community 50 - "app_config.dart"
Cohesion: 0.06
Nodes (33): androidNotificationChannelId, androidNotificationChannelName, AppConfig, appName, artworkPreloadCount, cacheCleanupInterval, defaultAnimationDuration, defaultBlurSigma (+25 more)

### Community 51 - "permissions_page.dart"
Cohesion: 0.06
Nodes (34): _audioPermissionGranted, _bluetoothPermissionGranted, _buildPermissionItem, _checkAndroidVersion, _checkPermissions, _contentFadeAnimation, _contentSlideAnimation, _controller (+26 more)

### Community 52 - "storage_settings_screen.dart"
Cohesion: 0.14
Nodes (10): build, _clearAllCaches, createState, _fmt, _infoRow, notificationManager, _showCacheInfo, _showClearCacheDialog (+2 more)

### Community 53 - "app_localizations_hi.dart"
Cohesion: 0.00
Nodes (607): aboutArtist, accentColor, accentColorDesc, add, addedToNamedPlaylist, addedToPlaylist, addExclusion, addRule (+599 more)

### Community 54 - "README.md"
Cohesion: 0.14
Nodes (22): Analysis Options (Dart Linter Config), Aurora Music App, audio_service (^0.18.15), audiotags (^1.4.5), dynamic_color (^1.7.0), Firebase Suite (core ^3.0.0, analytics ^11.0.0, crashlytics ^4.0.0, performance ^0.10.0), flutter_lints (^6.0.0), http (^1.2.1) (+14 more)

### Community 55 - "local_caching_service.dart"
Cohesion: 0.06
Nodes (29): _accessToken, cacheDir, _cacheTimestamps, _cacheTtl, _client, _clientId, _clientSecret, _createCacheDirectory (+21 more)

### Community 56 - "library_tab.dart"
Cohesion: 0.06
Nodes (20): _albumsFuture, _artistsFuture, _artworkService, build, buildCategorySection, _buildItemCard, _buildItemsList, _buildTabletCategorySection (+12 more)

### Community 57 - "app_localizations_de.dart"
Cohesion: 0.00
Nodes (607): aboutArtist, accentColor, accentColorDesc, add, addedToNamedPlaylist, addedToPlaylist, addExclusion, addRule (+599 more)

### Community 58 - "app_localizations_es.dart"
Cohesion: 0.00
Nodes (607): aboutArtist, accentColor, accentColorDesc, add, addedToNamedPlaylist, addedToPlaylist, addExclusion, addRule (+599 more)

### Community 60 - "fullscreen_artwork.dart"
Cohesion: 0.08
Nodes (24): _artworkProvider, _artworkService, _buildControls, _buildProgressBar, _buildSongInfo, _buildTopBar, _controlsAnimation, _controlsController (+16 more)

### Community 61 - "Aurora Music App Icon Design"
Cohesion: 0.08
Nodes (30): App Icon 1024x1024@1x (Master), App Icon 20x20@1x, App Icon 20x20@2x, App Icon 20x20@3x, App Icon 29x29@1x, App Icon 29x29@2x, App Icon 29x29@3x, App Icon 40x40@1x (+22 more)

### Community 62 - "artist_separator_service.dart"
Cohesion: 0.07
Nodes (27): addExclusion, addSeparator, defaultExclusions, defaultSeparators, _enabled, _enabledKey, _exclusions, _exclusionsKey (+19 more)

### Community 63 - "feedback_popup_widget.dart"
Cohesion: 0.06
Nodes (29): _accent, build, createState, _dismissPermanently, dispose, _fadeIn, FeedbackPopupWidget, _FeedbackPopupWidgetState (+21 more)

### Community 64 - "play_count_service.dart"
Cohesion: 0.07
Nodes (29): _albumPlayCounts, _artistPlayCounts, _audioQuery, dispose, _folderAccessCounts, getAlbumPlayCount, getArtistPlayCount, getFolderAccessCount (+21 more)

### Community 65 - "optimized_widgets.dart"
Cohesion: 0.06
Nodes (30): addAutomaticKeepAlive, addRepaintBoundary, build, child, childAspectRatio, children, color, ConstDivider (+22 more)

### Community 66 - "equalizer_service.dart"
Cohesion: 0.07
Nodes (27): allPresets, _applyGains, applyPreset, builtInPresets, _customPresets, deleteCustomPreset, dispose, _enabled (+19 more)

### Community 67 - "app_localizations_ru.dart"
Cohesion: 0.00
Nodes (607): aboutArtist, accentColor, accentColorDesc, add, addedToNamedPlaylist, addedToPlaylist, addExclusion, addRule (+599 more)

### Community 68 - "audio_handler.dart"
Cohesion: 0.05
Nodes (32): _aaAlbums, _aaArtists, _aaMediaItemFromSong, _aaPlaylists, _aaSongs, attachAndroidAutoCallbacks, AuroraAudioHandler, _bindPlayerStreams (+24 more)

### Community 69 - "folder_filter_settings_screen.dart"
Cohesion: 0.07
Nodes (26): _allFolders, _applyAndPop, _applySearch, _audioQuery, build, _buildEmptyState, createState, displayName (+18 more)

### Community 70 - "player_dialogs.dart"
Cohesion: 0.06
Nodes (30): audioPlayerService, build, colorScheme, createState, _dismissibleSongTile, icon, iconColor, InfoRow (+22 more)

### Community 71 - "toast_notification.dart"
Cohesion: 0.07
Nodes (24): _animationController, build, createState, _currentOverlay, dismiss, dispose, _fadeAnimation, hide (+16 more)

### Community 72 - "performance_manager.dart"
Cohesion: 0.07
Nodes (23): cacheCleanupInterval, _cleanupCallbacks, _cleanupTimer, _currentFps, dispose, _fpsStartTime, _frameCount, getMemoryInfo (+15 more)

### Community 73 - "music_stats_card.dart"
Cohesion: 0.08
Nodes (24): build, _cachedStats, compute, createState, _formatNumber, _getMemoizedStats, hashCode, isDark (+16 more)

### Community 74 - "artist_card.dart"
Cohesion: 0.07
Nodes (22): getPrimaryArtist, hasMultipleArtists, splitArtists, ArtistCard, _artistImagePath, _artistInfo, _artistInfoCache, artistName (+14 more)

### Community 75 - "audio_constants.dart"
Cohesion: 0.07
Nodes (26): kAllowedAudioExtensions, kAllowedUriSchemes, kCacheCleanupIntervalHours, kDefaultCacheSize, kDefaultTopItemCount, kErrorAudioLoadFailed, kErrorInvalidPath, kErrorInvalidPlaylist (+18 more)

### Community 76 - "donation_service.dart"
Cohesion: 0.07
Nodes (25): build, buyMeCoffeeUrl, buyMeCoffeeUsername, color, _DonationOption, DonationService, isDark, kofiUrl (+17 more)

### Community 77 - "error_tracking_service.dart"
Cohesion: 0.08
Nodes (21): clearPendingErrors, _currentErrors, error, ErrorRecord, errorString, ErrorTrackingService, fromJson, _getPrefs (+13 more)

### Community 78 - "audio_properties_reader.dart"
Cohesion: 0.06
Nodes (28): AudioPropertiesReader, _cache, _cacheMaxSize, clearCache, _flac, format, _maxReadBytes, _mp3 (+20 more)

### Community 79 - "artist_separator_settings.dart"
Cohesion: 0.08
Nodes (24): ArtistSeparatorSettingsScreen, build, _chipTag, createState, dispose, _emptyState, _exclusions, _formatSeparatorForDisplay (+16 more)

### Community 80 - "folder_detail_screen.dart"
Cohesion: 0.07
Nodes (25): _allSongs, _artworkBytes, _artworkService, _audioServiceRef, build, _buildSongsList, createState, _currentPage (+17 more)

### Community 81 - "library_screen_header.dart"
Cohesion: 0.08
Nodes (25): accentColor, actions, badge, build, _buildBackButton, _buildBackground, _buildBadgePill, _buildOrbs (+17 more)

### Community 82 - "Aurora Music App Icon - Composed Adaptive Icon"
Cohesion: 0.09
Nodes (25): Aurora Music Logo - Stylized Dual Musical Note S-Wave Symbol, App Icon Background Layer - Navy to Purple Gradient, Aurora Music App Icon - Composed Adaptive Icon, App Icon Foreground Layer - White Dual Music Note Logo, App Icon Monochrome Layer - Black Music Note Logo, Icon Background Layer HDPI, Icon Foreground Layer HDPI, App Icon HDPI Composed (72dp) (+17 more)

### Community 83 - "home_tab.dart"
Cohesion: 0.10
Nodes (14): artistService, build, _buildSection, _buildTabletLayout, createState, currentSong, HomeTab, _HomeTabState (+6 more)

### Community 84 - "performance_optimizations.dart"
Cohesion: 0.08
Nodes (22): batchDuration, _batchTimer, _cachedValue, call, clear, computation, Debouncer, delay (+14 more)

### Community 85 - "notification_manager.dart"
Cohesion: 0.08
Nodes (19): clearPullProgress, dispose, empty, _isAppBarVisible, isProgress, _isShowingProgress, message, _notificationController (+11 more)

### Community 86 - "static const String"
Cohesion: 0.09
Nodes (17): FontConstants, fontFamily, monospaceFontFamily, getNewLanguages, markAllSeen, NewLanguagesService, _seenLanguagesKey, markShown (+9 more)

### Community 87 - "lyrics_constants.dart"
Cohesion: 0.08
Nodes (23): kLyricsAnimationDuration, kLyricsBackgroundBlur, kLyricsCurrentFontSize, kLyricsDialogBgColor, kLyricsDialogBlur, kLyricsFadeDuration, kLyricsFontSizeExtraLarge, kLyricsFontSizeKey (+15 more)

### Community 88 - "home_layout_service.dart"
Cohesion: 0.10
Nodes (19): defaultOrder, HomeSection, HomeSectionExtension, id, initialize, _instance, _isInitialized, isSectionVisible (+11 more)

### Community 89 - "glassmorphic_dialog.dart"
Cohesion: 0.07
Nodes (25): actions, actionsPadding, alwaysDark, barrierDismissible, blur, borderRadius, build, child (+17 more)

### Community 90 - "playlist_persistence_service.dart"
Cohesion: 0.08
Nodes (23): addSongsToPlaylist, addSongToPlaylist, _audioQuery, createPlaylist, deletePlaylist, dispose, getPlaylist, getTopPlaylists (+15 more)

### Community 91 - "widgets.dart"
Cohesion: 0.05
Nodes (11): AppBackground, build, child, enableAnimation, actions, build, CommonScreenScaffold, searchBar (+3 more)

### Community 92 - "MainActivity.kt"
Cohesion: 0.08
Nodes (4): MainActivity, StreamHandler, OnDataCaptureListener, PendingWrite

### Community 93 - "performance_mode_provider.dart"
Cohesion: 0.09
Nodes (20): _autoDetect, _autoDetectKey, _currentMode, currentModeDisplayName, _currentSettings, enableAutoDetect, getPerformanceModeDescription, getPerformanceModeDisplayName (+12 more)

### Community 94 - "device_performance_service.dart"
Cohesion: 0.09
Nodes (21): AnimationSettings, _cachedLevel, DevicePerformanceService, enableBlur, enableComplexAnimations, enableMeshBackground, _evaluateAndroid, _evaluateAsus (+13 more)

### Community 95 - "artist_aggregator_service.dart"
Cohesion: 0.06
Nodes (24): ArtistAggregatorService, _artistMap, _artistSongsMap, _audioQuery, _cachedArtists, _cacheDuration, clearCache, getAlbumsByArtist (+16 more)

### Community 96 - "liked_songs_service.dart"
Cohesion: 0.09
Nodes (19): dispose, initializeEmptyPlaylist, isLiked, isLikedById, likedSongIds, _likedSongs, likedSongsNotifier, _likedSongsPlaylist (+11 more)

### Community 97 - "appearance_settings_screen.dart"
Cohesion: 0.06
Nodes (26): AppearanceSettingsScreen, build, currentCode, idx, isFirst, l10n, _LanguagePickerSheet, _LanguageTile (+18 more)

### Community 98 - "app_info_page.dart"
Cohesion: 0.11
Nodes (18): AppInfoPage, _AppInfoPageState, build, _buildFeatureItem, _contentFadeAnimation, _contentSlideAnimation, _controller, createState (+10 more)

### Community 99 - "language_selection_page.dart"
Cohesion: 0.10
Nodes (21): build, _contentFadeAnimation, _contentSlideAnimation, _controller, createState, dispose, _exitController, _exitFadeAnimation (+13 more)

### Community 100 - "sleep_timer_widgets.dart"
Cohesion: 0.07
Nodes (32): _autoCollapseTimer, _buildPresetTile, colorScheme, _CounterButton, createState, dispose, icon, _isExpanded (+24 more)

### Community 101 - "bluetooth_service.dart"
Cohesion: 0.10
Nodes (15): _checkBluetoothPermission, _connectedDeviceName, _devicesSubscription, dispose, _hasBluetoothPermission, initialize, _instance, _isBluetoothConnected (+7 more)

### Community 102 - "settings_tab.dart"
Cohesion: 0.10
Nodes (12): build, _buildCategoryCard, _buildSectionWidgets, _categoryRow, createState, _currentVersion, initState, _loadVersionInfo (+4 more)

### Community 103 - "audio_settings_service.dart"
Cohesion: 0.10
Nodes (20): AudioSettingsService, _cacheSize, _defaultSortOrder, _gaplessPlayback, _kDefaultCacheSize, _kDefaultPlaybackSpeed, _kDefaultSortOrder, _kSettingsFileName (+12 more)

### Community 104 - "song_like_button.dart"
Cohesion: 0.04
Nodes (49): build, CompletionPage, _CompletionPageState, _controller, createState, dispose, _fadeAnimation, initState (+41 more)

### Community 105 - "detail_header.dart"
Cohesion: 0.10
Nodes (17): accentColor, actions, artworkBytes, artworkFilePath, badge, build, _buildBackButton, _buildBadgePill (+9 more)

### Community 106 - "theme_selection_page.dart"
Cohesion: 0.06
Nodes (33): build, _buildDonationOption, _controller, createState, dispose, DonationPage, _DonationPageState, _exitController (+25 more)

### Community 107 - "insights_promo_service.dart"
Cohesion: 0.11
Nodes (17): checkAndTriggerBanner, defaultPeriodDays, getMonthlyEnabled, getRecapPeriodDays, getWeeklyEnabled, InsightsPromoService, _kMonthlyEnabled, _kMonthlyLastSeenMonth (+9 more)

### Community 108 - "album_card.dart"
Cohesion: 0.09
Nodes (21): ArtworkCacheService, AlbumCard, albumId, albumName, artistName, artworkBytes, _artworkCache, _artworkService (+13 more)

### Community 109 - "VoidCallback"
Cohesion: 0.05
Nodes (33): build, icon, _kIconSpacing, _kMenuBorderOpacity, _kMenuBorderRadius, label, _MenuItemRow, PlayerMoreOptionsMenu (+25 more)

### Community 110 - "insights_aurora_banner.dart"
Cohesion: 0.11
Nodes (16): _auroraCtrl, _blob, build, _buildBanner, _buildContent, createState, dispose, _entryCtrl (+8 more)

### Community 111 - "download_progress_monitor.dart"
Cohesion: 0.10
Nodes (14): BatchDownloadService, DownloadProgress, _currentProgress, dispose, DownloadProgressMonitor, _downloadService, _downloadStatusController, downloadStatusStream (+6 more)

### Community 112 - "library_manager.dart"
Cohesion: 0.06
Nodes (32): addSongsToPlaylist, addSongToLibrary, addSongToPlaylist, _checkPermissionStatus, createPlaylist, deletePlaylist, _filterExcludedSongsFromPlaylists, _filterExistingFiles (+24 more)

### Community 113 - "translation_contribution_page.dart"
Cohesion: 0.11
Nodes (17): build, _continue, _controller, createState, _crowdinProjectUrl, dispose, _exitController, _exitFadeAnimation (+9 more)

### Community 114 - "share_clip_service.dart"
Cohesion: 0.07
Nodes (23): SameLanguageException, _audioQuery, _composeVideo, _decodeImage, _drawCenteredIcon, _drawImageCover, _extractGlowColor, _frameFps (+15 more)

### Community 116 - "onboarding_screen.dart"
Cohesion: 0.15
Nodes (3): build, _completeOnboarding, _totalPages

### Community 117 - "pill_button.dart"
Cohesion: 0.04
Nodes (40): audioPlayerService, build, _buildArtistName, _buildSongTitle, isTablet, _kArtistFontSizePhone, _kArtistFontSizeTablet, _kDefaultArtistOpacity (+32 more)

### Community 118 - "share_clip_sheet.dart"
Cohesion: 0.08
Nodes (22): _artworkService, build, _clipService, createState, _durationSeconds, _error, _formatSeconds, _generateAndSave (+14 more)

### Community 119 - "Aurora Music — Website Brief"
Cohesion: 0.08
Nodes (24): 1. Identity, 2. Author, 3. Features, 4. Design system, 5. Release timeline, 6. Suggested website structure, 7. Assets to prepare, 8. Things to verify before publishing (+16 more)

### Community 120 - "glassmorphic_card.dart"
Cohesion: 0.11
Nodes (18): album, artist, artwork, artworkSize, backgroundColor, badge, build, CardBadge (+10 more)

### Community 121 - "scrolling_text.dart"
Cohesion: 0.12
Nodes (16): build, createState, didUpdateWidget, dispose, initState, _isScrolling, pauseDuration, _scrollController (+8 more)

### Community 122 - "player_controls.dart"
Cohesion: 0.11
Nodes (16): audioPlayerService, backgroundColor, build, _buildPlayPauseButton, _buildRepeatButton, _buildShuffleButton, _buildSkipNextButton, _buildSkipPreviousButton (+8 more)

### Community 123 - "audio_validators.dart"
Cohesion: 0.11
Nodes (15): any, hasAllowedAudioExtension, isValidAudioUri, isValidFilePath, isValidPlaylistId, isValidPlaylistName, lowerUri, parsedUri (+7 more)

### Community 124 - "player_progress_bar.dart"
Cohesion: 0.12
Nodes (15): audioService, build, _buildRow, _buildSlider, createState, dragging, dragPosition, _dragValue (+7 more)

### Community 125 - "frame_rate_monitor.dart"
Cohesion: 0.12
Nodes (16): _calculateFps, _currentFps, _frameCount, FrameRateMonitor, _frameTimes, getPerformanceAssessment, _instance, _isMonitoring (+8 more)

### Community 126 - "smart_playlist_model.dart"
Cohesion: 0.08
Nodes (22): copyWith, createdAt, field, fromJson, id, limit, matches, matchMode (+14 more)

### Community 127 - "Color"
Cohesion: 0.06
Nodes (24): actions, backgroundColor, barrierDismissible, blur, BlurDialog, borderRadius, build, _buildActionsSection (+16 more)

### Community 128 - "smart_playlist_editor_screen.dart"
Cohesion: 0.09
Nodes (21): build, createState, dispose, existing, field, _fieldLabel, initState, _limit (+13 more)

### Community 129 - "CustomPainter"
Cohesion: 0.12
Nodes (15): _RecapAuroraPainter, _BarChartPainter, _BlobPainter, _BarSpectrumPainter, _CircularBarsPainter, _FrequencyLinePainter, _MirrorBarsPainter, _ParticlePainter (+7 more)

### Community 130 - "lazy_loading_mixin.dart"
Cohesion: 0.12
Nodes (14): allSongs, buildLoadingIndicator, currentPage, disposeLazyLoading, hasMoreItems, initLazyLoading, isLoadingMore, lazyLoadingScrollController (+6 more)

### Community 131 - "about_settings_screen.dart"
Cohesion: 0.12
Nodes (10): AboutSettingsScreen, build, _checkUpdates, currentVersion, notificationManager, onResetSetup, onUpdateCheck, _showAboutDialog (+2 more)

### Community 133 - "now_playing_artwork.dart"
Cohesion: 0.09
Nodes (20): artworkProvider, artworkService, borderRadius, build, _buildArtworkContainer, _buildArtworkImage, _buildFallbackArtwork, heroTag (+12 more)

### Community 134 - "package:flutter/material.dart"
Cohesion: 0.04
Nodes (37): locale, LocaleProvider, of, updateShouldNotify, ShaderWarmupService, _warmupPaintOperations, warmupShaders, ChangelogContent (+29 more)

### Community 135 - "track_tag_editor_screen.dart"
Cohesion: 0.10
Nodes (19): build, _buildAddTagButton, _buildEmptyState, _buildHeader, _buildPlaybackBar, _buildTagsList, createState, _currentPosition (+11 more)

### Community 136 - "metadata_service.dart"
Cohesion: 0.14
Nodes (11): _buildQueryVariants, _cleanQuery, _deezerBaseUrl, downloadImage, _englishHeaders, fetchCoverArt, fetchFullTrackDetails, _itunesBaseUrl (+3 more)

### Community 138 - "play_counts.dart"
Cohesion: 0.11
Nodes (17): firstListenTime, getAllMostPlayedTracks, getAllRecentlyAdded, getAllRecentlyPlayed, getMostPlayedAlbums, getMostPlayedArtists, getMostPlayedTracks, getRecentlyPlayed (+9 more)

### Community 139 - "lyric_line_widget.dart"
Cohesion: 0.17
Nodes (7): build, fontSize, isCurrent, lineKey, LyricLineWidget, onTap, text

### Community 140 - "track_tag_service.dart"
Cohesion: 0.11
Nodes (15): addTag, addTags, deleteTag, dismissSuggestion, _fileName, hasTags, load, _loaded (+7 more)

### Community 141 - "../../l10n/generated/app_localizations.dart"
Cohesion: 0.05
Nodes (29): AlbumSection, audioPlayerService, build, _buildAlbumCard, _buildSectionTitle, _kBottomPadding, _kHorizontalMargin, _kSectionTitleFontSize (+21 more)

### Community 142 - "dart:convert"
Cohesion: 0.10
Nodes (16): _generateSuggestions, generateSuggestionsInIsolate, LyricsIsolate, _parseLrc, parseLrcInIsolate, buildM3uContent, exportToFile, _fileName (+8 more)

### Community 143 - "dart:io"
Cohesion: 0.07
Nodes (19): android, DefaultFirebaseOptions, ensureInitialized, _excludedFolders, filterSongs, hasExclusions, _initialized, _instance (+11 more)

### Community 145 - "Timer?"
Cohesion: 0.14
Nodes (10): buildSearchField, clearSearch, debounceMilliseconds, disposeSearch, initSearch, onSearchChanged, onSearchQuery, searchController (+2 more)

### Community 146 - "music_metadata_widget.dart"
Cohesion: 0.12
Nodes (12): build, _buildDivider, _buildStatItem, _estimateBitrateValue, _formatDuration, _getFileFormat, _getFileSizeFormatted, _getQualityColor (+4 more)

### Community 147 - "Metadata Generation Command arm64-v8a"
Cohesion: 0.22
Nodes (11): Android NDK Toolchain CMake File, Build File Index arm64-v8a, Metadata Generation Command arm64-v8a, Symbol Folder Index arm64-v8a, Build File Index armeabi-v7a, Metadata Generation Command armeabi-v7a, Symbol Folder Index armeabi-v7a, CXX Debug Object Output arm64-v8a (+3 more)

### Community 148 - "settings_manager.dart"
Cohesion: 0.12
Nodes (15): _applyNormalizationForCurrentSong, _applySettings, _loadSettings, _manageCacheSize, _saveSettings, setAutomixEnabled, setCacheSize, setCrossfadeDurationMs (+7 more)

### Community 149 - "track_tags_section.dart"
Cohesion: 0.12
Nodes (10): active, _activeTagIndex, audioPlayerService, build, isTablet, onDismiss, tags, _TagsListCard (+2 more)

### Community 150 - "smart_playlist_service.dart"
Cohesion: 0.14
Nodes (10): buildPlaylist, createSmartPlaylist, deleteSmartPlaylist, evaluate, _fileName, load, _loaded, _save (+2 more)

### Community 151 - "bool get"
Cohesion: 0.17
Nodes (9): cancelTimer, dispose, duration, isActive, _remainingTime, _sleepTimer, _sleepTimerDuration, startTimer (+1 more)

### Community 152 - "String?"
Cohesion: 0.17
Nodes (8): checkForNewVersion, getCurrentVersion, isUpdateAvailable, latestVersion, resetChangelog, shouldShowChangelog, VersionCheckResult, VersionService

### Community 153 - "queue_manager.dart"
Cohesion: 0.14
Nodes (13): addMultipleToQueue, addToQueue, clearQueue, clearUpcoming, moveInQueue, playNext, _rebuildAudioSourcePreservingPosition, removeFromQueue (+5 more)

### Community 154 - "Aurora Music Brand Logo (Stylized Music Note)"
Cohesion: 0.33
Nodes (10): Aurora Music Brand Logo (Stylized Music Note), Aurora Music Android Notification Icon Set, Aurora Music Purple Gradient Design Language, HDPI Notification Status Icon Variant, HDPI Notification Status Icon, HDPI Splash Screen Asset (White on Transparent), Notification Status Icon Variant 1, Widget Aurora Full Logo (White on Transparent) (+2 more)

### Community 155 - "logging_service.dart"
Cohesion: 0.22
Nodes (7): _appName, critical, debug, error, info, LoggingService, warning

### Community 156 - "supported_languages.dart"
Cohesion: 0.20
Nodes (8): all, code, englishName, forCode, nativeName, nativeNameFor, SupportedLanguage, SupportedLanguages

### Community 158 - "Duration"
Cohesion: 0.15
Nodes (10): text, time, TimedLyric, copyWith, fromJson, id, name, position (+2 more)

### Community 159 - "playlist_m3u_sync.dart"
Cohesion: 0.15
Nodes (12): exportPlaylistContent, exportPlaylistToTempFile, _fileBaseName, importPlaylistFromM3uFile, _isSyncExcludedPlaylist, _kSyncFolderPrefKey, _m3uService, playlistSyncFolder (+4 more)

### Community 161 - "Aurora Music - Project Structure"
Cohesion: 0.15
Nodes (13): 1. Feature-First Architecture, 2. Shared Layer, 3. Core Layer, 4. Barrel Files, Adding New Features, Adding Shared Components, Aurora Music - Project Structure, Directory Structure (+5 more)

### Community 162 - "crossfade_controller.dart"
Cohesion: 0.17
Nodes (11): attachCrossfadePipelineFactory, AudioCrossfadeControllerExtension, _beginCrossfade, cancelCrossfadeIfActive, _initCrossfadeEngine, kAutomixDurationMs, kMaxCrossfadeMs, kMinCrossfadeMs (+3 more)

### Community 163 - "playback_controller.dart"
Cohesion: 0.17
Nodes (11): back, pause, play, _playInternal, resume, setPlaylist, skip, _sortPlaylist (+3 more)

### Community 164 - "feedback_reminder_service.dart"
Cohesion: 0.17
Nodes (11): _appOpenCountKey, _dismissedPermanentlyKey, dismissPermanently, FeedbackReminderService, _lastPromptKey, _minDaysBetweenPrompts, _minOpensBeforeFirstPrompt, _promptCountKey (+3 more)

### Community 165 - "Core Features"
Cohesion: 0.18
Nodes (11): Core Features, Internationalization, Library, Now Playing, Onboarding & Settings, Personalization & Theming, Playback, Playlists (+3 more)

### Community 166 - "Android NDK 27.0.12077973"
Cohesion: 0.36
Nodes (8): Android Gradle Plugin 8.7.3, Android NDK 27.0.12077973, Android Platform API 29, CMakeCache arm64-v8a Debug, CMakeCache armeabi-v7a Debug, CMake 3.22.1, CXX Build Hash Key (6p5f3i11), LLVM Toolchain (NDK prebuilt)

### Community 167 - "duration_formatter.dart"
Cohesion: 0.25
Nodes (7): formatDuration, formatDurationCompact, formatDurationWithHours, hours, minutes, seconds, twoDigits

### Community 169 - ".application"
Cohesion: 0.12
Nodes (7): AVFoundation, Flutter, AppDelegate, AudioSessionHandler, RunnerTests, UIKit, XCTest

### Community 171 - "dart:async"
Cohesion: 0.29
Nodes (4): build, _openCrowdin, showIfNeeded, TranslationReminderDialog

### Community 172 - "Localization System (ARB + flutter gen-l10n)"
Cohesion: 0.31
Nodes (8): AppLocalizations (generated class), Crowdin Translation Management, Localization System (ARB + flutter gen-l10n), 4. After translators have worked... download translations, 5. Regenerate Dart files, MY NOTES, Crowdin Configuration, L10n Configuration (l10n.yaml)

### Community 173 - "Contributing Translations to Aurora Music"
Cohesion: 0.22
Nodes (9): Contributing Translations to Aurora Music, Keeping translations up to date, Need help?, Prerequisites, Step 1 – Create the translation file, Step 2 – Regenerate the Dart files, Step 3 – Register the language (the only manual step), Step 4 – (Optional) Add a welcome greeting (+1 more)

### Community 174 - "AppLocalizations"
Cohesion: 0.20
Nodes (9): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsCs, AppLocalizationsDe, AppLocalizationsEn, AppLocalizationsEs, AppLocalizationsHi, of (+1 more)

### Community 175 - "media_artwork.dart"
Cohesion: 0.29
Nodes (6): _createMediaItem, _createMediaItemSync, getCurrentSongArtwork, _loadRemainingArtworkInBackground, _updateBackgroundColors, updateCurrentArtwork

### Community 176 - "Aurora Music"
Cohesion: 0.33
Nodes (6): Aurora Music, Building & Running, Platforms, Project Structure, Tech Stack, What it does

### Community 177 - "TrackTagService"
Cohesion: 0.40
Nodes (5): _deleteTag, _importTimestamps, TrackTagEditorScreen, _TrackTagEditorScreenState, TrackTagService

### Community 178 - "_"
Cohesion: 0.40
Nodes (5): _, _ascendingKey, _optionKey, save, SortPreferences

### Community 181 - "queue_persistence.dart"
Cohesion: 0.50
Nodes (3): loadQueueState, _primeAudioSourceAfterRestore, saveQueueState

### Community 182 - "SmartPlaylistService"
Cohesion: 0.50
Nodes (4): _save, SmartPlaylistEditorScreen, _SmartPlaylistEditorScreenState, SmartPlaylistService

### Community 183 - "EqualizerService"
Cohesion: 0.50
Nodes (4): EqualizerScreen, _EqualizerScreenState, _maybeInit, EqualizerService

### Community 186 - "ic_stat_music1 xhdpi"
Cohesion: 0.50
Nodes (4): ic_stat_music1 mdpi, ic_stat_music1 xhdpi, ic_stat_music1 xxhdpi, ic_stat_music1 xxxhdpi

### Community 187 - "Splash Screen xhdpi"
Cohesion: 0.50
Nodes (4): Splash Screen mdpi, Splash Screen xhdpi, Splash Screen xxhdpi, Splash Screen xxxhdpi

### Community 195 - "ic_stat_music xhdpi"
Cohesion: 0.67
Nodes (3): ic_stat_music mdpi, ic_stat_music xhdpi, ic_stat_music xxhdpi

### Community 199 - "Default Album Art Placeholder"
Cohesion: 0.67
Nodes (3): Default Album Art Placeholder, Aurora Music Full Logo (white on white - transparent), Unknown Artist Placeholder Asset

### Community 204 - "Liked Playlist Cover Asset"
Cohesion: 1.00
Nodes (3): Liked Playlist Cover Asset, Most Played Playlist Cover Asset, Recently Added Playlist Cover Asset

## Knowledge Gaps
- **8119 isolated node(s):** `XCTest`, `AnimationConstants`, `fastest`, `fast`, `normal` (+8114 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 8557 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **42 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `list` connect `List` to `lazy_loading_mixin.dart`, `audio_player_service.dart`, `listening_recap_screen.dart`, `home_screen.dart`, `AudioPlayerService`, `metadata_detail_screen.dart`, `recently_played_section.dart`, `responsive_utils.dart`, `smart_suggestions_service.dart`, `music_visualizer_screen.dart`, `equalizer_screen.dart`, `fullscreen_lyrics.dart`, `listening_insights_screen.dart`, `splash_screen.dart`, `artists_screen.dart`, `albums_screen.dart`, `tracks_screen.dart`, `background_manager_service.dart`, `now_playing.dart`, `album_detail_screen.dart`, `lyrics_section.dart`, `search_tab.dart`, `responsive_scaffold.dart`, `main.dart`, `for_you_section.dart`, `animated_artwork_background.dart`, `playlists_screen.dart`, `artist_detail_screen.dart`, `folders_screen.dart`, `package:provider/provider.dart`, `welcome_page.dart`, `playlist_detail_screen.dart`, `batch_download_service.dart`, `artist_separator_service.dart`, `optimized_widgets.dart`, `equalizer_service.dart`, `folder_filter_settings_screen.dart`, `performance_manager.dart`, `audio_constants.dart`, `error_tracking_service.dart`, `artist_separator_settings.dart`, `folder_detail_screen.dart`, `library_screen_header.dart`, `home_tab.dart`, `home_layout_service.dart`, `glassmorphic_dialog.dart`, `playlist_persistence_service.dart`, `widgets.dart`, `artist_aggregator_service.dart`, `language_selection_page.dart`, `detail_header.dart`, `frame_rate_monitor.dart`, `Color`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._
- **What connects `XCTest`, `AnimationConstants`, `fastest` to the rest of the system?**
  _8119 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.002805049088359046 - nodes in this community are weakly interconnected._
- **Why does `AudioPlayerService` connect `AudioPlayerService` to `smart_playlist_editor_screen.dart`, `audio_player_service.dart`, `listening_recap_screen.dart`, `home_screen.dart`, `track_tag_editor_screen.dart`, `metadata_detail_screen.dart`, `recently_played_section.dart`, `music_visualizer_screen.dart`, `../../l10n/generated/app_localizations.dart`, `fullscreen_lyrics.dart`, `listening_insights_screen.dart`, `splash_screen.dart`, `artists_screen.dart`, `PerformanceModeProvider`, `expanding_player.dart`, `albums_screen.dart`, `tracks_screen.dart`, `track_tags_section.dart`, `now_playing.dart`, `album_detail_screen.dart`, `song_context_menu.dart`, `List`, `lyrics_section.dart`, `search_tab.dart`, `crossfade_controller.dart`, `main.dart`, `for_you_section.dart`, `playlists_screen.dart`, `artist_detail_screen.dart`, `playlist_detail_screen.dart`, `TrackTagService`, `SmartPlaylistService`, `library_tab.dart`, `fullscreen_artwork.dart`, `player_dialogs.dart`, `music_stats_card.dart`, `folder_detail_screen.dart`, `appearance_settings_screen.dart`, `sleep_timer_widgets.dart`, `song_like_button.dart`, `pill_button.dart`, `player_controls.dart`, `player_progress_bar.dart`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0028735632183908046 - nodes in this community are weakly interconnected._
- **Why does `PerformanceModeProvider` connect `PerformanceModeProvider` to `about_settings_screen.dart`, `home_screen.dart`, `AudioPlayerService`, `package:flutter/material.dart`, `metadata_detail_screen.dart`, `music_metadata_widget.dart`, `expanding_player.dart`, `now_playing.dart`, `lyrics_section.dart`, `search_tab.dart`, `main.dart`, `animated_artwork_background.dart`, `StatelessWidget`, `playlists_screen.dart`, `dart:async`, `package:provider/provider.dart`, `playlist_detail_screen.dart`, `storage_settings_screen.dart`, `player_dialogs.dart`, `toast_notification.dart`, `artist_card.dart`, `artist_separator_settings.dart`, `glassmorphic_dialog.dart`, `performance_mode_provider.dart`, `appearance_settings_screen.dart`, `sleep_timer_widgets.dart`, `settings_tab.dart`, `theme_selection_page.dart`, `album_card.dart`, `VoidCallback`, `insights_aurora_banner.dart`, `pill_button.dart`, `glassmorphic_card.dart`, `Color`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Should `app_localizations_cs.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0028735632183908046 - nodes in this community are weakly interconnected._