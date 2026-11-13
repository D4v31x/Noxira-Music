// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get aboutArtist => 'कलाकार के बारे में';

  @override
  String get add => 'जोड़ें';

  @override
  String get addExclusion => 'अपवाद जोड़ें';

  @override
  String get addSeparator => 'विभाजक जोड़ें';

  @override
  String get addSongs => 'गीत जोड़ें';

  @override
  String get addSongsToPlaylist => 'प्लेलिस्ट में गीत जोड़ें';

  @override
  String get addToPlaylist => 'प्लेलिस्ट में जोड़ें';

  @override
  String get adjustSync => 'सिंक समायोजित करें';

  @override
  String get album => 'एल्बम';

  @override
  String get albums => 'एल्बम';

  @override
  String get allSongs => 'सभी गीत';

  @override
  String get appName => 'Noxira Music';

  @override
  String get artist => 'कलाकार';

  @override
  String get artistName => 'कलाकार का नाम';

  @override
  String get artists => 'कलाकार';

  @override
  String get artistSeparation => 'कलाकार पृथक्करण';

  @override
  String get artistSeparationDesc =>
      'कई कलाकारों को कैसे विभाजित किया जाए, कॉन्फ़िगर करें';

  @override
  String get audioQuality => 'ध्वनि गुणवत्ता';

  @override
  String get audioQualityDesc => 'ऑडियो फ़ाइल के तकनीकी विनिर्देश';

  @override
  String get auroraMusic => 'Noxira Music';

  @override
  String get autoPlaylists => 'स्वचालित प्लेलिस्ट';

  @override
  String get autoTag => 'स्वचालित टैग';

  @override
  String get smartPlaylists => 'स्मार्ट प्लेलिस्ट';

  @override
  String get createSmartPlaylist => 'स्मार्ट प्लेलिस्ट बनाएँ…';

  @override
  String get editSmartPlaylist => 'स्मार्ट प्लेलिस्ट संपादित करें';

  @override
  String get smartPlaylistNameHint => 'प्लेलिस्ट का नाम';

  @override
  String get smartPlaylistRules => 'नियम';

  @override
  String get addRule => 'नियम जोड़ें';

  @override
  String get saveSmartPlaylist => 'बचाएँ';

  @override
  String get matchAll => 'सभी नियमों से मेल करें';

  @override
  String get matchAny => 'किसी भी नियम से मेल खाएं';

  @override
  String get limitResultsLabel => 'परिणाम सीमित करें';

  @override
  String get noLimit => 'कोई सीमा नहीं';

  @override
  String get deleteSmartPlaylistConfirm =>
      'क्या इस स्मार्ट प्लेलिस्ट को हटाना है? यह केवल सहेजे गए नियमों को हटाता है — आपके गाने प्रभावित नहीं होते।';

  @override
  String smartPlaylistPreviewCount(int count) {
    return 'अभी $count गाने मिल रहे हैं';
  }

  @override
  String get saveAsClip => 'क्लिप के रूप में सहेजें';

  @override
  String get generatingClip => 'क्लिप उत्पन्न हो रहा है…';

  @override
  String get clipDuration => 'क्लिप की अवधि';

  @override
  String get clipStartOffset => 'आरंभ बिंदु';

  @override
  String get saveClip => 'क्लिप सहेजें';

  @override
  String get clipSavedToDevice => 'क्लिप डिवाइस पर सहेजी गई';

  @override
  String get clipSaveFailed => 'क्लिप सहेज नहीं सके। कृपया फिर से प्रयास करें।';

  @override
  String get playlistSavedToDevice => 'प्लेलिस्ट डिवाइस पर सहेजी गई';

  @override
  String get trackTags => 'ट्रैक टैग्स';

  @override
  String get editTrackTags => 'टैग संपादित करें';

  @override
  String get addTrackTag => 'टैग जोड़ें';

  @override
  String get noTrackTagsYet =>
      'अभी तक कोई टैग नहीं है। इस ट्रैक के किसी हिस्से पर सीधे जाने के लिए एक टैग जोड़ें।';

  @override
  String get trackTagNameHint => 'उदाहरण के लिए गीत का शीर्षक या कलाकार';

  @override
  String get trackTagPosition => 'पद';

  @override
  String get useCurrentPosition => 'वर्तमान स्थिति का उपयोग करें';

  @override
  String get isThisASet => 'इस ट्रैक में टाइमस्टैम्प जोड़ें';

  @override
  String get tagPartsForEasySwitching =>
      'किसी भी क्षण को चिह्नित करें — अध्याय, मुख्य अंश, बुकमार्क, या कुछ भी।';

  @override
  String get tagThisTrack => 'टैग जोड़ें';

  @override
  String get pasteSetlist => 'टाइमस्टैम्प आयात करें';

  @override
  String get pasteSetlistDialogTitle => 'समय-मुद्राएँ आयात करें';

  @override
  String get pasteSetlistHint =>
      'यहाँ टाइमस्टैम्प पेस्ट करें, जैसे\n0:00 परिचय\n3:45 अध्याय का नाम';

  @override
  String get importAction => 'आयात';

  @override
  String tagsImportedMessage(int count) {
    return 'आयातित $count टैग';
  }

  @override
  String get noTagsFoundInPaste =>
      'पेस्ट किए गए टेक्स्ट में कोई टाइमस्टैम्प नहीं मिला।';

  @override
  String get bitrate => 'बिटरेट';

  @override
  String get buyMeCoffee => 'मुझे कॉफ़ी पिलाएँ';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get coffeeSupport => 'कॉफ़ी के साथ समर्थन';

  @override
  String get composer => 'रचनाकार';

  @override
  String get connectWithUs => 'हमसे जुड़ें';

  @override
  String get copied => 'नकल किया गया';

  @override
  String get copy => 'प्रतिलिपि';

  @override
  String get create => 'बनाएँ';

  @override
  String get createFirstPlaylist =>
      'अपना पहला प्लेलिस्ट बनाने के लिए ऊपर दिए गए बटन पर टैप करें।';

  @override
  String get createPlaylist => 'प्लेलिस्ट बनाएँ';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get dateAdded => 'जोड़ा गया दिनांक';

  @override
  String get dateModified => 'संशोधित तिथि';

  @override
  String get delete => 'मिटायें';

  @override
  String get deletePlaylist => 'प्लेलिस्ट हटाएँ';

  @override
  String get deletePlaylistConfirm => 'क्या आप वास्तव में हटाना चाहते हैं?';

  @override
  String get deletePlaylistConfirmation =>
      'क्या आप इस प्लेलिस्ट को हटाना चाहते हैं?';

  @override
  String get deselectAll => 'सभी को अनचुनें';

  @override
  String get details => 'विवरण देखें';

  @override
  String get discard => 'फेंको';

  @override
  String get dontShowAgain => 'फिर से न दिखाएँ';

  @override
  String get duration => 'अवधि';

  @override
  String get enableArtistSeparation => 'कलाकार पृथक्करण सक्षम करें';

  @override
  String get enableArtistSeparationDesc =>
      'संयुक्त कलाकार नामों को स्वचालित रूप से विभाजित करें';

  @override
  String get enjoyingAurora => 'क्या आप Noxira का आनंद ले रहे हैं?';

  @override
  String get enjoyingAuroraDesc =>
      'यदि आप Noxira Music का उपयोग करना पसंद करते हैं, तो इसके विकास का समर्थन करने पर विचार करें। आपका समर्थन इसे मुफ्त बनाए रखने में मदद करता है!';

  @override
  String get error => 'त्रुटि';

  @override
  String get exclusionHint => 'उदा. एसी/डीसी';

  @override
  String get exclusions => 'अपवाद';

  @override
  String get exclusionsDesc =>
      'कलाकार के नाम जिन्हें कभी विभाजित नहीं किया जाना चाहिए';

  @override
  String get exit => 'निकास';

  @override
  String get exitApp => 'ऐप बंद करें';

  @override
  String get exitAppConfirm => 'क्या आप बाहर निकलना चाहते हैं?';

  @override
  String get expandLyrics => 'गीत के बोल प्रदर्शित करें';

  @override
  String get extraLarge => 'अति विशाल';

  @override
  String get favoriteSongs => 'पसंदीदा गाने';

  @override
  String get fileInfo => 'फ़ाइल जानकारी';

  @override
  String get fileInfoDesc =>
      'मूल्यों को कॉपी करने के लिए उन पर लंबा दबाव डालें।';

  @override
  String get fileName => 'फ़ाइल का नाम';

  @override
  String get filePath => 'फ़ाइल पथ';

  @override
  String get folder => 'फ़ोल्डर';

  @override
  String get folders => 'फ़ोल्डर';

  @override
  String get fontSize => 'फ़ॉन्ट का आकार';

  @override
  String get format => 'स्वरूप';

  @override
  String get forYou => 'आपके लिए';

  @override
  String get genre => 'शैली';

  @override
  String get goodQuality => 'अच्छी गुणवत्ता';

  @override
  String get gotIt => 'समझ गया!';

  @override
  String get grantPermission => 'अनुमति दें';

  @override
  String get highQuality => 'उच्च गुणवत्ता';

  @override
  String get home => 'होम';

  @override
  String get kofi => 'को-फ़ी';

  @override
  String get buyMeACoffee => 'मुझे कॉफ़ी पिलाएँ';

  @override
  String get donationNote =>
      'कोई दबाव नहीं - आप सेटिंग्स में बाद में भी दान कर सकते हैं।';

  @override
  String get language => 'भाषा';

  @override
  String get large => 'बड़ा';

  @override
  String get later => 'बाद में';

  @override
  String get library => 'पुस्तकालय';

  @override
  String get libraryError => 'संगीत लाइब्रेरी लोड करने में त्रुटि';

  @override
  String get libraryLoaded => 'संगीत पुस्तकालय लोड हो गया';

  @override
  String get libraryUpdated => 'पुस्तकालय अपडेट किया गया';

  @override
  String get loading => 'लोड हो रहा है';

  @override
  String get loadingLibrary => 'लाइब्रेरी लोड हो रही है';

  @override
  String get lossless => 'हानिरहित';

  @override
  String get lowQuality => 'निम्न गुणवत्ता';

  @override
  String get lyrics => 'गीत के बोल';

  @override
  String get lyricsAhead => 'गीत के बोल आगे हैं';

  @override
  String get lyricsBehind => 'गीत के बोल पीछे हैं।';

  @override
  String get lyricsSynced => 'गीत के बोल सिंक हो गए हैं।';

  @override
  String get maybeLater => 'शायद बाद में';

  @override
  String get medium => 'मध्यम';

  @override
  String get metadata => 'मेटाडेटा';

  @override
  String get metadataSaved => 'मेटाडेटा सफलतापूर्वक सहेजा गया';

  @override
  String get metadataApplied => 'मेटाडेटा सफलतापूर्वक डाउनलोड हो गया';

  @override
  String get metadataDownloadFailed =>
      'डाउनलोड विफल हो गया। अपना कनेक्शन जांचें और फिर से प्रयास करें।';

  @override
  String get chooseArtworkFromDevice => 'डिवाइस से चुनें';

  @override
  String get mostPlayed => 'सबसे ज़्यादा बजाए गए';

  @override
  String get newPlaylist => 'नई प्लेलिस्ट';

  @override
  String get next => 'अगला';

  @override
  String get no => 'नहीं';

  @override
  String get noAlbumsFound => 'कोई एल्बम नहीं मिला';

  @override
  String get noArtistInfo => 'कलाकार की जानकारी उपलब्ध नहीं है';

  @override
  String get noArtistsFound => 'कोई कलाकार नहीं मिला';

  @override
  String get noData => 'प्रदर्शित करने के लिए कोई डेटा नहीं है';

  @override
  String get noExclusions => 'कोई अपवाद कॉन्फ़िगर नहीं किए गए हैं';

  @override
  String get noLyrics => 'गीत के बोल उपलब्ध नहीं हैं';

  @override
  String get noLyricsDesc => 'हम इस गाने के बोल नहीं ढूंढ पाए।';

  @override
  String get noLyricsFound => 'कोई गीत के बोल नहीं मिले';

  @override
  String get noPermissionExplanation =>
      'अनुमति के बिना, Noxira Music आपकी संगीत लाइब्रेरी तक पहुँच नहीं पाएगा।';

  @override
  String get noPlaylists => 'कोई प्लेलिस्ट उपलब्ध नहीं हैं';

  @override
  String get noResults => 'कोई परिणाम नहीं मिला';

  @override
  String get noSeparators => 'कोई विभाजक कॉन्फ़िगर नहीं किए गए हैं';

  @override
  String get noSongPlaying => 'कोई गीत नहीं बज रहा है';

  @override
  String get noSongsAvailable => 'कोई गीत उपलब्ध नहीं हैं';

  @override
  String get noSongsInPlaylist => 'इस प्लेलिस्ट में कोई गीत नहीं हैं';

  @override
  String get nowPlaying => 'अब चल रहा है';

  @override
  String get onboardingAlbumArtwork => 'एल्बम की कलाकृति';

  @override
  String get onboardingAlbumArtworkDesc =>
      'आपकी लाइब्रेरी को बेहतर बनाने के लिए उच्च-गुणवत्ता वाले एल्बम कवर लाता है।';

  @override
  String get onboardingAnalytics => 'अनाम विश्लेषण और क्रैश रिपोर्ट';

  @override
  String get onboardingAnalyticsDesc =>
      'यह हमें बग ठीक करने और प्रदर्शन सुधारने में मदद करता है। इसमें आपका सुनने का इतिहास या व्यक्तिगत डेटा कभी शामिल नहीं होता।';

  @override
  String get onboardingAppInfoSubtitle => 'आपका व्यक्तिगत संगीत साथी';

  @override
  String get onboardingAudioAccess => 'ऑडियो पहुँच';

  @override
  String get onboardingAudioAccessDesc =>
      'आपकी संगीत लाइब्रेरी को चलाने और प्रबंधित करने के लिए आवश्यक';

  @override
  String get onboardingBack => 'वापस';

  @override
  String get onboardingBeautifulArtwork => 'सुंदर एल्बम कवर';

  @override
  String get onboardingBeautifulArtworkDesc =>
      'स्वचालित रूप से एल्बम की कलाकृति प्राप्त करें और उसे वैसे ही प्रदर्शित करें जैसे इसे देखा जाना चाहिए।';

  @override
  String get onboardingBluetooth => 'ब्लूटूथ';

  @override
  String get onboardingBluetoothDesc =>
      'ब्लूटूथ डिवाइसों से कनेक्ट करने के लिए आवश्यक';

  @override
  String get onboardingChooseLanguage => 'अपनी भाषा चुनें';

  @override
  String get onboardingCompletionSubtitle =>
      'अपने संगीत का आनंद लेना शुरू करें';

  @override
  String get onboardingCompletionTitle => 'आप पूरी तरह तैयार हैं!';

  @override
  String get onboardingContinue => 'जारी रखें';

  @override
  String get onboardingDynamicColors => 'गतिशील रंग';

  @override
  String get onboardingDynamicColorsDesc => 'मैच सिस्टम वॉलपेपर रंग';

  @override
  String get onboardingGrantPermissions => 'अनुमति दें';

  @override
  String get onboardingInternetSubtitle =>
      'Noxira Music इंटरनेट का उपयोग कैसे करता है';

  @override
  String get onboardingInternetTitle => 'इंटरनेट का उपयोग';

  @override
  String get onboardingLocalMusic => 'आपके डिवाइस पर संगीत';

  @override
  String get onboardingLocalMusicDesc =>
      'अपने संगीत फ़ाइलों को अपने हाथ में रखें';

  @override
  String get onboardingLyrics => 'गीत के बोल';

  @override
  String get onboardingLyricsDesc =>
      'आपके गीतों के लिए सिंक्रोनाइज़्ड बोल LRCLIB, Better Lyrics, YouLyPlus और KuGou से डाउनलोड करता है। इन सेवाओं को गीत का शीर्षक, कलाकार, एल्बम और अवधि मिलती है। आप सेटिंग्स में अलग-अलग स्रोत बंद कर सकते हैं।';

  @override
  String get onboardingLyricsSupport => 'गीत-लेखन सहायता';

  @override
  String get onboardingLyricsSupportDesc =>
      'सुनते समय सिंक्रोनाइज़ किए गए बोल देखें';

  @override
  String get onboardingMaterialDesign => 'मैटेरियल यू डिज़ाइन';

  @override
  String get onboardingMaterialDesignDesc =>
      'आपकी पसंद के अनुसार अनुकूलित होने वाले गतिशील रंग';

  @override
  String get onboardingMusicMetadata => 'संगीत मेटाडेटा';

  @override
  String get onboardingMusicMetadataDesc =>
      'कलाकार की जानकारी, एल्बम का विवरण और ट्रैक की जानकारी प्राप्त करता है।';

  @override
  String get onboardingNotifications => 'सूचनाएँ';

  @override
  String get onboardingNotificationsDesc => 'प्लेबैक नियंत्रण और अपडेट दिखाएँ';

  @override
  String get onboardingPermissionsSubtitle =>
      'Noxira Music को ठीक से काम करने के लिए इन अनुमतियों की आवश्यकता है।';

  @override
  String get onboardingPermissionsTitle => 'अनुमति दें';

  @override
  String get onboardingPrivacyNote =>
      'आपकी गोपनीयता महत्वपूर्ण है। सभी संगीत फ़ाइलें आपके डिवाइस पर ही रहती हैं।';

  @override
  String get onboardingRequesting => 'अनुरोध कर रहा है...';

  @override
  String get onboardingRequired => 'आवश्यक';

  @override
  String get onboardingAudioRequired =>
      'जारी रखने के लिए ऑडियो एक्सेस आवश्यक है। कृपया ऊपर दी गई अनुमति प्रदान करें।';

  @override
  String get onboardingSelectLanguage => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String get onboardingSmartPlaylists => 'स्मार्ट प्लेलिस्ट';

  @override
  String get onboardingSmartPlaylistsDesc =>
      'अपने संगीत संग्रह बनाएँ और प्रबंधित करें';

  @override
  String get onboardingStartListening => 'सुनना शुरू करें';

  @override
  String get onboardingStorageAccess => 'भंडारण पहुँच';

  @override
  String get onboardingStorageAccessDesc =>
      'आपके डिवाइस से संगीत फ़ाइलें पढ़ने के लिए आवश्यक';

  @override
  String get onboardingVisualizerAccess => 'दृश्यीकरण उपकरण';

  @override
  String get onboardingVisualizerAccessDesc =>
      'यह विज़ुअलाइज़र को आपके डिवाइस के ऑडियो सत्र को लाइव बार स्पेक्ट्रम के लिए पढ़ने की अनुमति देता है। कोई ऑडियो कभी रिकॉर्ड नहीं किया जाता।';

  @override
  String get onboardingThemeSubtitle => 'अपनी शैली के अनुरूप एक थीम चुनें';

  @override
  String get onboardingThemeTitle => 'अपनी लुक को कस्टमाइज़ करें';

  @override
  String get oneTimeSupport => 'त्वरित एक-बार सहायता';

  @override
  String get openFolder => 'फ़ाइल मैनेजर में खोलें';

  @override
  String get openFolderInfo =>
      'इस स्थान पर नेविगेट करने के लिए अपने फ़ाइल प्रबंधक का उपयोग करें।';

  @override
  String get ownTimer => 'अपना टाइमर';

  @override
  String get permDeny => 'अनुमति अस्वीकार कर दी गई';

  @override
  String get permissionExplanation =>
      'Noxira Music को ठीक से काम करने के लिए इन अनुमतियों की आवश्यकता है। कृपया ऐप सेटिंग्स में ये अनुमतियाँ प्रदान करें।';

  @override
  String get permissionLater =>
      'आप बाद में ऐप सेटिंग्स में अनुमतियाँ दे सकते हैं।';

  @override
  String get permissionRequired => 'अनुमति आवश्यक';

  @override
  String get playAll => 'सभी चलाएँ';

  @override
  String get playingFrom => 'से खेलना';

  @override
  String get playlist => 'प्लेलिस्ट';

  @override
  String get playlistName => 'प्लेलिस्ट का नाम';

  @override
  String get playlists => 'प्लेलिस्ट';

  @override
  String get possibleReasons => 'संभावित कारण:';

  @override
  String get privacyNotice =>
      'इस ऐप का उपयोग जारी रखकर, आप हमारी गोपनीयता नीति से सहमत हैं।';

  @override
  String get privacyPolicyLink => 'हमारी गोपनीयता नीति पढ़ें';

  @override
  String get quality => 'गुणवत्ता';

  @override
  String get queue => 'कतार';

  @override
  String get queueEmpty => 'कतार खाली है';

  @override
  String get reasonFormat =>
      'फ़ाइल प्रारूप मेटाडेटा संपादन का समर्थन नहीं करता है।';

  @override
  String get reasonPermissions => 'भंडारण अनुमतियाँ प्रदान नहीं की गईं';

  @override
  String get reasonReadonly => 'फ़ाइल केवल-पठन या बाहरी भंडारण पर है।';

  @override
  String get recentlyAdded => 'हाल ही में जोड़ा गया';

  @override
  String get recentlyPlayed => 'हाल ही में खेला गया';

  @override
  String get recentlyPlayedArtists => 'हाल ही में बजाए गए कलाकार';

  @override
  String get recentlyPlayedSongs => 'हाल ही में बजाए गए गाने';

  @override
  String get refreshing => 'ताज़गी...';

  @override
  String get refreshLyrics => 'गीत के बोल ताज़ा करें';

  @override
  String get remove => 'हटाएँ';

  @override
  String get removeSong => 'गाना हटाएँ';

  @override
  String get removeSongConfirmation =>
      'क्या इस गाने को प्लेलिस्ट से हटाया जाए?';

  @override
  String get rename => 'नाम बदलें';

  @override
  String get renamePlaylist => 'प्लेलिस्ट का नाम बदलें';

  @override
  String get repeat => 'दोहराएँ';

  @override
  String get reset => 'पुनः आरंभ करें';

  @override
  String get resetArtistSeparationDesc =>
      'यह सभी डिफ़ॉल्ट विभाजक और अपवर्गों को पुनर्स्थापित करेगा।';

  @override
  String get resetToDefaults => 'डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get result => 'परिणाम';

  @override
  String get results => 'परिणाम';

  @override
  String get retry => 'दोबारा प्रयास करें';

  @override
  String get sampleRate => 'नमूना दर';

  @override
  String get save => 'बचाएँ';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get saveChangesDesc => 'क्या आप अपने बदलाव सहेजना चाहते हैं?';

  @override
  String get saveFailed => 'बचाई गई असफल';

  @override
  String get saveFailedDesc => 'इस फ़ाइल में मेटाडेटा सहेजने में असमर्थ।';

  @override
  String get scanFailed => 'स्कैन विफल हो गया';

  @override
  String get scanningSongs => 'गीतों को स्कैन करना';

  @override
  String get search => 'खोजें';

  @override
  String get searchAlbums => 'एल्बम खोजें';

  @override
  String get searchArtists => 'कलाकार खोजें';

  @override
  String get searchFailed => 'खोज असफल हुई';

  @override
  String get lyricsSource => 'बोल का स्रोत';

  @override
  String get inPlaylistHint => 'प्लेलिस्ट में';

  @override
  String get removeDuplicates => 'डुप्लिकेट हटाएँ';

  @override
  String get noDuplicatesFound => 'कोई डुप्लिकेट गाना नहीं मिला';

  @override
  String duplicatesRemoved(int count) {
    return '$count डुप्लिकेट गाने हटाए गए';
  }

  @override
  String get supportNoxiraTitle => 'Noxira का समर्थन करें!';

  @override
  String get supportButton => 'समर्थन करें';

  @override
  String supportGoalProgress(String raised, String goal) {
    return 'इस महीने $goal में से $raised';
  }

  @override
  String get onboardingSupportGoal => 'सहयोग लक्ष्य';

  @override
  String get onboardingSupportGoalDesc =>
      'कभी-कभी इस महीने के सहयोग लक्ष्य और अब तक जुटाई गई राशि वाली एक छोटी सार्वजनिक फ़ाइल डाउनलोड करता है। यह एक सादा डाउनलोड है: आपके या आपके संगीत के बारे में कुछ नहीं भेजा जाता।';

  @override
  String get songAddedChip => 'जोड़ा गया';

  @override
  String get tapToRemove => 'हटाने के लिए टैप करें';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingYourLanguage => 'आपकी भाषा?';

  @override
  String get onboardingAllow => 'अनुमति दें';

  @override
  String get onboardingSummaryLanguage => 'भाषा';

  @override
  String get onboardingSummaryTheme => 'रूप';

  @override
  String get onboardingSummaryLibrary => 'संगीत लाइब्रेरी तक पहुँच';

  @override
  String get onboardingAllowed => 'अनुमति दी गई';

  @override
  String get onboardingNotAllowed => 'अभी अनुमति नहीं';

  @override
  String get searchLyrics => 'गीत के बोल खोजें';

  @override
  String get searchMetadata => 'मेटाडेटा खोजें';

  @override
  String get searchTracks => 'ट्रैक खोजें';

  @override
  String get selectAll => 'सभी चुनें';

  @override
  String get selectArtist => 'कलाकार चुनें';

  @override
  String get selected => 'चुना हुआ';

  @override
  String get separator => 'विभाजक';

  @override
  String get separatorHint => 'उदाहरण के लिए / या फीचर्ड';

  @override
  String get separators => 'विभाजक';

  @override
  String get set => 'सेट';

  @override
  String get setMinutes => 'निर्धारित मिनट';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get settingsAbout => 'बारे में';

  @override
  String get settingsAboutApp => 'Noxira म्यूजिक के बारे में';

  @override
  String get settingsAboutSubtitle => 'संस्करण, प्रतिक्रिया और अपडेट';

  @override
  String get settingsGroupExperience => 'अनुभव';

  @override
  String get settingsGroupLibrary => 'लाइब्रेरी और डेटा';

  @override
  String get settingsGroupApp => 'ऐप';

  @override
  String get settingsAccentColor => 'उल्लेखनीय रंग';

  @override
  String get settingsAppearance => 'दृश्यमानता';

  @override
  String get settingsAppearanceSubtitle => 'थीम, रंग और लेआउट';

  @override
  String get settingsAudio => 'ऑडियो';

  @override
  String get settingsBackground => 'पृष्ठभूमि';

  @override
  String get settingsCacheCleared => 'कैश साफ़ हो गया';

  @override
  String get settingsCacheInfo => 'कैश जानकारी';

  @override
  String get settingsCacheInfoDesc => 'भंडारण उपयोग देखें';

  @override
  String get settingsCheckingUpdates => 'अपडेट्स की जाँच...';

  @override
  String get settingsCheckUpdates => 'अपडेट्स के लिए जाँच करें';

  @override
  String get settingsCheckUpdatesDesc => 'नवीनतम संस्करण प्राप्त करें';

  @override
  String get settingsClearCache => 'कैश साफ़ करें';

  @override
  String get settingsClearCacheDesc => 'सभी कैश किए गए डेटा को हटाएँ';

  @override
  String get settingsClearCacheMessage =>
      'सभी कैश किए गए डेटा को आवश्यकतानुसार हटा दिया जाएगा और पुनर्निर्मित किया जाएगा।';

  @override
  String get settingsClearCacheTitle => 'कैश साफ़ करें?';

  @override
  String get settingsDataWindow => 'डेटा विंडो';

  @override
  String get settingsDataWindowDesc => 'रिकैप स्क्रीन कितनी पीछे तक दिखती है';

  @override
  String get settingsGapless => 'बिना रुकावट प्लेबैक';

  @override
  String get settingsGaplessDesc => 'निर्बाध ट्रैक संक्रमण';

  @override
  String get settingsAutomix => 'ऑटोमिक्स';

  @override
  String get settingsAutomixDesc =>
      'गानों के बीच अपने आप एक सहज प्रवाह बनाता है';

  @override
  String get settingsCrossfade => 'क्रॉसफ़ेड';

  @override
  String get settingsCrossfadeDesc =>
      'एक ट्रैक के अंत को दूसरे ट्रैक में सहजता से मिलाएँ।';

  @override
  String get crossfadeDuration => 'क्रॉसफ़ेड अवधि';

  @override
  String get crossfadeDurationDesc =>
      'ट्रैकों के बीच का ओवरलैप कितनी देर तक रहता है';

  @override
  String get settingsInsights => 'अंतर्दृष्टियाँ';

  @override
  String get settingsInsightsSubtitle => 'सुनने का पुनरावलोकन काल';

  @override
  String get settingsLast7Days => 'पिछले 7 दिन';

  @override
  String get settingsLast30Days => 'पिछले 30 दिन';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLayout => 'लेआउट';

  @override
  String get settingsLibraryFolders => 'पुस्तकालय फ़ोल्डर';

  @override
  String get settingsLibraryFoldersSubtitle =>
      'स्कैन फ़ोल्डरों को शामिल करें या बाहर रखें';

  @override
  String get settingsMaterialYou => 'आपकी सामग्री';

  @override
  String get settingsMaterialYouDesc => 'वॉलपेपर से गतिशील रंग';

  @override
  String get settingsMonthlyRecap => 'मासिक सारांश';

  @override
  String get settingsMonthlyRecapDesc =>
      'हर महीने एक बैनर दिखाएँ (साप्ताहिक की तुलना में प्राथमिकता लेता है)';

  @override
  String get settingsNormalization => 'आयतन सामान्यीकरण';

  @override
  String get settingsNormalizationDesc =>
      'सुसंगत वॉल्यूम स्तर · आपकी फ़ाइलों में ReplayGain टैग्स की आवश्यकता है';

  @override
  String get playbackSpeed => 'प्लेबैक गति';

  @override
  String get playbackSpeedDesc => 'ऑडियो प्लेबैक दर समायोजित करें';

  @override
  String get adjustPitchWithSpeed => 'गति के साथ पिच समायोजित करें';

  @override
  String get adjustPitchWithSpeedDesc =>
      'बंद होने पर, पिच शिफ्ट के बिना टेम्पो बदलता है।';

  @override
  String get playbackPitch => 'पिच';

  @override
  String get playbackPitchDesc =>
      'स्पीड से स्वतंत्र रूप से आवाज़ को ऊँचा या नीचा करें';

  @override
  String get playbackPitchLinkedDesc => 'प्लेबैक स्पीड के अनुसार';

  @override
  String get settingsPlayback => 'प्लेबैक';

  @override
  String get settingsPlaybackSubtitle => 'गति, अंतराल रहित और सामान्यीकरण';

  @override
  String get settingsRecapBannerDesc =>
      'बैनर आपके पहले खेलने से गिने गए प्रत्येक नए सप्ताह या महीने की शुरुआत में होम स्क्रीन पर दिखाई देता है। \"बाद में\" पर टैप करने से यह सत्र के लिए छिपा रहता है; \"दिखाएँ\" पर टैप करने से इसे देखा हुआ माना जाता है।';

  @override
  String get settingsRecapContent => 'सारांश सामग्री';

  @override
  String get settingsRecapContentDesc =>
      'यह नियंत्रित करता है कि जब आप रिकैप स्क्रीन को मैन्युअली या बैनर के माध्यम से खोलते हैं, तो वह कितनी पिछली जानकारी दिखाती है।';

  @override
  String get settingsPreviewRecap => 'अग्रिम पुनरावलोकन सारांश';

  @override
  String get settingsPreviewRecapDesc =>
      'वर्तमान सेटिंग्स के साथ आपका सारांश अभी कैसा दिखता है देखें।';

  @override
  String get settingsRecapSchedule => 'सारांश अनुसूची';

  @override
  String get settingsStorage => 'भंडारण';

  @override
  String settingsCacheItems(String count) {
    return '$count आइटम';
  }

  @override
  String get settingsMemoryCache => 'मेमोरी कैश';

  @override
  String get settingsStorageSubtitle => 'कैश और मीडिया फ़ाइलें';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsTools => 'उपकरण';

  @override
  String get settingsResetSetup => 'सेटअप रीसेट करें';

  @override
  String get settingsResetSetupDesc =>
      'ऑनबोर्डिंग प्रक्रिया को फिर से शुरू करें';

  @override
  String get settingsUpdateAvailable => 'अपडेट उपलब्ध है!';

  @override
  String get settingsUpToDate => 'आप अप-टू-डेट हैं';

  @override
  String get settingsUpdateCheckFailed =>
      'अपडेट जाँचे नहीं जा सके। अपडेट Google Play से आते हैं।';

  @override
  String get settingsWeeklyRecap => 'साप्ताहिक सारांश';

  @override
  String get settingsWeeklyRecapDesc =>
      'अपनी पहली प्ले के बाद हर हफ्ते एक बैनर दिखाएँ';

  @override
  String get settingsVersion => 'संस्करण';

  @override
  String get share => 'साझा करें';

  @override
  String get shuffle => 'शफल';

  @override
  String get size => 'आकार';

  @override
  String get sleepTimer => 'नींद टाइमर';

  @override
  String get small => 'छोटा';

  @override
  String get songInfo => 'गीत की जानकारी';

  @override
  String get songs => 'गीत';

  @override
  String get songsLoaded => 'गीत लोड हुए';

  @override
  String get standardQuality => 'मानक गुणवत्ता';

  @override
  String get startType => 'खोजने के लिए टाइप करना शुरू करें';

  @override
  String get storagePermissionNeeded =>
      'मेटाडेटा संपादित करने के लिए, Noxira Music को फ़ाइलों का प्रबंधन करने की अनुमति चाहिए। कृपया सेटिंग्स में \'सभी फ़ाइलों तक पहुँच\' प्रदान करें।';

  @override
  String get suggestedArtists => 'कलाकार आपके लिए';

  @override
  String get suggestedTracks => 'सुझाए गए ट्रैक';

  @override
  String get supportAurora => 'Noxira का समर्थन करें';

  @override
  String get supportAuroraBtn => 'Noxira का समर्थन करें';

  @override
  String get supportAuroraDescShort => 'ऐप को मुफ्त बनाए रखने में मदद करें';

  @override
  String get supportAuroraMessage =>
      'Noxira Music को मुफ्त बनाए रखने और भविष्य के विकास का समर्थन करने में मदद करें। हर योगदान बहुत मायने रखता है!';

  @override
  String get supportAuroraTitle => 'Noxira म्यूजिक का समर्थन करें';

  @override
  String get updatedTitle => 'Noxira Music अपडेट हो गया';

  @override
  String get tapAddToAddSongs => 'गीत जोड़ने के लिए + पर टैप करें';

  @override
  String get reorderSongs => 'गीतों को फिर से क्रमबद्ध करें';

  @override
  String get done => 'हो गया';

  @override
  String get thankYouSupport => 'आपके समर्थन के लिए धन्यवाद!';

  @override
  String get theme => 'थीम';

  @override
  String get title => 'शीर्षक';

  @override
  String get topResult => 'शीर्ष परिणाम';

  @override
  String get total => 'कुल';

  @override
  String get track => 'ट्रैक';

  @override
  String get trackInfo => 'ट्रैक की जानकारी';

  @override
  String get trackInfoDesc =>
      'ट्रैक की जानकारी संशोधित करने के लिए संपादन आइकन पर टैप करें।';

  @override
  String get trackInfoEditDesc =>
      'नीचे दिए गए फ़ील्ड्स को संपादित करें, फिर सहेजने के लिए चेक आइकन पर टैप करें।';

  @override
  String get tracks => 'ट्रैक';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get unknownArtist => 'अज्ञात कलाकार';

  @override
  String get updateAvailable => 'अपडेट उपलब्ध है';

  @override
  String get updateMessage => 'एक नया संस्करण उपलब्ध है';

  @override
  String get updateNow => 'अभी अपडेट करें';

  @override
  String get viewArtist => 'कलाकार देखें';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get welcomeBack => 'फिर से स्वागत है';

  @override
  String get whatsNew => 'क्या नया है';

  @override
  String get view_changelog => 'चेंजलॉग और नई सुविधाएँ देखें';

  @override
  String get year => 'वर्ष';

  @override
  String get yes => 'हाँ';

  @override
  String get yourLibrary => 'आपकी लाइब्रेरी';

  @override
  String get yourPlaylists => 'आपकी प्लेलिस्ट';

  @override
  String get homeLayout => 'घर का लेआउट';

  @override
  String get homeLayoutDesc => 'होम टैब पर अनुभाग का क्रम अनुकूलित करें';

  @override
  String get customizeHomeTab => 'होम टैब को अनुकूलित करें';

  @override
  String get dragToReorder => 'अनुभागों को पुनः व्यवस्थित करने के लिए खींचें';

  @override
  String get resetToDefault => 'डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get resetLayoutConfirm => 'लेआउट को डिफ़ॉल्ट पर रीसेट करें?';

  @override
  String get resetLayoutMessage =>
      'यह मूल अनुभाग क्रम और दृश्यता को बहाल करेगा।';

  @override
  String get listeningHistory => 'श्रवण इतिहास';

  @override
  String get libraryStats => 'पुस्तकालय आँकड़े';

  @override
  String get back => 'वापस';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get send_feedback => 'प्रतिक्रिया भेजें';

  @override
  String get send_feedback_desc => 'बग रिपोर्ट करें या फीचर सुझाएँ';

  @override
  String get rateApp => 'Noxira Music को रेट करें';

  @override
  String get rateAppDesc => 'ऐप पसंद आ रहा है? Google Play पर समीक्षा दें';

  @override
  String get feedbackTypeBug => 'बग';

  @override
  String get feedbackTypeSuggestion => 'सुझाव';

  @override
  String get feedbackHint => 'बग या सुझाव का वर्णन करें...';

  @override
  String get feedbackSend => 'भेजें';

  @override
  String get feedbackSentThanks => 'आपकी प्रतिक्रिया के लिए धन्यवाद!';

  @override
  String get feedbackSentError =>
      'प्रतिक्रिया नहीं भेजी जा सकी। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get contributeTranslations => 'अनुवाद योगदान करें';

  @override
  String get contributeTranslationsDesc =>
      'Crowdin पर Noxira Music का अनुवाद करने में मदद करें';

  @override
  String get contributeTranslationsTitle => 'हमारा अनुवाद करने में मदद करें';

  @override
  String get contributeTranslationsSubtitle =>
      'हमारे अद्भुत समुदाय की बदौलत Noxira Music कई भाषाओं में उपलब्ध है। ऐप को अपनी भाषा में अनुवाद करके हमें और अधिक उपयोगकर्ताओं तक पहुँचने में मदद करें — शुरू करने में केवल कुछ ही मिनट लगते हैं।';

  @override
  String get contributeTranslationsOpenCrowdin => 'क्राउडइन खोलें';

  @override
  String get close => 'बंद करें';

  @override
  String get settingsHighendUi => 'उच्च-स्तरीय यूआई';

  @override
  String get settingsHighendUiDesc =>
      'उन्नत दृश्य प्रभाव और एनिमेशन सक्षम करें';

  @override
  String get clearUpcoming => 'स्पष्ट आगामी';

  @override
  String get addToQueue => 'कतार में जोड़ें';

  @override
  String get playNext => 'अगला चलाएँ';

  @override
  String get removeFromQueue => 'कतार से हटाएँ';

  @override
  String get play => 'बजाएँ';

  @override
  String get viewAlbum => 'एल्बम देखें';

  @override
  String get shuffleAll => 'सभी को मिलाएँ';

  @override
  String get noSongsFound => 'कोई गीत नहीं मिला';

  @override
  String get noFoldersFound => 'कोई फ़ोल्डर नहीं मिला';

  @override
  String get deleteSong => 'गाना हटाएँ';

  @override
  String get modifySystemSettingsPermission =>
      'खुले हुए पृष्ठ में \"सिस्टम सेटिंग्स संशोधित करें\" की अनुमति दें, फिर से प्रयास करें।';

  @override
  String errorMessage(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String songsAddedToQueue(int count) {
    return '$count गाने कतार में जोड़े गए';
  }

  @override
  String songAddedToQueue(String title) {
    return '$title कतार में जोड़ा गया';
  }

  @override
  String songSetAsRingtone(String title) {
    return '$title रिंगटोन के रूप में सेट करें';
  }

  @override
  String failedToSetRingtone(String error) {
    return 'रिंगटोन सेट करने में असफल: $error';
  }

  @override
  String deleteSongConfirm(String title) {
    return 'क्या आप अपने डिवाइस से \"$title\" हटाना चाहते हैं? इसे वापस नहीं किया जा सकता।';
  }

  @override
  String songDeleted(String title) {
    return '\"$title\" हटाया गया';
  }

  @override
  String failedToDelete(String error) {
    return 'मिटने में असफल: $error';
  }

  @override
  String songCount(int count) {
    return '$count गाने';
  }

  @override
  String get badgeNew => 'नया';

  @override
  String get paused => 'रुक गया';

  @override
  String get readyToPlay => 'खेलने के लिए तैयार';

  @override
  String get tapSongToStartListening =>
      'सुनना शुरू करने के लिए किसी गाने पर टैप करें';

  @override
  String get clearCachedLyrics => 'कैश किए गए बोल साफ़ करें';

  @override
  String lyricsCleared(String title) {
    return '\"$title\" के लिए कैश किए गए गीत साफ़ कर दिए गए।';
  }

  @override
  String lyricsAdded(String title) {
    return '“$title” के लिए बोल जोड़े गए';
  }

  @override
  String get noLyricsCached => 'इस गीत के लिए कोई कैश किए गए बोल नहीं मिले।';

  @override
  String get setAsRingtone => 'रिंगटोन के रूप में सेट करें';

  @override
  String get songInfoEdit => 'गाने की जानकारी / संपादित करें';

  @override
  String get goToAlbum => 'एल्बम पर जाएँ';

  @override
  String get goToArtist => 'कलाकार के पास जाएँ';

  @override
  String get deleteFromDevice => 'डिवाइस से हटाएँ';

  @override
  String get checkOutThisSong => 'यह गाना देखो!';

  @override
  String get backgroundSolid => 'एक रंग';

  @override
  String get backgroundHighEndStyle => 'अब पृष्ठभूमि में चल रहा है';

  @override
  String get backgroundHighEndStyleDesc =>
      'अब चल रहा है स्क्रीन में पृष्ठभूमि शैली';

  @override
  String get backgroundBlurredArtwork => 'धुंधली कलाकृति';

  @override
  String get accentColor => 'उल्लेखनीय रंग';

  @override
  String get accentColorDesc => 'ऐप का मुख्य रंग चुनें';

  @override
  String get backgroundBlur => 'पृष्ठभूमि धुंधलापन';

  @override
  String get backgroundBlurDesc => 'कलाकृति धुंधलापन तीव्रता';

  @override
  String get backgroundDarkness => 'पृष्ठभूमि अंधकार';

  @override
  String get backgroundDarknessDesc => 'कलाकृति पर ओवरले पारदर्शिता';

  @override
  String get microphoneAccessNeeded => 'माइक्रोफ़ोन की पहुँच आवश्यक है';

  @override
  String get microphoneAccessDesc =>
      'Noxira को लाइव विज़ुअलाइज़र के लिए आपके डिवाइस के ऑडियो सत्र तक पहुँचने हेतु माइक्रोफ़ोन की अनुमति चाहिए। कोई भी ऑडियो कभी रिकॉर्ड या संग्रहीत नहीं किया जाता।';

  @override
  String get recapWeek => 'सप्ताह';

  @override
  String get recapMonth => 'माह';

  @override
  String get recapPeriodWeek => 'सप्ताह';

  @override
  String get recapPeriodMonth => 'महीना';

  @override
  String get recapWeekly => 'साप्ताहिक';

  @override
  String get recapMonthly => 'मासिक';

  @override
  String get recapIntroAppName => 'Noxira Music';

  @override
  String recapIntroTitle(String period) {
    return 'आपका $period पुनरावलोकन';
  }

  @override
  String get recapIntroSubtitle => 'चलो देखते हैं कि तुम क्या सुन रहे थे।';

  @override
  String recapPlayedEyebrow(String period) {
    return 'यह $period तुमने संगीत बजाया';
  }

  @override
  String get recapTimeSingular => 'समय';

  @override
  String get recapTimePlural => 'बार';

  @override
  String get recapListenedForEyebrow => 'तुमने सुनने के लिए';

  @override
  String get recapListenedForLabel => 'संगीत का';

  @override
  String get recapTopTrackEyebrow => 'आपका #1 ट्रैक';

  @override
  String get recapPlays => 'निकालता है';

  @override
  String get recapTopTracksTitle => 'शीर्ष ट्रैक';

  @override
  String get recapTopArtistEyebrow => 'आपका शीर्ष कलाकार';

  @override
  String get recapTopArtistsTitle => 'शीर्ष कलाकार';

  @override
  String get recapNothingToWrap => 'अभी तक लपेटने के लिए कुछ नहीं है';

  @override
  String recapNothingToWrapBody(String period) {
    return 'इस $period पर कुछ संगीत बजाओ और वापस आओ।';
  }

  @override
  String get recapSwipeUp => 'ऊपर स्वाइप करें';

  @override
  String get recapYourSoundLabel => 'आपकी आवाज़';

  @override
  String get recapYouListenMost => 'आप सबसे ज़्यादा सुनते हैं';

  @override
  String recapOnDay(String day) {
    return 'पर ${day}s';
  }

  @override
  String recapAroundTime(String time) {
    return 'के आसपास $time';
  }

  @override
  String get recapVibesHitDifferent => 'तभी माहौल कुछ अलग हो गया।';

  @override
  String get recapThatsAWrap => 'काम पूरा हुआ';

  @override
  String recapInNumbers(String period) {
    return 'आपके $period\nआंकड़ों में';
  }

  @override
  String get recapNumberOneTrack => '#1 ट्रैक';

  @override
  String get recapStatTotalPlays => 'कुल प्ले';

  @override
  String get recapStatTimeListened => 'सुने गए समय';

  @override
  String get recapStatUniqueTracks => 'अनूठे ट्रैक';

  @override
  String get recapStatTopArtist => 'शीर्ष कलाकार';

  @override
  String get recapDone => 'हो गया';

  @override
  String get recapWeekdayMonday => 'सोमवार';

  @override
  String get recapWeekdayTuesday => 'मंगलवार';

  @override
  String get recapWeekdayWednesday => 'बुधवार';

  @override
  String get recapWeekdayThursday => 'गुरुवार';

  @override
  String get recapWeekdayFriday => 'शुक्रवार';

  @override
  String get recapWeekdaySaturday => 'शनिवार';

  @override
  String get recapWeekdaySunday => 'रविवार';

  @override
  String get recapBannerTitle => 'संगीत का सारांश यहाँ है';

  @override
  String get recapBannerShow => 'दिखाएँ';

  @override
  String get recapBannerLater => 'बाद में';

  @override
  String get rebrandTitle => 'Aurora अब Noxira है';

  @override
  String get rebrandSubtitle =>
      'वही म्यूज़िक ऐप जिसे आप जानते हैं, नए नाम, नए लुक और कुछ नई सुविधाओं के साथ।';

  @override
  String get rebrandNewHeading => 'नया क्या है';

  @override
  String get rebrandSlideLyricsTitle => 'लिरिक्स, नए सिरे से';

  @override
  String get rebrandSlideLyricsBody =>
      'नया लिरिक्स पेज और ज़्यादा स्रोत, ताकि ज़्यादा गानों को उनके बोल मिलें। किसी लाइन पर टैप करके वहाँ पहुँचें। अब आप बोल को अपनी पसंद की किसी भी भाषा में अनुवाद कर सकते हैं।';

  @override
  String get rebrandSlideWidgetTitle => 'नया होम स्क्रीन विजेट';

  @override
  String get rebrandSlideWidgetBody =>
      'आपके आर्टवर्क के रंगों वाला ग्लास, और पिछला, प्ले और अगला बटन जो ऐप खोले बिना काम करते हैं।';

  @override
  String get rebrandSlideQueueTitle => 'असली क्यू';

  @override
  String get rebrandSlideQueueBody =>
      'देखें क्या चला और आगे क्या है। क्रम बदलने के लिए खींचें, हटाने के लिए स्वाइप करें।';

  @override
  String get rebrandSlideOutputTitle => 'चुनें कि कहाँ बजे';

  @override
  String get rebrandSlideOutputBody =>
      'होम स्क्रीन पर ब्लूटूथ चिप या अभी चल रहा है पर नए बटन पर टैप करें, और ऐप के भीतर ही प्लेबैक को फ़ोन स्पीकर और जुड़े उपकरणों के बीच ले जाएँ।';

  @override
  String get rebrandSlideLibraryTitle => 'अधिक व्यवस्थित लाइब्रेरी';

  @override
  String get rebrandSlideLibraryBody =>
      'Noxira डुप्लिकेट ट्रैक पहचानता है और आपको चुनने देता है कि कौन-सी कॉपी रखनी है। प्लेलिस्ट का नया लेआउट है, जिसमें पसंदीदा, स्वचालित और स्मार्ट प्लेलिस्ट एक ही जगह हैं।';

  @override
  String get rebrandMoreMessages =>
      'संदेश अब स्क्रीन के नीचे एक छोटे आइलैंड के रूप में दिखते हैं।';

  @override
  String get rebrandMorePerformance =>
      'तेज़ खोज, जल्दी स्टार्ट और हल्की छवि लोडिंग।';

  @override
  String get translateLyricsTo => 'लिरिक्स का अनुवाद करें';

  @override
  String get translateLyricsAppLanguage => 'ऐप की भाषा';

  @override
  String get translateLyricsChooseLanguage => 'भाषा चुनें…';

  @override
  String get rebrandSlideMoreTitle => 'और भी कुछ चीज़ें';

  @override
  String get rebrandMoreSetup => 'सेटअप अब आपके फ़ोन के लिए सही मोड सुझाता है।';

  @override
  String get rebrandMoreLook =>
      'ज़्यादा शांत सपोर्ट बैनर, पसंदीदा गानों पर गोल प्ले बटन और लिरिक्स कंट्रोल जो अपनी जगह रहते हैं।';

  @override
  String get rebrandMoreMotion =>
      'पूरे ऐप में ज़्यादा स्मूद और बेहतर ट्रांज़िशन।';

  @override
  String get rebrandMorePlayback =>
      'स्पीड और पिच के अलग स्लाइडर, जिन्हें आप आपस में जोड़ सकते हैं।';

  @override
  String get rebrandMoreSearch =>
      'नया डिज़ाइन किया गया खोज टैब और समूहों में बँटा सेटिंग्स पेज।';

  @override
  String get rebrandMoreFixes =>
      'पूरे ऐप में स्थिरता और बग फ़िक्स, जिनमें लिरिक्स की झिलमिलाहट भी शामिल है।';

  @override
  String get eqTitle => 'समानाकार';

  @override
  String get eqOn => 'चालू';

  @override
  String get eqOff => 'बंद';

  @override
  String get eqNotAvailable => 'इस डिवाइस पर इक्वलाइज़र उपलब्ध नहीं है।';

  @override
  String get eqWaitingForAudio =>
      'इक्वलाइज़र समायोजित करने के लिए कोई गाना चलाएँ।';

  @override
  String get eqOpenSystem => 'ओपन सिस्टम इक्वलाइज़र';

  @override
  String get eqSavePreset => 'प्रीसेट सहेजें';

  @override
  String get eqPresetNameHint => 'उदा. मेरा बास बूस्ट';

  @override
  String get eqPresetNameEmpty => 'नाम खाली नहीं हो सकता।';

  @override
  String eqPresetNameBuiltIn(String name) {
    return '\"$name\" एक अंतर्निर्मित प्रीसेट नाम है।';
  }

  @override
  String get eqResetAllBands => 'सभी बैंड रीसेट करें';

  @override
  String get eqPresetsLabel => 'पूर्वनिर्धारित सेटिंग्स';

  @override
  String get eqYourPresetsLabel => 'आपके प्रीसेट्स';

  @override
  String get eqSaveCurrent => 'वर्तमान सहेजें';

  @override
  String get eqSettingsSubtitle =>
      'प्रत्येक बैंड के अनुसार ऑडियो आवृत्तियों को समायोजित करें';

  @override
  String get eqEmptyPresets =>
      'अपनी ध्वनि समायोजित करें, फिर \"वर्तमान सहेजें\" पर टैप करें।';

  @override
  String get lyricsHint =>
      'अन-सिंक किए हुए बोल यहाँ पेस्ट करें…\n\nप्रति छंद एक पंक्ति।';

  @override
  String get lyricsSelectLrcFile => 'कृपया एक .lrc फ़ाइल चुनें';

  @override
  String get lyricsNoLyricsInFile => 'उस फ़ाइल में कोई गीत के बोल नहीं मिले।';

  @override
  String importFailed(String error) {
    return 'आयात विफल: $error';
  }

  @override
  String get lyricsImportTooltip => '.lrc फ़ाइल आयात करें';

  @override
  String get importPlaylistM3u => 'प्लेलिस्ट आयात करें (.m3u)';

  @override
  String get setSyncFolder => 'सिंक फ़ोल्डर सेट करें…';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get searchPlaylists => 'प्लेलिस्ट खोजें…';

  @override
  String get pleaseSelectM3uFile => 'कृपया एक .m3u या .m3u8 फ़ाइल चुनें।';

  @override
  String get noMatchingSongsForPlaylist =>
      'उस प्लेलिस्ट के लिए कोई मेल खाने वाले गाने नहीं मिले।';

  @override
  String importedPlaylist(String name, int count) {
    return 'आयातित \"$name\" ($count गाने)';
  }

  @override
  String playlistsSyncWith(String folder) {
    return 'प्लेलिस्ट्स $folder के साथ सिंक होंगी।';
  }

  @override
  String couldNotSetSyncFolder(String error) {
    return 'सिंक फ़ोल्डर सेट नहीं हो सका: $error';
  }

  @override
  String get setSyncFolderFirst => 'पहले सिंक फ़ोल्डर सेट करें';

  @override
  String get playlistsSynced => 'प्लेलिस्ट सिंक हो गईं';

  @override
  String get alreadyUpToDate => 'पहले से ही अद्यतित';

  @override
  String syncFailed(String error) {
    return 'सिंक विफल: $error';
  }

  @override
  String exportFailed(String error) {
    return 'निर्यात विफल: $error';
  }

  @override
  String get searchFolders => 'खोज फ़ोल्डर…';

  @override
  String get songInfoPath => 'मार्ग';

  @override
  String get closeVisualiser => 'दृश्यीकरण बंद करें';

  @override
  String get visualizerWaitingForAudio => 'प्लेबैक ऑडियो की प्रतीक्षा...';

  @override
  String get visualizerUnavailable =>
      'इस आउटपुट के लिए लाइव ऑडियो विश्लेषण उपलब्ध नहीं है।';

  @override
  String get previousMode => 'पिछला मोड';

  @override
  String get nextMode => 'अगला मोड';

  @override
  String get sortBy => 'के अनुसार क्रमबद्ध करें';

  @override
  String get colorTheme => 'रंग योजना';

  @override
  String get insightsTotalPlays => 'कुल प्ले';

  @override
  String get insightsTracksHeard => 'ट्रैक सुने हुए';

  @override
  String get insightsEstListening => 'अनुमानित। सुनना';

  @override
  String get dismiss => 'अस्वीकार करें';

  @override
  String updateVersionAvailable(String version) {
    return 'संस्करण $version अब उपलब्ध है।';
  }

  @override
  String get updateNewVersionAvailable => 'एक नया संस्करण अब उपलब्ध है।';

  @override
  String get lyricsPasteLyricsTitle => 'गीत के बोल चिपकाएँ';

  @override
  String get lyricsUseLyrics => 'गीत के बोल का उपयोग करें';

  @override
  String get lyricsPaste => 'पेस्ट';

  @override
  String get lyricsNoLyricsYet => 'अभी तक कोई गीत के बोल नहीं';

  @override
  String get lyricsPasteToGetStarted =>
      'शुरू करने के लिए गीत के बोल पेस्ट करें';

  @override
  String get lyricsNoTimestampsYet =>
      'अभी तक कोई टाइमस्टैम्प नहीं — जब गाना चल रहा हो तो स्टैम्प बटन दबाएँ।';

  @override
  String get lyricsAllLinesStampedHint =>
      'सभी लाइनें स्टैम्प हो गईं — समाप्त करने के लिए सेव पर टैप करें।';

  @override
  String get lyricsAllStamped => '✓ सभी लाइनें मुद्रित';

  @override
  String get lyricsPasteFirst => 'पहले बोल चिपकाएँ';

  @override
  String lyricsTapToStamp(int current, int total) {
    return '⏱ स्टैम्प लाइन $current / $total पर टैप करें';
  }

  @override
  String get lyricsNextLabel => 'अगला';

  @override
  String get translationDisclaimerNote =>
      'कुछ अनुवाद AI द्वारा बनाए गए या समुदाय द्वारा योगदान किए गए हैं और उनमें त्रुटियाँ हो सकती हैं। Crowdin पर उन्हें बेहतर बनाने में हमारी मदद करें।';

  @override
  String get newLanguagesAvailableTitle => 'नई भाषाएँ उपलब्ध';

  @override
  String get newLanguagesAvailableBody =>
      'Noxira Music अब जर्मन, स्पेनिश, हिंदी और रूसी का समर्थन करता है। आप सेटिंग्स में भाषा बदल सकते हैं।';

  @override
  String get newLanguagesGoToSettings => 'भाषा बदलें';

  @override
  String get newLanguagesDismiss => 'ठीक है';

  @override
  String get settingsLyricsSources => 'बोल के स्रोत';

  @override
  String get lyricsProviderDesc =>
      'जब LRCLIB में बोल न हों तब उपयोग होता है। गीत का शीर्षक, कलाकार, एल्बम और अवधि प्राप्त करता है।';

  @override
  String get onlineAboutArtist => 'परिचय';

  @override
  String get onlineFansAlsoLike => 'प्रशंसकों को ये भी पसंद है';

  @override
  String get onlinePopularTracks => 'अभी लोकप्रिय';

  @override
  String get onlineReadMore => 'और पढ़ें';

  @override
  String get onlineBioDisclaimer =>
      'सार्वजनिक स्रोतों से अपने-आप एकत्र किया गया। सटीकता की गारंटी नहीं।';

  @override
  String get onlineShowLess => 'कम दिखाएँ';

  @override
  String get onlineWikipedia => 'Wikipedia';

  @override
  String onlineFansCount(String count) {
    return '$count प्रशंसक';
  }

  @override
  String get settingsOnlineSuggestions => 'ऑनलाइन सुझाव';

  @override
  String get settingsOnlineSuggestionsDesc =>
      'Deezer और Wikipedia से कलाकार की जानकारी और मिलते-जुलते कलाकार खोजें। केवल कलाकार का नाम भेजा जाता है।';

  @override
  String get onboardingUiModeTitle => 'इंटरफ़ेस शैली';

  @override
  String get onboardingUiModeDesc => 'ऐप कितना ग्लास और एनिमेशन इस्तेमाल करे';

  @override
  String get onboardingUiHighEnd => 'हाई-एंड';

  @override
  String get onboardingUiLowEnd => 'हल्का';

  @override
  String get onboardingRecommendedBadge => 'अनुशंसित';

  @override
  String get onboardingRecommendedForDevice => 'आपके डिवाइस के लिए अनुशंसित।';

  @override
  String onboardingTryNote(String recommended, String selected) {
    return 'आपके डिवाइस के स्पेसिफिकेशन के आधार पर हम $recommended की सलाह देते हैं, लेकिन आप $selected भी आज़मा सकते हैं।';
  }

  @override
  String onboardingHeaviestNote(String option) {
    return '$option सबसे भारी विकल्प है और आपके डिवाइस पर कम स्मूद चल सकता है।';
  }

  @override
  String get audioOutput => 'ऑडियो आउटपुट';

  @override
  String get audioOutputBluetoothDevice => 'ब्लूटूथ डिवाइस';

  @override
  String get audioOutputPhoneSpeaker => 'फ़ोन स्पीकर';

  @override
  String get audioOutputWired => 'वायर्ड हेडफ़ोन';

  @override
  String get audioOutputUsb => 'USB ऑडियो';

  @override
  String get audioOutputOther => 'अन्य आउटपुट';

  @override
  String get audioOutputNoOthers => 'कोई अन्य डिवाइस नहीं मिला';

  @override
  String get audioOutputCurrentDevice => 'वर्तमान डिवाइस';

  @override
  String get audioOutputSwitchFailed => 'ऑडियो आउटपुट बदला नहीं जा सका';

  @override
  String get duplicatesBannerTitle => 'डुप्लिकेट ट्रैक मिले';

  @override
  String duplicatesBannerSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रैक कई कॉपी में मौजूद हैं',
      one: '1 ट्रैक कई कॉपी में मौजूद है',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesReview => 'समीक्षा करें';

  @override
  String get duplicatesScreenTitle => 'डुप्लिकेट ट्रैक';

  @override
  String get duplicatesEmpty => 'कोई डुप्लिकेट नहीं मिला';

  @override
  String get duplicatesIgnore => 'अनदेखा करें';

  @override
  String get duplicatesIgnoreAll => 'सभी अनदेखा करें';

  @override
  String get duplicatesKeepBest => 'सर्वश्रेष्ठ गुणवत्ता';

  @override
  String duplicatesCopies(int count) {
    return '$count कॉपी';
  }

  @override
  String duplicatesDeleteOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'चुनी हुई रखें, $count और हटाएँ',
      one: 'चुनी हुई रखें, 1 और हटाएँ',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesDeleteFailed => 'कुछ कॉपी हटाई नहीं जा सकीं';

  @override
  String get duplicatesResolved => 'डुप्लिकेट हटा दिए गए';

  @override
  String get duplicatesHint =>
      'रखने के लिए कॉपी चुनें। बाकी आपके डिवाइस से हटा दी जाएँगी।';

  @override
  String get remoteAnnouncementOpenLink => 'और जानें';

  @override
  String get remoteAnnouncementOpenScreen => 'खोलें';

  @override
  String get updateRequiredTitle => 'अपडेट आवश्यक है';

  @override
  String get updateRequiredMessage =>
      'यह संस्करण अब समर्थित नहीं है। उपयोग जारी रखने के लिए कृपया Noxira Music अपडेट करें।';

  @override
  String get settingsSupport => 'सहयोग';

  @override
  String get settingsSupportSubtitle => 'सहयोगी और मदद करने के तरीके';

  @override
  String get supportSupporters => 'सहयोगी';

  @override
  String get supportNoSupportersYet =>
      'अभी तक कोई सहयोगी सूचीबद्ध नहीं है। पहले बनें!';

  @override
  String get musicInsightsTitle => 'संगीत इनसाइट्स';

  @override
  String get insightsActivityByTimeOfDay => 'दिन के समय के अनुसार गतिविधि';

  @override
  String get insightsActivityByDay => 'दिन के अनुसार गतिविधि';

  @override
  String get insightsGenreBreakdown => 'शैली विश्लेषण';

  @override
  String get insightsNoDataTitle => 'अभी तक कोई सुनने का डेटा नहीं';

  @override
  String get insightsNoDataBody =>
      'अपने इनसाइट्स बनाना शुरू करने के लिए कुछ संगीत चलाएं।';

  @override
  String insightsMostActiveAround(String time) {
    return '$time के आसपास सबसे सक्रिय';
  }

  @override
  String insightsMostActiveOn(String day) {
    return 'सबसे सक्रिय दिन: $day';
  }

  @override
  String moreFromArtist(String artist) {
    return '$artist की और सामग्री';
  }

  @override
  String tracksCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रैक',
      one: '1 ट्रैक',
    );
    return '$_temp0';
  }

  @override
  String songsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गाने',
      one: '1 गाना',
    );
    return '$_temp0';
  }

  @override
  String albumsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count एल्बम',
      one: '1 एल्बम',
    );
    return '$_temp0';
  }

  @override
  String playlistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लेलिस्ट',
      one: '1 प्लेलिस्ट',
    );
    return '$_temp0';
  }

  @override
  String foldersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोल्डर',
      one: '1 फ़ोल्डर',
    );
    return '$_temp0';
  }

  @override
  String foldersExcludedCount(int count) {
    return '$count बाहर रखे गए';
  }

  @override
  String get unknownAlbum => 'अज्ञात एल्बम';

  @override
  String get queueNextUp => 'आगे';

  @override
  String queueNextFrom(String source) {
    return '$source से आगे';
  }

  @override
  String get queueNothingElse => 'कतार में और कुछ नहीं';

  @override
  String get queueMoveToEnd => 'अंत में ले जाएं';

  @override
  String get translateLyrics => 'गीत के बोल अनुवाद करें';

  @override
  String get translateFailedTapToRetry =>
      'अनुवाद विफल — पुनः प्रयास के लिए टैप करें';

  @override
  String get translateShowOriginal => 'मूल दिखाएं';

  @override
  String get translateShowTranslation => 'अनुवाद दिखाएं';

  @override
  String get lyricsAiTranslatedNote =>
      'AI द्वारा अनुवादित · सटीकता भिन्न हो सकती है';

  @override
  String lyricsCantTranslateSameLanguage(String language) {
    return 'अनुवाद संभव नहीं — बोल पहले से लक्ष्य भाषा में हैं ($language)';
  }

  @override
  String get lyricsAddLyrics => 'बोल जोड़ें';

  @override
  String get lyricsBlurOn => 'बोल ब्लर: चालू';

  @override
  String get lyricsBlurOff => 'बोल ब्लर: बंद';

  @override
  String get lyricsAutoHideOn => 'नियंत्रण स्वतः छिपाएं: चालू';

  @override
  String get lyricsAutoHideOff => 'नियंत्रण स्वतः छिपाएं: बंद';

  @override
  String get lyricsEditCreate => 'बोल संपादित करें / बनाएं';

  @override
  String get sleepTimerMinShort => 'मिनट';

  @override
  String sleepTimerMinutesValue(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get sleepTimerMusicStopsAfter => 'संगीत इसके बाद रुकेगा…';

  @override
  String get sleepTimerPickDuration => 'नीचे अवधि चुनें';

  @override
  String get visualizerBarSpectrum => 'बार स्पेक्ट्रम';

  @override
  String get visualizerCircularBars => 'गोलाकार बार';

  @override
  String get visualizerMirrorBars => 'मिरर बार';

  @override
  String get visualizerFrequencyLine => 'फ़्रीक्वेंसी लाइन';

  @override
  String get visualizerDotMatrix => 'डॉट मैट्रिक्स';

  @override
  String get visualizerPeakBars => 'पीक बार';

  @override
  String get visualizerCircularWave => 'गोलाकार तरंग';

  @override
  String get visualizerAuroraWaves => 'ऑरोरा तरंगें';

  @override
  String get visualizerPulseRings => 'पल्स रिंग';

  @override
  String get smartFieldFolderPath => 'फ़ोल्डर पथ';

  @override
  String get smartFieldLiked => 'पसंदीदा';

  @override
  String get smartFieldPlayCount => 'प्ले काउंट';

  @override
  String get smartFieldDurationSeconds => 'अवधि (सेकंड)';

  @override
  String get smartFieldDaysSinceAdded => 'जोड़े जाने के बाद के दिन';

  @override
  String get smartOpContains => 'में शामिल है';

  @override
  String get smartOpNotContains => 'में शामिल नहीं है';

  @override
  String get smartOpEquals => 'के बराबर है';

  @override
  String get smartOpNotEquals => 'के बराबर नहीं है';

  @override
  String get smartOpGreaterThan => 'से अधिक है';

  @override
  String get smartOpLessThan => 'से कम है';

  @override
  String get smartOpIsTrue => 'सही है';

  @override
  String get smartOpIsFalse => 'गलत है';

  @override
  String get smartSortTitleAZ => 'शीर्षक (A-Z)';

  @override
  String get smartSortArtistAZ => 'कलाकार (A-Z)';

  @override
  String get smartSortDateAddedNewest => 'जोड़ने की तारीख (नवीनतम)';

  @override
  String get smartSortPlayCountHighest => 'प्ले काउंट (सर्वाधिक)';

  @override
  String get smartSortDurationLongest => 'अवधि (सबसे लंबी)';

  @override
  String get smartSortRandom => 'यादृच्छिक';

  @override
  String get folderFilterTitle => 'फ़ोल्डर फ़िल्टर';

  @override
  String get artistSeparatorTestHint => 'जैसे कलाकार एक / कलाकार दो feat. तीन';

  @override
  String get tracksPermissionRequired =>
      'मीडिया लाइब्रेरी तक पहुँचने की अनुमति आवश्यक है। कृपया ऑनबोर्डिंग या ऐप सेटिंग्स में अनुमतियाँ दें।';

  @override
  String tracksErrorFetching(String error) {
    return 'गाने प्राप्त करने में त्रुटि: $error';
  }

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get selectItemToViewDetails => 'विवरण देखने के लिए कोई आइटम चुनें';

  @override
  String get takeMeThere => 'मुझे वहाँ ले चलें';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get aboutCodename => 'कोडनेम';

  @override
  String get aboutDeveloper => 'डेवलपर';

  @override
  String get aboutCopyright => 'कॉपीराइट';

  @override
  String get aboutWebsite => 'वेबसाइट';

  @override
  String get openSourcePackages => 'ओपन सोर्स पैकेज';

  @override
  String packagesUsedCount(int count) {
    return '$count पैकेज उपयोग किए गए';
  }

  @override
  String get packagesThanks => 'सभी ओपन सोर्स योगदानकर्ताओं का धन्यवाद!';

  @override
  String versionWithCodename(String version, String codename) {
    return 'संस्करण $version ($codename)';
  }

  @override
  String get customColor => 'कस्टम रंग';

  @override
  String exportPlaylistAs(String format) {
    return 'निर्यात करें ($format)';
  }

  @override
  String get shareClipListeningTo => 'सुन रहा हूँ';

  @override
  String get shareClipNowOn => 'अब';

  @override
  String get splashInitializingServices => 'सेवाएं शुरू हो रही हैं';

  @override
  String get splashLoadingLibrary => 'लाइब्रेरी लोड हो रही है';

  @override
  String get splashPreparingHome => 'होम तैयार हो रहा है';

  @override
  String get splashCachingArtwork => 'आर्टवर्क कैश हो रहा है';

  @override
  String get splashFinalPreparations => 'अंतिम तैयारियां';

  @override
  String get queueHistory => 'इतिहास';

  @override
  String get sortName => 'नाम';

  @override
  String get bannerInsightsNewTitle => 'आपके संगीत इनसाइट्स आ गए हैं ✦';

  @override
  String get bannerInsightsNewBody =>
      'अपने शीर्ष ट्रैक, कलाकार और सुनने के पैटर्न देखें';

  @override
  String get bannerRecapTitle => 'आपका संगीत रिकैप आपका इंतज़ार कर रहा है';

  @override
  String get bannerRecapBody => 'अपने शीर्ष गाने और सुनने के रुझान जानें';

  @override
  String get musicalArtist => 'संगीत कलाकार';

  @override
  String get eqPresetFlat => 'फ़्लैट';

  @override
  String get eqPresetBassBoost => 'बास बूस्ट';

  @override
  String get eqPresetBassCut => 'बास कट';

  @override
  String get eqPresetTrebleBoost => 'ट्रेबल बूस्ट';

  @override
  String get eqPresetTrebleCut => 'ट्रेबल कट';

  @override
  String get eqPresetRock => 'रॉक';

  @override
  String get eqPresetPop => 'पॉप';

  @override
  String get eqPresetJazz => 'जैज़';

  @override
  String get eqPresetClassical => 'शास्त्रीय';

  @override
  String get eqPresetElectronic => 'इलेक्ट्रॉनिक';

  @override
  String get eqPresetHipHop => 'हिप हॉप';

  @override
  String get eqPresetRnB => 'R&B';

  @override
  String get eqPresetVocal => 'वोकल';

  @override
  String get eqPresetAcoustic => 'एकॉस्टिक';

  @override
  String get eqPresetDance => 'डांस';

  @override
  String get eqPresetMetal => 'मेटल';

  @override
  String get eqPresetLounge => 'लाउंज';

  @override
  String get eqPresetSpokenWord => 'बोला गया शब्द';

  @override
  String get supportOfMonthlyGoal => 'इस महीने के लक्ष्य का';

  @override
  String get cl200Hl1 => 'Aurora Music अब Noxira Music है, नए रूप के साथ';

  @override
  String get cl200Hl2 =>
      'गीत के बोल किसी भी भाषा में अनुवाद करें, अधिक स्रोतों से';

  @override
  String get cl200Hl3 =>
      'प्लेबैक नियंत्रणों के साथ नया डिज़ाइन किया गया होम स्क्रीन विजेट';

  @override
  String get cl200Hl4 => 'नया डिज़ाइन किया गया क्यू';

  @override
  String get cl200Hl5 =>
      'ब्लूटूथ चिप या अभी चल रहा है से चुनें कि ऑडियो कहाँ चले';

  @override
  String get cl200Hl6 => 'शब्द-दर-शब्द बोल, जब स्रोत में टाइमिंग हो';

  @override
  String get cl200Hl7 =>
      'डुप्लिकेट ट्रैक पहचाने जाते हैं, और आप चुनते हैं कि कौन-सी कॉपी रखनी है';

  @override
  String get cl200Hl8 => 'ग्लास सतहें जो आपके फ़ोन के अनुसार ढल जाती हैं';

  @override
  String get cl200Hl9 => 'अधिक सहज ट्रांज़िशन और तेज़ विवरण पेज';

  @override
  String get cl200SecWelcome => 'Noxira में आपका स्वागत है';

  @override
  String get cl200SecNew => 'नई सुविधाएँ';

  @override
  String get cl200SecLibrary => 'प्लेलिस्ट और लाइब्रेरी';

  @override
  String get cl200SecSetup => 'सेटअप';

  @override
  String get cl200SecLook => 'रूप और अनुभव';

  @override
  String get cl200SecPerf => 'प्रदर्शन';

  @override
  String get cl200SecHood => 'पर्दे के पीछे';

  @override
  String get cl200Welcome1 =>
      'Aurora Music अब Noxira Music है, नए नाम, वर्डमार्क और ऐप आइकन के साथ';

  @override
  String get cl200Welcome2 =>
      'एक नई एनिमेटेड स्प्लैश स्क्रीन Noxira वर्डमार्क बनाती है';

  @override
  String get cl200Welcome3 =>
      'मौजूदा उपयोगकर्ताओं को नया क्या है यह बताने वाला एक छोटा स्वागत पेज मिलता है, जिसे आप सेटिंग्स से फिर खोल सकते हैं';

  @override
  String get cl200New1 =>
      'गीत के बोल किसी भी भाषा में अनुवाद करें, केवल ऐप की भाषाओं में ही नहीं';

  @override
  String get cl200New2 =>
      'नया डिज़ाइन किया गया होम स्क्रीन विजेट: आपके आर्टवर्क के रंग में ग्लास, बिना ऐप खोले काम करने वाले पिछला / प्ले / अगला बटन, और विजेट लंबा होने पर सुझाए गए गाने';

  @override
  String get cl200New3 =>
      'नया डिज़ाइन किया गया क्यू पेज — देखें क्या बजा और आगे क्या है, क्रम बदलने के लिए खींचें, हटाने के लिए स्वाइप करें; अब अभी चल रहा है पर “आगे” का पूर्वावलोकन भी है';

  @override
  String get cl200New4 =>
      'मासिक सहयोग लक्ष्य समय-समय पर होम ऐप बार में और सेटिंग्स में “के बारे में” के अंतर्गत दिखता है';

  @override
  String get cl200New5 => 'लाइब्रेरी को रीफ़्रेश करने के लिए उसमें नीचे खींचें';

  @override
  String get cl200New6 =>
      'चुनें कि ऑडियो कहाँ चले: होम स्क्रीन पर ब्लूटूथ चिप या अभी चल रहा है पर नए आउटपुट आइलैंड पर टैप करें, और ऐप छोड़े बिना प्लेबैक को फ़ोन स्पीकर और जुड़े उपकरणों के बीच ले जाएँ';

  @override
  String get cl200New7 =>
      'स्पीड और पिच के अब अपने स्लाइडर हैं, और आप पिच को स्पीड से जोड़ सकते हैं';

  @override
  String get cl200New8 =>
      'पाँच नई विज़ुअलाइज़र शैलियाँ, और अधिक बार वाला बारीक स्पेक्ट्रम';

  @override
  String get cl200New9 =>
      'Noxira टीम की वैकल्पिक घोषणाएँ होम स्क्रीन पर दिख सकती हैं, एक बटन के साथ जो लिंक या ऐप की कोई स्क्रीन खोलता है';

  @override
  String get cl200Lyrics1 =>
      'नया डिज़ाइन किया गया बोल पेज: किसी पंक्ति पर टैप करके वहाँ जाएँ, बिंदु वाद्य अंतराल दिखाते हैं, और अभी चल रहा है का बोल बॉक्स साथ-साथ चलता है';

  @override
  String get cl200Lyrics2 =>
      'जब LRCLIB में कुछ न हो तो और बोल स्रोत (BetterLyrics, YouLyPlus और KuGou) आज़माए जाते हैं; सेटिंग्स में चुनें कि कौन-से उपयोग हों';

  @override
  String get cl200Lyrics3 =>
      'ऑडियो फ़ाइल में, या गाने के पास की .lrc फ़ाइल में सहेजे बोल पहले उपयोग होते हैं और ऑफ़लाइन चलते हैं';

  @override
  String get cl200Lyrics4 =>
      'फ़ुल-स्क्रीन बोल पर नियंत्रण स्वतः छिपाना अब एक विकल्प है और डिफ़ॉल्ट रूप से बंद है';

  @override
  String get cl200Lyrics5 =>
      'वे बोल ठीक किए गए जो झिलमिलाकर “बोल उपलब्ध नहीं” के साथ गायब हो जाते थे, रीफ़्रेश या मैन्युअल खोज के बाद भी';

  @override
  String get cl200Lyrics6 =>
      'शब्द-दर-शब्द बोल: जब किसी स्रोत में प्रति-शब्द टाइमिंग हो, तो हर शब्द गाए जाते समय जगमगाता है';

  @override
  String get cl200Library1 =>
      'नई प्लेलिस्ट में जोड़ने की शीट: एक ही जगह प्लेलिस्ट जोड़ें, हटाएँ और बनाएँ, जो गाने पहले से प्लेलिस्ट में हैं वे चिह्नित होते हैं';

  @override
  String get cl200Library2 =>
      'अब कोई गाना एक ही प्लेलिस्ट में दो बार नहीं जुड़ सकता, और डुप्लिकेट हटाएँ विकल्प मौजूदा डुप्लिकेट साफ़ करता है';

  @override
  String get cl200Library3 =>
      'Noxira अब आपकी लाइब्रेरी में डुप्लिकेट ट्रैक पहचानता है और लाइब्रेरी टैब में उनकी समीक्षा का विकल्प देता है: आप चुनते हैं कौन-सी कॉपी रखनी है';

  @override
  String get cl200Library4 =>
      'नया डिज़ाइन किया गया प्लेलिस्ट पेज: ऊपर पसंदीदा, स्वचालित प्लेलिस्ट टाइल के रूप में, और आपकी अपनी प्लेलिस्ट आर्टवर्क मोज़ेक वाले ग्रिड में';

  @override
  String get cl200Library5 =>
      'नया डिज़ाइन किया गया खोज टैब: ग्लास सर्च बार, परिणाम संख्या और अधिक स्पष्ट खाली व बिना-परिणाम स्थितियाँ';

  @override
  String get cl200Library6 =>
      'चल रहे गाने का आइकन अब प्लेलिस्ट में ट्रैक के साथ चलता है';

  @override
  String get cl200Library7 =>
      'वैकल्पिक ऑनलाइन सुझाव: Deezer और Wikipedia से कलाकार की जानकारी और मिलते-जुलते कलाकार (केवल कलाकार का नाम भेजा जाता है)';

  @override
  String get cl200Library8 =>
      'इक्वलाइज़र अब गलती से खुद को अनुपलब्ध नहीं बताता; वह अपने आप फिर कोशिश करता है और पुनः प्रयास तथा सिस्टम इक्वलाइज़र खोलें के विकल्प देता है';

  @override
  String get cl200Library9 =>
      'कैश जानकारी अब असली आकार दिखाती है, उसका बटन डायलॉग बंद करता है, और कैश साफ़ करें डाउनलोड की गई कलाकार छवियाँ भी साफ़ करता है';

  @override
  String get cl200Setup1 =>
      'ग्लास पैनल, प्रवेश एनिमेशन और बहती पृष्ठभूमि के साथ नया डिज़ाइन किया गया ऑनबोर्डिंग';

  @override
  String get cl200Setup2 =>
      'सेटअप वह इंटरफ़ेस शैली सुझाता है जो आपके फ़ोन के अनुकूल हो (हाई-एंड या हल्की) और मेल खाती पृष्ठभूमि, और दूसरी आज़माने देता है';

  @override
  String get cl200Setup3 =>
      'हल्का इंटरफ़ेस अब हमेशा सादी पृष्ठभूमि उपयोग करता है; एनिमेटेड ब्लॉब्स विकल्प हटा दिया गया';

  @override
  String get cl200Setup4 =>
      'सेटिंग्स अब समूहों (अनुभव, लाइब्रेरी और डेटा, ऐप) में बँटी है, सेटअप जैसे ही सरल ग्लास रूप में';

  @override
  String get cl200Setup5 =>
      'संदेश स्नैकबार के बजाय स्क्रीन के नीचे एक छोटे आइलैंड के रूप में दिखते हैं';

  @override
  String get cl200Look1 =>
      'नया ऐप फ़ॉन्ट (Cal Sans) और पूरे ऐप में थोड़ा अधिक सघन टेक्स्ट';

  @override
  String get cl200Look2 =>
      'हर जगह फ़्रॉस्टेड ग्लास सतहें, कमज़ोर फ़ोन पर सादी ठोस सतह के रूप में बनाई गईं';

  @override
  String get cl200Look3 =>
      'आर्टवर्क कार्ड से एल्बम, कलाकार, फ़ोल्डर और प्लेलिस्ट पेज में उड़ता है; दबाए गए कार्ड प्रतिक्रिया देते हैं, पसंदीदा गाने दिलों में बिखरते हैं, और समय के लेबल घूमते हैं';

  @override
  String get cl200Look4 => 'पसंदीदा गानों पर गोल-चौकोर प्ले बटन';

  @override
  String get cl200Look5 =>
      'होम और लाइब्रेरी कार्ड सेटअप जैसा ही ग्लास रूप उपयोग करते हैं, धुंधली पृष्ठभूमि के ऊपर अतिरिक्त ब्लर के बिना';

  @override
  String get cl200Perf1 =>
      'Noxira आपके फ़ोन का हार्डवेयर पहचानता है और ग्लास प्रभाव, छवि कैश और ट्रांज़िशन को उसके अनुसार ढालता है';

  @override
  String get cl200Perf2 =>
      'एल्बम, कलाकार, फ़ोल्डर और प्लेलिस्ट पेज सहजता से खुलते हैं: वे खुलने के एनिमेशन के बाद लोड होते हैं, गानों का छोटा पहला पेज बनाते हैं और अपने हेडर का आर्टवर्क पहले से धुंधला करते हैं';

  @override
  String get cl200Perf3 =>
      'एक-दूसरे पर चढ़ने वाली लाइब्रेरी क्वेरी दोहराई नहीं जातीं बल्कि साझा होती हैं, जिससे बड़ी लाइब्रेरी में मेमोरी का उपयोग घटता है';

  @override
  String get cl200Perf4 =>
      'तेज़ खोज और लाइब्रेरी रीस्कैन, हल्की छवि लोडिंग और सूचियाँ स्क्रॉल करते समय कम काम';

  @override
  String get cl200Hood1 =>
      'कई क्रैश ठीक किए गए: पेज हटने के बाद बोल संपादक, टैग संपादक या स्लीप टाइमर में बंद करें पर टैप करना, गाने के मेनू से क्यू में जोड़ना या रिंगटोन सेट करना, बोल अनुवाद करना, और विजेट से Noxira खोलना';

  @override
  String get cl200Hood2 => 'स्टोरेज अनुमति न होने पर ऐप अब क्रैश नहीं होता';

  @override
  String get cl200Hood3 =>
      'प्लेलिस्ट, पसंदीदा गाने, प्ले काउंट और सेटिंग्स सुरक्षित रूप से सहेजे जाते हैं, इसलिए बाधित सेव अब खाली फ़ाइल नहीं छोड़ता';

  @override
  String get cl200Hood4 =>
      'वे FLAC फ़ाइलें जिनके मेटाडेटा ब्लॉक टैग संपादक ने अधूरे छोड़ दिए थे, सेव करते समय ठीक हो जाती हैं, इसलिए वे फिर बजती हैं';

  @override
  String get cl200Hood5 =>
      'मीडिया नोटिफ़िकेशन का आर्टवर्क छोटा किया जाता है ताकि नोटिफ़िकेशन बनते समय फ़्रीज़ न हो';

  @override
  String get cl200Hood6 =>
      'वॉइस रिकॉर्डिंग (M4A) पर टैग संपादन अब फ़ाइल के अंत में बचे डेटा के कारण विफल नहीं होता';

  @override
  String get cl200Hood7 =>
      'विज़ुअलाइज़र अब Dolby Atmos ट्रैक को विकृत नहीं करता; वे सिम्युलेटेड एनिमेशन उपयोग करते हैं';

  @override
  String get cl200Hood8 =>
      'जो फ़ोन इक्वलाइज़र प्रभाव नहीं बना सकते वे अब सामान्य रूप से बजाते हैं, और इक्वलाइज़र टाइमआउट होने के बजाय पहले गाने की प्रतीक्षा करता है';

  @override
  String get cl200Hood9 =>
      'अपडेट जाँचें अब अपना परिणाम दिखाता है, और बताता है जब अपडेट Google Play से आते हैं';

  @override
  String get cl200Hood10 =>
      'घोषणाएँ, सहयोग लक्ष्य और कुछ ऑनलाइन सेवाएँ ऐप अपडेट के बिना समायोजित की जा सकती हैं';

  @override
  String get cl200Hood11 => 'निर्भरताएँ अपडेट की गईं';

  @override
  String get pkgJustAudio => 'Flutter के लिए सुविधा-समृद्ध ऑडियो प्लेयर';

  @override
  String get pkgAudioService => 'बैकग्राउंड ऑडियो प्लेबैक और मीडिया नियंत्रण';

  @override
  String get pkgAudioSession => 'सही ऑडियो फ़ोकस के लिए ऑडियो सेशन प्रबंधन';

  @override
  String get pkgOnAudioQuery => 'डिवाइस स्टोरेज से ऑडियो फ़ाइलें खोजें';

  @override
  String get pkgHaudiotagger => 'ऑडियो मेटाडेटा टैग पढ़ें और लिखें';

  @override
  String get pkgProvider => 'Flutter के लिए स्टेट मैनेजमेंट समाधान';

  @override
  String get pkgSharedPreferences => 'स्थायी की-वैल्यू स्टोरेज';

  @override
  String get pkgPathProvider => 'डिवाइस के फ़ाइल सिस्टम पथों तक पहुँच';

  @override
  String get pkgPermissionHandler => 'रनटाइम अनुमतियाँ संभालें';

  @override
  String get pkgDynamicColor => 'Material You डायनामिक कलर थीमिंग';

  @override
  String get pkgPaletteGenerator => 'छवियों से रंग निकालें';

  @override
  String get pkgStaggeredAnimations => 'सूचियों के क्रमिक एनिमेशन';

  @override
  String get pkgHttp => 'API कॉल के लिए HTTP अनुरोध';

  @override
  String get pkgUrlLauncher => 'ब्राउज़र में URL खोलें';

  @override
  String get pkgSharePlus => 'अन्य ऐप्स के साथ सामग्री साझा करें';

  @override
  String get pkgPackageInfoPlus => 'ऐप संस्करण और पैकेज जानकारी प्राप्त करें';

  @override
  String get pkgDeviceInfoPlus => 'डिवाइस की जानकारी प्राप्त करें';

  @override
  String get pkgFlutterDotenv => '.env फ़ाइल से एनवायरनमेंट वेरिएबल लोड करें';

  @override
  String get pkgCrypto => 'क्रिप्टोग्राफ़िक हैशिंग फ़ंक्शन';

  @override
  String get pkgIntl => 'अंतर्राष्ट्रीयकरण और स्थानीयकरण';

  @override
  String get pkgPubSemver => 'सिमेंटिक वर्शनिंग उपयोगिताएँ';

  @override
  String get pkgClarityFlutter => 'Microsoft Clarity एनालिटिक्स';

  @override
  String get pkgFlutterHooks => 'Flutter के लिए React जैसे हुक';

  @override
  String get themeAurora => 'ऑरोरा';

  @override
  String get themeMidnight => 'आधी रात';

  @override
  String get themeOcean => 'महासागर';

  @override
  String get themeTeal => 'टील';

  @override
  String get themeForest => 'जंगल';

  @override
  String get themeNeon => 'नियॉन';

  @override
  String get themeGold => 'सुनहरा';

  @override
  String get themeEmber => 'अंगारा';

  @override
  String get themeRose => 'गुलाब';

  @override
  String get themeSakura => 'साकुरा';

  @override
  String artistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कलाकार',
      one: '1 कलाकार',
    );
    return '$_temp0';
  }

  @override
  String get playbackInvalidPlaylist => 'अमान्य प्लेलिस्ट या प्रारंभ स्थिति';

  @override
  String playbackCouldNotPlayTitleSkipping(String title) {
    return '“$title” नहीं चल सका — छोड़ा जा रहा है';
  }

  @override
  String get playbackCouldNotPlaySkipping =>
      'यह गाना नहीं चल सका — छोड़ा जा रहा है';

  @override
  String playbackCouldNotPlayTitle(String title) {
    return '“$title” नहीं चल सका';
  }

  @override
  String get playbackFailed => 'प्लेबैक विफल';

  @override
  String playbackSetPlaylistFailed(String error) {
    return 'प्लेलिस्ट सेट करने में विफल: $error';
  }

  @override
  String playbackUpdatePlaylistFailed(String error) {
    return 'प्लेलिस्ट अपडेट करने में विफल: $error';
  }
}
