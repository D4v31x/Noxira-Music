// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aboutArtist => 'Über den Künstler';

  @override
  String get add => 'Hinzufügen';

  @override
  String get addExclusion => 'Ausschluss hinzufügen';

  @override
  String get addSeparator => 'Trennzeichen hinzufügen';

  @override
  String get addSongs => 'Songs hinzufügen';

  @override
  String get addSongsToPlaylist => 'Titel zur Wiedergabeliste hinzufügen';

  @override
  String get addToPlaylist => 'Zur Wiedergabeliste hinzufügen';

  @override
  String get adjustSync => 'Synchronisierung anpassen';

  @override
  String get album => 'Album';

  @override
  String get albums => 'Alben';

  @override
  String get allSongs => 'Alle Songs';

  @override
  String get appName => 'Noxira Music';

  @override
  String get artist => 'Künstler';

  @override
  String get artistName => 'Künstlername';

  @override
  String get artists => 'Künstler';

  @override
  String get artistSeparation => 'Trennung der Künstler';

  @override
  String get artistSeparationDesc =>
      'Konfigurieren Sie, wie mehrere Interpreten aufgeteilt werden';

  @override
  String get audioQuality => 'Audioqualität';

  @override
  String get audioQualityDesc => 'Technische Daten der Audiodatei';

  @override
  String get auroraMusic => 'Noxira Music';

  @override
  String get autoPlaylists => 'Automatische Wiedergabelisten';

  @override
  String get autoTag => 'Auto-Tag';

  @override
  String get smartPlaylists => 'Intelligente Wiedergabelisten';

  @override
  String get createSmartPlaylist => 'Intelligente Wiedergabeliste erstellen…';

  @override
  String get editSmartPlaylist => 'Intelligente Wiedergabeliste bearbeiten';

  @override
  String get smartPlaylistNameHint => 'Name der Wiedergabeliste';

  @override
  String get smartPlaylistRules => 'Regeln';

  @override
  String get addRule => 'Regel hinzufügen';

  @override
  String get saveSmartPlaylist => 'Speichern';

  @override
  String get matchAll => 'Alle Regeln erfüllen';

  @override
  String get matchAny => 'Regel „BELIEBIG“';

  @override
  String get limitResultsLabel => 'Ergebnisse einschränken';

  @override
  String get noLimit => 'Keine Begrenzung';

  @override
  String get deleteSmartPlaylistConfirm =>
      'Diese intelligente Wiedergabeliste löschen? Dadurch werden lediglich die gespeicherten Regeln entfernt – deine Titel bleiben davon unberührt.';

  @override
  String smartPlaylistPreviewCount(int count) {
    return 'Es werden derzeit $count Titel angezeigt';
  }

  @override
  String get saveAsClip => 'Als Clip speichern';

  @override
  String get generatingClip => 'Clip wird erstellt…';

  @override
  String get clipDuration => 'Dauer des Clips';

  @override
  String get clipStartOffset => 'Ausgangspunkt';

  @override
  String get saveClip => 'Clip speichern';

  @override
  String get clipSavedToDevice => 'Clip auf dem Gerät gespeichert';

  @override
  String get clipSaveFailed =>
      'Der Clip konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get playlistSavedToDevice => 'Playlist auf dem Gerät gespeichert';

  @override
  String get trackTags => 'Track-Tags';

  @override
  String get editTrackTags => 'Tags bearbeiten';

  @override
  String get addTrackTag => 'Tag hinzufügen';

  @override
  String get noTrackTagsYet =>
      'Noch keine Tags. Füge einen hinzu, um direkt zu einem bestimmten Abschnitt dieses Titels zu springen.';

  @override
  String get trackTagNameHint => 'z. B. Songtitel oder Interpret';

  @override
  String get trackTagPosition => 'Position';

  @override
  String get useCurrentPosition => 'Aktuelle Position verwenden';

  @override
  String get isThisASet => 'Zeitstempel zu diesem Titel hinzufügen';

  @override
  String get tagPartsForEasySwitching =>
      'Markieren Sie jeden beliebigen Moment – Kapitel, Höhepunkte, Lesezeichen oder was auch immer.';

  @override
  String get tagThisTrack => 'Tags hinzufügen';

  @override
  String get pasteSetlist => 'Zeitstempel importieren';

  @override
  String get pasteSetlistDialogTitle => 'Zeitstempel importieren';

  @override
  String get pasteSetlistHint =>
      'Fügen Sie hier Zeitstempel ein, z. B.\n0:00 Intro\n3:45 Kapitelbezeichnung';

  @override
  String get importAction => 'Importieren';

  @override
  String tagsImportedMessage(int count) {
    return 'Importierte $count-Tags';
  }

  @override
  String get noTagsFoundInPaste =>
      'Im eingefügten Text wurden keine Zeitstempel gefunden.';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get buyMeCoffee => 'Lade mir einen Kaffee ein';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get coffeeSupport => 'Unterstützung bei einem Kaffee';

  @override
  String get composer => 'Komponist';

  @override
  String get connectWithUs => 'Bleiben Sie mit uns in Kontakt';

  @override
  String get copied => 'Kopiert';

  @override
  String get copy => 'Kopieren';

  @override
  String get create => 'Erstellen';

  @override
  String get createFirstPlaylist =>
      'Tippe auf die Schaltfläche oben, um deine erste Wiedergabeliste zu erstellen';

  @override
  String get createPlaylist => 'Playlist erstellen';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get dateAdded => 'Hinzugefügt am';

  @override
  String get dateModified => 'Änderungsdatum';

  @override
  String get delete => 'Löschen';

  @override
  String get deletePlaylist => 'Wiedergabeliste löschen';

  @override
  String get deletePlaylistConfirm => 'Möchten Sie das wirklich löschen?';

  @override
  String get deletePlaylistConfirmation =>
      'Möchtest du diese Wiedergabeliste wirklich löschen?';

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get details => 'Details anzeigen';

  @override
  String get discard => 'Verwerfen';

  @override
  String get dontShowAgain => 'Nicht mehr anzeigen';

  @override
  String get duration => 'Dauer';

  @override
  String get enableArtistSeparation => 'Künstlertrennung aktivieren';

  @override
  String get enableArtistSeparationDesc =>
      'Kombinierte Künstlernamen automatisch trennen';

  @override
  String get enjoyingAurora => 'Gefällt dir „Noxira“?';

  @override
  String get enjoyingAuroraDesc =>
      'Wenn Ihnen Noxira Music gefällt, denken Sie doch einmal darüber nach, die Entwicklung der App zu unterstützen. Ihre Unterstützung trägt dazu bei, dass die App kostenlos bleibt!';

  @override
  String get error => 'Fehler';

  @override
  String get exclusionHint => 'z. B. AC/DC';

  @override
  String get exclusions => 'Ausschlüsse';

  @override
  String get exclusionsDesc =>
      'Künstlernamen, die niemals getrennt werden sollten';

  @override
  String get exit => 'Beenden';

  @override
  String get exitApp => 'App beenden';

  @override
  String get exitAppConfirm => 'Möchten Sie das Programm beenden?';

  @override
  String get expandLyrics => 'Songtext anzeigen';

  @override
  String get extraLarge => 'Extra groß';

  @override
  String get favoriteSongs => 'Lieblingslieder';

  @override
  String get fileInfo => 'Datei-Info';

  @override
  String get fileInfoDesc =>
      'Halten Sie die Werte gedrückt, um sie zu kopieren';

  @override
  String get fileName => 'Dateiname';

  @override
  String get filePath => 'Dateipfad';

  @override
  String get folder => 'Ordner';

  @override
  String get folders => 'Ordner';

  @override
  String get fontSize => 'Schriftgröße';

  @override
  String get format => 'Format';

  @override
  String get forYou => 'Für dich';

  @override
  String get genre => 'Genre';

  @override
  String get goodQuality => 'Gute Qualität';

  @override
  String get gotIt => 'Verstanden!';

  @override
  String get grantPermission => 'Berechtigung erteilen';

  @override
  String get highQuality => 'Hohe Qualität';

  @override
  String get home => 'Startseite';

  @override
  String get kofi => 'Ko-fi';

  @override
  String get buyMeACoffee => 'Lade mir einen Kaffee ein';

  @override
  String get donationNote =>
      'Kein Druck – du kannst jederzeit später unter „Einstellungen“ spenden.';

  @override
  String get language => 'Sprache';

  @override
  String get large => 'Groß';

  @override
  String get later => 'Später';

  @override
  String get library => 'Bibliothek';

  @override
  String get libraryError => 'Fehler beim Laden der Musikbibliothek';

  @override
  String get libraryLoaded => 'Musikbibliothek wurde geladen';

  @override
  String get libraryUpdated => 'Bibliothek aktualisiert';

  @override
  String get loading => 'Wird geladen';

  @override
  String get loadingLibrary => 'Bibliothek wird geladen';

  @override
  String get lossless => 'Verlustfrei';

  @override
  String get lowQuality => 'Geringe Qualität';

  @override
  String get lyrics => 'Songtext';

  @override
  String get lyricsAhead => 'Es folgen die Liedtexte';

  @override
  String get lyricsBehind => 'Die Liedtexte folgen';

  @override
  String get lyricsSynced => 'Die Liedtexte sind synchronisiert';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get medium => 'Mittel';

  @override
  String get metadata => 'Metadaten';

  @override
  String get metadataSaved => 'Metadaten erfolgreich gespeichert';

  @override
  String get metadataApplied => 'Metadaten wurden erfolgreich heruntergeladen';

  @override
  String get metadataDownloadFailed =>
      'Der Download ist fehlgeschlagen. Überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

  @override
  String get chooseArtworkFromDevice => 'Wählen Sie ein Gerät aus';

  @override
  String get mostPlayed => 'Am häufigsten gespielt';

  @override
  String get newPlaylist => 'Neue Wiedergabeliste';

  @override
  String get next => 'Weiter';

  @override
  String get no => 'Nein';

  @override
  String get noAlbumsFound => 'Es wurden keine Alben gefunden';

  @override
  String get noArtistInfo => 'Keine Informationen zum Künstler verfügbar';

  @override
  String get noArtistsFound => 'Es wurden keine Künstler gefunden';

  @override
  String get noData => 'Es sind keine Daten vorhanden.';

  @override
  String get noExclusions => 'Es sind keine Ausschlüsse konfiguriert';

  @override
  String get noLyrics => 'Songtext nicht verfügbar';

  @override
  String get noLyricsDesc =>
      'Wir konnten keinen Liedtext zu diesem Lied finden.';

  @override
  String get noLyricsFound => 'Es wurden keine Liedtexte gefunden';

  @override
  String get noPermissionExplanation =>
      'Ohne die entsprechenden Berechtigungen kann Noxira Music nicht auf Ihre Musikbibliothek zugreifen.';

  @override
  String get noPlaylists => 'Es sind keine Wiedergabelisten verfügbar';

  @override
  String get noResults => 'Es wurden keine Ergebnisse gefunden';

  @override
  String get noSeparators => 'Es sind keine Trennzeichen konfiguriert';

  @override
  String get noSongPlaying => 'Es wird kein Lied abgespielt';

  @override
  String get noSongsAvailable => 'Es sind keine Songs verfügbar';

  @override
  String get noSongsInPlaylist => 'Diese Wiedergabeliste enthält keine Titel';

  @override
  String get nowPlaying => 'Aktuell läuft';

  @override
  String get onboardingAlbumArtwork => 'Albumcover';

  @override
  String get onboardingAlbumArtworkDesc =>
      'Lädt hochwertige Albumcover herunter, um Ihre Mediathek aufzuwerten';

  @override
  String get onboardingAnalytics => 'Anonyme Analysen & Absturzberichte';

  @override
  String get onboardingAnalyticsDesc =>
      'Hilft uns, Fehler zu beheben und die Leistung zu verbessern. Enthält niemals Ihren Hörverlauf oder persönliche Daten.';

  @override
  String get onboardingAppInfoSubtitle => 'Dein persönlicher Musikbegleiter';

  @override
  String get onboardingAudioAccess => 'Audio-Zugriff';

  @override
  String get onboardingAudioAccessDesc =>
      'Erforderlich zum Abspielen und Verwalten Ihrer Musikbibliothek';

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get onboardingBeautifulArtwork => 'Wunderschönes Albumcover';

  @override
  String get onboardingBeautifulArtworkDesc =>
      'Albumcover automatisch abrufen und so anzeigen, wie sie eigentlich gedacht sind';

  @override
  String get onboardingBluetooth => 'Bluetooth';

  @override
  String get onboardingBluetoothDesc =>
      'Erforderlich für die Verbindung mit Bluetooth-Geräten';

  @override
  String get onboardingChooseLanguage => 'Wählen Sie Ihre Sprache';

  @override
  String get onboardingCompletionSubtitle => 'Genießen Sie Ihre Musik';

  @override
  String get onboardingCompletionTitle => 'Das war\'s schon!';

  @override
  String get onboardingContinue => 'Weiter';

  @override
  String get onboardingDynamicColors => 'Dynamische Farben';

  @override
  String get onboardingDynamicColorsDesc =>
      'Farben der Systemhintergründe anpassen';

  @override
  String get onboardingGrantPermissions => 'Berechtigungen erteilen';

  @override
  String get onboardingInternetSubtitle =>
      'Wie Noxira Music das Internet nutzt';

  @override
  String get onboardingInternetTitle => 'Internetnutzung';

  @override
  String get onboardingLocalMusic => 'Musik auf Ihrem Gerät';

  @override
  String get onboardingLocalMusicDesc => 'Ihre Musikdateien immer griffbereit';

  @override
  String get onboardingLyrics => 'Songtext';

  @override
  String get onboardingLyricsDesc =>
      'Lädt synchronisierte Songtexte für deine Lieder von LRCLIB, Better Lyrics, YouLyPlus und KuGou herunter. Diese Dienste erhalten Titel, Interpret, Album und Länge des Songs. Einzelne Quellen kannst du in den Einstellungen deaktivieren.';

  @override
  String get onboardingLyricsSupport => 'Unterstützung bei Liedtexten';

  @override
  String get onboardingLyricsSupportDesc =>
      'Synchronisierte Liedtexte beim Anhören anzeigen';

  @override
  String get onboardingMaterialDesign => 'Material You-Design';

  @override
  String get onboardingMaterialDesignDesc =>
      'Dynamische Farben, die sich Ihren Vorlieben anpassen';

  @override
  String get onboardingMusicMetadata => 'Musik-Metadaten';

  @override
  String get onboardingMusicMetadataDesc =>
      'Ruft Informationen zum Interpreten, zum Album und zu den Titeln ab';

  @override
  String get onboardingNotifications => 'Benachrichtigungen';

  @override
  String get onboardingNotificationsDesc =>
      'Wiedergabesteuerung und Aktualisierungen anzeigen';

  @override
  String get onboardingPermissionsSubtitle =>
      'Noxira Music benötigt diese Berechtigungen, um ordnungsgemäß zu funktionieren';

  @override
  String get onboardingPermissionsTitle => 'Berechtigungen erteilen';

  @override
  String get onboardingPrivacyNote =>
      'Der Schutz Ihrer Privatsphäre ist uns wichtig. Alle Musikdateien verbleiben auf Ihrem Gerät.';

  @override
  String get onboardingRequesting => 'Wird angefordert...';

  @override
  String get onboardingRequired => 'Erforderlich';

  @override
  String get onboardingAudioRequired =>
      'Um fortzufahren, ist der Zugriff auf die Audiofunktion erforderlich. Bitte erteilen Sie die oben genannte Berechtigung.';

  @override
  String get onboardingSelectLanguage =>
      'Wählen Sie Ihre bevorzugte Sprache aus';

  @override
  String get onboardingSmartPlaylists => 'Intelligente Wiedergabelisten';

  @override
  String get onboardingSmartPlaylistsDesc =>
      'Erstellen und verwalten Sie Ihre Musiksammlungen';

  @override
  String get onboardingStartListening => 'Zum Anhören';

  @override
  String get onboardingStorageAccess => 'Speicherzugriff';

  @override
  String get onboardingStorageAccessDesc =>
      'Erforderlich, um Musikdateien von Ihrem Gerät zu lesen';

  @override
  String get onboardingVisualizerAccess => 'Visualisierer';

  @override
  String get onboardingVisualizerAccessDesc =>
      'Ermöglicht es dem Visualizer, die Audiositzung Ihres Geräts für das Live-Balkenspektrum auszulesen. Es wird zu keinem Zeitpunkt Audio aufgezeichnet.';

  @override
  String get onboardingThemeSubtitle =>
      'Wähle ein Thema, das zu deinem Stil passt';

  @override
  String get onboardingThemeTitle =>
      'Gestalte deinen Look ganz nach deinen Wünschen';

  @override
  String get oneTimeSupport => 'Schnelle einmalige Unterstützung';

  @override
  String get openFolder => 'Im Dateimanager öffnen';

  @override
  String get openFolderInfo =>
      'Navigieren Sie mit Ihrem Dateimanager zu diesem Speicherort';

  @override
  String get ownTimer => 'Eigener Timer';

  @override
  String get permDeny => 'Zugriff verweigert';

  @override
  String get permissionExplanation =>
      'Noxira Music benötigt diese Berechtigungen, um ordnungsgemäß zu funktionieren. Bitte erteilen Sie die Berechtigungen in den App-Einstellungen.';

  @override
  String get permissionLater =>
      'Sie können die Berechtigungen später in den App-Einstellungen erteilen.';

  @override
  String get permissionRequired => 'Genehmigung erforderlich';

  @override
  String get playAll => 'Alle abspielen';

  @override
  String get playingFrom => 'Abspielen von';

  @override
  String get playlist => 'Wiedergabeliste';

  @override
  String get playlistName => 'Name der Wiedergabeliste';

  @override
  String get playlists => 'Playlists';

  @override
  String get possibleReasons => 'Mögliche Gründe:';

  @override
  String get privacyNotice =>
      'Wenn Sie diese App weiterhin nutzen, erklären Sie sich mit unserer Datenschutzerklärung einverstanden.';

  @override
  String get privacyPolicyLink => 'Lesen Sie unsere Datenschutzerklärung';

  @override
  String get quality => 'Qualität';

  @override
  String get queue => 'Warteschlange';

  @override
  String get queueEmpty => 'Die Warteschlange ist leer';

  @override
  String get reasonFormat =>
      'Das Dateiformat unterstützt die Bearbeitung von Metadaten nicht.';

  @override
  String get reasonPermissions => 'Speicherberechtigungen nicht erteilt';

  @override
  String get reasonReadonly =>
      'Die Datei ist schreibgeschützt oder befindet sich auf einem externen Speichermedium';

  @override
  String get recentlyAdded => 'Kürzlich hinzugefügt';

  @override
  String get recentlyPlayed => 'Zuletzt gespielt';

  @override
  String get recentlyPlayedArtists => 'Zuletzt abgespielte Künstler';

  @override
  String get recentlyPlayedSongs => 'Zuletzt abgespielte Titel';

  @override
  String get refreshing => 'Erfrischend...';

  @override
  String get refreshLyrics => 'Songtexte aktualisieren';

  @override
  String get remove => 'Entfernen';

  @override
  String get removeSong => 'Titel entfernen';

  @override
  String get removeSongConfirmation =>
      'Soll dieser Titel aus der Wiedergabeliste entfernt werden?';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renamePlaylist => 'Wiedergabeliste umbenennen';

  @override
  String get repeat => 'Wiederholen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get resetArtistSeparationDesc =>
      'Dadurch werden alle Standardtrennzeichen und Ausschlüsse wiederhergestellt.';

  @override
  String get resetToDefaults => 'Auf Standardwerte zurücksetzen';

  @override
  String get result => 'Ergebnis';

  @override
  String get results => 'Ergebnisse';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get sampleRate => 'Abtastrate';

  @override
  String get save => 'Speichern';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get saveChangesDesc => 'Möchten Sie Ihre Änderungen speichern?';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen';

  @override
  String get saveFailedDesc =>
      'Metadaten können nicht in dieser Datei gespeichert werden.';

  @override
  String get scanFailed => 'Scan fehlgeschlagen';

  @override
  String get scanningSongs => 'Songs scannen';

  @override
  String get search => 'Suche';

  @override
  String get searchAlbums => 'Alben suchen';

  @override
  String get searchArtists => 'Künstler suchen';

  @override
  String get searchFailed => 'Die Suche ist fehlgeschlagen';

  @override
  String get lyricsSource => 'Songtext-Quelle';

  @override
  String get inPlaylistHint => 'In einer Playlist';

  @override
  String get removeDuplicates => 'Duplikate entfernen';

  @override
  String get noDuplicatesFound => 'Keine doppelten Songs gefunden';

  @override
  String duplicatesRemoved(int count) {
    return '$count doppelte Songs entfernt';
  }

  @override
  String get supportNoxiraTitle => 'Unterstütze Noxira!';

  @override
  String get supportButton => 'Unterstützen';

  @override
  String supportGoalProgress(String raised, String goal) {
    return '$raised von $goal in diesem Monat';
  }

  @override
  String get onboardingSupportGoal => 'Unterstützungsziel';

  @override
  String get onboardingSupportGoalDesc =>
      'Lädt gelegentlich eine winzige öffentliche Datei mit dem Unterstützungsziel dieses Monats und dem bisher gesammelten Betrag herunter. Es ist ein einfacher Download: Nichts über dich oder deine Musik wird gesendet.';

  @override
  String get songAddedChip => 'Hinzugefügt';

  @override
  String get tapToRemove => 'Zum Entfernen tippen';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingYourLanguage => 'Deine Sprache?';

  @override
  String get onboardingAllow => 'Erlauben';

  @override
  String get onboardingSummaryLanguage => 'Sprache';

  @override
  String get onboardingSummaryTheme => 'Look';

  @override
  String get onboardingSummaryLibrary => 'Zugriff auf die Musikbibliothek';

  @override
  String get onboardingAllowed => 'Erlaubt';

  @override
  String get onboardingNotAllowed => 'Noch nicht erlaubt';

  @override
  String get searchLyrics => 'Songtexte suchen';

  @override
  String get searchMetadata => 'Metadaten durchsuchen';

  @override
  String get searchTracks => 'Titel suchen';

  @override
  String get selectAll => 'Alles auswählen';

  @override
  String get selectArtist => 'Künstler auswählen';

  @override
  String get selected => 'ausgewählt';

  @override
  String get separator => 'Trennzeichen';

  @override
  String get separatorHint => 'z. B. / oder mit';

  @override
  String get separators => 'Trennzeichen';

  @override
  String get set => 'Set';

  @override
  String get setMinutes => 'Protokoll festlegen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsAboutApp => 'Über Noxira Music';

  @override
  String get settingsAboutSubtitle => 'Version, Feedback und Updates';

  @override
  String get settingsGroupExperience => 'Erlebnis';

  @override
  String get settingsGroupLibrary => 'Bibliothek & Daten';

  @override
  String get settingsGroupApp => 'App';

  @override
  String get settingsAccentColor => 'Akzentfarbe';

  @override
  String get settingsAppearance => 'Aussehen';

  @override
  String get settingsAppearanceSubtitle => 'Thema, Farben und Layout';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsBackground => 'Hintergrund';

  @override
  String get settingsCacheCleared => 'Cache geleert';

  @override
  String get settingsCacheInfo => 'Cache-Informationen';

  @override
  String get settingsCacheInfoDesc => 'Speicherbelegung anzeigen';

  @override
  String get settingsCheckingUpdates => 'Nach Updates suchen...';

  @override
  String get settingsCheckUpdates => 'Nach Updates suchen';

  @override
  String get settingsCheckUpdatesDesc => 'Aktuelle Version herunterladen';

  @override
  String get settingsClearCache => 'Cache leeren';

  @override
  String get settingsClearCacheDesc =>
      'Alle zwischengespeicherten Daten löschen';

  @override
  String get settingsClearCacheMessage =>
      'Alle zwischengespeicherten Daten werden gelöscht und bei Bedarf neu erstellt.';

  @override
  String get settingsClearCacheTitle => 'Cache leeren?';

  @override
  String get settingsDataWindow => 'Datenfenster';

  @override
  String get settingsDataWindowDesc =>
      'Wie weit zurück der Rückblick-Bildschirm reicht';

  @override
  String get settingsGapless => 'Wiedergabe ohne Pausen';

  @override
  String get settingsGaplessDesc => 'Nahtlose Übergänge zwischen den Titeln';

  @override
  String get settingsAutomix => 'Automix';

  @override
  String get settingsAutomixDesc =>
      'Erzeugt automatisch einen nahtlosen Übergang zwischen Titeln';

  @override
  String get settingsCrossfade => 'Crossfade';

  @override
  String get settingsCrossfadeDesc =>
      'Das Ende eines Titels nahtlos in den nächsten überblenden';

  @override
  String get crossfadeDuration => 'Überblenddauer';

  @override
  String get crossfadeDurationDesc =>
      'Wie lange die Überlappung zwischen den Titeln dauert';

  @override
  String get settingsInsights => 'Einblicke';

  @override
  String get settingsInsightsSubtitle =>
      'Zusammenfassung der Hörverständnis-Phase';

  @override
  String get settingsLast7Days => 'Die letzten 7 Tage';

  @override
  String get settingsLast30Days => 'Letzte 30 Tage';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLayout => 'Layout';

  @override
  String get settingsLibraryFolders => 'Bibliotheksordner';

  @override
  String get settingsLibraryFoldersSubtitle =>
      'Scan-Ordner einbeziehen oder ausschließen';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouDesc => 'Dynamische Farben durch die Tapete';

  @override
  String get settingsMonthlyRecap => 'Monatsrückblick';

  @override
  String get settingsMonthlyRecapDesc =>
      'Jeden Monat ein Banner anzeigen (hat Vorrang vor der wöchentlichen Anzeige)';

  @override
  String get settingsNormalization => 'Lautstärkenormalisierung';

  @override
  String get settingsNormalizationDesc =>
      'Gleichmäßige Lautstärke · Erfordert ReplayGain-Tags in Ihren Dateien';

  @override
  String get playbackSpeed => 'Wiedergabegeschwindigkeit';

  @override
  String get playbackSpeedDesc => 'Wiedergabegeschwindigkeit anpassen';

  @override
  String get adjustPitchWithSpeed => 'Tonhöhe mit der Geschwindigkeit anpassen';

  @override
  String get adjustPitchWithSpeedDesc =>
      'Wenn ausgeschaltet, ändert sich das Tempo ohne Tonhöhenverschiebung';

  @override
  String get playbackPitch => 'Tonhöhe';

  @override
  String get playbackPitchDesc =>
      'Verschiebt den Klang nach oben oder unten, unabhängig vom Tempo';

  @override
  String get playbackPitchLinkedDesc => 'Folgt dem Wiedergabetempo';

  @override
  String get settingsPlayback => 'Wiedergabe';

  @override
  String get settingsPlaybackSubtitle =>
      'Geschwindigkeit, lückenlose Wiedergabe und Normalisierung';

  @override
  String get settingsRecapBannerDesc =>
      'Das Banner wird zu Beginn jeder neuen Woche oder jedes neuen Monats – gerechnet ab deinem allerersten Spiel – auf dem Startbildschirm angezeigt. Wenn du auf „Später“ tippst, wird es für diese Sitzung ausgeblendet; wenn du auf „Anzeigen“ tippst, wird es als gesehen markiert.';

  @override
  String get settingsRecapContent => 'Zusammenfassung des Inhalts';

  @override
  String get settingsRecapContentDesc =>
      'Legt fest, wie viel Verlauf auf dem Übersichtsbildschirm angezeigt wird, wenn Sie ihn manuell oder über das Banner öffnen.';

  @override
  String get settingsPreviewRecap => 'Vorschau – Rückblick';

  @override
  String get settingsPreviewRecapDesc =>
      'Sehen Sie sich an, wie Ihre Zusammenfassung mit den aktuellen Einstellungen derzeit aussieht';

  @override
  String get settingsRecapSchedule => 'Zeitplan der Zusammenfassungen';

  @override
  String get settingsStorage => 'Lagerung';

  @override
  String settingsCacheItems(String count) {
    return '$count Artikel';
  }

  @override
  String get settingsMemoryCache => 'Speicher-Cache';

  @override
  String get settingsStorageSubtitle => 'Cache- und Mediendateien';

  @override
  String get settingsTheme => 'Thema';

  @override
  String get settingsTools => 'Werkzeuge';

  @override
  String get settingsResetSetup => 'Einstellungen zurücksetzen';

  @override
  String get settingsResetSetupDesc => 'Den Onboarding-Prozess neu starten';

  @override
  String get settingsUpdateAvailable => 'Update verfügbar!';

  @override
  String get settingsUpToDate => 'Du bist auf dem neuesten Stand';

  @override
  String get settingsUpdateCheckFailed =>
      'Updates konnten nicht geprüft werden. Updates kommen über Google Play.';

  @override
  String get settingsWeeklyRecap => 'Wochenrückblick';

  @override
  String get settingsWeeklyRecapDesc =>
      'Zeige jede Woche nach dem ersten Abspielen ein Banner an';

  @override
  String get settingsVersion => 'Version';

  @override
  String get share => 'Teilen';

  @override
  String get shuffle => 'Zufallsreihenfolge';

  @override
  String get size => 'Größe';

  @override
  String get sleepTimer => 'Ausschalt-Timer';

  @override
  String get small => 'Klein';

  @override
  String get songInfo => 'Informationen zum Song';

  @override
  String get songs => 'Lieder';

  @override
  String get songsLoaded => 'Lieder wurden geladen';

  @override
  String get standardQuality => 'Standardqualität';

  @override
  String get startType => 'Beginnen Sie mit der Eingabe, um zu suchen';

  @override
  String get storagePermissionNeeded =>
      'Um Metadaten zu bearbeiten, benötigt Noxira Music die Berechtigung, Dateien zu verwalten. Bitte erteilen Sie in den Einstellungen die Berechtigung „Zugriff auf alle Dateien“.';

  @override
  String get suggestedArtists => 'Künstler für dich';

  @override
  String get suggestedTracks => 'Empfohlene Titel';

  @override
  String get supportAurora => 'Unterstütze Noxira';

  @override
  String get supportAuroraBtn => 'Unterstütze Noxira';

  @override
  String get supportAuroraDescShort => 'Hilf mit, die App kostenlos zu halten';

  @override
  String get supportAuroraMessage =>
      'Helfen Sie mit, Noxira Music kostenlos zu halten, und unterstützen Sie die weitere Entwicklung. Jeder Beitrag bedeutet uns sehr viel!';

  @override
  String get supportAuroraTitle => 'Unterstützen Sie Noxira Music';

  @override
  String get updatedTitle => 'Noxira Music wurde aktualisiert';

  @override
  String get tapAddToAddSongs => 'Tippe auf „+“, um Songs hinzuzufügen';

  @override
  String get reorderSongs => 'Songs neu anordnen';

  @override
  String get done => 'Fertig';

  @override
  String get thankYouSupport => 'Vielen Dank für Ihre Unterstützung!';

  @override
  String get theme => 'Thema';

  @override
  String get title => 'Titel';

  @override
  String get topResult => 'Top-Ergebnis';

  @override
  String get total => 'Gesamt';

  @override
  String get track => 'Titel';

  @override
  String get trackInfo => 'Titelinformationen';

  @override
  String get trackInfoDesc =>
      'Tippe auf das Bearbeitungssymbol, um die Titelinformationen zu ändern';

  @override
  String get trackInfoEditDesc =>
      'Bearbeiten Sie die untenstehenden Felder und tippen Sie anschließend auf das Häkchen-Symbol, um zu speichern';

  @override
  String get tracks => 'Titel';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get unknownArtist => 'Unbekannter Künstler';

  @override
  String get updateAvailable => 'Update verfügbar';

  @override
  String get updateMessage => 'Eine neue Version ist verfügbar';

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get viewArtist => 'Künstler anzeigen';

  @override
  String get viewDetails => 'Details anzeigen';

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get whatsNew => 'Was gibt’s Neues?';

  @override
  String get view_changelog =>
      'Änderungsprotokoll und neue Funktionen anzeigen';

  @override
  String get year => 'Jahr';

  @override
  String get yes => 'Ja';

  @override
  String get yourLibrary => 'Ihre Bibliothek';

  @override
  String get yourPlaylists => 'Deine Wiedergabelisten';

  @override
  String get homeLayout => 'Startseite – Layout';

  @override
  String get homeLayoutDesc =>
      'Reihenfolge der Abschnitte auf der Registerkarte „Startseite“ anpassen';

  @override
  String get customizeHomeTab => 'Registerkarte „Startseite“ anpassen';

  @override
  String get dragToReorder => 'Zum Neuanordnen der Abschnitte ziehen';

  @override
  String get resetToDefault => 'Auf Standardwerte zurücksetzen';

  @override
  String get resetLayoutConfirm => 'Layout auf Standard zurücksetzen?';

  @override
  String get resetLayoutMessage =>
      'Dadurch werden die ursprüngliche Reihenfolge und Sichtbarkeit der Abschnitte wiederhergestellt.';

  @override
  String get listeningHistory => 'Hörverlauf';

  @override
  String get libraryStats => 'Bibliotheksstatistiken';

  @override
  String get back => 'Zurück';

  @override
  String get continueButton => 'Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String get send_feedback => 'Feedback senden';

  @override
  String get send_feedback_desc => 'Fehler melden oder Funktionen vorschlagen';

  @override
  String get rateApp => 'Noxira Music bewerten';

  @override
  String get rateAppDesc =>
      'Gefällt dir die App? Hinterlasse eine Bewertung bei Google Play';

  @override
  String get feedbackTypeBug => 'Fehler';

  @override
  String get feedbackTypeSuggestion => 'Vorschlag';

  @override
  String get feedbackHint => 'Beschreibe den Fehler oder Vorschlag...';

  @override
  String get feedbackSend => 'Senden';

  @override
  String get feedbackSentThanks => 'Danke für dein Feedback!';

  @override
  String get feedbackSentError =>
      'Feedback konnte nicht gesendet werden. Bitte versuche es später erneut.';

  @override
  String get contributeTranslations => 'Übersetzungen beisteuern';

  @override
  String get contributeTranslationsDesc =>
      'Hilf mit, „Noxira Music“ auf Crowdin zu übersetzen';

  @override
  String get contributeTranslationsTitle => 'Helfen Sie uns beim Übersetzen';

  @override
  String get contributeTranslationsSubtitle =>
      'Dank unserer großartigen Community ist Noxira Music in mehreren Sprachen verfügbar. Hilf uns dabei, noch mehr Nutzer zu erreichen, indem du die App in deine Sprache übersetzt – der Einstieg dauert nur wenige Minuten.';

  @override
  String get contributeTranslationsOpenCrowdin => 'Crowdin öffnen';

  @override
  String get close => 'Schließen';

  @override
  String get settingsHighendUi => 'Hochwertige Benutzeroberfläche';

  @override
  String get settingsHighendUiDesc =>
      'Erweiterte visuelle Effekte und Animationen aktivieren';

  @override
  String get clearUpcoming => 'Anstehende Termine löschen';

  @override
  String get addToQueue => 'Zur Warteschlange hinzufügen';

  @override
  String get playNext => 'Als Nächstes abspielen';

  @override
  String get removeFromQueue => 'Aus der Warteschlange entfernen';

  @override
  String get play => 'Abspielen';

  @override
  String get viewAlbum => 'Album anzeigen';

  @override
  String get shuffleAll => 'Alle mischen';

  @override
  String get noSongsFound => 'Es wurden keine Lieder gefunden';

  @override
  String get noFoldersFound => 'Es wurden keine Ordner gefunden';

  @override
  String get deleteSong => 'Titel löschen';

  @override
  String get modifySystemSettingsPermission =>
      'Aktivieren Sie auf der sich öffnenden Seite die Option „Systemeinstellungen ändern“ und versuchen Sie es dann erneut.';

  @override
  String errorMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String songsAddedToQueue(int count) {
    return '$count Titel wurden zur Wiedergabeliste hinzugefügt';
  }

  @override
  String songAddedToQueue(String title) {
    return '„$title“ wurde zur Warteschlange hinzugefügt';
  }

  @override
  String songSetAsRingtone(String title) {
    return '„$title“ als Klingelton festlegen';
  }

  @override
  String failedToSetRingtone(String error) {
    return 'Das Festlegen des Klingeltons ist fehlgeschlagen: $error';
  }

  @override
  String deleteSongConfirm(String title) {
    return '„$title“ von Ihrem Gerät löschen? Dieser Vorgang kann nicht rückgängig gemacht werden.';
  }

  @override
  String songDeleted(String title) {
    return '„$title“ wurde gelöscht';
  }

  @override
  String failedToDelete(String error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String songCount(int count) {
    return '$count Lieder';
  }

  @override
  String get badgeNew => 'NEU';

  @override
  String get paused => 'Angehalten';

  @override
  String get readyToPlay => 'Bereit zum Spielen';

  @override
  String get tapSongToStartListening =>
      'Tippe auf einen Song, um ihn abzuspielen';

  @override
  String get clearCachedLyrics => 'Zwischengespeicherte Liedtexte löschen';

  @override
  String lyricsCleared(String title) {
    return 'Zwischengespeicherte Songtexte für „$title“ gelöscht';
  }

  @override
  String lyricsAdded(String title) {
    return 'Songtext für „$title“ hinzugefügt';
  }

  @override
  String get noLyricsCached =>
      'Für diesen Song wurden keine zwischengespeicherten Songtexte gefunden.';

  @override
  String get setAsRingtone => 'Als Klingelton festlegen';

  @override
  String get songInfoEdit => 'Song-Infos / Bearbeiten';

  @override
  String get goToAlbum => 'Zum Album';

  @override
  String get goToArtist => 'Zum Künstler';

  @override
  String get deleteFromDevice => 'Vom Gerät löschen';

  @override
  String get checkOutThisSong => 'Hör dir diesen Song mal an!';

  @override
  String get backgroundSolid => 'Einfarbig';

  @override
  String get backgroundHighEndStyle => 'Aktuelle Wiedergabe – Hintergrund';

  @override
  String get backgroundHighEndStyleDesc =>
      'Hintergrundstil im Bildschirm „Aktuelle Wiedergabe“';

  @override
  String get backgroundBlurredArtwork => 'Unscharfe Kunstwerke';

  @override
  String get accentColor => 'Akzentfarbe';

  @override
  String get accentColorDesc => 'Wähle die Akzentfarbe der App aus';

  @override
  String get backgroundBlur => 'Hintergrundunschärfe';

  @override
  String get backgroundBlurDesc => 'Intensität der Unschärfe des Bildes';

  @override
  String get backgroundDarkness => 'Hintergrund: Dunkelheit';

  @override
  String get backgroundDarknessDesc =>
      'Deckkraft der Überlagerung auf der Grafik';

  @override
  String get microphoneAccessNeeded => 'Zugriff auf das Mikrofon erforderlich';

  @override
  String get microphoneAccessDesc =>
      'Noxira benötigt Zugriff auf das Mikrofon, um für den Live-Visualizer auf die Audiositzung Ihres Geräts zugreifen zu können. Es werden zu keinem Zeitpunkt Audiodaten aufgezeichnet oder gespeichert.';

  @override
  String get recapWeek => 'Woche';

  @override
  String get recapMonth => 'Monat';

  @override
  String get recapPeriodWeek => 'Woche';

  @override
  String get recapPeriodMonth => 'Monat';

  @override
  String get recapWeekly => 'Wöchentlich';

  @override
  String get recapMonthly => 'Monatlich';

  @override
  String get recapIntroAppName => 'NOXIRA MUSIC';

  @override
  String recapIntroTitle(String period) {
    return 'Dein $period\nZusammenfassung';
  }

  @override
  String get recapIntroSubtitle => 'Mal sehen, was du dir\nso angehört hast.';

  @override
  String recapPlayedEyebrow(String period) {
    return 'In diesem $period hast du Musik abgespielt';
  }

  @override
  String get recapTimeSingular => 'Zeit';

  @override
  String get recapTimePlural => 'Mal';

  @override
  String get recapListenedForEyebrow => 'Du hast darauf geachtet, ob';

  @override
  String get recapListenedForLabel => 'Musik';

  @override
  String get recapTopTrackEyebrow => 'Dein beliebtester Titel';

  @override
  String get recapPlays => 'Stücke';

  @override
  String get recapTopTracksTitle => 'Top-Titel';

  @override
  String get recapTopArtistEyebrow => 'Dein Lieblingskünstler';

  @override
  String get recapTopArtistsTitle => 'Top-Künstler';

  @override
  String get recapNothingToWrap => 'Noch gibt es nichts zum Einpacken';

  @override
  String recapNothingToWrapBody(String period) {
    return 'Spiel doch ein bisschen Musik, $period, und komm dann wieder zurück.';
  }

  @override
  String get recapSwipeUp => 'NACH OBEN WISCHEN';

  @override
  String get recapYourSoundLabel => 'DEIN SOUND';

  @override
  String get recapYouListenMost => 'DU HÖRST AM MEISTEN ZU';

  @override
  String recapOnDay(String day) {
    return 'auf ${day}s';
  }

  @override
  String recapAroundTime(String time) {
    return 'etwa $time';
  }

  @override
  String get recapVibesHitDifferent =>
      'Da war die Stimmung plötzlich ganz anders.';

  @override
  String get recapThatsAWrap => 'DAS WAR\'S DANN';

  @override
  String recapInNumbers(String period) {
    return 'Dein $period\nin Zahlen';
  }

  @override
  String get recapNumberOneTrack => '#1 TITEL';

  @override
  String get recapStatTotalPlays => 'Gesamtanzahl der Wiedergaben';

  @override
  String get recapStatTimeListened => 'Hörzeit';

  @override
  String get recapStatUniqueTracks => 'Einzigartige Titel';

  @override
  String get recapStatTopArtist => 'Top-Künstler';

  @override
  String get recapDone => 'Fertig';

  @override
  String get recapWeekdayMonday => 'Montag';

  @override
  String get recapWeekdayTuesday => 'Dienstag';

  @override
  String get recapWeekdayWednesday => 'Mittwoch';

  @override
  String get recapWeekdayThursday => 'Donnerstag';

  @override
  String get recapWeekdayFriday => 'Freitag';

  @override
  String get recapWeekdaySaturday => 'Samstag';

  @override
  String get recapWeekdaySunday => 'Sonntag';

  @override
  String get recapBannerTitle => 'Hier geht’s zum Musikrückblick';

  @override
  String get recapBannerShow => 'Anzeigen';

  @override
  String get recapBannerLater => 'Später';

  @override
  String get rebrandTitle => 'Aurora heißt jetzt Noxira';

  @override
  String get rebrandSubtitle =>
      'Dieselbe Musik-App, die du kennst – mit neuem Namen, frischem Look und ein paar neuen Funktionen.';

  @override
  String get rebrandNewHeading => 'Neu';

  @override
  String get rebrandSlideLyricsTitle => 'Songtexte, neu gebaut';

  @override
  String get rebrandSlideLyricsBody =>
      'Eine neue Songtext-Seite und mehr Quellen, damit mehr Songs ihre Texte finden. Tippe auf eine Zeile, um dorthin zu springen. Songtexte lassen sich jetzt in jede beliebige Sprache übersetzen.';

  @override
  String get rebrandSlideWidgetTitle => 'Ein neues Startbildschirm-Widget';

  @override
  String get rebrandSlideWidgetBody =>
      'Glas in den Farben deines Covers und Zurück-, Play- und Weiter-Tasten, die ohne Öffnen der App funktionieren.';

  @override
  String get rebrandSlideQueueTitle => 'Eine richtige Warteschlange';

  @override
  String get rebrandSlideQueueBody =>
      'Sieh, was lief und was als Nächstes kommt. Zum Sortieren ziehen, zum Entfernen wischen.';

  @override
  String get rebrandSlideOutputTitle => 'Wähle, wo es spielt';

  @override
  String get rebrandSlideOutputBody =>
      'Tippe auf den Bluetooth-Chip auf dem Startbildschirm oder die neue Schaltfläche in der aktuellen Wiedergabe, um die Wiedergabe direkt in der App zwischen Handylautsprecher und verbundenen Geräten zu wechseln.';

  @override
  String get rebrandSlideLibraryTitle => 'Eine aufgeräumtere Bibliothek';

  @override
  String get rebrandSlideLibraryBody =>
      'Noxira erkennt doppelte Titel und lässt dich wählen, welche Kopie bleibt. Playlists haben ein neues Layout mit Favoriten sowie automatischen und intelligenten Playlists an einem Ort.';

  @override
  String get rebrandMoreMessages =>
      'Meldungen erscheinen jetzt als kleine Insel am unteren Bildschirmrand.';

  @override
  String get rebrandMorePerformance =>
      'Schnellere Suche, ein flotterer Start und leichteres Laden von Bildern.';

  @override
  String get translateLyricsTo => 'Songtext übersetzen in';

  @override
  String get translateLyricsAppLanguage => 'App-Sprache';

  @override
  String get translateLyricsChooseLanguage => 'Sprache wählen…';

  @override
  String get rebrandSlideMoreTitle => 'Und noch ein paar Dinge';

  @override
  String get rebrandMoreSetup =>
      'Die Einrichtung empfiehlt jetzt den passenden Modus für dein Handy.';

  @override
  String get rebrandMoreLook =>
      'Ein ruhigerer Support-Banner, ein abgerundeter Play-Button bei Lieblingssongs und Songtext-Steuerung, die nicht mehr verschwindet.';

  @override
  String get rebrandMoreMotion =>
      'Flüssigere, schönere Übergänge in der ganzen App.';

  @override
  String get rebrandMorePlayback =>
      'Getrennte Regler für Tempo und Tonhöhe, die sich koppeln lassen.';

  @override
  String get rebrandMoreSearch =>
      'Ein neu gestalteter Suchen-Tab und eine nach Gruppen sortierte Einstellungsseite.';

  @override
  String get rebrandMoreFixes =>
      'Stabilität und Fehlerbehebungen in der ganzen App, darunter flackernde Songtexte.';

  @override
  String get eqTitle => 'Equalizer';

  @override
  String get eqOn => 'EIN';

  @override
  String get eqOff => 'AUS';

  @override
  String get eqNotAvailable =>
      'Der Equalizer ist auf diesem Gerät nicht verfügbar.';

  @override
  String get eqWaitingForAudio =>
      'Starte einen Song, um den Equalizer anzupassen.';

  @override
  String get eqOpenSystem => 'Offener System-Equalizer';

  @override
  String get eqSavePreset => 'Voreinstellung speichern';

  @override
  String get eqPresetNameHint => 'z. B. „My Bass Boost“';

  @override
  String get eqPresetNameEmpty => 'Der Name darf nicht leer sein.';

  @override
  String eqPresetNameBuiltIn(String name) {
    return '„$name“ ist der Name einer integrierten Voreinstellung.';
  }

  @override
  String get eqResetAllBands => 'Alle Frequenzbänder zurücksetzen';

  @override
  String get eqPresetsLabel => 'VOREINSTELLUNGEN';

  @override
  String get eqYourPresetsLabel => 'IHRE VOREINSTELLUNGEN';

  @override
  String get eqSaveCurrent => 'Aktuellen Stand speichern';

  @override
  String get eqSettingsSubtitle => 'Audiofrequenzen pro Frequenzband anpassen';

  @override
  String get eqEmptyPresets =>
      'Stelle deinen Sound ein und tippe anschließend auf „Aktuellen Sound speichern“.';

  @override
  String get lyricsHint =>
      'Füge hier die nicht synchronisierten Songtexte ein…\n\nEine Zeile pro Verszeile.';

  @override
  String get lyricsSelectLrcFile => 'Bitte wählen Sie eine .lrc-Datei aus';

  @override
  String get lyricsNoLyricsInFile =>
      'In dieser Datei wurden keine Liedtexte gefunden';

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get lyricsImportTooltip => '.lrc-Datei importieren';

  @override
  String get importPlaylistM3u => 'Wiedergabeliste importieren (.m3u)';

  @override
  String get setSyncFolder => 'Synchronisierungsordner festlegen…';

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get searchPlaylists => 'Playlists suchen…';

  @override
  String get pleaseSelectM3uFile =>
      'Bitte wählen Sie eine .m3u- oder .m3u8-Datei aus';

  @override
  String get noMatchingSongsForPlaylist =>
      'Für diese Wiedergabeliste wurden keine passenden Titel gefunden.';

  @override
  String importedPlaylist(String name, int count) {
    return '„$name“ importiert ($count Titel)';
  }

  @override
  String playlistsSyncWith(String folder) {
    return 'Die Wiedergabelisten werden mit $folder synchronisiert.';
  }

  @override
  String couldNotSetSyncFolder(String error) {
    return 'Der Synchronisierungsordner konnte nicht festgelegt werden: $error';
  }

  @override
  String get setSyncFolderFirst =>
      'Legen Sie zunächst einen Synchronisierungsordner fest';

  @override
  String get playlistsSynced => 'Playlists synchronisiert';

  @override
  String get alreadyUpToDate => 'Bereits auf dem neuesten Stand';

  @override
  String syncFailed(String error) {
    return 'Synchronisierung fehlgeschlagen: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get searchFolders => 'Suchordner…';

  @override
  String get songInfoPath => 'Pfad';

  @override
  String get closeVisualiser => 'Visualisierung schließen';

  @override
  String get visualizerWaitingForAudio => 'Warte auf Wiedergabe-Audio...';

  @override
  String get visualizerUnavailable =>
      'Für diese Ausgabe ist keine Live-Audioanalyse verfügbar.';

  @override
  String get previousMode => 'Vorheriger Modus';

  @override
  String get nextMode => 'Nächster Modus';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get colorTheme => 'Farbschema';

  @override
  String get insightsTotalPlays => 'Gesamt\nAufrufe';

  @override
  String get insightsTracksHeard => 'Titel\nGehört';

  @override
  String get insightsEstListening => 'Geschätzt.\nZuhören';

  @override
  String get dismiss => 'Schließen';

  @override
  String updateVersionAvailable(String version) {
    return 'Version $version ist jetzt verfügbar.';
  }

  @override
  String get updateNewVersionAvailable =>
      'Eine neue Version ist nun verfügbar.';

  @override
  String get lyricsPasteLyricsTitle => 'Songtext einfügen';

  @override
  String get lyricsUseLyrics => 'Songtexte verwenden';

  @override
  String get lyricsPaste => 'Einfügen';

  @override
  String get lyricsNoLyricsYet => 'Noch kein Liedtext';

  @override
  String get lyricsPasteToGetStarted => 'Füge den Liedtext ein, um loszulegen';

  @override
  String get lyricsNoTimestampsYet =>
      'Noch keine Zeitstempel – tippe während der Wiedergabe auf die Stempel-Schaltfläche.';

  @override
  String get lyricsAllLinesStampedHint =>
      'Alle Zeilen sind markiert – tippe auf „Speichern“, um den Vorgang abzuschließen.';

  @override
  String get lyricsAllStamped => '✓  Alle Zeilen abgestempelt';

  @override
  String get lyricsPasteFirst => 'Füge zuerst den Liedtext ein';

  @override
  String lyricsTapToStamp(int current, int total) {
    return '⏱  AUF DIE ZEILE $current / $total TIPPEN, UM SIE ZU STAMPFEN';
  }

  @override
  String get lyricsNextLabel => 'Weiter';

  @override
  String get translationDisclaimerNote =>
      'Einige Übersetzungen sind KI-generiert oder von der Community beigesteuert und können Fehler enthalten. Hilf uns, sie auf Crowdin zu verbessern.';

  @override
  String get newLanguagesAvailableTitle => 'Neue Sprachen verfügbar';

  @override
  String get newLanguagesAvailableBody =>
      'Noxira Music unterstützt jetzt Deutsch, Spanisch, Hindi und Russisch. Du kannst deine Sprache in den Einstellungen ändern.';

  @override
  String get newLanguagesGoToSettings => 'Sprache ändern';

  @override
  String get newLanguagesDismiss => 'Verstanden';

  @override
  String get settingsLyricsSources => 'Songtext-Quellen';

  @override
  String get lyricsProviderDesc =>
      'Wird verwendet, wenn LRCLIB keine Texte hat. Erhält Titel, Interpret, Album und Länge.';

  @override
  String get onlineAboutArtist => 'Info';

  @override
  String get onlineFansAlsoLike => 'Fans mögen auch';

  @override
  String get onlinePopularTracks => 'Gerade beliebt';

  @override
  String get onlineReadMore => 'Mehr lesen';

  @override
  String get onlineBioDisclaimer =>
      'Automatisch aus öffentlichen Quellen zusammengetragen. Keine Gewähr für Richtigkeit.';

  @override
  String get onlineShowLess => 'Weniger anzeigen';

  @override
  String get onlineWikipedia => 'Wikipedia';

  @override
  String onlineFansCount(String count) {
    return '$count Fans';
  }

  @override
  String get settingsOnlineSuggestions => 'Online-Vorschläge';

  @override
  String get settingsOnlineSuggestionsDesc =>
      'Künstlerinfos und ähnliche Künstler von Deezer und Wikipedia abrufen. Es wird nur der Künstlername gesendet.';

  @override
  String get onboardingUiModeTitle => 'Oberflächenstil';

  @override
  String get onboardingUiModeDesc =>
      'Wie viel Glas und Animation die App nutzt';

  @override
  String get onboardingUiHighEnd => 'High-End';

  @override
  String get onboardingUiLowEnd => 'Schlank';

  @override
  String get onboardingRecommendedBadge => 'Empfohlen';

  @override
  String get onboardingRecommendedForDevice => 'Für dein Gerät empfohlen.';

  @override
  String onboardingTryNote(String recommended, String selected) {
    return 'Nach den technischen Daten deines Geräts empfehlen wir $recommended, aber du kannst gern $selected ausprobieren.';
  }

  @override
  String onboardingHeaviestNote(String option) {
    return '$option ist die aufwendigste Option und läuft auf deinem Gerät eventuell weniger flüssig.';
  }

  @override
  String get audioOutput => 'Audioausgabe';

  @override
  String get audioOutputBluetoothDevice => 'Bluetooth-Gerät';

  @override
  String get audioOutputPhoneSpeaker => 'Handylautsprecher';

  @override
  String get audioOutputWired => 'Kabelgebundene Kopfhörer';

  @override
  String get audioOutputUsb => 'USB-Audio';

  @override
  String get audioOutputOther => 'Andere Ausgabe';

  @override
  String get audioOutputNoOthers => 'Keine weiteren Geräte gefunden';

  @override
  String get audioOutputCurrentDevice => 'Aktuelles Gerät';

  @override
  String get audioOutputSwitchFailed =>
      'Die Audioausgabe konnte nicht gewechselt werden';

  @override
  String get duplicatesBannerTitle => 'Doppelte Titel gefunden';

  @override
  String duplicatesBannerSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel sind mehrfach vorhanden',
      one: '1 Titel ist mehrfach vorhanden',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesReview => 'Prüfen';

  @override
  String get duplicatesScreenTitle => 'Doppelte Titel';

  @override
  String get duplicatesEmpty => 'Keine Duplikate gefunden';

  @override
  String get duplicatesIgnore => 'Ignorieren';

  @override
  String get duplicatesIgnoreAll => 'Alle ignorieren';

  @override
  String get duplicatesKeepBest => 'Beste Qualität';

  @override
  String duplicatesCopies(int count) {
    return '$count Kopien';
  }

  @override
  String duplicatesDeleteOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ausgewählte behalten, $count weitere löschen',
      one: 'Ausgewählte behalten, 1 weitere löschen',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesDeleteFailed =>
      'Einige Kopien konnten nicht gelöscht werden';

  @override
  String get duplicatesResolved => 'Duplikate entfernt';

  @override
  String get duplicatesHint =>
      'Wähle die Kopie, die bleiben soll. Die anderen werden von deinem Gerät gelöscht.';

  @override
  String get remoteAnnouncementOpenLink => 'Mehr erfahren';

  @override
  String get remoteAnnouncementOpenScreen => 'Öffnen';

  @override
  String get updateRequiredTitle => 'Update erforderlich';

  @override
  String get updateRequiredMessage =>
      'Diese Version wird nicht mehr unterstützt. Bitte aktualisiere Noxira Music, um es weiter zu nutzen.';

  @override
  String get settingsSupport => 'Unterstützen';

  @override
  String get settingsSupportSubtitle =>
      'Unterstützer und Möglichkeiten zu helfen';

  @override
  String get supportSupporters => 'Unterstützer';

  @override
  String get supportNoSupportersYet =>
      'Noch keine Unterstützer gelistet. Sei der Erste!';

  @override
  String get musicInsightsTitle => 'Musik-Einblicke';

  @override
  String get insightsActivityByTimeOfDay => 'Aktivität nach Tageszeit';

  @override
  String get insightsActivityByDay => 'Aktivität nach Wochentag';

  @override
  String get insightsGenreBreakdown => 'Genre-Verteilung';

  @override
  String get insightsNoDataTitle => 'Noch keine Hördaten';

  @override
  String get insightsNoDataBody =>
      'Spiele etwas Musik ab, um deine Einblicke aufzubauen.';

  @override
  String insightsMostActiveAround(String time) {
    return 'Am aktivsten gegen $time';
  }

  @override
  String insightsMostActiveOn(String day) {
    return 'Am aktivsten am $day';
  }

  @override
  String moreFromArtist(String artist) {
    return 'Mehr von $artist';
  }

  @override
  String tracksCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
    );
    return '$_temp0';
  }

  @override
  String songsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lieder',
      one: '1 Lied',
    );
    return '$_temp0';
  }

  @override
  String albumsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Alben',
      one: '1 Album',
    );
    return '$_temp0';
  }

  @override
  String playlistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Playlists',
      one: '1 Playlist',
    );
    return '$_temp0';
  }

  @override
  String foldersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ordner',
      one: '1 Ordner',
    );
    return '$_temp0';
  }

  @override
  String foldersExcludedCount(int count) {
    return '$count ausgeschlossen';
  }

  @override
  String get unknownAlbum => 'Unbekanntes Album';

  @override
  String get queueNextUp => 'Als Nächstes';

  @override
  String queueNextFrom(String source) {
    return 'Als Nächstes aus $source';
  }

  @override
  String get queueNothingElse => 'Nichts weiter in der Warteschlange';

  @override
  String get queueMoveToEnd => 'Ans Ende verschieben';

  @override
  String get translateLyrics => 'Songtext übersetzen';

  @override
  String get translateFailedTapToRetry =>
      'Übersetzung fehlgeschlagen – zum Wiederholen tippen';

  @override
  String get translateShowOriginal => 'Original anzeigen';

  @override
  String get translateShowTranslation => 'Übersetzung anzeigen';

  @override
  String get lyricsAiTranslatedNote =>
      'KI-übersetzt · Genauigkeit kann abweichen';

  @override
  String lyricsCantTranslateSameLanguage(String language) {
    return 'Übersetzung nicht möglich – der Songtext liegt bereits in der Zielsprache vor ($language)';
  }

  @override
  String get lyricsAddLyrics => 'Songtext hinzufügen';

  @override
  String get lyricsBlurOn => 'Songtext-Unschärfe: an';

  @override
  String get lyricsBlurOff => 'Songtext-Unschärfe: aus';

  @override
  String get lyricsAutoHideOn => 'Steuerung automatisch ausblenden: an';

  @override
  String get lyricsAutoHideOff => 'Steuerung automatisch ausblenden: aus';

  @override
  String get lyricsEditCreate => 'Songtext bearbeiten / erstellen';

  @override
  String get sleepTimerMinShort => 'Min.';

  @override
  String sleepTimerMinutesValue(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get sleepTimerMusicStopsAfter => 'Musik stoppt nach…';

  @override
  String get sleepTimerPickDuration => 'Wähle unten eine Dauer';

  @override
  String get visualizerBarSpectrum => 'Balkenspektrum';

  @override
  String get visualizerCircularBars => 'Kreisbalken';

  @override
  String get visualizerMirrorBars => 'Spiegelbalken';

  @override
  String get visualizerFrequencyLine => 'Frequenzlinie';

  @override
  String get visualizerDotMatrix => 'Punktmatrix';

  @override
  String get visualizerPeakBars => 'Spitzenbalken';

  @override
  String get visualizerCircularWave => 'Kreiswelle';

  @override
  String get visualizerAuroraWaves => 'Polarlichtwellen';

  @override
  String get visualizerPulseRings => 'Pulsringe';

  @override
  String get smartFieldFolderPath => 'Ordnerpfad';

  @override
  String get smartFieldLiked => 'Gefällt mir';

  @override
  String get smartFieldPlayCount => 'Anzahl Wiedergaben';

  @override
  String get smartFieldDurationSeconds => 'Dauer (Sekunden)';

  @override
  String get smartFieldDaysSinceAdded => 'Tage seit Hinzufügen';

  @override
  String get smartOpContains => 'enthält';

  @override
  String get smartOpNotContains => 'enthält nicht';

  @override
  String get smartOpEquals => 'ist gleich';

  @override
  String get smartOpNotEquals => 'ist nicht gleich';

  @override
  String get smartOpGreaterThan => 'ist größer als';

  @override
  String get smartOpLessThan => 'ist kleiner als';

  @override
  String get smartOpIsTrue => 'ist wahr';

  @override
  String get smartOpIsFalse => 'ist falsch';

  @override
  String get smartSortTitleAZ => 'Titel (A–Z)';

  @override
  String get smartSortArtistAZ => 'Künstler (A–Z)';

  @override
  String get smartSortDateAddedNewest => 'Hinzugefügt am (neueste)';

  @override
  String get smartSortPlayCountHighest => 'Wiedergaben (meiste)';

  @override
  String get smartSortDurationLongest => 'Dauer (längste)';

  @override
  String get smartSortRandom => 'Zufällig';

  @override
  String get folderFilterTitle => 'Ordnerfilter';

  @override
  String get artistSeparatorTestHint =>
      'z. B. Künstler Eins / Künstler Zwei feat. Drei';

  @override
  String get tracksPermissionRequired =>
      'Der Zugriff auf die Medienbibliothek muss erlaubt werden. Bitte erteile die Berechtigung in der Einrichtung oder in den App-Einstellungen.';

  @override
  String tracksErrorFetching(String error) {
    return 'Fehler beim Laden der Songs: $error';
  }

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get selectItemToViewDetails =>
      'Wähle ein Element, um Details anzuzeigen';

  @override
  String get takeMeThere => 'Bring mich hin';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get aboutCodename => 'Codename';

  @override
  String get aboutDeveloper => 'Entwickler';

  @override
  String get aboutCopyright => 'Urheberrecht';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get openSourcePackages => 'Open-Source-Pakete';

  @override
  String packagesUsedCount(int count) {
    return '$count verwendete Pakete';
  }

  @override
  String get packagesThanks => 'Danke an alle Open-Source-Mitwirkenden!';

  @override
  String versionWithCodename(String version, String codename) {
    return 'Version $version ($codename)';
  }

  @override
  String get customColor => 'Eigene Farbe';

  @override
  String exportPlaylistAs(String format) {
    return 'Exportieren ($format)';
  }

  @override
  String get shareClipListeningTo => 'ICH HÖRE';

  @override
  String get shareClipNowOn => 'JETZT AUF';

  @override
  String get splashInitializingServices => 'Dienste werden initialisiert';

  @override
  String get splashLoadingLibrary => 'Bibliothek wird geladen';

  @override
  String get splashPreparingHome => 'Startseite wird vorbereitet';

  @override
  String get splashCachingArtwork => 'Cover werden zwischengespeichert';

  @override
  String get splashFinalPreparations => 'Letzte Vorbereitungen';

  @override
  String get queueHistory => 'Verlauf';

  @override
  String get sortName => 'Name';

  @override
  String get bannerInsightsNewTitle => 'Deine Musik-Einblicke sind da ✦';

  @override
  String get bannerInsightsNewBody =>
      'Sieh dir deine Top-Titel, Künstler und Hörgewohnheiten an';

  @override
  String get bannerRecapTitle => 'Dein Musik-Rückblick wartet';

  @override
  String get bannerRecapBody => 'Entdecke deine Top-Songs und Hörtrends';

  @override
  String get musicalArtist => 'Musiker';

  @override
  String get eqPresetFlat => 'Flach';

  @override
  String get eqPresetBassBoost => 'Bass-Boost';

  @override
  String get eqPresetBassCut => 'Bass-Absenkung';

  @override
  String get eqPresetTrebleBoost => 'Höhen-Boost';

  @override
  String get eqPresetTrebleCut => 'Höhen-Absenkung';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetClassical => 'Klassik';

  @override
  String get eqPresetElectronic => 'Elektronisch';

  @override
  String get eqPresetHipHop => 'Hip-Hop';

  @override
  String get eqPresetRnB => 'R&B';

  @override
  String get eqPresetVocal => 'Gesang';

  @override
  String get eqPresetAcoustic => 'Akustisch';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetMetal => 'Metal';

  @override
  String get eqPresetLounge => 'Lounge';

  @override
  String get eqPresetSpokenWord => 'Gesprochenes Wort';

  @override
  String get supportOfMonthlyGoal => 'des Monatsziels';

  @override
  String get cl200Hl1 =>
      'Aurora Music heißt jetzt Noxira Music – mit neuem Look';

  @override
  String get cl200Hl2 =>
      'Songtexte in jede Sprache übersetzen, aus mehr Songtext-Quellen';

  @override
  String get cl200Hl3 =>
      'Ein neu gestaltetes Homescreen-Widget mit Wiedergabesteuerung';

  @override
  String get cl200Hl4 => 'Eine neu gestaltete Warteschlange';

  @override
  String get cl200Hl5 =>
      'Wähle über den Bluetooth-Chip oder die aktuelle Wiedergabe, wo der Ton abgespielt wird';

  @override
  String get cl200Hl6 =>
      'Wort-für-Wort-Songtexte, wenn die Quelle das Timing liefert';

  @override
  String get cl200Hl7 =>
      'Doppelte Titel werden erkannt – du wählst, welche Kopie bleibt';

  @override
  String get cl200Hl8 => 'Glasflächen, die sich an dein Handy anpassen';

  @override
  String get cl200Hl9 => 'Flüssigere Übergänge und schnellere Detailseiten';

  @override
  String get cl200SecWelcome => 'Willkommen bei Noxira';

  @override
  String get cl200SecNew => 'Neue Funktionen';

  @override
  String get cl200SecLibrary => 'Playlists & Bibliothek';

  @override
  String get cl200SecSetup => 'Einrichtung';

  @override
  String get cl200SecLook => 'Look & Feel';

  @override
  String get cl200SecPerf => 'Leistung';

  @override
  String get cl200SecHood => 'Unter der Haube';

  @override
  String get cl200Welcome1 =>
      'Aurora Music heißt jetzt Noxira Music, mit neuem Namen, Schriftzug und App-Symbol';

  @override
  String get cl200Welcome2 =>
      'Ein neuer animierter Startbildschirm zeichnet den Noxira-Schriftzug';

  @override
  String get cl200Welcome3 =>
      'Bestehende Nutzer sehen eine kurze Willkommensseite mit den Neuerungen, die sich in den Einstellungen erneut öffnen lässt';

  @override
  String get cl200New1 =>
      'Übersetze Songtexte in jede beliebige Sprache, nicht nur in die App-Sprachen';

  @override
  String get cl200New2 =>
      'Neu gestaltetes Homescreen-Widget: Glas in den Farben deines Covers, Zurück-/Play-/Weiter-Tasten, die ohne Öffnen der App funktionieren, und empfohlene Songs, wenn das Widget hoch ist';

  @override
  String get cl200New3 =>
      'Neu gestaltete Warteschlange – sieh, was lief und was als Nächstes kommt, ziehe zum Sortieren, wische zum Entfernen; eine „Als Nächstes“-Vorschau erscheint jetzt in der aktuellen Wiedergabe';

  @override
  String get cl200New4 =>
      'Ein monatliches Unterstützungsziel erscheint von Zeit zu Zeit in der Startleiste und in den Einstellungen unter „Info“';

  @override
  String get cl200New5 =>
      'Ziehe in der Bibliothek nach unten, um sie zu aktualisieren';

  @override
  String get cl200New6 =>
      'Wähle, wo der Ton abgespielt wird: Tippe auf den Bluetooth-Chip auf dem Startbildschirm oder die neue Ausgabe-Insel in der aktuellen Wiedergabe, um die Wiedergabe zwischen Handylautsprecher und verbundenen Geräten zu wechseln, ohne die App zu verlassen';

  @override
  String get cl200New7 =>
      'Tempo und Tonhöhe haben jetzt eigene Regler, und du kannst die Tonhöhe an das Tempo koppeln';

  @override
  String get cl200New8 =>
      'Fünf neue Visualizer-Stile und ein feineres Spektrum mit mehr Balken';

  @override
  String get cl200New9 =>
      'Optionale Ankündigungen des Noxira-Teams können auf dem Startbildschirm erscheinen, mit einer Schaltfläche, die einen Link oder einen Bildschirm der App öffnet';

  @override
  String get cl200Lyrics1 =>
      'Neu gestaltete Songtext-Seite: Tippe auf eine Zeile, um dorthin zu springen, Punkte markieren instrumentale Pausen, und das Songtext-Feld in der aktuellen Wiedergabe läuft mit';

  @override
  String get cl200Lyrics2 =>
      'Weitere Songtext-Quellen (BetterLyrics, YouLyPlus und KuGou) werden ausprobiert, wenn LRCLIB nichts hat; in den Einstellungen wählst du, welche genutzt werden';

  @override
  String get cl200Lyrics3 =>
      'Songtexte in der Audiodatei oder in einer .lrc-Datei neben dem Song werden zuerst verwendet und funktionieren offline';

  @override
  String get cl200Lyrics4 =>
      'Das automatische Ausblenden der Steuerung im Vollbild-Songtext ist jetzt eine Option und standardmäßig aus';

  @override
  String get cl200Lyrics5 =>
      'Behoben: Songtexte, die flackerten und dann mit „Kein Songtext verfügbar“ verschwanden, auch nach einer Aktualisierung oder manuellen Suche';

  @override
  String get cl200Lyrics6 =>
      'Wort-für-Wort-Songtexte: Hat eine Quelle Timing pro Wort, leuchtet jedes Wort auf, während es gesungen wird';

  @override
  String get cl200Library1 =>
      'Neues Blatt zum Hinzufügen zu Playlists: Playlists an einem Ort hinzufügen, entfernen und erstellen, Songs, die schon in einer Playlist sind, sind markiert';

  @override
  String get cl200Library2 =>
      'Ein Song lässt sich nicht mehr zweimal zur selben Playlist hinzufügen, und die Option „Duplikate entfernen“ räumt vorhandene auf';

  @override
  String get cl200Library3 =>
      'Noxira erkennt jetzt doppelte Titel in deiner Bibliothek und bietet im Bibliothek-Tab an, sie zu prüfen: Du wählst, welche Kopie bleibt';

  @override
  String get cl200Library4 =>
      'Neu gestaltete Playlist-Seite: Favoriten oben, automatische Playlists als Kacheln und deine eigenen Playlists als Raster mit Cover-Mosaiken';

  @override
  String get cl200Library5 =>
      'Neu gestalteter Suchen-Tab: eine gläserne Suchleiste, Ergebniszahlen und klarere Zustände ohne Treffer';

  @override
  String get cl200Library6 =>
      'Das Symbol für den laufenden Song folgt dem Titel jetzt in Playlists';

  @override
  String get cl200Library7 =>
      'Optionale Online-Vorschläge: Künstlerinfos und ähnliche Künstler von Deezer und Wikipedia (es wird nur der Künstlername gesendet)';

  @override
  String get cl200Library8 =>
      'Der Equalizer meldet sich nicht mehr fälschlich als nicht verfügbar; er versucht es selbst erneut und bietet „Erneut versuchen“ und „System-Equalizer öffnen“';

  @override
  String get cl200Library9 =>
      'Cache-Informationen zeigen jetzt echte Größen, die Schaltfläche schließt den Dialog, und „Cache leeren“ löscht auch heruntergeladene Künstlerbilder';

  @override
  String get cl200Setup1 =>
      'Neu gestaltete Einrichtung mit Glasflächen, Einblendanimationen und fließendem Hintergrund';

  @override
  String get cl200Setup2 =>
      'Die Einrichtung empfiehlt den Oberflächenstil, der zu deinem Handy passt (High-End oder schlank), samt passendem Hintergrund, und lässt dich den anderen ausprobieren';

  @override
  String get cl200Setup3 =>
      'Die schlanke Oberfläche nutzt jetzt immer einen einfachen Hintergrund; die Option „Animierte Blobs“ wurde entfernt';

  @override
  String get cl200Setup4 =>
      'Die Einstellungen sind jetzt in Gruppen sortiert (Erlebnis, Bibliothek & Daten, App) – im gleichen schlichten Glaslook wie die Einrichtung';

  @override
  String get cl200Setup5 =>
      'Meldungen erscheinen als kleine Insel am unteren Bildschirmrand statt als Snackbars';

  @override
  String get cl200Look1 =>
      'Neue App-Schrift (Cal Sans) und etwas kompakterer Text in der ganzen App';

  @override
  String get cl200Look2 =>
      'Milchglas-Flächen überall, auf schwächeren Handys als einfache, deckende Flächen gezeichnet';

  @override
  String get cl200Look3 =>
      'Cover fliegen von Karten auf Album-, Künstler-, Ordner- und Playlist-Seiten; gedrückte Karten reagieren, geliebte Songs lassen Herzen platzen, und die Zeitangaben rollen';

  @override
  String get cl200Look4 =>
      'Abgerundeter quadratischer Play-Button bei den Lieblingssongs';

  @override
  String get cl200Look5 =>
      'Start- und Bibliothekskarten haben denselben Glaslook wie die Einrichtung, ohne zusätzliche Unschärfe über dem unscharfen Hintergrund';

  @override
  String get cl200Perf1 =>
      'Noxira erkennt die Hardware deines Handys und passt Glaseffekte, Bild-Caches und Übergänge daran an';

  @override
  String get cl200Perf2 =>
      'Album-, Künstler-, Ordner- und Playlist-Seiten öffnen flüssig: Sie laden nach der Öffnungsanimation, bauen eine kurze erste Songseite auf und verwischen ihr Kopf-Cover vorab';

  @override
  String get cl200Perf3 =>
      'Überlappende Bibliotheksabfragen werden geteilt statt wiederholt, was den Speicherbedarf bei großen Bibliotheken senkt';

  @override
  String get cl200Perf4 =>
      'Schnellere Suche und Bibliotheks-Scans, leichteres Laden von Bildern und weniger Arbeit beim Scrollen von Listen';

  @override
  String get cl200Hood1 =>
      'Mehrere Abstürze behoben: Tippen auf „Schließen“ im Songtext-Editor, im Tag-Editor oder im Schlaf-Timer, nachdem die Seite weg war, Hinzufügen zur Warteschlange oder Festlegen eines Klingeltons im Song-Menü, Übersetzen von Songtexten und Öffnen von Noxira über das Widget';

  @override
  String get cl200Hood2 =>
      'Die App stürzt nicht mehr ab, wenn die Speicherberechtigung fehlt';

  @override
  String get cl200Hood3 =>
      'Playlists, Lieblingssongs, Wiedergabezähler und Einstellungen werden sicher gespeichert, sodass ein unterbrochenes Speichern keine leere Datei mehr hinterlässt';

  @override
  String get cl200Hood4 =>
      'FLAC-Dateien, deren Metadatenblöcke von einem Tag-Editor unvollständig hinterlassen wurden, werden beim Speichern repariert und lassen sich wieder abspielen';

  @override
  String get cl200Hood5 =>
      'Das Cover in der Medienbenachrichtigung wird verkleinert, um Ruckler beim Erstellen der Benachrichtigung zu vermeiden';

  @override
  String get cl200Hood6 =>
      'Das Bearbeiten von Tags bei Sprachaufnahmen (M4A) schlägt nicht mehr wegen Restdaten am Dateiende fehl';

  @override
  String get cl200Hood7 =>
      'Der Visualizer verzerrt Dolby-Atmos-Titel nicht mehr; sie nutzen stattdessen die simulierte Animation';

  @override
  String get cl200Hood8 =>
      'Handys, die keinen Equalizer-Effekt erstellen können, spielen jetzt normal ab, und der Equalizer wartet auf den ersten Song, statt in ein Timeout zu laufen';

  @override
  String get cl200Hood9 =>
      '„Nach Updates suchen“ zeigt jetzt sein Ergebnis und weist darauf hin, wenn Updates über Google Play kommen';

  @override
  String get cl200Hood10 =>
      'Ankündigungen, das Unterstützungsziel und einige Online-Dienste lassen sich ohne App-Update anpassen';

  @override
  String get cl200Hood11 => 'Abhängigkeiten aktualisiert';

  @override
  String get pkgJustAudio => 'Funktionsreicher Audio-Player für Flutter';

  @override
  String get pkgAudioService => 'Wiedergabe im Hintergrund und Mediensteuerung';

  @override
  String get pkgAudioSession =>
      'Audiositzungsverwaltung für korrekten Audiofokus';

  @override
  String get pkgOnAudioQuery => 'Audiodateien aus dem Gerätespeicher abfragen';

  @override
  String get pkgHaudiotagger => 'Audio-Metadaten-Tags lesen und schreiben';

  @override
  String get pkgProvider => 'Zustandsverwaltung für Flutter';

  @override
  String get pkgSharedPreferences => 'Dauerhafter Schlüssel-Wert-Speicher';

  @override
  String get pkgPathProvider => 'Zugriff auf Dateisystempfade des Geräts';

  @override
  String get pkgPermissionHandler => 'Laufzeitberechtigungen verwalten';

  @override
  String get pkgDynamicColor => 'Dynamische Farbthemen mit Material You';

  @override
  String get pkgPaletteGenerator => 'Farben aus Bildern extrahieren';

  @override
  String get pkgStaggeredAnimations => 'Gestaffelte Listenanimationen';

  @override
  String get pkgHttp => 'HTTP-Anfragen für API-Aufrufe';

  @override
  String get pkgUrlLauncher => 'URLs im Browser öffnen';

  @override
  String get pkgSharePlus => 'Inhalte mit anderen Apps teilen';

  @override
  String get pkgPackageInfoPlus => 'App-Version und Paketinformationen abrufen';

  @override
  String get pkgDeviceInfoPlus => 'Geräteinformationen abrufen';

  @override
  String get pkgFlutterDotenv => 'Umgebungsvariablen aus .env-Datei laden';

  @override
  String get pkgCrypto => 'Kryptografische Hash-Funktionen';

  @override
  String get pkgIntl => 'Internationalisierung und Lokalisierung';

  @override
  String get pkgPubSemver => 'Hilfsmittel für semantische Versionierung';

  @override
  String get pkgClarityFlutter => 'Microsoft-Clarity-Analysen';

  @override
  String get pkgFlutterHooks => 'React-ähnliche Hooks für Flutter';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeMidnight => 'Mitternacht';

  @override
  String get themeOcean => 'Ozean';

  @override
  String get themeTeal => 'Petrol';

  @override
  String get themeForest => 'Wald';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeGold => 'Gold';

  @override
  String get themeEmber => 'Glut';

  @override
  String get themeRose => 'Rose';

  @override
  String get themeSakura => 'Sakura';

  @override
  String artistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Künstler',
      one: '1 Künstler',
    );
    return '$_temp0';
  }

  @override
  String get playbackInvalidPlaylist => 'Ungültige Playlist oder Startposition';

  @override
  String playbackCouldNotPlayTitleSkipping(String title) {
    return '„$title“ konnte nicht abgespielt werden – wird übersprungen';
  }

  @override
  String get playbackCouldNotPlaySkipping =>
      'Dieser Song konnte nicht abgespielt werden – wird übersprungen';

  @override
  String playbackCouldNotPlayTitle(String title) {
    return '„$title“ konnte nicht abgespielt werden';
  }

  @override
  String get playbackFailed => 'Wiedergabe fehlgeschlagen';

  @override
  String playbackSetPlaylistFailed(String error) {
    return 'Playlist konnte nicht gesetzt werden: $error';
  }

  @override
  String playbackUpdatePlaylistFailed(String error) {
    return 'Playlist konnte nicht aktualisiert werden: $error';
  }
}
