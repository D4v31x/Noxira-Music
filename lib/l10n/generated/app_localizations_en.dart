// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutArtist => 'About artist';

  @override
  String get add => 'Add';

  @override
  String get addExclusion => 'Add Exclusion';

  @override
  String get addSeparator => 'Add Separator';

  @override
  String get addSongs => 'Add Songs';

  @override
  String get addSongsToPlaylist => 'Add Songs to Playlist';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get adjustSync => 'Adjust Sync';

  @override
  String get album => 'Album';

  @override
  String get albums => 'Albums';

  @override
  String get allSongs => 'All Songs';

  @override
  String get appName => 'Noxira Music';

  @override
  String get artist => 'Artist';

  @override
  String get artistName => 'Artist name';

  @override
  String get artists => 'Artists';

  @override
  String get artistSeparation => 'Artist Separation';

  @override
  String get artistSeparationDesc => 'Configure how multiple artists are split';

  @override
  String get audioQuality => 'Audio Quality';

  @override
  String get audioQualityDesc => 'Technical specifications of the audio file';

  @override
  String get auroraMusic => 'Noxira Music';

  @override
  String get autoPlaylists => 'Auto Playlists';

  @override
  String get autoTag => 'Auto Tag';

  @override
  String get smartPlaylists => 'Smart Playlists';

  @override
  String get createSmartPlaylist => 'Create smart playlist…';

  @override
  String get editSmartPlaylist => 'Edit Smart Playlist';

  @override
  String get smartPlaylistNameHint => 'Playlist name';

  @override
  String get smartPlaylistRules => 'Rules';

  @override
  String get addRule => 'Add rule';

  @override
  String get saveSmartPlaylist => 'Save';

  @override
  String get matchAll => 'Match ALL rules';

  @override
  String get matchAny => 'Match ANY rule';

  @override
  String get limitResultsLabel => 'Limit results';

  @override
  String get noLimit => 'No limit';

  @override
  String get deleteSmartPlaylistConfirm =>
      'Delete this smart playlist? This only removes the saved rules — your songs are not affected.';

  @override
  String smartPlaylistPreviewCount(int count) {
    return 'Matches $count songs right now';
  }

  @override
  String get saveAsClip => 'Save as clip';

  @override
  String get generatingClip => 'Generating clip…';

  @override
  String get clipDuration => 'Clip duration';

  @override
  String get clipStartOffset => 'Start point';

  @override
  String get saveClip => 'Save clip';

  @override
  String get clipSavedToDevice => 'Clip saved to device';

  @override
  String get clipSaveFailed => 'Couldn\'t save the clip. Please try again.';

  @override
  String get playlistSavedToDevice => 'Playlist saved to device';

  @override
  String get trackTags => 'Track Tags';

  @override
  String get editTrackTags => 'Edit tags';

  @override
  String get addTrackTag => 'Add tag';

  @override
  String get noTrackTagsYet =>
      'No tags yet. Add one to jump straight to a part of this track.';

  @override
  String get trackTagNameHint => 'e.g. Song title or artist';

  @override
  String get trackTagPosition => 'Position';

  @override
  String get useCurrentPosition => 'Use current position';

  @override
  String get isThisASet => 'Add timestamps to this track';

  @override
  String get tagPartsForEasySwitching =>
      'Mark any moment — chapters, highlights, bookmarks, or anything else.';

  @override
  String get tagThisTrack => 'Add tags';

  @override
  String get pasteSetlist => 'Import timestamps';

  @override
  String get pasteSetlistDialogTitle => 'Import Timestamps';

  @override
  String get pasteSetlistHint =>
      'Paste timestamps here, e.g.\n0:00 Intro\n3:45 Chapter Name';

  @override
  String get importAction => 'Import';

  @override
  String tagsImportedMessage(int count) {
    return 'Imported $count tags';
  }

  @override
  String get noTagsFoundInPaste => 'No timestamps found in the pasted text.';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get buyMeCoffee => 'Buy Me a Coffee';

  @override
  String get cancel => 'Cancel';

  @override
  String get coffeeSupport => 'Support with a coffee';

  @override
  String get composer => 'Composer';

  @override
  String get connectWithUs => 'Connect with us';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get create => 'Create';

  @override
  String get createFirstPlaylist =>
      'Tap the button above to create your first playlist';

  @override
  String get createPlaylist => 'Create Playlist';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get dateAdded => 'Date Added';

  @override
  String get dateModified => 'Date Modified';

  @override
  String get delete => 'Delete';

  @override
  String get deletePlaylist => 'Delete Playlist';

  @override
  String get deletePlaylistConfirm => 'Are you sure you want to delete';

  @override
  String get deletePlaylistConfirmation =>
      'Are you sure you want to delete this playlist?';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get details => 'See details';

  @override
  String get discard => 'Discard';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get duration => 'Duration';

  @override
  String get enableArtistSeparation => 'Enable Artist Separation';

  @override
  String get enableArtistSeparationDesc =>
      'Automatically split combined artist names';

  @override
  String get enjoyingAurora => 'Enjoying Noxira?';

  @override
  String get enjoyingAuroraDesc =>
      'If you love using Noxira Music, consider supporting its development. Your support helps keep it free!';

  @override
  String get error => 'Error';

  @override
  String get exclusionHint => 'e.g. AC/DC';

  @override
  String get exclusions => 'Exclusions';

  @override
  String get exclusionsDesc => 'Artist names that should never be split';

  @override
  String get exit => 'Exit';

  @override
  String get exitApp => 'Exit App';

  @override
  String get exitAppConfirm => 'Do you want to exit?';

  @override
  String get expandLyrics => 'Expand Lyrics';

  @override
  String get extraLarge => 'Extra Large';

  @override
  String get favoriteSongs => 'Favorite Songs';

  @override
  String get fileInfo => 'File Info';

  @override
  String get fileInfoDesc => 'Long press on values to copy them';

  @override
  String get fileName => 'File Name';

  @override
  String get filePath => 'File Path';

  @override
  String get folder => 'Folder';

  @override
  String get folders => 'Folders';

  @override
  String get fontSize => 'Font Size';

  @override
  String get format => 'Format';

  @override
  String get forYou => 'For You';

  @override
  String get genre => 'Genre';

  @override
  String get goodQuality => 'Good Quality';

  @override
  String get gotIt => 'Got it!';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get highQuality => 'High Quality';

  @override
  String get home => 'Home';

  @override
  String get kofi => 'Ko-fi';

  @override
  String get buyMeACoffee => 'Buy Me a Coffee';

  @override
  String get donationNote =>
      'No pressure - you can always donate later in Settings';

  @override
  String get language => 'Language';

  @override
  String get large => 'Large';

  @override
  String get later => 'Later';

  @override
  String get library => 'Library';

  @override
  String get libraryError => 'Error loading music library';

  @override
  String get libraryLoaded => 'Music library loaded';

  @override
  String get libraryUpdated => 'Library updated';

  @override
  String get loading => 'Loading';

  @override
  String get loadingLibrary => 'Loading library';

  @override
  String get lossless => 'Lossless';

  @override
  String get lowQuality => 'Low Quality';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get lyricsAhead => 'Lyrics are ahead';

  @override
  String get lyricsBehind => 'Lyrics are behind';

  @override
  String get lyricsSynced => 'Lyrics are synced';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get medium => 'Medium';

  @override
  String get metadata => 'Metadata';

  @override
  String get metadataSaved => 'Metadata saved successfully';

  @override
  String get metadataApplied => 'Metadata downloaded successfully';

  @override
  String get metadataDownloadFailed =>
      'Download failed. Check your connection and try again.';

  @override
  String get chooseArtworkFromDevice => 'Choose from device';

  @override
  String get mostPlayed => 'Most Played';

  @override
  String get newPlaylist => 'New Playlist';

  @override
  String get next => 'Next';

  @override
  String get no => 'No';

  @override
  String get noAlbumsFound => 'No albums found';

  @override
  String get noArtistInfo => 'Artist info not available';

  @override
  String get noArtistsFound => 'No artists found';

  @override
  String get noData => 'No data to display';

  @override
  String get noExclusions => 'No exclusions configured';

  @override
  String get noLyrics => 'Lyrics not available';

  @override
  String get noLyricsDesc => 'We couldn\'t find lyrics for this song';

  @override
  String get noLyricsFound => 'No lyrics found';

  @override
  String get noPermissionExplanation =>
      'Without permissions, Noxira Music won\'t be able to access your music library.';

  @override
  String get noPlaylists => 'No playlists available';

  @override
  String get noResults => 'No results found';

  @override
  String get noSeparators => 'No separators configured';

  @override
  String get noSongPlaying => 'No song playing';

  @override
  String get noSongsAvailable => 'No songs available';

  @override
  String get noSongsInPlaylist => 'No songs in this playlist';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get onboardingAlbumArtwork => 'Album Artwork';

  @override
  String get onboardingAlbumArtworkDesc =>
      'Fetches high-quality album covers to enhance your library';

  @override
  String get onboardingAnalytics => 'Anonymous analytics & crash reports';

  @override
  String get onboardingAnalyticsDesc =>
      'Helps us fix bugs and improve performance. Never includes your listening history or personal data.';

  @override
  String get onboardingAppInfoSubtitle => 'Your personal music companion';

  @override
  String get onboardingAudioAccess => 'Audio Access';

  @override
  String get onboardingAudioAccessDesc =>
      'Required to play and manage your music library';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingBeautifulArtwork => 'Beautiful album artwork';

  @override
  String get onboardingBeautifulArtworkDesc =>
      'Automatically fetch and display album artwork in the way it was meant to be seen';

  @override
  String get onboardingBluetooth => 'Bluetooth';

  @override
  String get onboardingBluetoothDesc =>
      'Needed to connect to bluetooth devices';

  @override
  String get onboardingChooseLanguage => 'Choose Your Language';

  @override
  String get onboardingCompletionSubtitle => 'Start enjoying your music';

  @override
  String get onboardingCompletionTitle => 'You\'re All Set!';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingDynamicColors => 'Dynamic Colors';

  @override
  String get onboardingDynamicColorsDesc => 'Match system wallpaper colors';

  @override
  String get onboardingGrantPermissions => 'Grant Permissions';

  @override
  String get onboardingInternetSubtitle => 'How Noxira Music uses the internet';

  @override
  String get onboardingInternetTitle => 'Internet Usage';

  @override
  String get onboardingLocalMusic => 'Music on your device';

  @override
  String get onboardingLocalMusicDesc =>
      'Have your music files in the palm of your hand';

  @override
  String get onboardingLyrics => 'Lyrics';

  @override
  String get onboardingLyricsDesc =>
      'Downloads synchronized lyrics for your songs from LRCLIB, Better Lyrics, YouLyPlus and KuGou. These services receive the song title, artist, album and length. You can turn individual sources off in Settings.';

  @override
  String get onboardingLyricsSupport => 'Lyrics Support';

  @override
  String get onboardingLyricsSupportDesc =>
      'View synchronized lyrics while listening';

  @override
  String get onboardingMaterialDesign => 'Material You Design';

  @override
  String get onboardingMaterialDesignDesc =>
      'Dynamic colors that adapt to your preferences';

  @override
  String get onboardingMusicMetadata => 'Music Metadata';

  @override
  String get onboardingMusicMetadataDesc =>
      'Gets artist info, album details, and track information';

  @override
  String get onboardingNotifications => 'Notifications';

  @override
  String get onboardingNotificationsDesc =>
      'Show playback controls and updates';

  @override
  String get onboardingPermissionsSubtitle =>
      'Noxira Music needs these permissions to work properly';

  @override
  String get onboardingPermissionsTitle => 'Grant Permissions';

  @override
  String get onboardingPrivacyNote =>
      'Your privacy is important. All music files stay on your device.';

  @override
  String get onboardingRequesting => 'Requesting...';

  @override
  String get onboardingRequired => 'Required';

  @override
  String get onboardingAudioRequired =>
      'Audio access is required to continue. Please grant the permission above.';

  @override
  String get onboardingSelectLanguage => 'Select your preferred language';

  @override
  String get onboardingSmartPlaylists => 'Smart Playlists';

  @override
  String get onboardingSmartPlaylistsDesc =>
      'Create and manage your music collections';

  @override
  String get onboardingStartListening => 'Start Listening';

  @override
  String get onboardingStorageAccess => 'Storage Access';

  @override
  String get onboardingStorageAccessDesc =>
      'Required to read music files from your device';

  @override
  String get onboardingVisualizerAccess => 'Visualizer';

  @override
  String get onboardingVisualizerAccessDesc =>
      'Lets the visualizer read your device\'s audio session for the live bar spectrum. No audio is ever recorded.';

  @override
  String get onboardingThemeSubtitle => 'Choose a theme that suits your style';

  @override
  String get onboardingThemeTitle => 'Customize Your Look';

  @override
  String get oneTimeSupport => 'Quick one-time support';

  @override
  String get openFolder => 'Open in File Manager';

  @override
  String get openFolderInfo =>
      'Use your file manager to navigate to this location';

  @override
  String get ownTimer => 'Own timer';

  @override
  String get permDeny => 'Permissions denied';

  @override
  String get permissionExplanation =>
      'Noxira Music needs these permissions to function properly. Please grant the permissions in the app settings.';

  @override
  String get permissionLater =>
      'You can grant permissions later in app settings';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get playAll => 'Play All';

  @override
  String get playingFrom => 'Playing from';

  @override
  String get playlist => 'Playlist';

  @override
  String get playlistName => 'Playlist name';

  @override
  String get playlists => 'Playlists';

  @override
  String get possibleReasons => 'Possible reasons:';

  @override
  String get privacyNotice =>
      'By continuing to use this app, you agree to our Privacy Policy.';

  @override
  String get privacyPolicyLink => 'Read our Privacy Policy';

  @override
  String get quality => 'Quality';

  @override
  String get queue => 'Queue';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get reasonFormat => 'File format doesn\'t support metadata editing';

  @override
  String get reasonPermissions => 'Storage permissions not granted';

  @override
  String get reasonReadonly => 'File is read-only or on external storage';

  @override
  String get recentlyAdded => 'Recently Added';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get recentlyPlayedArtists => 'Recently played artists';

  @override
  String get recentlyPlayedSongs => 'Recently played songs';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get refreshLyrics => 'Refresh Lyrics';

  @override
  String get remove => 'Remove';

  @override
  String get removeSong => 'Remove Song';

  @override
  String get removeSongConfirmation => 'Remove this song from the playlist?';

  @override
  String get rename => 'Rename';

  @override
  String get renamePlaylist => 'Rename Playlist';

  @override
  String get repeat => 'Repeat';

  @override
  String get reset => 'Reset';

  @override
  String get resetArtistSeparationDesc =>
      'This will restore all default separators and exclusions.';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get result => 'Result';

  @override
  String get results => 'Results';

  @override
  String get retry => 'Retry';

  @override
  String get sampleRate => 'Sample Rate';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveChangesDesc => 'Do you want to save your changes?';

  @override
  String get saveFailed => 'Save Failed';

  @override
  String get saveFailedDesc => 'Unable to save metadata to this file.';

  @override
  String get scanFailed => 'Scan failed';

  @override
  String get scanningSongs => 'Scanning songs';

  @override
  String get search => 'Search';

  @override
  String get searchAlbums => 'Search albums';

  @override
  String get searchArtists => 'Search artists';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get lyricsSource => 'Lyrics source';

  @override
  String get inPlaylistHint => 'In a playlist';

  @override
  String get removeDuplicates => 'Remove duplicates';

  @override
  String get noDuplicatesFound => 'No duplicate songs found';

  @override
  String duplicatesRemoved(int count) {
    return '$count duplicate songs removed';
  }

  @override
  String get supportNoxiraTitle => 'Support Noxira!';

  @override
  String get supportButton => 'Support';

  @override
  String supportGoalProgress(String raised, String goal) {
    return '$raised of $goal this month';
  }

  @override
  String get onboardingSupportGoal => 'Support goal';

  @override
  String get onboardingSupportGoalDesc =>
      'Occasionally downloads a tiny public file with this month\'s support goal and amount raised. It is a plain download: nothing about you or your music is sent.';

  @override
  String get songAddedChip => 'Added';

  @override
  String get tapToRemove => 'Tap to remove';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingYourLanguage => 'Your language?';

  @override
  String get onboardingAllow => 'Allow';

  @override
  String get onboardingSummaryLanguage => 'Language';

  @override
  String get onboardingSummaryTheme => 'Look';

  @override
  String get onboardingSummaryLibrary => 'Music library access';

  @override
  String get onboardingAllowed => 'Allowed';

  @override
  String get onboardingNotAllowed => 'Not allowed yet';

  @override
  String get searchLyrics => 'Search Lyrics';

  @override
  String get searchMetadata => 'Search metadata';

  @override
  String get searchTracks => 'Search tracks';

  @override
  String get selectAll => 'Select All';

  @override
  String get selectArtist => 'Select artist';

  @override
  String get selected => 'selected';

  @override
  String get separator => 'Separator';

  @override
  String get separatorHint => 'e.g. / or feat.';

  @override
  String get separators => 'Separators';

  @override
  String get set => 'Set';

  @override
  String get setMinutes => 'Set minutes';

  @override
  String get settings => 'Settings';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutApp => 'About Noxira Music';

  @override
  String get settingsAboutSubtitle => 'Version, feedback & updates';

  @override
  String get settingsGroupExperience => 'Experience';

  @override
  String get settingsGroupLibrary => 'Library & data';

  @override
  String get settingsGroupApp => 'App';

  @override
  String get settingsAccentColor => 'Accent Color';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSubtitle => 'Theme, colors & layout';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsBackground => 'Background';

  @override
  String get settingsCacheCleared => 'Cache cleared';

  @override
  String get settingsCacheInfo => 'Cache Information';

  @override
  String get settingsCacheInfoDesc => 'View storage usage';

  @override
  String get settingsCheckingUpdates => 'Checking for updates...';

  @override
  String get settingsCheckUpdates => 'Check for Updates';

  @override
  String get settingsCheckUpdatesDesc => 'Get latest version';

  @override
  String get settingsClearCache => 'Clear Cache';

  @override
  String get settingsClearCacheDesc => 'Remove all cached data';

  @override
  String get settingsClearCacheMessage =>
      'All cached data will be deleted and rebuilt as needed.';

  @override
  String get settingsClearCacheTitle => 'Clear Cache?';

  @override
  String get settingsDataWindow => 'Data Window';

  @override
  String get settingsDataWindowDesc => 'How far back the recap screen looks';

  @override
  String get settingsGapless => 'Gapless Playback';

  @override
  String get settingsGaplessDesc => 'Seamless track transitions';

  @override
  String get settingsAutomix => 'Automix';

  @override
  String get settingsAutomixDesc =>
      'Automatically create a seamless flow between songs';

  @override
  String get settingsCrossfade => 'Crossfade';

  @override
  String get settingsCrossfadeDesc =>
      'Smoothly blend the end of one track into the next';

  @override
  String get crossfadeDuration => 'Crossfade Duration';

  @override
  String get crossfadeDurationDesc =>
      'How long the overlap between tracks lasts';

  @override
  String get settingsInsights => 'Insights';

  @override
  String get settingsInsightsSubtitle => 'Listening recap period';

  @override
  String get settingsLast7Days => 'Last 7 Days';

  @override
  String get settingsLast30Days => 'Last 30 Days';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLayout => 'Layout';

  @override
  String get settingsLibraryFolders => 'Library Folders';

  @override
  String get settingsLibraryFoldersSubtitle =>
      'Include or exclude scan folders';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouDesc => 'Dynamic colors from wallpaper';

  @override
  String get settingsMonthlyRecap => 'Monthly Recap';

  @override
  String get settingsMonthlyRecapDesc =>
      'Show a banner every month (takes precedence over weekly)';

  @override
  String get settingsNormalization => 'Volume Normalization';

  @override
  String get settingsNormalizationDesc =>
      'Consistent volume levels · Requires ReplayGain tags in your files';

  @override
  String get playbackSpeed => 'Playback Speed';

  @override
  String get playbackSpeedDesc => 'Adjust audio playback rate';

  @override
  String get adjustPitchWithSpeed => 'Link pitch to speed';

  @override
  String get adjustPitchWithSpeedDesc =>
      'Pitch rises and falls with speed. Turn off to set it yourself.';

  @override
  String get playbackPitch => 'Pitch';

  @override
  String get playbackPitchDesc =>
      'Shift the sound up or down, independent of speed';

  @override
  String get playbackPitchLinkedDesc => 'Following playback speed';

  @override
  String get settingsPlayback => 'Playback';

  @override
  String get settingsPlaybackSubtitle => 'Speed, gapless & normalization';

  @override
  String get settingsRecapBannerDesc =>
      'The banner appears on the home screen at the start of each new week or month counted from your very first play. Tapping \"Later\" hides it for the session; tapping \"Show\" marks it as seen.';

  @override
  String get settingsRecapContent => 'Recap Content';

  @override
  String get settingsRecapContentDesc =>
      'Controls how much history the recap screen displays when you open it manually or via the banner.';

  @override
  String get settingsPreviewRecap => 'Preview Recap';

  @override
  String get settingsPreviewRecapDesc =>
      'See how your recap looks right now with the current settings';

  @override
  String get settingsRecapSchedule => 'Recap Schedule';

  @override
  String get settingsStorage => 'Storage';

  @override
  String settingsCacheItems(String count) {
    return '$count items';
  }

  @override
  String get settingsMemoryCache => 'Memory Cache';

  @override
  String get settingsStorageSubtitle => 'Cache & media files';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsTools => 'Tools';

  @override
  String get settingsResetSetup => 'Run Setup Again';

  @override
  String get settingsResetSetupDesc => 'Go through the welcome setup again';

  @override
  String get settingsUpdateAvailable => 'Update available!';

  @override
  String get settingsUpToDate => 'You\'re up to date';

  @override
  String get settingsUpdateCheckFailed =>
      'Couldn\'t check for updates. Updates come from Google Play.';

  @override
  String get settingsWeeklyRecap => 'Weekly Recap';

  @override
  String get settingsWeeklyRecapDesc =>
      'Show a banner every week after your first play';

  @override
  String get settingsVersion => 'Version';

  @override
  String get share => 'Share';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get size => 'Size';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get small => 'Small';

  @override
  String get songInfo => 'Song Info';

  @override
  String get songs => 'Songs';

  @override
  String get songsLoaded => 'Songs loaded';

  @override
  String get standardQuality => 'Standard Quality';

  @override
  String get startType => 'Start typing to search';

  @override
  String get storagePermissionNeeded =>
      'To edit metadata, Noxira Music needs permission to manage files. Please grant \'All files access\' in settings.';

  @override
  String get suggestedArtists => 'Artists For You';

  @override
  String get suggestedTracks => 'Suggested Tracks';

  @override
  String get supportAurora => 'Support Noxira';

  @override
  String get supportAuroraBtn => 'Support Noxira';

  @override
  String get supportAuroraDescShort => 'Help keep the app free';

  @override
  String get supportAuroraMessage =>
      'Help keep Noxira Music free and support future development. Every contribution means a lot!';

  @override
  String get supportAuroraTitle => 'Support Noxira Music';

  @override
  String get updatedTitle => 'Noxira Music was updated';

  @override
  String get tapAddToAddSongs => 'Tap + to add songs';

  @override
  String get reorderSongs => 'Reorder Songs';

  @override
  String get done => 'Done';

  @override
  String get thankYouSupport => 'Thank you for your support!';

  @override
  String get theme => 'Theme';

  @override
  String get title => 'Title';

  @override
  String get topResult => 'Top Result';

  @override
  String get total => 'Total';

  @override
  String get track => 'Track';

  @override
  String get trackInfo => 'Track Info';

  @override
  String get trackInfoDesc => 'Tap the edit icon to modify track information';

  @override
  String get trackInfoEditDesc =>
      'Edit fields below, then tap the check icon to save';

  @override
  String get tracks => 'Tracks';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateMessage => 'A new version is available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get viewArtist => 'View artist';

  @override
  String get viewDetails => 'View details';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get view_changelog => 'View changelog and new features';

  @override
  String get year => 'Year';

  @override
  String get yes => 'Yes';

  @override
  String get yourLibrary => 'Your Library';

  @override
  String get yourPlaylists => 'Your Playlists';

  @override
  String get homeLayout => 'Home Layout';

  @override
  String get homeLayoutDesc => 'Customize section order on Home tab';

  @override
  String get customizeHomeTab => 'Customize Home Tab';

  @override
  String get dragToReorder => 'Drag to reorder sections';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetLayoutConfirm => 'Reset layout to default?';

  @override
  String get resetLayoutMessage =>
      'This will restore the original section order and visibility.';

  @override
  String get listeningHistory => 'Listening History';

  @override
  String get libraryStats => 'Library Stats';

  @override
  String get back => 'Back';

  @override
  String get continueButton => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get send_feedback => 'Send Feedback';

  @override
  String get send_feedback_desc => 'Report bugs or suggest features';

  @override
  String get rateApp => 'Rate Noxira Music';

  @override
  String get rateAppDesc => 'Enjoying the app? Leave a review on Google Play';

  @override
  String get feedbackTypeBug => 'Bug';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackHint => 'Describe the bug or suggestion...';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackSentThanks => 'Thanks for your feedback!';

  @override
  String get feedbackSentError =>
      'Couldn\'t send feedback. Please try again later.';

  @override
  String get contributeTranslations => 'Contribute Translations';

  @override
  String get contributeTranslationsDesc =>
      'Help translate Noxira Music on Crowdin';

  @override
  String get contributeTranslationsTitle => 'Help Us Translate';

  @override
  String get contributeTranslationsSubtitle =>
      'Noxira Music is available in multiple languages thanks to our amazing community. Help us reach even more users by translating the app into your language — it only takes a few minutes to get started.';

  @override
  String get contributeTranslationsOpenCrowdin => 'Open Crowdin';

  @override
  String get close => 'Close';

  @override
  String get settingsHighendUi => 'High-end UI';

  @override
  String get settingsHighendUiDesc =>
      'Enable advanced visual effects and animations';

  @override
  String get clearUpcoming => 'Clear upcoming';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String get playNext => 'Play next';

  @override
  String get removeFromQueue => 'Remove from queue';

  @override
  String get play => 'Play';

  @override
  String get viewAlbum => 'View Album';

  @override
  String get shuffleAll => 'Shuffle All';

  @override
  String get noSongsFound => 'No songs found';

  @override
  String get noFoldersFound => 'No folders found';

  @override
  String get deleteSong => 'Delete Song';

  @override
  String get modifySystemSettingsPermission =>
      'Allow \"Modify system settings\" in the page that opened, then try again.';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String songsAddedToQueue(int count) {
    return '$count songs added to queue';
  }

  @override
  String songAddedToQueue(String title) {
    return '\"$title\" added to queue';
  }

  @override
  String songSetAsRingtone(String title) {
    return '\"$title\" set as ringtone';
  }

  @override
  String failedToSetRingtone(String error) {
    return 'Failed to set ringtone: $error';
  }

  @override
  String deleteSongConfirm(String title) {
    return 'Delete \"$title\" from your device? This cannot be undone.';
  }

  @override
  String songDeleted(String title) {
    return '\"$title\" deleted';
  }

  @override
  String failedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String songCount(int count) {
    return '$count songs';
  }

  @override
  String get badgeNew => 'NEW';

  @override
  String get paused => 'Paused';

  @override
  String get readyToPlay => 'Ready to play';

  @override
  String get tapSongToStartListening => 'Tap a song to start listening';

  @override
  String get clearCachedLyrics => 'Clear cached lyrics';

  @override
  String lyricsCleared(String title) {
    return 'Cached lyrics cleared for \"$title\"';
  }

  @override
  String lyricsAdded(String title) {
    return 'Lyrics added for \"$title\"';
  }

  @override
  String get noLyricsCached => 'No cached lyrics found for this song';

  @override
  String get setAsRingtone => 'Set as ringtone';

  @override
  String get songInfoEdit => 'Song info / Edit';

  @override
  String get goToAlbum => 'Go to album';

  @override
  String get goToArtist => 'Go to artist';

  @override
  String get deleteFromDevice => 'Delete from device';

  @override
  String get checkOutThisSong => 'Check out this song!';

  @override
  String get backgroundSolid => 'Solid Color';

  @override
  String get backgroundHighEndStyle => 'Now Playing Background';

  @override
  String get backgroundHighEndStyleDesc =>
      'Background style in the Now Playing screen';

  @override
  String get backgroundBlurredArtwork => 'Blurred Artwork';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get accentColorDesc => 'Choose the app accent color';

  @override
  String get backgroundBlur => 'Background Blur';

  @override
  String get backgroundBlurDesc => 'Artwork blur intensity';

  @override
  String get backgroundDarkness => 'Background Darkness';

  @override
  String get backgroundDarknessDesc => 'Overlay opacity on artwork';

  @override
  String get microphoneAccessNeeded => 'Microphone access needed';

  @override
  String get microphoneAccessDesc =>
      'Noxira needs microphone access to tap your device\'s audio session for the live visualizer. No audio is ever recorded or stored.';

  @override
  String get recapWeek => 'week';

  @override
  String get recapMonth => 'month';

  @override
  String get recapPeriodWeek => 'Week';

  @override
  String get recapPeriodMonth => 'Month';

  @override
  String get recapWeekly => 'Weekly';

  @override
  String get recapMonthly => 'Monthly';

  @override
  String get recapIntroAppName => 'NOXIRA MUSIC';

  @override
  String recapIntroTitle(String period) {
    return 'Your $period\nRecap';
  }

  @override
  String get recapIntroSubtitle =>
      'Let\'s see what you\'ve been\nlistening to.';

  @override
  String recapPlayedEyebrow(String period) {
    return 'This $period you played music';
  }

  @override
  String get recapTimeSingular => 'time';

  @override
  String get recapTimePlural => 'times';

  @override
  String get recapListenedForEyebrow => 'You listened for';

  @override
  String get recapListenedForLabel => 'of music';

  @override
  String get recapTopTrackEyebrow => 'Your #1 track';

  @override
  String get recapPlays => 'plays';

  @override
  String get recapTopTracksTitle => 'Top Tracks';

  @override
  String get recapTopArtistEyebrow => 'Your top artist';

  @override
  String get recapTopArtistsTitle => 'Top Artists';

  @override
  String get recapNothingToWrap => 'Nothing to wrap yet';

  @override
  String recapNothingToWrapBody(String period) {
    return 'Play some music this $period and come back.';
  }

  @override
  String get recapSwipeUp => 'SWIPE UP';

  @override
  String get recapYourSoundLabel => 'YOUR SOUND';

  @override
  String get recapYouListenMost => 'YOU LISTEN MOST';

  @override
  String recapOnDay(String day) {
    return 'on ${day}s';
  }

  @override
  String recapAroundTime(String time) {
    return 'around $time';
  }

  @override
  String get recapVibesHitDifferent => 'That\'s when the vibes hit different.';

  @override
  String get recapThatsAWrap => 'THAT\'S A WRAP';

  @override
  String recapInNumbers(String period) {
    return 'Your $period\nin Numbers';
  }

  @override
  String get recapNumberOneTrack => '#1 TRACK';

  @override
  String get recapStatTotalPlays => 'Total Plays';

  @override
  String get recapStatTimeListened => 'Time Listened';

  @override
  String get recapStatUniqueTracks => 'Unique Tracks';

  @override
  String get recapStatTopArtist => 'Top Artist';

  @override
  String get recapDone => 'Done';

  @override
  String get recapWeekdayMonday => 'Monday';

  @override
  String get recapWeekdayTuesday => 'Tuesday';

  @override
  String get recapWeekdayWednesday => 'Wednesday';

  @override
  String get recapWeekdayThursday => 'Thursday';

  @override
  String get recapWeekdayFriday => 'Friday';

  @override
  String get recapWeekdaySaturday => 'Saturday';

  @override
  String get recapWeekdaySunday => 'Sunday';

  @override
  String get recapBannerTitle => 'Music recap is here';

  @override
  String get recapBannerShow => 'Show';

  @override
  String get recapBannerLater => 'Later';

  @override
  String get rebrandTitle => 'Aurora is now Noxira';

  @override
  String get rebrandSubtitle =>
      'Same music app you know, with a new name, a fresh look and some new tricks.';

  @override
  String get rebrandNewHeading => 'What\'s new';

  @override
  String get rebrandSlideLyricsTitle => 'Lyrics, rebuilt';

  @override
  String get rebrandSlideLyricsBody =>
      'A redesigned lyrics page and more lyric sources, so more songs find their words. Songs with word-by-word timing light up word by word. Tap a line to jump to it, and translate lyrics into any language you like.';

  @override
  String get rebrandSlideWidgetTitle => 'A refreshed home screen widget';

  @override
  String get rebrandSlideWidgetBody =>
      'Glass tinted with your artwork, and previous, play and next buttons that work without opening the app.';

  @override
  String get rebrandSlideQueueTitle => 'A redesigned queue';

  @override
  String get rebrandSlideQueueBody =>
      'See what played and what\'s next. Drag to reorder, swipe to remove.';

  @override
  String get rebrandSlideOutputTitle => 'Choose where it plays';

  @override
  String get rebrandSlideOutputBody =>
      'Tap the Bluetooth chip on the home screen, or the new button on Now Playing, to move playback between your phone speaker and connected devices, right inside the app.';

  @override
  String get rebrandSlideLibraryTitle => 'A tidier library';

  @override
  String get rebrandSlideLibraryBody =>
      'Noxira spots duplicate tracks and lets you pick which copy to keep. Playlists have a new layout with Favorites, automatic and smart playlists in one place.';

  @override
  String get rebrandMoreMessages =>
      'Messages now appear as a small island at the bottom of the screen.';

  @override
  String get rebrandMorePerformance =>
      'Faster search, a quicker start and lighter image loading.';

  @override
  String get translateLyricsTo => 'Translate lyrics to';

  @override
  String get translateLyricsAppLanguage => 'App language';

  @override
  String get translateLyricsChooseLanguage => 'Choose language…';

  @override
  String get rebrandSlideMoreTitle => 'And a few more things';

  @override
  String get rebrandMoreSetup =>
      'Setup now suggests the right mode for your phone.';

  @override
  String get rebrandMoreLook =>
      'Rounded play button on Favorite Songs and lyric controls that stay put.';

  @override
  String get rebrandMoreMotion =>
      'Smoother, better transitions across the whole app.';

  @override
  String get rebrandMorePlayback =>
      'Separate speed and pitch sliders, which you can link together.';

  @override
  String get rebrandMoreSearch =>
      'A redesigned Search tab and a Settings page sorted into groups.';

  @override
  String get rebrandMoreFixes =>
      'Stability fixes, including editing tags on voice recordings, the visualizer on Dolby tracks and phones without an equalizer.';

  @override
  String get eqTitle => 'Equalizer';

  @override
  String get eqOn => 'ON';

  @override
  String get eqOff => 'OFF';

  @override
  String get eqNotAvailable => 'Equalizer not available on this device.';

  @override
  String get eqWaitingForAudio =>
      'Start playing a song to adjust the equalizer.';

  @override
  String get eqOpenSystem => 'Open System Equalizer';

  @override
  String get eqSavePreset => 'Save Preset';

  @override
  String get eqPresetNameHint => 'e.g. My Bass Boost';

  @override
  String get eqPresetNameEmpty => 'Name cannot be empty.';

  @override
  String eqPresetNameBuiltIn(String name) {
    return '\"$name\" is a built-in preset name.';
  }

  @override
  String get eqResetAllBands => 'Reset all bands';

  @override
  String get eqPresetsLabel => 'PRESETS';

  @override
  String get eqYourPresetsLabel => 'YOUR PRESETS';

  @override
  String get eqSaveCurrent => 'Save current';

  @override
  String get eqSettingsSubtitle => 'Adjust audio frequencies per band';

  @override
  String get eqEmptyPresets => 'Dial in your sound, then tap \"Save current\".';

  @override
  String get lyricsHint =>
      'Paste unsynced lyrics here…\n\nOne line per verse line.';

  @override
  String get lyricsSelectLrcFile => 'Please select a .lrc file';

  @override
  String get lyricsNoLyricsInFile => 'No lyrics found in that file';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get lyricsImportTooltip => 'Import .lrc file';

  @override
  String get importPlaylistM3u => 'Import playlist (.m3u)';

  @override
  String get setSyncFolder => 'Set sync folder…';

  @override
  String get syncNow => 'Sync now';

  @override
  String get searchPlaylists => 'Search playlists…';

  @override
  String get pleaseSelectM3uFile => 'Please select an .m3u or .m3u8 file';

  @override
  String get noMatchingSongsForPlaylist =>
      'No matching songs found for that playlist';

  @override
  String importedPlaylist(String name, int count) {
    return 'Imported \"$name\" ($count songs)';
  }

  @override
  String playlistsSyncWith(String folder) {
    return 'Playlists will sync with: $folder';
  }

  @override
  String couldNotSetSyncFolder(String error) {
    return 'Could not set sync folder: $error';
  }

  @override
  String get setSyncFolderFirst => 'Set a sync folder first';

  @override
  String get playlistsSynced => 'Playlists synced';

  @override
  String get alreadyUpToDate => 'Already up to date';

  @override
  String syncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get searchFolders => 'Search folders…';

  @override
  String get songInfoPath => 'Path';

  @override
  String get closeVisualiser => 'Close visualiser';

  @override
  String get visualizerWaitingForAudio => 'Waiting for playback audio...';

  @override
  String get visualizerUnavailable =>
      'Live audio analysis is unavailable for this output.';

  @override
  String get previousMode => 'Previous mode';

  @override
  String get nextMode => 'Next mode';

  @override
  String get sortBy => 'Sort by';

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get insightsTotalPlays => 'Total\nPlays';

  @override
  String get insightsTracksHeard => 'Tracks\nHeard';

  @override
  String get insightsEstListening => 'Est.\nListening';

  @override
  String get dismiss => 'Dismiss';

  @override
  String updateVersionAvailable(String version) {
    return 'Version $version is now available.';
  }

  @override
  String get updateNewVersionAvailable => 'A new version is now available.';

  @override
  String get lyricsPasteLyricsTitle => 'Paste Lyrics';

  @override
  String get lyricsUseLyrics => 'Use Lyrics';

  @override
  String get lyricsPaste => 'Paste';

  @override
  String get lyricsNoLyricsYet => 'No lyrics yet';

  @override
  String get lyricsPasteToGetStarted => 'Paste lyrics to get started';

  @override
  String get lyricsNoTimestampsYet =>
      'No timestamps yet — tap the stamp button while the song plays.';

  @override
  String get lyricsAllLinesStampedHint =>
      'All lines stamped — tap Save to finish.';

  @override
  String get lyricsAllStamped => '✓  All lines stamped';

  @override
  String get lyricsPasteFirst => 'Paste lyrics first';

  @override
  String lyricsTapToStamp(int current, int total) {
    return '⏱  TAP TO STAMP LINE $current / $total';
  }

  @override
  String get lyricsNextLabel => 'Next';

  @override
  String get translationDisclaimerNote =>
      'Some translations are AI-generated or community-contributed and may contain errors. Help us improve them on Crowdin.';

  @override
  String get newLanguagesAvailableTitle => 'New Languages Available';

  @override
  String get newLanguagesAvailableBody =>
      'Noxira Music now supports German, Spanish, Hindi, and Russian. You can change your language in Settings.';

  @override
  String get newLanguagesGoToSettings => 'Change Language';

  @override
  String get newLanguagesDismiss => 'Got it';

  @override
  String get settingsLyricsSources => 'Lyrics sources';

  @override
  String get lyricsProviderDesc =>
      'Used when LRCLIB has no lyrics. Receives the song title, artist, album and length.';

  @override
  String get onlineAboutArtist => 'About';

  @override
  String get onlineFansAlsoLike => 'Fans also like';

  @override
  String get onlinePopularTracks => 'Popular right now';

  @override
  String get onlineReadMore => 'Read more';

  @override
  String get onlineBioDisclaimer =>
      'Gathered automatically from public sources. Not guaranteed to be accurate.';

  @override
  String get onlineShowLess => 'Show less';

  @override
  String get onlineWikipedia => 'Wikipedia';

  @override
  String onlineFansCount(String count) {
    return '$count fans';
  }

  @override
  String get settingsOnlineSuggestions => 'Online suggestions';

  @override
  String get settingsOnlineSuggestionsDesc =>
      'Look up artist info and similar artists from Deezer and Wikipedia. Only the artist name is sent.';

  @override
  String get onboardingUiModeTitle => 'Interface style';

  @override
  String get onboardingUiModeDesc =>
      'How much glass and animation the app uses';

  @override
  String get onboardingUiHighEnd => 'High-end';

  @override
  String get onboardingUiLowEnd => 'Lightweight';

  @override
  String get onboardingRecommendedBadge => 'Recommended';

  @override
  String get onboardingRecommendedForDevice => 'Recommended for your device.';

  @override
  String onboardingTryNote(String recommended, String selected) {
    return 'Based on your device\'s specs we recommend $recommended, but you\'re welcome to try $selected.';
  }

  @override
  String onboardingHeaviestNote(String option) {
    return '$option is the heaviest option and may feel less smooth on your device.';
  }

  @override
  String get audioOutput => 'Audio Output';

  @override
  String get audioOutputBluetoothDevice => 'Bluetooth Device';

  @override
  String get audioOutputPhoneSpeaker => 'Phone Speaker';

  @override
  String get audioOutputWired => 'Wired Headphones';

  @override
  String get audioOutputUsb => 'USB Audio';

  @override
  String get audioOutputOther => 'Other output';

  @override
  String get audioOutputNoOthers => 'No other devices detected';

  @override
  String get audioOutputCurrentDevice => 'Current Device';

  @override
  String get audioOutputSwitchFailed => 'Couldn\'t switch the audio output';

  @override
  String get duplicatesBannerTitle => 'Duplicate tracks found';

  @override
  String duplicatesBannerSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks exist in multiple copies',
      one: '1 track exists in multiple copies',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesReview => 'Review';

  @override
  String get duplicatesScreenTitle => 'Duplicate tracks';

  @override
  String get duplicatesEmpty => 'No duplicates found';

  @override
  String get duplicatesIgnore => 'Ignore';

  @override
  String get duplicatesIgnoreAll => 'Ignore all';

  @override
  String get duplicatesKeepBest => 'Best quality';

  @override
  String duplicatesCopies(int count) {
    return '$count copies';
  }

  @override
  String duplicatesDeleteOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Keep selected, delete $count others',
      one: 'Keep selected, delete 1 other',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesDeleteFailed => 'Could not delete some copies';

  @override
  String get duplicatesResolved => 'Duplicates removed';

  @override
  String get duplicatesHint =>
      'Pick the copy to keep. The others will be deleted from your device.';

  @override
  String get remoteAnnouncementOpenLink => 'Learn more';

  @override
  String get remoteAnnouncementOpenScreen => 'Open';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredMessage =>
      'This version is no longer supported. Please update Noxira Music to keep using it.';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsSupportSubtitle => 'Supporters and ways to help';

  @override
  String get supportSupporters => 'Supporters';

  @override
  String get supportNoSupportersYet =>
      'No supporters listed yet. Be the first to appear here!';

  @override
  String get musicInsightsTitle => 'Music Insights';

  @override
  String get insightsActivityByTimeOfDay => 'Activity by Time of Day';

  @override
  String get insightsActivityByDay => 'Activity by Day';

  @override
  String get insightsGenreBreakdown => 'Genre Breakdown';

  @override
  String get insightsNoDataTitle => 'No listening data yet';

  @override
  String get insightsNoDataBody =>
      'Play some music to start building your insights.';

  @override
  String insightsMostActiveAround(String time) {
    return 'Most active around $time';
  }

  @override
  String insightsMostActiveOn(String day) {
    return 'Most active on $day';
  }

  @override
  String moreFromArtist(String artist) {
    return 'More from $artist';
  }

  @override
  String tracksCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
    );
    return '$_temp0';
  }

  @override
  String songsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
    );
    return '$_temp0';
  }

  @override
  String albumsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count albums',
      one: '1 album',
    );
    return '$_temp0';
  }

  @override
  String playlistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count playlists',
      one: '1 playlist',
    );
    return '$_temp0';
  }

  @override
  String foldersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folders',
      one: '1 folder',
    );
    return '$_temp0';
  }

  @override
  String foldersExcludedCount(int count) {
    return '$count excluded';
  }

  @override
  String get unknownAlbum => 'Unknown Album';

  @override
  String get queueNextUp => 'Next Up';

  @override
  String queueNextFrom(String source) {
    return 'Next from $source';
  }

  @override
  String get queueNothingElse => 'Nothing else queued';

  @override
  String get queueMoveToEnd => 'Move to end';

  @override
  String get translateLyrics => 'Translate lyrics';

  @override
  String get translateFailedTapToRetry => 'Translation failed — tap to retry';

  @override
  String get translateShowOriginal => 'Show original';

  @override
  String get translateShowTranslation => 'Show translation';

  @override
  String get lyricsAiTranslatedNote => 'AI translated · accuracy may vary';

  @override
  String lyricsCantTranslateSameLanguage(String language) {
    return 'Can\'t translate — lyrics are already in the target language ($language)';
  }

  @override
  String get lyricsAddLyrics => 'Add Lyrics';

  @override
  String get lyricsBlurOn => 'Lyrics blur: on';

  @override
  String get lyricsBlurOff => 'Lyrics blur: off';

  @override
  String get lyricsAutoHideOn => 'Auto-hide controls: on';

  @override
  String get lyricsAutoHideOff => 'Auto-hide controls: off';

  @override
  String get lyricsEditCreate => 'Edit / Create Lyrics';

  @override
  String get sleepTimerMinShort => 'min';

  @override
  String sleepTimerMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get sleepTimerMusicStopsAfter => 'Music stops after…';

  @override
  String get sleepTimerPickDuration => 'Pick a duration below';

  @override
  String get visualizerBarSpectrum => 'Bar Spectrum';

  @override
  String get visualizerCircularBars => 'Circular Bars';

  @override
  String get visualizerMirrorBars => 'Mirror Bars';

  @override
  String get visualizerFrequencyLine => 'Frequency Line';

  @override
  String get visualizerDotMatrix => 'Dot Matrix';

  @override
  String get visualizerPeakBars => 'Peak Bars';

  @override
  String get visualizerCircularWave => 'Circular Wave';

  @override
  String get visualizerAuroraWaves => 'Aurora Waves';

  @override
  String get visualizerPulseRings => 'Pulse Rings';

  @override
  String get smartFieldFolderPath => 'Folder path';

  @override
  String get smartFieldLiked => 'Liked';

  @override
  String get smartFieldPlayCount => 'Play count';

  @override
  String get smartFieldDurationSeconds => 'Duration (seconds)';

  @override
  String get smartFieldDaysSinceAdded => 'Days since added';

  @override
  String get smartOpContains => 'contains';

  @override
  String get smartOpNotContains => 'does not contain';

  @override
  String get smartOpEquals => 'equals';

  @override
  String get smartOpNotEquals => 'does not equal';

  @override
  String get smartOpGreaterThan => 'is greater than';

  @override
  String get smartOpLessThan => 'is less than';

  @override
  String get smartOpIsTrue => 'is true';

  @override
  String get smartOpIsFalse => 'is false';

  @override
  String get smartSortTitleAZ => 'Title (A-Z)';

  @override
  String get smartSortArtistAZ => 'Artist (A-Z)';

  @override
  String get smartSortDateAddedNewest => 'Date added (newest)';

  @override
  String get smartSortPlayCountHighest => 'Play count (highest)';

  @override
  String get smartSortDurationLongest => 'Duration (longest)';

  @override
  String get smartSortRandom => 'Random';

  @override
  String get folderFilterTitle => 'Folder Filter';

  @override
  String get artistSeparatorTestHint =>
      'e.g. Artist One / Artist Two feat. Three';

  @override
  String get tracksPermissionRequired =>
      'Permission to access media library is required. Please grant permissions in the onboarding or app settings.';

  @override
  String tracksErrorFetching(String error) {
    return 'Error fetching songs: $error';
  }

  @override
  String get seeAll => 'See all';

  @override
  String get selectItemToViewDetails => 'Select an item to view details';

  @override
  String get takeMeThere => 'Take me there';

  @override
  String get notNow => 'Not now';

  @override
  String get aboutCodename => 'Codename';

  @override
  String get aboutDeveloper => 'Developer';

  @override
  String get aboutCopyright => 'Copyright';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get openSourcePackages => 'Open Source Packages';

  @override
  String packagesUsedCount(int count) {
    return '$count packages used';
  }

  @override
  String get packagesThanks => 'Thank you to all the open source contributors!';

  @override
  String versionWithCodename(String version, String codename) {
    return 'Version $version ($codename)';
  }

  @override
  String get customColor => 'Custom color';

  @override
  String exportPlaylistAs(String format) {
    return 'Export ($format)';
  }

  @override
  String get shareClipListeningTo => 'LISTENING TO';

  @override
  String get shareClipNowOn => 'NOW ON';

  @override
  String get splashInitializingServices => 'Initializing Services';

  @override
  String get splashLoadingLibrary => 'Loading Library';

  @override
  String get splashPreparingHome => 'Preparing Home';

  @override
  String get splashCachingArtwork => 'Caching Artwork';

  @override
  String get splashFinalPreparations => 'Final Preparations';

  @override
  String get queueHistory => 'History';

  @override
  String get sortName => 'Name';

  @override
  String get bannerInsightsNewTitle => 'Your Music Insights Are Here ✦';

  @override
  String get bannerInsightsNewBody =>
      'See your top tracks, artists & listening patterns';

  @override
  String get bannerRecapTitle => 'Your Music Recap Awaits';

  @override
  String get bannerRecapBody => 'Discover your top songs and listening trends';

  @override
  String get musicalArtist => 'Musical artist';

  @override
  String get eqPresetFlat => 'Flat';

  @override
  String get eqPresetBassBoost => 'Bass Boost';

  @override
  String get eqPresetBassCut => 'Bass Cut';

  @override
  String get eqPresetTrebleBoost => 'Treble Boost';

  @override
  String get eqPresetTrebleCut => 'Treble Cut';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetClassical => 'Classical';

  @override
  String get eqPresetElectronic => 'Electronic';

  @override
  String get eqPresetHipHop => 'Hip Hop';

  @override
  String get eqPresetRnB => 'R&B';

  @override
  String get eqPresetVocal => 'Vocal';

  @override
  String get eqPresetAcoustic => 'Acoustic';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetMetal => 'Metal';

  @override
  String get eqPresetLounge => 'Lounge';

  @override
  String get eqPresetSpokenWord => 'Spoken Word';

  @override
  String get supportOfMonthlyGoal => 'of this month\'s goal';

  @override
  String get cl200Hl1 => 'Aurora Music is now Noxira Music, with a new look';

  @override
  String get cl200Hl2 =>
      'Translate lyrics into any language, from more lyric sources';

  @override
  String get cl200Hl3 =>
      'A redesigned home screen widget with playback controls';

  @override
  String get cl200Hl4 => 'A redesigned queue';

  @override
  String get cl200Hl5 =>
      'Choose where audio plays from the Bluetooth chip or Now Playing';

  @override
  String get cl200Hl6 => 'Word-by-word lyrics when the source has the timing';

  @override
  String get cl200Hl7 =>
      'Duplicate tracks are spotted, and you pick the copy to keep';

  @override
  String get cl200Hl8 => 'Glass surfaces that adapt to your phone';

  @override
  String get cl200Hl9 => 'Smoother transitions and faster detail pages';

  @override
  String get cl200SecWelcome => 'Welcome to Noxira';

  @override
  String get cl200SecNew => 'New Features';

  @override
  String get cl200SecLibrary => 'Playlists & Library';

  @override
  String get cl200SecSetup => 'Setup';

  @override
  String get cl200SecLook => 'Look & Feel';

  @override
  String get cl200SecPerf => 'Performance';

  @override
  String get cl200SecHood => 'Under the Hood';

  @override
  String get cl200Welcome1 =>
      'Aurora Music is now Noxira Music, with a new name, wordmark and app icon';

  @override
  String get cl200Welcome2 =>
      'A new animated splash screen draws the Noxira wordmark';

  @override
  String get cl200Welcome3 =>
      'Existing users get a short welcome page explaining what is new, and you can open it again from Settings';

  @override
  String get cl200New1 =>
      'Translate lyrics into any language you like, not only the app languages';

  @override
  String get cl200New2 =>
      'Redesigned home screen widget: glass tinted with your artwork, previous / play / next buttons that work without opening the app, and recommended songs when the widget is tall';

  @override
  String get cl200New3 =>
      'Redesigned queue page — see what played and what is next, drag to reorder, swipe to remove; an Up next preview now sits on Now Playing';

  @override
  String get cl200New4 =>
      'A monthly support goal appears on the home app bar from time to time, and in Settings under About';

  @override
  String get cl200New5 => 'Pull down in the Library to refresh it';

  @override
  String get cl200New6 =>
      'Choose where audio plays: tap the Bluetooth chip on the home screen, or the new output island on Now Playing, to move playback between your phone speaker and connected devices without leaving the app';

  @override
  String get cl200New7 =>
      'Speed and pitch now have their own sliders, and you can link pitch to speed';

  @override
  String get cl200New8 =>
      'Five new visualizer styles, and a finer spectrum with more bars';

  @override
  String get cl200New9 =>
      'Optional announcements from the Noxira team can appear on the home screen, with a button that opens a link or a screen of the app';

  @override
  String get cl200Lyrics1 =>
      'Redesigned lyrics page: tap a line to jump to it, dots mark instrumental breaks, and the lyrics box on Now Playing follows along';

  @override
  String get cl200Lyrics2 =>
      'More lyric sources (BetterLyrics, YouLyPlus and KuGou) are tried when LRCLIB has nothing; choose which ones to use in Settings';

  @override
  String get cl200Lyrics3 =>
      'Lyrics stored in the audio file, or in a .lrc file next to the song, are used first and work offline';

  @override
  String get cl200Lyrics4 =>
      'Auto-hide controls on the full-screen lyrics is now an option and off by default';

  @override
  String get cl200Lyrics5 =>
      'Fixed lyrics that flickered and then disappeared with “no lyrics available”, including after a refresh or a manual search';

  @override
  String get cl200Lyrics6 =>
      'Word-by-word lyrics: when a source has per-word timing, each word lights up as it is sung';

  @override
  String get cl200Library1 =>
      'New add-to-playlist sheet: add, remove and create playlists in one place, with songs already in a playlist marked';

  @override
  String get cl200Library2 =>
      'A song can no longer be added to the same playlist twice, and a Remove duplicates option cleans up existing ones';

  @override
  String get cl200Library3 =>
      'Noxira now notices duplicate tracks in your library and, in the Library tab, offers to review them: you pick which copy to keep';

  @override
  String get cl200Library4 =>
      'Redesigned Playlists page: Favorites on top, automatic playlists as tiles and your own playlists as a grid with artwork mosaics';

  @override
  String get cl200Library5 =>
      'Redesigned Search tab: a glass search bar, result counts and clearer empty and no-result states';

  @override
  String get cl200Library6 =>
      'The playing-song icon now follows the track in playlists';

  @override
  String get cl200Library7 =>
      'Optional online suggestions: artist info and similar artists from Deezer and Wikipedia (only the artist name is sent)';

  @override
  String get cl200Library8 =>
      'The equalizer no longer reports itself as unavailable by mistake; it retries on its own and offers Retry and Open system equalizer';

  @override
  String get cl200Library9 =>
      'Cache Information now shows real sizes, its button closes the dialog, and Clear Cache also clears downloaded artist images';

  @override
  String get cl200Setup1 =>
      'Redesigned onboarding with glass panels, entrance animations and a flowing background';

  @override
  String get cl200Setup2 =>
      'Setup recommends the interface style that suits your phone (high-end or lightweight) and the matching background, and lets you try the other one';

  @override
  String get cl200Setup3 =>
      'The lightweight interface now always uses a plain background; the Animated Blobs option was removed';

  @override
  String get cl200Setup4 =>
      'Settings is now sorted into groups (Experience, Library & data, App) with the same simple glass look as setup';

  @override
  String get cl200Setup5 =>
      'Messages appear as a small island at the bottom of the screen instead of snack bars';

  @override
  String get cl200Look1 =>
      'New app font (Cal Sans) and slightly more compact text across the app';

  @override
  String get cl200Look2 =>
      'Frosted glass surfaces throughout, drawn as plain solid surfaces on low-end phones';

  @override
  String get cl200Look3 =>
      'Artwork flies from cards into album, artist, folder and playlist pages; pressed cards respond, liked songs burst into hearts, and the time labels roll';

  @override
  String get cl200Look4 => 'Rounded-square play button on Favorite Songs';

  @override
  String get cl200Look5 =>
      'Home and Library cards use the same glass look as setup, without an extra blur on top of the blurred background';

  @override
  String get cl200Perf1 =>
      'Noxira detects your phone\'s hardware and tunes glass effects, image caches and transitions to it';

  @override
  String get cl200Perf2 =>
      'Album, artist, folder and playlist pages open smoothly: they load after the opening animation, build a short first page of songs and blur their header artwork ahead of time';

  @override
  String get cl200Perf3 =>
      'Library queries that overlap are shared instead of repeated, which lowers memory use on big libraries';

  @override
  String get cl200Perf4 =>
      'Faster search and library rescans, lighter image loading and less work while lists scroll';

  @override
  String get cl200Hood1 =>
      'Fixed several crashes: tapping Close in the lyrics editor, the tag editor or the sleep timer after the page was gone, adding to the queue or setting a ringtone from a song menu, translating lyrics, and opening Noxira from the widget';

  @override
  String get cl200Hood2 =>
      'The app no longer crashes when storage permission is missing';

  @override
  String get cl200Hood3 =>
      'Playlists, liked songs, play counts and settings are saved safely, so an interrupted save can no longer leave an empty file';

  @override
  String get cl200Hood4 =>
      'FLAC files whose metadata blocks were left incomplete by a tag editor are repaired when saved, so they play again';

  @override
  String get cl200Hood5 =>
      'Media notification artwork is downscaled to avoid freezes while the notification is built';

  @override
  String get cl200Hood6 =>
      'Editing tags on voice recordings (M4A) no longer fails because of leftover data at the end of the file';

  @override
  String get cl200Hood7 =>
      'The visualizer no longer distorts Dolby Atmos tracks; they use the simulated animation instead';

  @override
  String get cl200Hood8 =>
      'Phones that cannot create an equalizer effect now play normally, and the equalizer waits for the first song instead of timing out';

  @override
  String get cl200Hood9 =>
      'Check for updates now shows its result, and says so when updates come from Google Play';

  @override
  String get cl200Hood10 =>
      'Announcements, the support goal and some online services can be adjusted without an app update';

  @override
  String get cl200Hood11 => 'Updated dependencies';

  @override
  String get pkgJustAudio => 'Feature-rich audio player for Flutter';

  @override
  String get pkgAudioService => 'Background audio playback and media controls';

  @override
  String get pkgAudioSession =>
      'Audio session management for proper audio focus';

  @override
  String get pkgOnAudioQuery => 'Query audio files from device storage';

  @override
  String get pkgHaudiotagger => 'Read and write audio metadata tags';

  @override
  String get pkgProvider => 'State management solution for Flutter';

  @override
  String get pkgSharedPreferences => 'Persistent key-value storage';

  @override
  String get pkgPathProvider => 'Access to device file system paths';

  @override
  String get pkgPermissionHandler => 'Handle runtime permissions';

  @override
  String get pkgDynamicColor => 'Material You dynamic color theming';

  @override
  String get pkgPaletteGenerator => 'Extract colors from images';

  @override
  String get pkgStaggeredAnimations => 'Staggered list animations';

  @override
  String get pkgHttp => 'HTTP requests for API calls';

  @override
  String get pkgUrlLauncher => 'Launch URLs in browser';

  @override
  String get pkgSharePlus => 'Share content with other apps';

  @override
  String get pkgPackageInfoPlus => 'Get app version and package info';

  @override
  String get pkgDeviceInfoPlus => 'Get device information';

  @override
  String get pkgFlutterDotenv => 'Load environment variables from .env file';

  @override
  String get pkgCrypto => 'Cryptographic hashing functions';

  @override
  String get pkgIntl => 'Internationalization and localization';

  @override
  String get pkgPubSemver => 'Semantic versioning utilities';

  @override
  String get pkgClarityFlutter => 'Microsoft Clarity analytics';

  @override
  String get pkgFlutterHooks => 'React-like hooks for Flutter';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeMidnight => 'Midnight';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeTeal => 'Teal';

  @override
  String get themeForest => 'Forest';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeGold => 'Gold';

  @override
  String get themeEmber => 'Ember';

  @override
  String get themeRose => 'Rose';

  @override
  String get themeSakura => 'Sakura';

  @override
  String artistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artists',
      one: '1 artist',
    );
    return '$_temp0';
  }

  @override
  String get playbackInvalidPlaylist => 'Invalid playlist or start index';

  @override
  String playbackCouldNotPlayTitleSkipping(String title) {
    return 'Couldn\'t play \"$title\" — skipping';
  }

  @override
  String get playbackCouldNotPlaySkipping =>
      'Couldn\'t play this song — skipping';

  @override
  String playbackCouldNotPlayTitle(String title) {
    return 'Couldn\'t play \"$title\"';
  }

  @override
  String get playbackFailed => 'Playback failed';

  @override
  String playbackSetPlaylistFailed(String error) {
    return 'Failed to set playlist: $error';
  }

  @override
  String playbackUpdatePlaylistFailed(String error) {
    return 'Failed to update playlist: $error';
  }
}
