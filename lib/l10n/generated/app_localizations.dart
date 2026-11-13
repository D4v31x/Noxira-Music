import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('ru')
  ];

  /// No description provided for @aboutArtist.
  ///
  /// In en, this message translates to:
  /// **'About artist'**
  String get aboutArtist;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addExclusion.
  ///
  /// In en, this message translates to:
  /// **'Add Exclusion'**
  String get addExclusion;

  /// No description provided for @addSeparator.
  ///
  /// In en, this message translates to:
  /// **'Add Separator'**
  String get addSeparator;

  /// No description provided for @addSongs.
  ///
  /// In en, this message translates to:
  /// **'Add Songs'**
  String get addSongs;

  /// No description provided for @addSongsToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add Songs to Playlist'**
  String get addSongsToPlaylist;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @adjustSync.
  ///
  /// In en, this message translates to:
  /// **'Adjust Sync'**
  String get adjustSync;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @allSongs.
  ///
  /// In en, this message translates to:
  /// **'All Songs'**
  String get allSongs;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Noxira Music'**
  String get appName;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @artistName.
  ///
  /// In en, this message translates to:
  /// **'Artist name'**
  String get artistName;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @artistSeparation.
  ///
  /// In en, this message translates to:
  /// **'Artist Separation'**
  String get artistSeparation;

  /// No description provided for @artistSeparationDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure how multiple artists are split'**
  String get artistSeparationDesc;

  /// No description provided for @audioQuality.
  ///
  /// In en, this message translates to:
  /// **'Audio Quality'**
  String get audioQuality;

  /// No description provided for @audioQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'Technical specifications of the audio file'**
  String get audioQualityDesc;

  /// No description provided for @auroraMusic.
  ///
  /// In en, this message translates to:
  /// **'Noxira Music'**
  String get auroraMusic;

  /// No description provided for @autoPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Auto Playlists'**
  String get autoPlaylists;

  /// No description provided for @autoTag.
  ///
  /// In en, this message translates to:
  /// **'Auto Tag'**
  String get autoTag;

  /// No description provided for @smartPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Smart Playlists'**
  String get smartPlaylists;

  /// No description provided for @createSmartPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create smart playlist…'**
  String get createSmartPlaylist;

  /// No description provided for @editSmartPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Edit Smart Playlist'**
  String get editSmartPlaylist;

  /// No description provided for @smartPlaylistNameHint.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get smartPlaylistNameHint;

  /// No description provided for @smartPlaylistRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get smartPlaylistRules;

  /// No description provided for @addRule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get addRule;

  /// No description provided for @saveSmartPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveSmartPlaylist;

  /// No description provided for @matchAll.
  ///
  /// In en, this message translates to:
  /// **'Match ALL rules'**
  String get matchAll;

  /// No description provided for @matchAny.
  ///
  /// In en, this message translates to:
  /// **'Match ANY rule'**
  String get matchAny;

  /// No description provided for @limitResultsLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit results'**
  String get limitResultsLabel;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @deleteSmartPlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this smart playlist? This only removes the saved rules — your songs are not affected.'**
  String get deleteSmartPlaylistConfirm;

  /// No description provided for @smartPlaylistPreviewCount.
  ///
  /// In en, this message translates to:
  /// **'Matches {count} songs right now'**
  String smartPlaylistPreviewCount(int count);

  /// No description provided for @saveAsClip.
  ///
  /// In en, this message translates to:
  /// **'Save as clip'**
  String get saveAsClip;

  /// No description provided for @generatingClip.
  ///
  /// In en, this message translates to:
  /// **'Generating clip…'**
  String get generatingClip;

  /// No description provided for @clipDuration.
  ///
  /// In en, this message translates to:
  /// **'Clip duration'**
  String get clipDuration;

  /// No description provided for @clipStartOffset.
  ///
  /// In en, this message translates to:
  /// **'Start point'**
  String get clipStartOffset;

  /// No description provided for @saveClip.
  ///
  /// In en, this message translates to:
  /// **'Save clip'**
  String get saveClip;

  /// No description provided for @clipSavedToDevice.
  ///
  /// In en, this message translates to:
  /// **'Clip saved to device'**
  String get clipSavedToDevice;

  /// No description provided for @clipSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the clip. Please try again.'**
  String get clipSaveFailed;

  /// No description provided for @playlistSavedToDevice.
  ///
  /// In en, this message translates to:
  /// **'Playlist saved to device'**
  String get playlistSavedToDevice;

  /// No description provided for @trackTags.
  ///
  /// In en, this message translates to:
  /// **'Track Tags'**
  String get trackTags;

  /// No description provided for @editTrackTags.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get editTrackTags;

  /// No description provided for @addTrackTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTrackTag;

  /// No description provided for @noTrackTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Add one to jump straight to a part of this track.'**
  String get noTrackTagsYet;

  /// No description provided for @trackTagNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Song title or artist'**
  String get trackTagNameHint;

  /// No description provided for @trackTagPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get trackTagPosition;

  /// No description provided for @useCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Use current position'**
  String get useCurrentPosition;

  /// No description provided for @isThisASet.
  ///
  /// In en, this message translates to:
  /// **'Add timestamps to this track'**
  String get isThisASet;

  /// No description provided for @tagPartsForEasySwitching.
  ///
  /// In en, this message translates to:
  /// **'Mark any moment — chapters, highlights, bookmarks, or anything else.'**
  String get tagPartsForEasySwitching;

  /// No description provided for @tagThisTrack.
  ///
  /// In en, this message translates to:
  /// **'Add tags'**
  String get tagThisTrack;

  /// No description provided for @pasteSetlist.
  ///
  /// In en, this message translates to:
  /// **'Import timestamps'**
  String get pasteSetlist;

  /// No description provided for @pasteSetlistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Timestamps'**
  String get pasteSetlistDialogTitle;

  /// No description provided for @pasteSetlistHint.
  ///
  /// In en, this message translates to:
  /// **'Paste timestamps here, e.g.\n0:00 Intro\n3:45 Chapter Name'**
  String get pasteSetlistHint;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @tagsImportedMessage.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} tags'**
  String tagsImportedMessage(int count);

  /// No description provided for @noTagsFoundInPaste.
  ///
  /// In en, this message translates to:
  /// **'No timestamps found in the pasted text.'**
  String get noTagsFoundInPaste;

  /// No description provided for @bitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get bitrate;

  /// No description provided for @buyMeCoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy Me a Coffee'**
  String get buyMeCoffee;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @coffeeSupport.
  ///
  /// In en, this message translates to:
  /// **'Support with a coffee'**
  String get coffeeSupport;

  /// No description provided for @composer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get composer;

  /// No description provided for @connectWithUs.
  ///
  /// In en, this message translates to:
  /// **'Connect with us'**
  String get connectWithUs;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createFirstPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Tap the button above to create your first playlist'**
  String get createFirstPlaylist;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get createPlaylist;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get dateAdded;

  /// No description provided for @dateModified.
  ///
  /// In en, this message translates to:
  /// **'Date Modified'**
  String get dateModified;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get deletePlaylist;

  /// No description provided for @deletePlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deletePlaylistConfirm;

  /// No description provided for @deletePlaylistConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this playlist?'**
  String get deletePlaylistConfirmation;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'See details'**
  String get details;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @enableArtistSeparation.
  ///
  /// In en, this message translates to:
  /// **'Enable Artist Separation'**
  String get enableArtistSeparation;

  /// No description provided for @enableArtistSeparationDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically split combined artist names'**
  String get enableArtistSeparationDesc;

  /// No description provided for @enjoyingAurora.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Noxira?'**
  String get enjoyingAurora;

  /// No description provided for @enjoyingAuroraDesc.
  ///
  /// In en, this message translates to:
  /// **'If you love using Noxira Music, consider supporting its development. Your support helps keep it free!'**
  String get enjoyingAuroraDesc;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @exclusionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AC/DC'**
  String get exclusionHint;

  /// No description provided for @exclusions.
  ///
  /// In en, this message translates to:
  /// **'Exclusions'**
  String get exclusions;

  /// No description provided for @exclusionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Artist names that should never be split'**
  String get exclusionsDesc;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @exitAppConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit?'**
  String get exitAppConfirm;

  /// No description provided for @expandLyrics.
  ///
  /// In en, this message translates to:
  /// **'Expand Lyrics'**
  String get expandLyrics;

  /// No description provided for @extraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get extraLarge;

  /// No description provided for @favoriteSongs.
  ///
  /// In en, this message translates to:
  /// **'Favorite Songs'**
  String get favoriteSongs;

  /// No description provided for @fileInfo.
  ///
  /// In en, this message translates to:
  /// **'File Info'**
  String get fileInfo;

  /// No description provided for @fileInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Long press on values to copy them'**
  String get fileInfoDesc;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @filePath.
  ///
  /// In en, this message translates to:
  /// **'File Path'**
  String get filePath;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get forYou;

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @goodQuality.
  ///
  /// In en, this message translates to:
  /// **'Good Quality'**
  String get goodQuality;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @highQuality.
  ///
  /// In en, this message translates to:
  /// **'High Quality'**
  String get highQuality;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @kofi.
  ///
  /// In en, this message translates to:
  /// **'Ko-fi'**
  String get kofi;

  /// No description provided for @buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy Me a Coffee'**
  String get buyMeACoffee;

  /// No description provided for @donationNote.
  ///
  /// In en, this message translates to:
  /// **'No pressure - you can always donate later in Settings'**
  String get donationNote;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @libraryError.
  ///
  /// In en, this message translates to:
  /// **'Error loading music library'**
  String get libraryError;

  /// No description provided for @libraryLoaded.
  ///
  /// In en, this message translates to:
  /// **'Music library loaded'**
  String get libraryLoaded;

  /// No description provided for @libraryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Library updated'**
  String get libraryUpdated;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @loadingLibrary.
  ///
  /// In en, this message translates to:
  /// **'Loading library'**
  String get loadingLibrary;

  /// No description provided for @lossless.
  ///
  /// In en, this message translates to:
  /// **'Lossless'**
  String get lossless;

  /// No description provided for @lowQuality.
  ///
  /// In en, this message translates to:
  /// **'Low Quality'**
  String get lowQuality;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @lyricsAhead.
  ///
  /// In en, this message translates to:
  /// **'Lyrics are ahead'**
  String get lyricsAhead;

  /// No description provided for @lyricsBehind.
  ///
  /// In en, this message translates to:
  /// **'Lyrics are behind'**
  String get lyricsBehind;

  /// No description provided for @lyricsSynced.
  ///
  /// In en, this message translates to:
  /// **'Lyrics are synced'**
  String get lyricsSynced;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get metadata;

  /// No description provided for @metadataSaved.
  ///
  /// In en, this message translates to:
  /// **'Metadata saved successfully'**
  String get metadataSaved;

  /// No description provided for @metadataApplied.
  ///
  /// In en, this message translates to:
  /// **'Metadata downloaded successfully'**
  String get metadataApplied;

  /// No description provided for @metadataDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection and try again.'**
  String get metadataDownloadFailed;

  /// No description provided for @chooseArtworkFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Choose from device'**
  String get chooseArtworkFromDevice;

  /// No description provided for @mostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get mostPlayed;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get newPlaylist;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noAlbumsFound.
  ///
  /// In en, this message translates to:
  /// **'No albums found'**
  String get noAlbumsFound;

  /// No description provided for @noArtistInfo.
  ///
  /// In en, this message translates to:
  /// **'Artist info not available'**
  String get noArtistInfo;

  /// No description provided for @noArtistsFound.
  ///
  /// In en, this message translates to:
  /// **'No artists found'**
  String get noArtistsFound;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data to display'**
  String get noData;

  /// No description provided for @noExclusions.
  ///
  /// In en, this message translates to:
  /// **'No exclusions configured'**
  String get noExclusions;

  /// No description provided for @noLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics not available'**
  String get noLyrics;

  /// No description provided for @noLyricsDesc.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find lyrics for this song'**
  String get noLyricsDesc;

  /// No description provided for @noLyricsFound.
  ///
  /// In en, this message translates to:
  /// **'No lyrics found'**
  String get noLyricsFound;

  /// No description provided for @noPermissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Without permissions, Noxira Music won\'t be able to access your music library.'**
  String get noPermissionExplanation;

  /// No description provided for @noPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists available'**
  String get noPlaylists;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @noSeparators.
  ///
  /// In en, this message translates to:
  /// **'No separators configured'**
  String get noSeparators;

  /// No description provided for @noSongPlaying.
  ///
  /// In en, this message translates to:
  /// **'No song playing'**
  String get noSongPlaying;

  /// No description provided for @noSongsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No songs available'**
  String get noSongsAvailable;

  /// No description provided for @noSongsInPlaylist.
  ///
  /// In en, this message translates to:
  /// **'No songs in this playlist'**
  String get noSongsInPlaylist;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @onboardingAlbumArtwork.
  ///
  /// In en, this message translates to:
  /// **'Album Artwork'**
  String get onboardingAlbumArtwork;

  /// No description provided for @onboardingAlbumArtworkDesc.
  ///
  /// In en, this message translates to:
  /// **'Fetches high-quality album covers to enhance your library'**
  String get onboardingAlbumArtworkDesc;

  /// No description provided for @onboardingAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Anonymous analytics & crash reports'**
  String get onboardingAnalytics;

  /// No description provided for @onboardingAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Helps us fix bugs and improve performance. Never includes your listening history or personal data.'**
  String get onboardingAnalyticsDesc;

  /// No description provided for @onboardingAppInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal music companion'**
  String get onboardingAppInfoSubtitle;

  /// No description provided for @onboardingAudioAccess.
  ///
  /// In en, this message translates to:
  /// **'Audio Access'**
  String get onboardingAudioAccess;

  /// No description provided for @onboardingAudioAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Required to play and manage your music library'**
  String get onboardingAudioAccessDesc;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingBeautifulArtwork.
  ///
  /// In en, this message translates to:
  /// **'Beautiful album artwork'**
  String get onboardingBeautifulArtwork;

  /// No description provided for @onboardingBeautifulArtworkDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically fetch and display album artwork in the way it was meant to be seen'**
  String get onboardingBeautifulArtworkDesc;

  /// No description provided for @onboardingBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get onboardingBluetooth;

  /// No description provided for @onboardingBluetoothDesc.
  ///
  /// In en, this message translates to:
  /// **'Needed to connect to bluetooth devices'**
  String get onboardingBluetoothDesc;

  /// No description provided for @onboardingChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get onboardingChooseLanguage;

  /// No description provided for @onboardingCompletionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start enjoying your music'**
  String get onboardingCompletionSubtitle;

  /// No description provided for @onboardingCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingCompletionTitle;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingDynamicColors.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Colors'**
  String get onboardingDynamicColors;

  /// No description provided for @onboardingDynamicColorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Match system wallpaper colors'**
  String get onboardingDynamicColorsDesc;

  /// No description provided for @onboardingGrantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get onboardingGrantPermissions;

  /// No description provided for @onboardingInternetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How Noxira Music uses the internet'**
  String get onboardingInternetSubtitle;

  /// No description provided for @onboardingInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'Internet Usage'**
  String get onboardingInternetTitle;

  /// No description provided for @onboardingLocalMusic.
  ///
  /// In en, this message translates to:
  /// **'Music on your device'**
  String get onboardingLocalMusic;

  /// No description provided for @onboardingLocalMusicDesc.
  ///
  /// In en, this message translates to:
  /// **'Have your music files in the palm of your hand'**
  String get onboardingLocalMusicDesc;

  /// No description provided for @onboardingLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get onboardingLyrics;

  /// No description provided for @onboardingLyricsDesc.
  ///
  /// In en, this message translates to:
  /// **'Downloads synchronized lyrics for your songs from LRCLIB, Better Lyrics, YouLyPlus and KuGou. These services receive the song title, artist, album and length. You can turn individual sources off in Settings.'**
  String get onboardingLyricsDesc;

  /// No description provided for @onboardingLyricsSupport.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Support'**
  String get onboardingLyricsSupport;

  /// No description provided for @onboardingLyricsSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'View synchronized lyrics while listening'**
  String get onboardingLyricsSupportDesc;

  /// No description provided for @onboardingMaterialDesign.
  ///
  /// In en, this message translates to:
  /// **'Material You Design'**
  String get onboardingMaterialDesign;

  /// No description provided for @onboardingMaterialDesignDesc.
  ///
  /// In en, this message translates to:
  /// **'Dynamic colors that adapt to your preferences'**
  String get onboardingMaterialDesignDesc;

  /// No description provided for @onboardingMusicMetadata.
  ///
  /// In en, this message translates to:
  /// **'Music Metadata'**
  String get onboardingMusicMetadata;

  /// No description provided for @onboardingMusicMetadataDesc.
  ///
  /// In en, this message translates to:
  /// **'Gets artist info, album details, and track information'**
  String get onboardingMusicMetadataDesc;

  /// No description provided for @onboardingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onboardingNotifications;

  /// No description provided for @onboardingNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show playback controls and updates'**
  String get onboardingNotificationsDesc;

  /// No description provided for @onboardingPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Noxira Music needs these permissions to work properly'**
  String get onboardingPermissionsSubtitle;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important. All music files stay on your device.'**
  String get onboardingPrivacyNote;

  /// No description provided for @onboardingRequesting.
  ///
  /// In en, this message translates to:
  /// **'Requesting...'**
  String get onboardingRequesting;

  /// No description provided for @onboardingRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get onboardingRequired;

  /// No description provided for @onboardingAudioRequired.
  ///
  /// In en, this message translates to:
  /// **'Audio access is required to continue. Please grant the permission above.'**
  String get onboardingAudioRequired;

  /// No description provided for @onboardingSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get onboardingSelectLanguage;

  /// No description provided for @onboardingSmartPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Smart Playlists'**
  String get onboardingSmartPlaylists;

  /// No description provided for @onboardingSmartPlaylistsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create and manage your music collections'**
  String get onboardingSmartPlaylistsDesc;

  /// No description provided for @onboardingStartListening.
  ///
  /// In en, this message translates to:
  /// **'Start Listening'**
  String get onboardingStartListening;

  /// No description provided for @onboardingStorageAccess.
  ///
  /// In en, this message translates to:
  /// **'Storage Access'**
  String get onboardingStorageAccess;

  /// No description provided for @onboardingStorageAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Required to read music files from your device'**
  String get onboardingStorageAccessDesc;

  /// No description provided for @onboardingVisualizerAccess.
  ///
  /// In en, this message translates to:
  /// **'Visualizer'**
  String get onboardingVisualizerAccess;

  /// No description provided for @onboardingVisualizerAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Lets the visualizer read your device\'s audio session for the live bar spectrum. No audio is ever recorded.'**
  String get onboardingVisualizerAccessDesc;

  /// No description provided for @onboardingThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme that suits your style'**
  String get onboardingThemeSubtitle;

  /// No description provided for @onboardingThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Your Look'**
  String get onboardingThemeTitle;

  /// No description provided for @oneTimeSupport.
  ///
  /// In en, this message translates to:
  /// **'Quick one-time support'**
  String get oneTimeSupport;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open in File Manager'**
  String get openFolder;

  /// No description provided for @openFolderInfo.
  ///
  /// In en, this message translates to:
  /// **'Use your file manager to navigate to this location'**
  String get openFolderInfo;

  /// No description provided for @ownTimer.
  ///
  /// In en, this message translates to:
  /// **'Own timer'**
  String get ownTimer;

  /// No description provided for @permDeny.
  ///
  /// In en, this message translates to:
  /// **'Permissions denied'**
  String get permDeny;

  /// No description provided for @permissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Noxira Music needs these permissions to function properly. Please grant the permissions in the app settings.'**
  String get permissionExplanation;

  /// No description provided for @permissionLater.
  ///
  /// In en, this message translates to:
  /// **'You can grant permissions later in app settings'**
  String get permissionLater;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get playAll;

  /// No description provided for @playingFrom.
  ///
  /// In en, this message translates to:
  /// **'Playing from'**
  String get playingFrom;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @possibleReasons.
  ///
  /// In en, this message translates to:
  /// **'Possible reasons:'**
  String get possibleReasons;

  /// No description provided for @privacyNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing to use this app, you agree to our Privacy Policy.'**
  String get privacyNotice;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Read our Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// No description provided for @reasonFormat.
  ///
  /// In en, this message translates to:
  /// **'File format doesn\'t support metadata editing'**
  String get reasonFormat;

  /// No description provided for @reasonPermissions.
  ///
  /// In en, this message translates to:
  /// **'Storage permissions not granted'**
  String get reasonPermissions;

  /// No description provided for @reasonReadonly.
  ///
  /// In en, this message translates to:
  /// **'File is read-only or on external storage'**
  String get reasonReadonly;

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get recentlyAdded;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @recentlyPlayedArtists.
  ///
  /// In en, this message translates to:
  /// **'Recently played artists'**
  String get recentlyPlayedArtists;

  /// No description provided for @recentlyPlayedSongs.
  ///
  /// In en, this message translates to:
  /// **'Recently played songs'**
  String get recentlyPlayedSongs;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @refreshLyrics.
  ///
  /// In en, this message translates to:
  /// **'Refresh Lyrics'**
  String get refreshLyrics;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeSong.
  ///
  /// In en, this message translates to:
  /// **'Remove Song'**
  String get removeSong;

  /// No description provided for @removeSongConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove this song from the playlist?'**
  String get removeSongConfirmation;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename Playlist'**
  String get renamePlaylist;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetArtistSeparationDesc.
  ///
  /// In en, this message translates to:
  /// **'This will restore all default separators and exclusions.'**
  String get resetArtistSeparationDesc;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample Rate'**
  String get sampleRate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save your changes?'**
  String get saveChangesDesc;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save Failed'**
  String get saveFailed;

  /// No description provided for @saveFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Unable to save metadata to this file.'**
  String get saveFailedDesc;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed'**
  String get scanFailed;

  /// No description provided for @scanningSongs.
  ///
  /// In en, this message translates to:
  /// **'Scanning songs'**
  String get scanningSongs;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchAlbums.
  ///
  /// In en, this message translates to:
  /// **'Search albums'**
  String get searchAlbums;

  /// No description provided for @searchArtists.
  ///
  /// In en, this message translates to:
  /// **'Search artists'**
  String get searchArtists;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @lyricsSource.
  ///
  /// In en, this message translates to:
  /// **'Lyrics source'**
  String get lyricsSource;

  /// No description provided for @inPlaylistHint.
  ///
  /// In en, this message translates to:
  /// **'In a playlist'**
  String get inPlaylistHint;

  /// No description provided for @removeDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Remove duplicates'**
  String get removeDuplicates;

  /// No description provided for @noDuplicatesFound.
  ///
  /// In en, this message translates to:
  /// **'No duplicate songs found'**
  String get noDuplicatesFound;

  /// No description provided for @duplicatesRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count} duplicate songs removed'**
  String duplicatesRemoved(int count);

  /// No description provided for @supportNoxiraTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Noxira!'**
  String get supportNoxiraTitle;

  /// No description provided for @supportButton.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportButton;

  /// No description provided for @supportGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{raised} of {goal} this month'**
  String supportGoalProgress(String raised, String goal);

  /// No description provided for @onboardingSupportGoal.
  ///
  /// In en, this message translates to:
  /// **'Support goal'**
  String get onboardingSupportGoal;

  /// No description provided for @onboardingSupportGoalDesc.
  ///
  /// In en, this message translates to:
  /// **'Occasionally downloads a tiny public file with this month\'s support goal and amount raised. It is a plain download: nothing about you or your music is sent.'**
  String get onboardingSupportGoalDesc;

  /// No description provided for @songAddedChip.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get songAddedChip;

  /// No description provided for @tapToRemove.
  ///
  /// In en, this message translates to:
  /// **'Tap to remove'**
  String get tapToRemove;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Your language?'**
  String get onboardingYourLanguage;

  /// No description provided for @onboardingAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get onboardingAllow;

  /// No description provided for @onboardingSummaryLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingSummaryLanguage;

  /// No description provided for @onboardingSummaryTheme.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get onboardingSummaryTheme;

  /// No description provided for @onboardingSummaryLibrary.
  ///
  /// In en, this message translates to:
  /// **'Music library access'**
  String get onboardingSummaryLibrary;

  /// No description provided for @onboardingAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get onboardingAllowed;

  /// No description provided for @onboardingNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed yet'**
  String get onboardingNotAllowed;

  /// No description provided for @searchLyrics.
  ///
  /// In en, this message translates to:
  /// **'Search Lyrics'**
  String get searchLyrics;

  /// No description provided for @searchMetadata.
  ///
  /// In en, this message translates to:
  /// **'Search metadata'**
  String get searchMetadata;

  /// No description provided for @searchTracks.
  ///
  /// In en, this message translates to:
  /// **'Search tracks'**
  String get searchTracks;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @selectArtist.
  ///
  /// In en, this message translates to:
  /// **'Select artist'**
  String get selectArtist;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @separator.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get separator;

  /// No description provided for @separatorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. / or feat.'**
  String get separatorHint;

  /// No description provided for @separators.
  ///
  /// In en, this message translates to:
  /// **'Separators'**
  String get separators;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @setMinutes.
  ///
  /// In en, this message translates to:
  /// **'Set minutes'**
  String get setMinutes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Noxira Music'**
  String get settingsAboutApp;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, feedback & updates'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsGroupExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get settingsGroupExperience;

  /// No description provided for @settingsGroupLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library & data'**
  String get settingsGroupLibrary;

  /// No description provided for @settingsGroupApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsGroupApp;

  /// No description provided for @settingsAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsAccentColor;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, colors & layout'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get settingsAudio;

  /// No description provided for @settingsBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get settingsBackground;

  /// No description provided for @settingsCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get settingsCacheCleared;

  /// No description provided for @settingsCacheInfo.
  ///
  /// In en, this message translates to:
  /// **'Cache Information'**
  String get settingsCacheInfo;

  /// No description provided for @settingsCacheInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'View storage usage'**
  String get settingsCacheInfoDesc;

  /// No description provided for @settingsCheckingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get settingsCheckingUpdates;

  /// No description provided for @settingsCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get settingsCheckUpdates;

  /// No description provided for @settingsCheckUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Get latest version'**
  String get settingsCheckUpdatesDesc;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all cached data'**
  String get settingsClearCacheDesc;

  /// No description provided for @settingsClearCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'All cached data will be deleted and rebuilt as needed.'**
  String get settingsClearCacheMessage;

  /// No description provided for @settingsClearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache?'**
  String get settingsClearCacheTitle;

  /// No description provided for @settingsDataWindow.
  ///
  /// In en, this message translates to:
  /// **'Data Window'**
  String get settingsDataWindow;

  /// No description provided for @settingsDataWindowDesc.
  ///
  /// In en, this message translates to:
  /// **'How far back the recap screen looks'**
  String get settingsDataWindowDesc;

  /// No description provided for @settingsGapless.
  ///
  /// In en, this message translates to:
  /// **'Gapless Playback'**
  String get settingsGapless;

  /// No description provided for @settingsGaplessDesc.
  ///
  /// In en, this message translates to:
  /// **'Seamless track transitions'**
  String get settingsGaplessDesc;

  /// No description provided for @settingsAutomix.
  ///
  /// In en, this message translates to:
  /// **'Automix'**
  String get settingsAutomix;

  /// No description provided for @settingsAutomixDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically create a seamless flow between songs'**
  String get settingsAutomixDesc;

  /// No description provided for @settingsCrossfade.
  ///
  /// In en, this message translates to:
  /// **'Crossfade'**
  String get settingsCrossfade;

  /// No description provided for @settingsCrossfadeDesc.
  ///
  /// In en, this message translates to:
  /// **'Smoothly blend the end of one track into the next'**
  String get settingsCrossfadeDesc;

  /// No description provided for @crossfadeDuration.
  ///
  /// In en, this message translates to:
  /// **'Crossfade Duration'**
  String get crossfadeDuration;

  /// No description provided for @crossfadeDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'How long the overlap between tracks lasts'**
  String get crossfadeDurationDesc;

  /// No description provided for @settingsInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get settingsInsights;

  /// No description provided for @settingsInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listening recap period'**
  String get settingsInsightsSubtitle;

  /// No description provided for @settingsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get settingsLast7Days;

  /// No description provided for @settingsLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get settingsLast30Days;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLayout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get settingsLayout;

  /// No description provided for @settingsLibraryFolders.
  ///
  /// In en, this message translates to:
  /// **'Library Folders'**
  String get settingsLibraryFolders;

  /// No description provided for @settingsLibraryFoldersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include or exclude scan folders'**
  String get settingsLibraryFoldersSubtitle;

  /// No description provided for @settingsMaterialYou.
  ///
  /// In en, this message translates to:
  /// **'Material You'**
  String get settingsMaterialYou;

  /// No description provided for @settingsMaterialYouDesc.
  ///
  /// In en, this message translates to:
  /// **'Dynamic colors from wallpaper'**
  String get settingsMaterialYouDesc;

  /// No description provided for @settingsMonthlyRecap.
  ///
  /// In en, this message translates to:
  /// **'Monthly Recap'**
  String get settingsMonthlyRecap;

  /// No description provided for @settingsMonthlyRecapDesc.
  ///
  /// In en, this message translates to:
  /// **'Show a banner every month (takes precedence over weekly)'**
  String get settingsMonthlyRecapDesc;

  /// No description provided for @settingsNormalization.
  ///
  /// In en, this message translates to:
  /// **'Volume Normalization'**
  String get settingsNormalization;

  /// No description provided for @settingsNormalizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Consistent volume levels · Requires ReplayGain tags in your files'**
  String get settingsNormalizationDesc;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get playbackSpeed;

  /// No description provided for @playbackSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust audio playback rate'**
  String get playbackSpeedDesc;

  /// No description provided for @adjustPitchWithSpeed.
  ///
  /// In en, this message translates to:
  /// **'Link pitch to speed'**
  String get adjustPitchWithSpeed;

  /// No description provided for @adjustPitchWithSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Pitch rises and falls with speed. Turn off to set it yourself.'**
  String get adjustPitchWithSpeedDesc;

  /// No description provided for @playbackPitch.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get playbackPitch;

  /// No description provided for @playbackPitchDesc.
  ///
  /// In en, this message translates to:
  /// **'Shift the sound up or down, independent of speed'**
  String get playbackPitchDesc;

  /// No description provided for @playbackPitchLinkedDesc.
  ///
  /// In en, this message translates to:
  /// **'Following playback speed'**
  String get playbackPitchLinkedDesc;

  /// No description provided for @settingsPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsPlayback;

  /// No description provided for @settingsPlaybackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speed, gapless & normalization'**
  String get settingsPlaybackSubtitle;

  /// No description provided for @settingsRecapBannerDesc.
  ///
  /// In en, this message translates to:
  /// **'The banner appears on the home screen at the start of each new week or month counted from your very first play. Tapping \"Later\" hides it for the session; tapping \"Show\" marks it as seen.'**
  String get settingsRecapBannerDesc;

  /// No description provided for @settingsRecapContent.
  ///
  /// In en, this message translates to:
  /// **'Recap Content'**
  String get settingsRecapContent;

  /// No description provided for @settingsRecapContentDesc.
  ///
  /// In en, this message translates to:
  /// **'Controls how much history the recap screen displays when you open it manually or via the banner.'**
  String get settingsRecapContentDesc;

  /// No description provided for @settingsPreviewRecap.
  ///
  /// In en, this message translates to:
  /// **'Preview Recap'**
  String get settingsPreviewRecap;

  /// No description provided for @settingsPreviewRecapDesc.
  ///
  /// In en, this message translates to:
  /// **'See how your recap looks right now with the current settings'**
  String get settingsPreviewRecapDesc;

  /// No description provided for @settingsRecapSchedule.
  ///
  /// In en, this message translates to:
  /// **'Recap Schedule'**
  String get settingsRecapSchedule;

  /// No description provided for @settingsStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorage;

  /// No description provided for @settingsCacheItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String settingsCacheItems(String count);

  /// No description provided for @settingsMemoryCache.
  ///
  /// In en, this message translates to:
  /// **'Memory Cache'**
  String get settingsMemoryCache;

  /// No description provided for @settingsStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cache & media files'**
  String get settingsStorageSubtitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get settingsTools;

  /// No description provided for @settingsResetSetup.
  ///
  /// In en, this message translates to:
  /// **'Run Setup Again'**
  String get settingsResetSetup;

  /// No description provided for @settingsResetSetupDesc.
  ///
  /// In en, this message translates to:
  /// **'Go through the welcome setup again'**
  String get settingsResetSetupDesc;

  /// No description provided for @settingsUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available!'**
  String get settingsUpdateAvailable;

  /// No description provided for @settingsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get settingsUpToDate;

  /// No description provided for @settingsUpdateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for updates. Updates come from Google Play.'**
  String get settingsUpdateCheckFailed;

  /// No description provided for @settingsWeeklyRecap.
  ///
  /// In en, this message translates to:
  /// **'Weekly Recap'**
  String get settingsWeeklyRecap;

  /// No description provided for @settingsWeeklyRecapDesc.
  ///
  /// In en, this message translates to:
  /// **'Show a banner every week after your first play'**
  String get settingsWeeklyRecapDesc;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @songInfo.
  ///
  /// In en, this message translates to:
  /// **'Song Info'**
  String get songInfo;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @songsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Songs loaded'**
  String get songsLoaded;

  /// No description provided for @standardQuality.
  ///
  /// In en, this message translates to:
  /// **'Standard Quality'**
  String get standardQuality;

  /// No description provided for @startType.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get startType;

  /// No description provided for @storagePermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'To edit metadata, Noxira Music needs permission to manage files. Please grant \'All files access\' in settings.'**
  String get storagePermissionNeeded;

  /// No description provided for @suggestedArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists For You'**
  String get suggestedArtists;

  /// No description provided for @suggestedTracks.
  ///
  /// In en, this message translates to:
  /// **'Suggested Tracks'**
  String get suggestedTracks;

  /// No description provided for @supportAurora.
  ///
  /// In en, this message translates to:
  /// **'Support Noxira'**
  String get supportAurora;

  /// No description provided for @supportAuroraBtn.
  ///
  /// In en, this message translates to:
  /// **'Support Noxira'**
  String get supportAuroraBtn;

  /// No description provided for @supportAuroraDescShort.
  ///
  /// In en, this message translates to:
  /// **'Help keep the app free'**
  String get supportAuroraDescShort;

  /// No description provided for @supportAuroraMessage.
  ///
  /// In en, this message translates to:
  /// **'Help keep Noxira Music free and support future development. Every contribution means a lot!'**
  String get supportAuroraMessage;

  /// No description provided for @supportAuroraTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Noxira Music'**
  String get supportAuroraTitle;

  /// No description provided for @updatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Noxira Music was updated'**
  String get updatedTitle;

  /// No description provided for @tapAddToAddSongs.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add songs'**
  String get tapAddToAddSongs;

  /// No description provided for @reorderSongs.
  ///
  /// In en, this message translates to:
  /// **'Reorder Songs'**
  String get reorderSongs;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @thankYouSupport.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get thankYouSupport;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @topResult.
  ///
  /// In en, this message translates to:
  /// **'Top Result'**
  String get topResult;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @trackInfo.
  ///
  /// In en, this message translates to:
  /// **'Track Info'**
  String get trackInfo;

  /// No description provided for @trackInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the edit icon to modify track information'**
  String get trackInfoDesc;

  /// No description provided for @trackInfoEditDesc.
  ///
  /// In en, this message translates to:
  /// **'Edit fields below, then tap the check icon to save'**
  String get trackInfoEditDesc;

  /// No description provided for @tracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracks;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get unknownArtist;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get updateMessage;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @viewArtist.
  ///
  /// In en, this message translates to:
  /// **'View artist'**
  String get viewArtist;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNew;

  /// No description provided for @view_changelog.
  ///
  /// In en, this message translates to:
  /// **'View changelog and new features'**
  String get view_changelog;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @yourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Your Library'**
  String get yourLibrary;

  /// No description provided for @yourPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Your Playlists'**
  String get yourPlaylists;

  /// No description provided for @homeLayout.
  ///
  /// In en, this message translates to:
  /// **'Home Layout'**
  String get homeLayout;

  /// No description provided for @homeLayoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize section order on Home tab'**
  String get homeLayoutDesc;

  /// No description provided for @customizeHomeTab.
  ///
  /// In en, this message translates to:
  /// **'Customize Home Tab'**
  String get customizeHomeTab;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder sections'**
  String get dragToReorder;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @resetLayoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset layout to default?'**
  String get resetLayoutConfirm;

  /// No description provided for @resetLayoutMessage.
  ///
  /// In en, this message translates to:
  /// **'This will restore the original section order and visibility.'**
  String get resetLayoutMessage;

  /// No description provided for @listeningHistory.
  ///
  /// In en, this message translates to:
  /// **'Listening History'**
  String get listeningHistory;

  /// No description provided for @libraryStats.
  ///
  /// In en, this message translates to:
  /// **'Library Stats'**
  String get libraryStats;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @send_feedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get send_feedback;

  /// No description provided for @send_feedback_desc.
  ///
  /// In en, this message translates to:
  /// **'Report bugs or suggest features'**
  String get send_feedback_desc;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Noxira Music'**
  String get rateApp;

  /// No description provided for @rateAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoying the app? Leave a review on Google Play'**
  String get rateAppDesc;

  /// No description provided for @feedbackTypeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get feedbackTypeBug;

  /// No description provided for @feedbackTypeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get feedbackTypeSuggestion;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the bug or suggestion...'**
  String get feedbackHint;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// No description provided for @feedbackSentThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get feedbackSentThanks;

  /// No description provided for @feedbackSentError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send feedback. Please try again later.'**
  String get feedbackSentError;

  /// No description provided for @contributeTranslations.
  ///
  /// In en, this message translates to:
  /// **'Contribute Translations'**
  String get contributeTranslations;

  /// No description provided for @contributeTranslationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Help translate Noxira Music on Crowdin'**
  String get contributeTranslationsDesc;

  /// No description provided for @contributeTranslationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Us Translate'**
  String get contributeTranslationsTitle;

  /// No description provided for @contributeTranslationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Noxira Music is available in multiple languages thanks to our amazing community. Help us reach even more users by translating the app into your language — it only takes a few minutes to get started.'**
  String get contributeTranslationsSubtitle;

  /// No description provided for @contributeTranslationsOpenCrowdin.
  ///
  /// In en, this message translates to:
  /// **'Open Crowdin'**
  String get contributeTranslationsOpenCrowdin;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settingsHighendUi.
  ///
  /// In en, this message translates to:
  /// **'High-end UI'**
  String get settingsHighendUi;

  /// No description provided for @settingsHighendUiDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable advanced visual effects and animations'**
  String get settingsHighendUiDesc;

  /// No description provided for @clearUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Clear upcoming'**
  String get clearUpcoming;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get playNext;

  /// No description provided for @removeFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get removeFromQueue;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @viewAlbum.
  ///
  /// In en, this message translates to:
  /// **'View Album'**
  String get viewAlbum;

  /// No description provided for @shuffleAll.
  ///
  /// In en, this message translates to:
  /// **'Shuffle All'**
  String get shuffleAll;

  /// No description provided for @noSongsFound.
  ///
  /// In en, this message translates to:
  /// **'No songs found'**
  String get noSongsFound;

  /// No description provided for @noFoldersFound.
  ///
  /// In en, this message translates to:
  /// **'No folders found'**
  String get noFoldersFound;

  /// No description provided for @deleteSong.
  ///
  /// In en, this message translates to:
  /// **'Delete Song'**
  String get deleteSong;

  /// No description provided for @modifySystemSettingsPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow \"Modify system settings\" in the page that opened, then try again.'**
  String get modifySystemSettingsPermission;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @songsAddedToQueue.
  ///
  /// In en, this message translates to:
  /// **'{count} songs added to queue'**
  String songsAddedToQueue(int count);

  /// No description provided for @songAddedToQueue.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" added to queue'**
  String songAddedToQueue(String title);

  /// No description provided for @songSetAsRingtone.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" set as ringtone'**
  String songSetAsRingtone(String title);

  /// No description provided for @failedToSetRingtone.
  ///
  /// In en, this message translates to:
  /// **'Failed to set ringtone: {error}'**
  String failedToSetRingtone(String error);

  /// No description provided for @deleteSongConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" from your device? This cannot be undone.'**
  String deleteSongConfirm(String title);

  /// No description provided for @songDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" deleted'**
  String songDeleted(String title);

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDelete(String error);

  /// No description provided for @songCount.
  ///
  /// In en, this message translates to:
  /// **'{count} songs'**
  String songCount(int count);

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @readyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get readyToPlay;

  /// No description provided for @tapSongToStartListening.
  ///
  /// In en, this message translates to:
  /// **'Tap a song to start listening'**
  String get tapSongToStartListening;

  /// No description provided for @clearCachedLyrics.
  ///
  /// In en, this message translates to:
  /// **'Clear cached lyrics'**
  String get clearCachedLyrics;

  /// No description provided for @lyricsCleared.
  ///
  /// In en, this message translates to:
  /// **'Cached lyrics cleared for \"{title}\"'**
  String lyricsCleared(String title);

  /// No description provided for @lyricsAdded.
  ///
  /// In en, this message translates to:
  /// **'Lyrics added for \"{title}\"'**
  String lyricsAdded(String title);

  /// No description provided for @noLyricsCached.
  ///
  /// In en, this message translates to:
  /// **'No cached lyrics found for this song'**
  String get noLyricsCached;

  /// No description provided for @setAsRingtone.
  ///
  /// In en, this message translates to:
  /// **'Set as ringtone'**
  String get setAsRingtone;

  /// No description provided for @songInfoEdit.
  ///
  /// In en, this message translates to:
  /// **'Song info / Edit'**
  String get songInfoEdit;

  /// No description provided for @goToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Go to album'**
  String get goToAlbum;

  /// No description provided for @goToArtist.
  ///
  /// In en, this message translates to:
  /// **'Go to artist'**
  String get goToArtist;

  /// No description provided for @deleteFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete from device'**
  String get deleteFromDevice;

  /// No description provided for @checkOutThisSong.
  ///
  /// In en, this message translates to:
  /// **'Check out this song!'**
  String get checkOutThisSong;

  /// No description provided for @backgroundSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid Color'**
  String get backgroundSolid;

  /// No description provided for @backgroundHighEndStyle.
  ///
  /// In en, this message translates to:
  /// **'Now Playing Background'**
  String get backgroundHighEndStyle;

  /// No description provided for @backgroundHighEndStyleDesc.
  ///
  /// In en, this message translates to:
  /// **'Background style in the Now Playing screen'**
  String get backgroundHighEndStyleDesc;

  /// No description provided for @backgroundBlurredArtwork.
  ///
  /// In en, this message translates to:
  /// **'Blurred Artwork'**
  String get backgroundBlurredArtwork;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @accentColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the app accent color'**
  String get accentColorDesc;

  /// No description provided for @backgroundBlur.
  ///
  /// In en, this message translates to:
  /// **'Background Blur'**
  String get backgroundBlur;

  /// No description provided for @backgroundBlurDesc.
  ///
  /// In en, this message translates to:
  /// **'Artwork blur intensity'**
  String get backgroundBlurDesc;

  /// No description provided for @backgroundDarkness.
  ///
  /// In en, this message translates to:
  /// **'Background Darkness'**
  String get backgroundDarkness;

  /// No description provided for @backgroundDarknessDesc.
  ///
  /// In en, this message translates to:
  /// **'Overlay opacity on artwork'**
  String get backgroundDarknessDesc;

  /// No description provided for @microphoneAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Microphone access needed'**
  String get microphoneAccessNeeded;

  /// No description provided for @microphoneAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Noxira needs microphone access to tap your device\'s audio session for the live visualizer. No audio is ever recorded or stored.'**
  String get microphoneAccessDesc;

  /// No description provided for @recapWeek.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get recapWeek;

  /// No description provided for @recapMonth.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get recapMonth;

  /// No description provided for @recapPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get recapPeriodWeek;

  /// No description provided for @recapPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get recapPeriodMonth;

  /// No description provided for @recapWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recapWeekly;

  /// No description provided for @recapMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recapMonthly;

  /// No description provided for @recapIntroAppName.
  ///
  /// In en, this message translates to:
  /// **'NOXIRA MUSIC'**
  String get recapIntroAppName;

  /// No description provided for @recapIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {period}\nRecap'**
  String recapIntroTitle(String period);

  /// No description provided for @recapIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s see what you\'ve been\nlistening to.'**
  String get recapIntroSubtitle;

  /// No description provided for @recapPlayedEyebrow.
  ///
  /// In en, this message translates to:
  /// **'This {period} you played music'**
  String recapPlayedEyebrow(String period);

  /// No description provided for @recapTimeSingular.
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get recapTimeSingular;

  /// No description provided for @recapTimePlural.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get recapTimePlural;

  /// No description provided for @recapListenedForEyebrow.
  ///
  /// In en, this message translates to:
  /// **'You listened for'**
  String get recapListenedForEyebrow;

  /// No description provided for @recapListenedForLabel.
  ///
  /// In en, this message translates to:
  /// **'of music'**
  String get recapListenedForLabel;

  /// No description provided for @recapTopTrackEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your #1 track'**
  String get recapTopTrackEyebrow;

  /// No description provided for @recapPlays.
  ///
  /// In en, this message translates to:
  /// **'plays'**
  String get recapPlays;

  /// No description provided for @recapTopTracksTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Tracks'**
  String get recapTopTracksTitle;

  /// No description provided for @recapTopArtistEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your top artist'**
  String get recapTopArtistEyebrow;

  /// No description provided for @recapTopArtistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Artists'**
  String get recapTopArtistsTitle;

  /// No description provided for @recapNothingToWrap.
  ///
  /// In en, this message translates to:
  /// **'Nothing to wrap yet'**
  String get recapNothingToWrap;

  /// No description provided for @recapNothingToWrapBody.
  ///
  /// In en, this message translates to:
  /// **'Play some music this {period} and come back.'**
  String recapNothingToWrapBody(String period);

  /// No description provided for @recapSwipeUp.
  ///
  /// In en, this message translates to:
  /// **'SWIPE UP'**
  String get recapSwipeUp;

  /// No description provided for @recapYourSoundLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR SOUND'**
  String get recapYourSoundLabel;

  /// No description provided for @recapYouListenMost.
  ///
  /// In en, this message translates to:
  /// **'YOU LISTEN MOST'**
  String get recapYouListenMost;

  /// No description provided for @recapOnDay.
  ///
  /// In en, this message translates to:
  /// **'on {day}s'**
  String recapOnDay(String day);

  /// No description provided for @recapAroundTime.
  ///
  /// In en, this message translates to:
  /// **'around {time}'**
  String recapAroundTime(String time);

  /// No description provided for @recapVibesHitDifferent.
  ///
  /// In en, this message translates to:
  /// **'That\'s when the vibes hit different.'**
  String get recapVibesHitDifferent;

  /// No description provided for @recapThatsAWrap.
  ///
  /// In en, this message translates to:
  /// **'THAT\'S A WRAP'**
  String get recapThatsAWrap;

  /// No description provided for @recapInNumbers.
  ///
  /// In en, this message translates to:
  /// **'Your {period}\nin Numbers'**
  String recapInNumbers(String period);

  /// No description provided for @recapNumberOneTrack.
  ///
  /// In en, this message translates to:
  /// **'#1 TRACK'**
  String get recapNumberOneTrack;

  /// No description provided for @recapStatTotalPlays.
  ///
  /// In en, this message translates to:
  /// **'Total Plays'**
  String get recapStatTotalPlays;

  /// No description provided for @recapStatTimeListened.
  ///
  /// In en, this message translates to:
  /// **'Time Listened'**
  String get recapStatTimeListened;

  /// No description provided for @recapStatUniqueTracks.
  ///
  /// In en, this message translates to:
  /// **'Unique Tracks'**
  String get recapStatUniqueTracks;

  /// No description provided for @recapStatTopArtist.
  ///
  /// In en, this message translates to:
  /// **'Top Artist'**
  String get recapStatTopArtist;

  /// No description provided for @recapDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get recapDone;

  /// No description provided for @recapWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get recapWeekdayMonday;

  /// No description provided for @recapWeekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get recapWeekdayTuesday;

  /// No description provided for @recapWeekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get recapWeekdayWednesday;

  /// No description provided for @recapWeekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get recapWeekdayThursday;

  /// No description provided for @recapWeekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get recapWeekdayFriday;

  /// No description provided for @recapWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get recapWeekdaySaturday;

  /// No description provided for @recapWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get recapWeekdaySunday;

  /// No description provided for @recapBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Music recap is here'**
  String get recapBannerTitle;

  /// No description provided for @recapBannerShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get recapBannerShow;

  /// No description provided for @recapBannerLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get recapBannerLater;

  /// No description provided for @rebrandTitle.
  ///
  /// In en, this message translates to:
  /// **'Aurora is now Noxira'**
  String get rebrandTitle;

  /// No description provided for @rebrandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same music app you know, with a new name, a fresh look and some new tricks.'**
  String get rebrandSubtitle;

  /// No description provided for @rebrandNewHeading.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get rebrandNewHeading;

  /// No description provided for @rebrandSlideLyricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lyrics, rebuilt'**
  String get rebrandSlideLyricsTitle;

  /// No description provided for @rebrandSlideLyricsBody.
  ///
  /// In en, this message translates to:
  /// **'A redesigned lyrics page and more lyric sources, so more songs find their words. Songs with word-by-word timing light up word by word. Tap a line to jump to it, and translate lyrics into any language you like.'**
  String get rebrandSlideLyricsBody;

  /// No description provided for @rebrandSlideWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'A refreshed home screen widget'**
  String get rebrandSlideWidgetTitle;

  /// No description provided for @rebrandSlideWidgetBody.
  ///
  /// In en, this message translates to:
  /// **'Glass tinted with your artwork, and previous, play and next buttons that work without opening the app.'**
  String get rebrandSlideWidgetBody;

  /// No description provided for @rebrandSlideQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'A redesigned queue'**
  String get rebrandSlideQueueTitle;

  /// No description provided for @rebrandSlideQueueBody.
  ///
  /// In en, this message translates to:
  /// **'See what played and what\'s next. Drag to reorder, swipe to remove.'**
  String get rebrandSlideQueueBody;

  /// No description provided for @rebrandSlideOutputTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose where it plays'**
  String get rebrandSlideOutputTitle;

  /// No description provided for @rebrandSlideOutputBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the Bluetooth chip on the home screen, or the new button on Now Playing, to move playback between your phone speaker and connected devices, right inside the app.'**
  String get rebrandSlideOutputBody;

  /// No description provided for @rebrandSlideLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'A tidier library'**
  String get rebrandSlideLibraryTitle;

  /// No description provided for @rebrandSlideLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Noxira spots duplicate tracks and lets you pick which copy to keep. Playlists have a new layout with Favorites, automatic and smart playlists in one place.'**
  String get rebrandSlideLibraryBody;

  /// No description provided for @rebrandMoreMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages now appear as a small island at the bottom of the screen.'**
  String get rebrandMoreMessages;

  /// No description provided for @rebrandMorePerformance.
  ///
  /// In en, this message translates to:
  /// **'Faster search, a quicker start and lighter image loading.'**
  String get rebrandMorePerformance;

  /// No description provided for @translateLyricsTo.
  ///
  /// In en, this message translates to:
  /// **'Translate lyrics to'**
  String get translateLyricsTo;

  /// No description provided for @translateLyricsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get translateLyricsAppLanguage;

  /// No description provided for @translateLyricsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language…'**
  String get translateLyricsChooseLanguage;

  /// No description provided for @rebrandSlideMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'And a few more things'**
  String get rebrandSlideMoreTitle;

  /// No description provided for @rebrandMoreSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup now suggests the right mode for your phone.'**
  String get rebrandMoreSetup;

  /// No description provided for @rebrandMoreLook.
  ///
  /// In en, this message translates to:
  /// **'Rounded play button on Favorite Songs and lyric controls that stay put.'**
  String get rebrandMoreLook;

  /// No description provided for @rebrandMoreMotion.
  ///
  /// In en, this message translates to:
  /// **'Smoother, better transitions across the whole app.'**
  String get rebrandMoreMotion;

  /// No description provided for @rebrandMorePlayback.
  ///
  /// In en, this message translates to:
  /// **'Separate speed and pitch sliders, which you can link together.'**
  String get rebrandMorePlayback;

  /// No description provided for @rebrandMoreSearch.
  ///
  /// In en, this message translates to:
  /// **'A redesigned Search tab and a Settings page sorted into groups.'**
  String get rebrandMoreSearch;

  /// No description provided for @rebrandMoreFixes.
  ///
  /// In en, this message translates to:
  /// **'Stability fixes, including editing tags on voice recordings, the visualizer on Dolby tracks and phones without an equalizer.'**
  String get rebrandMoreFixes;

  /// No description provided for @eqTitle.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get eqTitle;

  /// No description provided for @eqOn.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get eqOn;

  /// No description provided for @eqOff.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get eqOff;

  /// No description provided for @eqNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Equalizer not available on this device.'**
  String get eqNotAvailable;

  /// No description provided for @eqWaitingForAudio.
  ///
  /// In en, this message translates to:
  /// **'Start playing a song to adjust the equalizer.'**
  String get eqWaitingForAudio;

  /// No description provided for @eqOpenSystem.
  ///
  /// In en, this message translates to:
  /// **'Open System Equalizer'**
  String get eqOpenSystem;

  /// No description provided for @eqSavePreset.
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get eqSavePreset;

  /// No description provided for @eqPresetNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Bass Boost'**
  String get eqPresetNameHint;

  /// No description provided for @eqPresetNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty.'**
  String get eqPresetNameEmpty;

  /// No description provided for @eqPresetNameBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is a built-in preset name.'**
  String eqPresetNameBuiltIn(String name);

  /// No description provided for @eqResetAllBands.
  ///
  /// In en, this message translates to:
  /// **'Reset all bands'**
  String get eqResetAllBands;

  /// No description provided for @eqPresetsLabel.
  ///
  /// In en, this message translates to:
  /// **'PRESETS'**
  String get eqPresetsLabel;

  /// No description provided for @eqYourPresetsLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR PRESETS'**
  String get eqYourPresetsLabel;

  /// No description provided for @eqSaveCurrent.
  ///
  /// In en, this message translates to:
  /// **'Save current'**
  String get eqSaveCurrent;

  /// No description provided for @eqSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust audio frequencies per band'**
  String get eqSettingsSubtitle;

  /// No description provided for @eqEmptyPresets.
  ///
  /// In en, this message translates to:
  /// **'Dial in your sound, then tap \"Save current\".'**
  String get eqEmptyPresets;

  /// No description provided for @lyricsHint.
  ///
  /// In en, this message translates to:
  /// **'Paste unsynced lyrics here…\n\nOne line per verse line.'**
  String get lyricsHint;

  /// No description provided for @lyricsSelectLrcFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a .lrc file'**
  String get lyricsSelectLrcFile;

  /// No description provided for @lyricsNoLyricsInFile.
  ///
  /// In en, this message translates to:
  /// **'No lyrics found in that file'**
  String get lyricsNoLyricsInFile;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @lyricsImportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import .lrc file'**
  String get lyricsImportTooltip;

  /// No description provided for @importPlaylistM3u.
  ///
  /// In en, this message translates to:
  /// **'Import playlist (.m3u)'**
  String get importPlaylistM3u;

  /// No description provided for @setSyncFolder.
  ///
  /// In en, this message translates to:
  /// **'Set sync folder…'**
  String get setSyncFolder;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @searchPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Search playlists…'**
  String get searchPlaylists;

  /// No description provided for @pleaseSelectM3uFile.
  ///
  /// In en, this message translates to:
  /// **'Please select an .m3u or .m3u8 file'**
  String get pleaseSelectM3uFile;

  /// No description provided for @noMatchingSongsForPlaylist.
  ///
  /// In en, this message translates to:
  /// **'No matching songs found for that playlist'**
  String get noMatchingSongsForPlaylist;

  /// No description provided for @importedPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Imported \"{name}\" ({count} songs)'**
  String importedPlaylist(String name, int count);

  /// No description provided for @playlistsSyncWith.
  ///
  /// In en, this message translates to:
  /// **'Playlists will sync with: {folder}'**
  String playlistsSyncWith(String folder);

  /// No description provided for @couldNotSetSyncFolder.
  ///
  /// In en, this message translates to:
  /// **'Could not set sync folder: {error}'**
  String couldNotSetSyncFolder(String error);

  /// No description provided for @setSyncFolderFirst.
  ///
  /// In en, this message translates to:
  /// **'Set a sync folder first'**
  String get setSyncFolderFirst;

  /// No description provided for @playlistsSynced.
  ///
  /// In en, this message translates to:
  /// **'Playlists synced'**
  String get playlistsSynced;

  /// No description provided for @alreadyUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Already up to date'**
  String get alreadyUpToDate;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @searchFolders.
  ///
  /// In en, this message translates to:
  /// **'Search folders…'**
  String get searchFolders;

  /// No description provided for @songInfoPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get songInfoPath;

  /// No description provided for @closeVisualiser.
  ///
  /// In en, this message translates to:
  /// **'Close visualiser'**
  String get closeVisualiser;

  /// No description provided for @visualizerWaitingForAudio.
  ///
  /// In en, this message translates to:
  /// **'Waiting for playback audio...'**
  String get visualizerWaitingForAudio;

  /// No description provided for @visualizerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Live audio analysis is unavailable for this output.'**
  String get visualizerUnavailable;

  /// No description provided for @previousMode.
  ///
  /// In en, this message translates to:
  /// **'Previous mode'**
  String get previousMode;

  /// No description provided for @nextMode.
  ///
  /// In en, this message translates to:
  /// **'Next mode'**
  String get nextMode;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// No description provided for @insightsTotalPlays.
  ///
  /// In en, this message translates to:
  /// **'Total\nPlays'**
  String get insightsTotalPlays;

  /// No description provided for @insightsTracksHeard.
  ///
  /// In en, this message translates to:
  /// **'Tracks\nHeard'**
  String get insightsTracksHeard;

  /// No description provided for @insightsEstListening.
  ///
  /// In en, this message translates to:
  /// **'Est.\nListening'**
  String get insightsEstListening;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @updateVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is now available.'**
  String updateVersionAvailable(String version);

  /// No description provided for @updateNewVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version is now available.'**
  String get updateNewVersionAvailable;

  /// No description provided for @lyricsPasteLyricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste Lyrics'**
  String get lyricsPasteLyricsTitle;

  /// No description provided for @lyricsUseLyrics.
  ///
  /// In en, this message translates to:
  /// **'Use Lyrics'**
  String get lyricsUseLyrics;

  /// No description provided for @lyricsPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get lyricsPaste;

  /// No description provided for @lyricsNoLyricsYet.
  ///
  /// In en, this message translates to:
  /// **'No lyrics yet'**
  String get lyricsNoLyricsYet;

  /// No description provided for @lyricsPasteToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Paste lyrics to get started'**
  String get lyricsPasteToGetStarted;

  /// No description provided for @lyricsNoTimestampsYet.
  ///
  /// In en, this message translates to:
  /// **'No timestamps yet — tap the stamp button while the song plays.'**
  String get lyricsNoTimestampsYet;

  /// No description provided for @lyricsAllLinesStampedHint.
  ///
  /// In en, this message translates to:
  /// **'All lines stamped — tap Save to finish.'**
  String get lyricsAllLinesStampedHint;

  /// No description provided for @lyricsAllStamped.
  ///
  /// In en, this message translates to:
  /// **'✓  All lines stamped'**
  String get lyricsAllStamped;

  /// No description provided for @lyricsPasteFirst.
  ///
  /// In en, this message translates to:
  /// **'Paste lyrics first'**
  String get lyricsPasteFirst;

  /// No description provided for @lyricsTapToStamp.
  ///
  /// In en, this message translates to:
  /// **'⏱  TAP TO STAMP LINE {current} / {total}'**
  String lyricsTapToStamp(int current, int total);

  /// No description provided for @lyricsNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get lyricsNextLabel;

  /// No description provided for @translationDisclaimerNote.
  ///
  /// In en, this message translates to:
  /// **'Some translations are AI-generated or community-contributed and may contain errors. Help us improve them on Crowdin.'**
  String get translationDisclaimerNote;

  /// No description provided for @newLanguagesAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'New Languages Available'**
  String get newLanguagesAvailableTitle;

  /// No description provided for @newLanguagesAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Noxira Music now supports German, Spanish, Hindi, and Russian. You can change your language in Settings.'**
  String get newLanguagesAvailableBody;

  /// No description provided for @newLanguagesGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get newLanguagesGoToSettings;

  /// No description provided for @newLanguagesDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get newLanguagesDismiss;

  /// No description provided for @settingsLyricsSources.
  ///
  /// In en, this message translates to:
  /// **'Lyrics sources'**
  String get settingsLyricsSources;

  /// No description provided for @lyricsProviderDesc.
  ///
  /// In en, this message translates to:
  /// **'Used when LRCLIB has no lyrics. Receives the song title, artist, album and length.'**
  String get lyricsProviderDesc;

  /// No description provided for @onlineAboutArtist.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get onlineAboutArtist;

  /// No description provided for @onlineFansAlsoLike.
  ///
  /// In en, this message translates to:
  /// **'Fans also like'**
  String get onlineFansAlsoLike;

  /// No description provided for @onlinePopularTracks.
  ///
  /// In en, this message translates to:
  /// **'Popular right now'**
  String get onlinePopularTracks;

  /// No description provided for @onlineReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get onlineReadMore;

  /// No description provided for @onlineBioDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Gathered automatically from public sources. Not guaranteed to be accurate.'**
  String get onlineBioDisclaimer;

  /// No description provided for @onlineShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get onlineShowLess;

  /// No description provided for @onlineWikipedia.
  ///
  /// In en, this message translates to:
  /// **'Wikipedia'**
  String get onlineWikipedia;

  /// No description provided for @onlineFansCount.
  ///
  /// In en, this message translates to:
  /// **'{count} fans'**
  String onlineFansCount(String count);

  /// No description provided for @settingsOnlineSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Online suggestions'**
  String get settingsOnlineSuggestions;

  /// No description provided for @settingsOnlineSuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Look up artist info and similar artists from Deezer and Wikipedia. Only the artist name is sent.'**
  String get settingsOnlineSuggestionsDesc;

  /// No description provided for @onboardingUiModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Interface style'**
  String get onboardingUiModeTitle;

  /// No description provided for @onboardingUiModeDesc.
  ///
  /// In en, this message translates to:
  /// **'How much glass and animation the app uses'**
  String get onboardingUiModeDesc;

  /// No description provided for @onboardingUiHighEnd.
  ///
  /// In en, this message translates to:
  /// **'High-end'**
  String get onboardingUiHighEnd;

  /// No description provided for @onboardingUiLowEnd.
  ///
  /// In en, this message translates to:
  /// **'Lightweight'**
  String get onboardingUiLowEnd;

  /// No description provided for @onboardingRecommendedBadge.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get onboardingRecommendedBadge;

  /// No description provided for @onboardingRecommendedForDevice.
  ///
  /// In en, this message translates to:
  /// **'Recommended for your device.'**
  String get onboardingRecommendedForDevice;

  /// No description provided for @onboardingTryNote.
  ///
  /// In en, this message translates to:
  /// **'Based on your device\'s specs we recommend {recommended}, but you\'re welcome to try {selected}.'**
  String onboardingTryNote(String recommended, String selected);

  /// No description provided for @onboardingHeaviestNote.
  ///
  /// In en, this message translates to:
  /// **'{option} is the heaviest option and may feel less smooth on your device.'**
  String onboardingHeaviestNote(String option);

  /// No description provided for @audioOutput.
  ///
  /// In en, this message translates to:
  /// **'Audio Output'**
  String get audioOutput;

  /// No description provided for @audioOutputBluetoothDevice.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Device'**
  String get audioOutputBluetoothDevice;

  /// No description provided for @audioOutputPhoneSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Phone Speaker'**
  String get audioOutputPhoneSpeaker;

  /// No description provided for @audioOutputWired.
  ///
  /// In en, this message translates to:
  /// **'Wired Headphones'**
  String get audioOutputWired;

  /// No description provided for @audioOutputUsb.
  ///
  /// In en, this message translates to:
  /// **'USB Audio'**
  String get audioOutputUsb;

  /// No description provided for @audioOutputOther.
  ///
  /// In en, this message translates to:
  /// **'Other output'**
  String get audioOutputOther;

  /// No description provided for @audioOutputNoOthers.
  ///
  /// In en, this message translates to:
  /// **'No other devices detected'**
  String get audioOutputNoOthers;

  /// No description provided for @audioOutputCurrentDevice.
  ///
  /// In en, this message translates to:
  /// **'Current Device'**
  String get audioOutputCurrentDevice;

  /// No description provided for @audioOutputSwitchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t switch the audio output'**
  String get audioOutputSwitchFailed;

  /// No description provided for @duplicatesBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate tracks found'**
  String get duplicatesBannerTitle;

  /// No description provided for @duplicatesBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track exists in multiple copies} other{{count} tracks exist in multiple copies}}'**
  String duplicatesBannerSubtitle(int count);

  /// No description provided for @duplicatesReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get duplicatesReview;

  /// No description provided for @duplicatesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate tracks'**
  String get duplicatesScreenTitle;

  /// No description provided for @duplicatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No duplicates found'**
  String get duplicatesEmpty;

  /// No description provided for @duplicatesIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get duplicatesIgnore;

  /// No description provided for @duplicatesIgnoreAll.
  ///
  /// In en, this message translates to:
  /// **'Ignore all'**
  String get duplicatesIgnoreAll;

  /// No description provided for @duplicatesKeepBest.
  ///
  /// In en, this message translates to:
  /// **'Best quality'**
  String get duplicatesKeepBest;

  /// No description provided for @duplicatesCopies.
  ///
  /// In en, this message translates to:
  /// **'{count} copies'**
  String duplicatesCopies(int count);

  /// No description provided for @duplicatesDeleteOthers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Keep selected, delete 1 other} other{Keep selected, delete {count} others}}'**
  String duplicatesDeleteOthers(int count);

  /// No description provided for @duplicatesDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete some copies'**
  String get duplicatesDeleteFailed;

  /// No description provided for @duplicatesResolved.
  ///
  /// In en, this message translates to:
  /// **'Duplicates removed'**
  String get duplicatesResolved;

  /// No description provided for @duplicatesHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the copy to keep. The others will be deleted from your device.'**
  String get duplicatesHint;

  /// No description provided for @remoteAnnouncementOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get remoteAnnouncementOpenLink;

  /// No description provided for @remoteAnnouncementOpenScreen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get remoteAnnouncementOpenScreen;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Please update Noxira Music to keep using it.'**
  String get updateRequiredMessage;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supporters and ways to help'**
  String get settingsSupportSubtitle;

  /// No description provided for @supportSupporters.
  ///
  /// In en, this message translates to:
  /// **'Supporters'**
  String get supportSupporters;

  /// No description provided for @supportNoSupportersYet.
  ///
  /// In en, this message translates to:
  /// **'No supporters listed yet. Be the first to appear here!'**
  String get supportNoSupportersYet;

  /// No description provided for @musicInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Music Insights'**
  String get musicInsightsTitle;

  /// No description provided for @insightsActivityByTimeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Activity by Time of Day'**
  String get insightsActivityByTimeOfDay;

  /// No description provided for @insightsActivityByDay.
  ///
  /// In en, this message translates to:
  /// **'Activity by Day'**
  String get insightsActivityByDay;

  /// No description provided for @insightsGenreBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Genre Breakdown'**
  String get insightsGenreBreakdown;

  /// No description provided for @insightsNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No listening data yet'**
  String get insightsNoDataTitle;

  /// No description provided for @insightsNoDataBody.
  ///
  /// In en, this message translates to:
  /// **'Play some music to start building your insights.'**
  String get insightsNoDataBody;

  /// No description provided for @insightsMostActiveAround.
  ///
  /// In en, this message translates to:
  /// **'Most active around {time}'**
  String insightsMostActiveAround(String time);

  /// No description provided for @insightsMostActiveOn.
  ///
  /// In en, this message translates to:
  /// **'Most active on {day}'**
  String insightsMostActiveOn(String day);

  /// No description provided for @moreFromArtist.
  ///
  /// In en, this message translates to:
  /// **'More from {artist}'**
  String moreFromArtist(String artist);

  /// No description provided for @tracksCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track} other{{count} tracks}}'**
  String tracksCountPlural(int count);

  /// No description provided for @songsCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song} other{{count} songs}}'**
  String songsCountPlural(int count);

  /// No description provided for @albumsCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 album} other{{count} albums}}'**
  String albumsCountPlural(int count);

  /// No description provided for @playlistsCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 playlist} other{{count} playlists}}'**
  String playlistsCountPlural(int count);

  /// No description provided for @foldersCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 folder} other{{count} folders}}'**
  String foldersCountPlural(int count);

  /// No description provided for @foldersExcludedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} excluded'**
  String foldersExcludedCount(int count);

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown Album'**
  String get unknownAlbum;

  /// No description provided for @queueNextUp.
  ///
  /// In en, this message translates to:
  /// **'Next Up'**
  String get queueNextUp;

  /// No description provided for @queueNextFrom.
  ///
  /// In en, this message translates to:
  /// **'Next from {source}'**
  String queueNextFrom(String source);

  /// No description provided for @queueNothingElse.
  ///
  /// In en, this message translates to:
  /// **'Nothing else queued'**
  String get queueNothingElse;

  /// No description provided for @queueMoveToEnd.
  ///
  /// In en, this message translates to:
  /// **'Move to end'**
  String get queueMoveToEnd;

  /// No description provided for @translateLyrics.
  ///
  /// In en, this message translates to:
  /// **'Translate lyrics'**
  String get translateLyrics;

  /// No description provided for @translateFailedTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Translation failed — tap to retry'**
  String get translateFailedTapToRetry;

  /// No description provided for @translateShowOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get translateShowOriginal;

  /// No description provided for @translateShowTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get translateShowTranslation;

  /// No description provided for @lyricsAiTranslatedNote.
  ///
  /// In en, this message translates to:
  /// **'AI translated · accuracy may vary'**
  String get lyricsAiTranslatedNote;

  /// No description provided for @lyricsCantTranslateSameLanguage.
  ///
  /// In en, this message translates to:
  /// **'Can\'t translate — lyrics are already in the target language ({language})'**
  String lyricsCantTranslateSameLanguage(String language);

  /// No description provided for @lyricsAddLyrics.
  ///
  /// In en, this message translates to:
  /// **'Add Lyrics'**
  String get lyricsAddLyrics;

  /// No description provided for @lyricsBlurOn.
  ///
  /// In en, this message translates to:
  /// **'Lyrics blur: on'**
  String get lyricsBlurOn;

  /// No description provided for @lyricsBlurOff.
  ///
  /// In en, this message translates to:
  /// **'Lyrics blur: off'**
  String get lyricsBlurOff;

  /// No description provided for @lyricsAutoHideOn.
  ///
  /// In en, this message translates to:
  /// **'Auto-hide controls: on'**
  String get lyricsAutoHideOn;

  /// No description provided for @lyricsAutoHideOff.
  ///
  /// In en, this message translates to:
  /// **'Auto-hide controls: off'**
  String get lyricsAutoHideOff;

  /// No description provided for @lyricsEditCreate.
  ///
  /// In en, this message translates to:
  /// **'Edit / Create Lyrics'**
  String get lyricsEditCreate;

  /// No description provided for @sleepTimerMinShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get sleepTimerMinShort;

  /// No description provided for @sleepTimerMinutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sleepTimerMinutesValue(int minutes);

  /// No description provided for @sleepTimerMusicStopsAfter.
  ///
  /// In en, this message translates to:
  /// **'Music stops after…'**
  String get sleepTimerMusicStopsAfter;

  /// No description provided for @sleepTimerPickDuration.
  ///
  /// In en, this message translates to:
  /// **'Pick a duration below'**
  String get sleepTimerPickDuration;

  /// No description provided for @visualizerBarSpectrum.
  ///
  /// In en, this message translates to:
  /// **'Bar Spectrum'**
  String get visualizerBarSpectrum;

  /// No description provided for @visualizerCircularBars.
  ///
  /// In en, this message translates to:
  /// **'Circular Bars'**
  String get visualizerCircularBars;

  /// No description provided for @visualizerMirrorBars.
  ///
  /// In en, this message translates to:
  /// **'Mirror Bars'**
  String get visualizerMirrorBars;

  /// No description provided for @visualizerFrequencyLine.
  ///
  /// In en, this message translates to:
  /// **'Frequency Line'**
  String get visualizerFrequencyLine;

  /// No description provided for @visualizerDotMatrix.
  ///
  /// In en, this message translates to:
  /// **'Dot Matrix'**
  String get visualizerDotMatrix;

  /// No description provided for @visualizerPeakBars.
  ///
  /// In en, this message translates to:
  /// **'Peak Bars'**
  String get visualizerPeakBars;

  /// No description provided for @visualizerCircularWave.
  ///
  /// In en, this message translates to:
  /// **'Circular Wave'**
  String get visualizerCircularWave;

  /// No description provided for @visualizerAuroraWaves.
  ///
  /// In en, this message translates to:
  /// **'Aurora Waves'**
  String get visualizerAuroraWaves;

  /// No description provided for @visualizerPulseRings.
  ///
  /// In en, this message translates to:
  /// **'Pulse Rings'**
  String get visualizerPulseRings;

  /// No description provided for @smartFieldFolderPath.
  ///
  /// In en, this message translates to:
  /// **'Folder path'**
  String get smartFieldFolderPath;

  /// No description provided for @smartFieldLiked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get smartFieldLiked;

  /// No description provided for @smartFieldPlayCount.
  ///
  /// In en, this message translates to:
  /// **'Play count'**
  String get smartFieldPlayCount;

  /// No description provided for @smartFieldDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'Duration (seconds)'**
  String get smartFieldDurationSeconds;

  /// No description provided for @smartFieldDaysSinceAdded.
  ///
  /// In en, this message translates to:
  /// **'Days since added'**
  String get smartFieldDaysSinceAdded;

  /// No description provided for @smartOpContains.
  ///
  /// In en, this message translates to:
  /// **'contains'**
  String get smartOpContains;

  /// No description provided for @smartOpNotContains.
  ///
  /// In en, this message translates to:
  /// **'does not contain'**
  String get smartOpNotContains;

  /// No description provided for @smartOpEquals.
  ///
  /// In en, this message translates to:
  /// **'equals'**
  String get smartOpEquals;

  /// No description provided for @smartOpNotEquals.
  ///
  /// In en, this message translates to:
  /// **'does not equal'**
  String get smartOpNotEquals;

  /// No description provided for @smartOpGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'is greater than'**
  String get smartOpGreaterThan;

  /// No description provided for @smartOpLessThan.
  ///
  /// In en, this message translates to:
  /// **'is less than'**
  String get smartOpLessThan;

  /// No description provided for @smartOpIsTrue.
  ///
  /// In en, this message translates to:
  /// **'is true'**
  String get smartOpIsTrue;

  /// No description provided for @smartOpIsFalse.
  ///
  /// In en, this message translates to:
  /// **'is false'**
  String get smartOpIsFalse;

  /// No description provided for @smartSortTitleAZ.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get smartSortTitleAZ;

  /// No description provided for @smartSortArtistAZ.
  ///
  /// In en, this message translates to:
  /// **'Artist (A-Z)'**
  String get smartSortArtistAZ;

  /// No description provided for @smartSortDateAddedNewest.
  ///
  /// In en, this message translates to:
  /// **'Date added (newest)'**
  String get smartSortDateAddedNewest;

  /// No description provided for @smartSortPlayCountHighest.
  ///
  /// In en, this message translates to:
  /// **'Play count (highest)'**
  String get smartSortPlayCountHighest;

  /// No description provided for @smartSortDurationLongest.
  ///
  /// In en, this message translates to:
  /// **'Duration (longest)'**
  String get smartSortDurationLongest;

  /// No description provided for @smartSortRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get smartSortRandom;

  /// No description provided for @folderFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Folder Filter'**
  String get folderFilterTitle;

  /// No description provided for @artistSeparatorTestHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Artist One / Artist Two feat. Three'**
  String get artistSeparatorTestHint;

  /// No description provided for @tracksPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission to access media library is required. Please grant permissions in the onboarding or app settings.'**
  String get tracksPermissionRequired;

  /// No description provided for @tracksErrorFetching.
  ///
  /// In en, this message translates to:
  /// **'Error fetching songs: {error}'**
  String tracksErrorFetching(String error);

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @selectItemToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Select an item to view details'**
  String get selectItemToViewDetails;

  /// No description provided for @takeMeThere.
  ///
  /// In en, this message translates to:
  /// **'Take me there'**
  String get takeMeThere;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @aboutCodename.
  ///
  /// In en, this message translates to:
  /// **'Codename'**
  String get aboutCodename;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get aboutCopyright;

  /// No description provided for @aboutWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @openSourcePackages.
  ///
  /// In en, this message translates to:
  /// **'Open Source Packages'**
  String get openSourcePackages;

  /// No description provided for @packagesUsedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} packages used'**
  String packagesUsedCount(int count);

  /// No description provided for @packagesThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you to all the open source contributors!'**
  String get packagesThanks;

  /// No description provided for @versionWithCodename.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({codename})'**
  String versionWithCodename(String version, String codename);

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @exportPlaylistAs.
  ///
  /// In en, this message translates to:
  /// **'Export ({format})'**
  String exportPlaylistAs(String format);

  /// No description provided for @shareClipListeningTo.
  ///
  /// In en, this message translates to:
  /// **'LISTENING TO'**
  String get shareClipListeningTo;

  /// No description provided for @shareClipNowOn.
  ///
  /// In en, this message translates to:
  /// **'NOW ON'**
  String get shareClipNowOn;

  /// No description provided for @splashInitializingServices.
  ///
  /// In en, this message translates to:
  /// **'Initializing Services'**
  String get splashInitializingServices;

  /// No description provided for @splashLoadingLibrary.
  ///
  /// In en, this message translates to:
  /// **'Loading Library'**
  String get splashLoadingLibrary;

  /// No description provided for @splashPreparingHome.
  ///
  /// In en, this message translates to:
  /// **'Preparing Home'**
  String get splashPreparingHome;

  /// No description provided for @splashCachingArtwork.
  ///
  /// In en, this message translates to:
  /// **'Caching Artwork'**
  String get splashCachingArtwork;

  /// No description provided for @splashFinalPreparations.
  ///
  /// In en, this message translates to:
  /// **'Final Preparations'**
  String get splashFinalPreparations;

  /// No description provided for @queueHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get queueHistory;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @bannerInsightsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Music Insights Are Here ✦'**
  String get bannerInsightsNewTitle;

  /// No description provided for @bannerInsightsNewBody.
  ///
  /// In en, this message translates to:
  /// **'See your top tracks, artists & listening patterns'**
  String get bannerInsightsNewBody;

  /// No description provided for @bannerRecapTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Music Recap Awaits'**
  String get bannerRecapTitle;

  /// No description provided for @bannerRecapBody.
  ///
  /// In en, this message translates to:
  /// **'Discover your top songs and listening trends'**
  String get bannerRecapBody;

  /// No description provided for @musicalArtist.
  ///
  /// In en, this message translates to:
  /// **'Musical artist'**
  String get musicalArtist;

  /// No description provided for @eqPresetFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get eqPresetFlat;

  /// No description provided for @eqPresetBassBoost.
  ///
  /// In en, this message translates to:
  /// **'Bass Boost'**
  String get eqPresetBassBoost;

  /// No description provided for @eqPresetBassCut.
  ///
  /// In en, this message translates to:
  /// **'Bass Cut'**
  String get eqPresetBassCut;

  /// No description provided for @eqPresetTrebleBoost.
  ///
  /// In en, this message translates to:
  /// **'Treble Boost'**
  String get eqPresetTrebleBoost;

  /// No description provided for @eqPresetTrebleCut.
  ///
  /// In en, this message translates to:
  /// **'Treble Cut'**
  String get eqPresetTrebleCut;

  /// No description provided for @eqPresetRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get eqPresetRock;

  /// No description provided for @eqPresetPop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get eqPresetPop;

  /// No description provided for @eqPresetJazz.
  ///
  /// In en, this message translates to:
  /// **'Jazz'**
  String get eqPresetJazz;

  /// No description provided for @eqPresetClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get eqPresetClassical;

  /// No description provided for @eqPresetElectronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get eqPresetElectronic;

  /// No description provided for @eqPresetHipHop.
  ///
  /// In en, this message translates to:
  /// **'Hip Hop'**
  String get eqPresetHipHop;

  /// No description provided for @eqPresetRnB.
  ///
  /// In en, this message translates to:
  /// **'R&B'**
  String get eqPresetRnB;

  /// No description provided for @eqPresetVocal.
  ///
  /// In en, this message translates to:
  /// **'Vocal'**
  String get eqPresetVocal;

  /// No description provided for @eqPresetAcoustic.
  ///
  /// In en, this message translates to:
  /// **'Acoustic'**
  String get eqPresetAcoustic;

  /// No description provided for @eqPresetDance.
  ///
  /// In en, this message translates to:
  /// **'Dance'**
  String get eqPresetDance;

  /// No description provided for @eqPresetMetal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get eqPresetMetal;

  /// No description provided for @eqPresetLounge.
  ///
  /// In en, this message translates to:
  /// **'Lounge'**
  String get eqPresetLounge;

  /// No description provided for @eqPresetSpokenWord.
  ///
  /// In en, this message translates to:
  /// **'Spoken Word'**
  String get eqPresetSpokenWord;

  /// No description provided for @supportOfMonthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'of this month\'s goal'**
  String get supportOfMonthlyGoal;

  /// No description provided for @cl200Hl1.
  ///
  /// In en, this message translates to:
  /// **'Aurora Music is now Noxira Music, with a new look'**
  String get cl200Hl1;

  /// No description provided for @cl200Hl2.
  ///
  /// In en, this message translates to:
  /// **'Translate lyrics into any language, from more lyric sources'**
  String get cl200Hl2;

  /// No description provided for @cl200Hl3.
  ///
  /// In en, this message translates to:
  /// **'A redesigned home screen widget with playback controls'**
  String get cl200Hl3;

  /// No description provided for @cl200Hl4.
  ///
  /// In en, this message translates to:
  /// **'A redesigned queue'**
  String get cl200Hl4;

  /// No description provided for @cl200Hl5.
  ///
  /// In en, this message translates to:
  /// **'Choose where audio plays from the Bluetooth chip or Now Playing'**
  String get cl200Hl5;

  /// No description provided for @cl200Hl6.
  ///
  /// In en, this message translates to:
  /// **'Word-by-word lyrics when the source has the timing'**
  String get cl200Hl6;

  /// No description provided for @cl200Hl7.
  ///
  /// In en, this message translates to:
  /// **'Duplicate tracks are spotted, and you pick the copy to keep'**
  String get cl200Hl7;

  /// No description provided for @cl200Hl8.
  ///
  /// In en, this message translates to:
  /// **'Glass surfaces that adapt to your phone'**
  String get cl200Hl8;

  /// No description provided for @cl200Hl9.
  ///
  /// In en, this message translates to:
  /// **'Smoother transitions and faster detail pages'**
  String get cl200Hl9;

  /// No description provided for @cl200SecWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Noxira'**
  String get cl200SecWelcome;

  /// No description provided for @cl200SecNew.
  ///
  /// In en, this message translates to:
  /// **'New Features'**
  String get cl200SecNew;

  /// No description provided for @cl200SecLibrary.
  ///
  /// In en, this message translates to:
  /// **'Playlists & Library'**
  String get cl200SecLibrary;

  /// No description provided for @cl200SecSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get cl200SecSetup;

  /// No description provided for @cl200SecLook.
  ///
  /// In en, this message translates to:
  /// **'Look & Feel'**
  String get cl200SecLook;

  /// No description provided for @cl200SecPerf.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get cl200SecPerf;

  /// No description provided for @cl200SecHood.
  ///
  /// In en, this message translates to:
  /// **'Under the Hood'**
  String get cl200SecHood;

  /// No description provided for @cl200Welcome1.
  ///
  /// In en, this message translates to:
  /// **'Aurora Music is now Noxira Music, with a new name, wordmark and app icon'**
  String get cl200Welcome1;

  /// No description provided for @cl200Welcome2.
  ///
  /// In en, this message translates to:
  /// **'A new animated splash screen draws the Noxira wordmark'**
  String get cl200Welcome2;

  /// No description provided for @cl200Welcome3.
  ///
  /// In en, this message translates to:
  /// **'Existing users get a short welcome page explaining what is new, and you can open it again from Settings'**
  String get cl200Welcome3;

  /// No description provided for @cl200New1.
  ///
  /// In en, this message translates to:
  /// **'Translate lyrics into any language you like, not only the app languages'**
  String get cl200New1;

  /// No description provided for @cl200New2.
  ///
  /// In en, this message translates to:
  /// **'Redesigned home screen widget: glass tinted with your artwork, previous / play / next buttons that work without opening the app, and recommended songs when the widget is tall'**
  String get cl200New2;

  /// No description provided for @cl200New3.
  ///
  /// In en, this message translates to:
  /// **'Redesigned queue page — see what played and what is next, drag to reorder, swipe to remove; an Up next preview now sits on Now Playing'**
  String get cl200New3;

  /// No description provided for @cl200New4.
  ///
  /// In en, this message translates to:
  /// **'A monthly support goal appears on the home app bar from time to time, and in Settings under About'**
  String get cl200New4;

  /// No description provided for @cl200New5.
  ///
  /// In en, this message translates to:
  /// **'Pull down in the Library to refresh it'**
  String get cl200New5;

  /// No description provided for @cl200New6.
  ///
  /// In en, this message translates to:
  /// **'Choose where audio plays: tap the Bluetooth chip on the home screen, or the new output island on Now Playing, to move playback between your phone speaker and connected devices without leaving the app'**
  String get cl200New6;

  /// No description provided for @cl200New7.
  ///
  /// In en, this message translates to:
  /// **'Speed and pitch now have their own sliders, and you can link pitch to speed'**
  String get cl200New7;

  /// No description provided for @cl200New8.
  ///
  /// In en, this message translates to:
  /// **'Five new visualizer styles, and a finer spectrum with more bars'**
  String get cl200New8;

  /// No description provided for @cl200New9.
  ///
  /// In en, this message translates to:
  /// **'Optional announcements from the Noxira team can appear on the home screen, with a button that opens a link or a screen of the app'**
  String get cl200New9;

  /// No description provided for @cl200Lyrics1.
  ///
  /// In en, this message translates to:
  /// **'Redesigned lyrics page: tap a line to jump to it, dots mark instrumental breaks, and the lyrics box on Now Playing follows along'**
  String get cl200Lyrics1;

  /// No description provided for @cl200Lyrics2.
  ///
  /// In en, this message translates to:
  /// **'More lyric sources (BetterLyrics, YouLyPlus and KuGou) are tried when LRCLIB has nothing; choose which ones to use in Settings'**
  String get cl200Lyrics2;

  /// No description provided for @cl200Lyrics3.
  ///
  /// In en, this message translates to:
  /// **'Lyrics stored in the audio file, or in a .lrc file next to the song, are used first and work offline'**
  String get cl200Lyrics3;

  /// No description provided for @cl200Lyrics4.
  ///
  /// In en, this message translates to:
  /// **'Auto-hide controls on the full-screen lyrics is now an option and off by default'**
  String get cl200Lyrics4;

  /// No description provided for @cl200Lyrics5.
  ///
  /// In en, this message translates to:
  /// **'Fixed lyrics that flickered and then disappeared with “no lyrics available”, including after a refresh or a manual search'**
  String get cl200Lyrics5;

  /// No description provided for @cl200Lyrics6.
  ///
  /// In en, this message translates to:
  /// **'Word-by-word lyrics: when a source has per-word timing, each word lights up as it is sung'**
  String get cl200Lyrics6;

  /// No description provided for @cl200Library1.
  ///
  /// In en, this message translates to:
  /// **'New add-to-playlist sheet: add, remove and create playlists in one place, with songs already in a playlist marked'**
  String get cl200Library1;

  /// No description provided for @cl200Library2.
  ///
  /// In en, this message translates to:
  /// **'A song can no longer be added to the same playlist twice, and a Remove duplicates option cleans up existing ones'**
  String get cl200Library2;

  /// No description provided for @cl200Library3.
  ///
  /// In en, this message translates to:
  /// **'Noxira now notices duplicate tracks in your library and, in the Library tab, offers to review them: you pick which copy to keep'**
  String get cl200Library3;

  /// No description provided for @cl200Library4.
  ///
  /// In en, this message translates to:
  /// **'Redesigned Playlists page: Favorites on top, automatic playlists as tiles and your own playlists as a grid with artwork mosaics'**
  String get cl200Library4;

  /// No description provided for @cl200Library5.
  ///
  /// In en, this message translates to:
  /// **'Redesigned Search tab: a glass search bar, result counts and clearer empty and no-result states'**
  String get cl200Library5;

  /// No description provided for @cl200Library6.
  ///
  /// In en, this message translates to:
  /// **'The playing-song icon now follows the track in playlists'**
  String get cl200Library6;

  /// No description provided for @cl200Library7.
  ///
  /// In en, this message translates to:
  /// **'Optional online suggestions: artist info and similar artists from Deezer and Wikipedia (only the artist name is sent)'**
  String get cl200Library7;

  /// No description provided for @cl200Library8.
  ///
  /// In en, this message translates to:
  /// **'The equalizer no longer reports itself as unavailable by mistake; it retries on its own and offers Retry and Open system equalizer'**
  String get cl200Library8;

  /// No description provided for @cl200Library9.
  ///
  /// In en, this message translates to:
  /// **'Cache Information now shows real sizes, its button closes the dialog, and Clear Cache also clears downloaded artist images'**
  String get cl200Library9;

  /// No description provided for @cl200Setup1.
  ///
  /// In en, this message translates to:
  /// **'Redesigned onboarding with glass panels, entrance animations and a flowing background'**
  String get cl200Setup1;

  /// No description provided for @cl200Setup2.
  ///
  /// In en, this message translates to:
  /// **'Setup recommends the interface style that suits your phone (high-end or lightweight) and the matching background, and lets you try the other one'**
  String get cl200Setup2;

  /// No description provided for @cl200Setup3.
  ///
  /// In en, this message translates to:
  /// **'The lightweight interface now always uses a plain background; the Animated Blobs option was removed'**
  String get cl200Setup3;

  /// No description provided for @cl200Setup4.
  ///
  /// In en, this message translates to:
  /// **'Settings is now sorted into groups (Experience, Library & data, App) with the same simple glass look as setup'**
  String get cl200Setup4;

  /// No description provided for @cl200Setup5.
  ///
  /// In en, this message translates to:
  /// **'Messages appear as a small island at the bottom of the screen instead of snack bars'**
  String get cl200Setup5;

  /// No description provided for @cl200Look1.
  ///
  /// In en, this message translates to:
  /// **'New app font (Cal Sans) and slightly more compact text across the app'**
  String get cl200Look1;

  /// No description provided for @cl200Look2.
  ///
  /// In en, this message translates to:
  /// **'Frosted glass surfaces throughout, drawn as plain solid surfaces on low-end phones'**
  String get cl200Look2;

  /// No description provided for @cl200Look3.
  ///
  /// In en, this message translates to:
  /// **'Artwork flies from cards into album, artist, folder and playlist pages; pressed cards respond, liked songs burst into hearts, and the time labels roll'**
  String get cl200Look3;

  /// No description provided for @cl200Look4.
  ///
  /// In en, this message translates to:
  /// **'Rounded-square play button on Favorite Songs'**
  String get cl200Look4;

  /// No description provided for @cl200Look5.
  ///
  /// In en, this message translates to:
  /// **'Home and Library cards use the same glass look as setup, without an extra blur on top of the blurred background'**
  String get cl200Look5;

  /// No description provided for @cl200Perf1.
  ///
  /// In en, this message translates to:
  /// **'Noxira detects your phone\'s hardware and tunes glass effects, image caches and transitions to it'**
  String get cl200Perf1;

  /// No description provided for @cl200Perf2.
  ///
  /// In en, this message translates to:
  /// **'Album, artist, folder and playlist pages open smoothly: they load after the opening animation, build a short first page of songs and blur their header artwork ahead of time'**
  String get cl200Perf2;

  /// No description provided for @cl200Perf3.
  ///
  /// In en, this message translates to:
  /// **'Library queries that overlap are shared instead of repeated, which lowers memory use on big libraries'**
  String get cl200Perf3;

  /// No description provided for @cl200Perf4.
  ///
  /// In en, this message translates to:
  /// **'Faster search and library rescans, lighter image loading and less work while lists scroll'**
  String get cl200Perf4;

  /// No description provided for @cl200Hood1.
  ///
  /// In en, this message translates to:
  /// **'Fixed several crashes: tapping Close in the lyrics editor, the tag editor or the sleep timer after the page was gone, adding to the queue or setting a ringtone from a song menu, translating lyrics, and opening Noxira from the widget'**
  String get cl200Hood1;

  /// No description provided for @cl200Hood2.
  ///
  /// In en, this message translates to:
  /// **'The app no longer crashes when storage permission is missing'**
  String get cl200Hood2;

  /// No description provided for @cl200Hood3.
  ///
  /// In en, this message translates to:
  /// **'Playlists, liked songs, play counts and settings are saved safely, so an interrupted save can no longer leave an empty file'**
  String get cl200Hood3;

  /// No description provided for @cl200Hood4.
  ///
  /// In en, this message translates to:
  /// **'FLAC files whose metadata blocks were left incomplete by a tag editor are repaired when saved, so they play again'**
  String get cl200Hood4;

  /// No description provided for @cl200Hood5.
  ///
  /// In en, this message translates to:
  /// **'Media notification artwork is downscaled to avoid freezes while the notification is built'**
  String get cl200Hood5;

  /// No description provided for @cl200Hood6.
  ///
  /// In en, this message translates to:
  /// **'Editing tags on voice recordings (M4A) no longer fails because of leftover data at the end of the file'**
  String get cl200Hood6;

  /// No description provided for @cl200Hood7.
  ///
  /// In en, this message translates to:
  /// **'The visualizer no longer distorts Dolby Atmos tracks; they use the simulated animation instead'**
  String get cl200Hood7;

  /// No description provided for @cl200Hood8.
  ///
  /// In en, this message translates to:
  /// **'Phones that cannot create an equalizer effect now play normally, and the equalizer waits for the first song instead of timing out'**
  String get cl200Hood8;

  /// No description provided for @cl200Hood9.
  ///
  /// In en, this message translates to:
  /// **'Check for updates now shows its result, and says so when updates come from Google Play'**
  String get cl200Hood9;

  /// No description provided for @cl200Hood10.
  ///
  /// In en, this message translates to:
  /// **'Announcements, the support goal and some online services can be adjusted without an app update'**
  String get cl200Hood10;

  /// No description provided for @cl200Hood11.
  ///
  /// In en, this message translates to:
  /// **'Updated dependencies'**
  String get cl200Hood11;

  /// No description provided for @pkgJustAudio.
  ///
  /// In en, this message translates to:
  /// **'Feature-rich audio player for Flutter'**
  String get pkgJustAudio;

  /// No description provided for @pkgAudioService.
  ///
  /// In en, this message translates to:
  /// **'Background audio playback and media controls'**
  String get pkgAudioService;

  /// No description provided for @pkgAudioSession.
  ///
  /// In en, this message translates to:
  /// **'Audio session management for proper audio focus'**
  String get pkgAudioSession;

  /// No description provided for @pkgOnAudioQuery.
  ///
  /// In en, this message translates to:
  /// **'Query audio files from device storage'**
  String get pkgOnAudioQuery;

  /// No description provided for @pkgHaudiotagger.
  ///
  /// In en, this message translates to:
  /// **'Read and write audio metadata tags'**
  String get pkgHaudiotagger;

  /// No description provided for @pkgProvider.
  ///
  /// In en, this message translates to:
  /// **'State management solution for Flutter'**
  String get pkgProvider;

  /// No description provided for @pkgSharedPreferences.
  ///
  /// In en, this message translates to:
  /// **'Persistent key-value storage'**
  String get pkgSharedPreferences;

  /// No description provided for @pkgPathProvider.
  ///
  /// In en, this message translates to:
  /// **'Access to device file system paths'**
  String get pkgPathProvider;

  /// No description provided for @pkgPermissionHandler.
  ///
  /// In en, this message translates to:
  /// **'Handle runtime permissions'**
  String get pkgPermissionHandler;

  /// No description provided for @pkgDynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Material You dynamic color theming'**
  String get pkgDynamicColor;

  /// No description provided for @pkgPaletteGenerator.
  ///
  /// In en, this message translates to:
  /// **'Extract colors from images'**
  String get pkgPaletteGenerator;

  /// No description provided for @pkgStaggeredAnimations.
  ///
  /// In en, this message translates to:
  /// **'Staggered list animations'**
  String get pkgStaggeredAnimations;

  /// No description provided for @pkgHttp.
  ///
  /// In en, this message translates to:
  /// **'HTTP requests for API calls'**
  String get pkgHttp;

  /// No description provided for @pkgUrlLauncher.
  ///
  /// In en, this message translates to:
  /// **'Launch URLs in browser'**
  String get pkgUrlLauncher;

  /// No description provided for @pkgSharePlus.
  ///
  /// In en, this message translates to:
  /// **'Share content with other apps'**
  String get pkgSharePlus;

  /// No description provided for @pkgPackageInfoPlus.
  ///
  /// In en, this message translates to:
  /// **'Get app version and package info'**
  String get pkgPackageInfoPlus;

  /// No description provided for @pkgDeviceInfoPlus.
  ///
  /// In en, this message translates to:
  /// **'Get device information'**
  String get pkgDeviceInfoPlus;

  /// No description provided for @pkgFlutterDotenv.
  ///
  /// In en, this message translates to:
  /// **'Load environment variables from .env file'**
  String get pkgFlutterDotenv;

  /// No description provided for @pkgCrypto.
  ///
  /// In en, this message translates to:
  /// **'Cryptographic hashing functions'**
  String get pkgCrypto;

  /// No description provided for @pkgIntl.
  ///
  /// In en, this message translates to:
  /// **'Internationalization and localization'**
  String get pkgIntl;

  /// No description provided for @pkgPubSemver.
  ///
  /// In en, this message translates to:
  /// **'Semantic versioning utilities'**
  String get pkgPubSemver;

  /// No description provided for @pkgClarityFlutter.
  ///
  /// In en, this message translates to:
  /// **'Microsoft Clarity analytics'**
  String get pkgClarityFlutter;

  /// No description provided for @pkgFlutterHooks.
  ///
  /// In en, this message translates to:
  /// **'React-like hooks for Flutter'**
  String get pkgFlutterHooks;

  /// No description provided for @themeAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get themeAurora;

  /// No description provided for @themeMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themeMidnight;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get themeTeal;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// No description provided for @themeNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get themeNeon;

  /// No description provided for @themeGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get themeGold;

  /// No description provided for @themeEmber.
  ///
  /// In en, this message translates to:
  /// **'Ember'**
  String get themeEmber;

  /// No description provided for @themeRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get themeRose;

  /// No description provided for @themeSakura.
  ///
  /// In en, this message translates to:
  /// **'Sakura'**
  String get themeSakura;

  /// No description provided for @artistsCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 artist} other{{count} artists}}'**
  String artistsCountPlural(int count);

  /// No description provided for @playbackInvalidPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Invalid playlist or start index'**
  String get playbackInvalidPlaylist;

  /// No description provided for @playbackCouldNotPlayTitleSkipping.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play \"{title}\" — skipping'**
  String playbackCouldNotPlayTitleSkipping(String title);

  /// No description provided for @playbackCouldNotPlaySkipping.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play this song — skipping'**
  String get playbackCouldNotPlaySkipping;

  /// No description provided for @playbackCouldNotPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play \"{title}\"'**
  String playbackCouldNotPlayTitle(String title);

  /// No description provided for @playbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Playback failed'**
  String get playbackFailed;

  /// No description provided for @playbackSetPlaylistFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to set playlist: {error}'**
  String playbackSetPlaylistFailed(String error);

  /// No description provided for @playbackUpdatePlaylistFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update playlist: {error}'**
  String playbackUpdatePlaylistFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'cs',
        'de',
        'en',
        'es',
        'hi',
        'ru'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
