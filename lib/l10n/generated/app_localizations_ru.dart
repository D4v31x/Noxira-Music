// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get aboutArtist => 'Об Исполнителе';

  @override
  String get add => 'Добавить';

  @override
  String get addExclusion => 'Добавить Исключение';

  @override
  String get addSeparator => 'Добавить Разделитель';

  @override
  String get addSongs => 'Добавить Песни';

  @override
  String get addSongsToPlaylist => 'Добавить Песни в Плейлист';

  @override
  String get addToPlaylist => 'Добавить в Плейлист';

  @override
  String get adjustSync => 'Настройка Синхронизации';

  @override
  String get album => 'Альбом';

  @override
  String get albums => 'Альбомы';

  @override
  String get allSongs => 'Все песни';

  @override
  String get appName => 'Noxira Music';

  @override
  String get artist => 'Исполнитель';

  @override
  String get artistName => 'Имя исполнителя';

  @override
  String get artists => 'Исполнители';

  @override
  String get artistSeparation => 'Разделитель Исполнителей';

  @override
  String get artistSeparationDesc =>
      'Настройте как разделяются несколько исполнителей';

  @override
  String get audioQuality => 'Качество Звука';

  @override
  String get audioQualityDesc => 'Технические характеристики аудиофайла';

  @override
  String get auroraMusic => 'Noxira Music';

  @override
  String get autoPlaylists => 'Автоплейлист';

  @override
  String get autoTag => 'Автотег';

  @override
  String get smartPlaylists => 'Умные плейлисты';

  @override
  String get createSmartPlaylist => 'Создать интеллектуальный плейлист…';

  @override
  String get editSmartPlaylist => 'Редактировать интеллектуальный плейлист';

  @override
  String get smartPlaylistNameHint => 'Название плейлиста';

  @override
  String get smartPlaylistRules => 'Правила';

  @override
  String get addRule => 'Добавить правило';

  @override
  String get saveSmartPlaylist => 'Сохранить';

  @override
  String get matchAll => 'Соответствовать ВСЕМ правилам';

  @override
  String get matchAny => 'Правило «Соответствие ЛЮБОМУ»';

  @override
  String get limitResultsLabel => 'Ограничить результаты';

  @override
  String get noLimit => 'Без ограничений';

  @override
  String get deleteSmartPlaylistConfirm =>
      'Удалить этот интеллектуальный плейлист? При этом будут удалены только сохраненные правила — на ваши песни это никак не повлияет.';

  @override
  String smartPlaylistPreviewCount(int count) {
    return 'Сейчас найдено $count песен';
  }

  @override
  String get saveAsClip => 'Сохранить как клип';

  @override
  String get generatingClip => 'Создание клипа…';

  @override
  String get clipDuration => 'Продолжительность клипа';

  @override
  String get clipStartOffset => 'Начальная точка';

  @override
  String get saveClip => 'Сохранить клип';

  @override
  String get clipSavedToDevice => 'Клип сохранен на устройстве';

  @override
  String get clipSaveFailed =>
      'Не удалось сохранить клип. Пожалуйста, попробуйте ещё раз.';

  @override
  String get playlistSavedToDevice => 'Плейлист сохранен на устройстве';

  @override
  String get trackTags => 'Теги треков';

  @override
  String get editTrackTags => 'Редактировать теги';

  @override
  String get addTrackTag => 'Добавить тег';

  @override
  String get noTrackTagsYet =>
      'Тегов пока нет. Добавьте тег, чтобы сразу перейти к определенному участку этого трека.';

  @override
  String get trackTagNameHint => 'например, название песни или исполнитель';

  @override
  String get trackTagPosition => 'Должность';

  @override
  String get useCurrentPosition => 'Использовать текущее положение';

  @override
  String get isThisASet => 'Добавить временные метки к этой дорожке';

  @override
  String get tagPartsForEasySwitching =>
      'Отмечайте любые моменты — главы, важные фрагменты, закладки или что угодно.';

  @override
  String get tagThisTrack => 'Добавить теги';

  @override
  String get pasteSetlist => 'Импорт временных меток';

  @override
  String get pasteSetlistDialogTitle => 'Импорт временных меток';

  @override
  String get pasteSetlistHint =>
      'Вставьте сюда временные метки, например:\n0:00 Вступление\n3:45 Название главы';

  @override
  String get importAction => 'Импорт';

  @override
  String tagsImportedMessage(int count) {
    return 'Импортировано $count тегов';
  }

  @override
  String get noTagsFoundInPaste =>
      'В вставленном тексте не найдено временных меток.';

  @override
  String get bitrate => 'Битрейт';

  @override
  String get buyMeCoffee => 'Купи Мне Кофе';

  @override
  String get cancel => 'Закрыть';

  @override
  String get coffeeSupport => 'Поддержать кружкой кофе';

  @override
  String get composer => 'Композитор';

  @override
  String get connectWithUs => 'Связаться с нами';

  @override
  String get copied => 'Скопировано';

  @override
  String get copy => 'Скопировать';

  @override
  String get create => 'Создать';

  @override
  String get createFirstPlaylist =>
      'Нажми на кнопку выше, чтобы создать ваш первый плейлист';

  @override
  String get createPlaylist => 'Создать Плейлист';

  @override
  String get darkMode => 'Тёмная Тема';

  @override
  String get dateAdded => 'Дата Добавления';

  @override
  String get dateModified => 'Дата Изменения';

  @override
  String get delete => 'Удалить';

  @override
  String get deletePlaylist => 'Удалить Плейлист';

  @override
  String get deletePlaylistConfirm => 'Вы уверены, что хотите удалить';

  @override
  String get deletePlaylistConfirmation =>
      'Вы действительно хотите удалить этот плейлист?';

  @override
  String get deselectAll => 'Отменить выбор всех';

  @override
  String get details => 'Подробнее';

  @override
  String get discard => 'Отменить';

  @override
  String get dontShowAgain => 'Не показывать снова';

  @override
  String get duration => 'Длительность';

  @override
  String get enableArtistSeparation => 'Включить Разделение Исполнителей';

  @override
  String get enableArtistSeparationDesc =>
      'Автоматически разделять составные имена исполнителей';

  @override
  String get enjoyingAurora => 'Нравится Noxira?';

  @override
  String get enjoyingAuroraDesc =>
      'Если вам нравится пользоваться Noxira Music, подумайте о том, чтобы поддержать её разработку. Ваша поддержка помогает сохранить бесплатный доступ к приложению!';

  @override
  String get error => 'Ошибка';

  @override
  String get exclusionHint => 'например, переменный/постоянный ток';

  @override
  String get exclusions => 'Исключения';

  @override
  String get exclusionsDesc =>
      'Имена исполнителей, которые не должны разделяться';

  @override
  String get exit => 'Выйти';

  @override
  String get exitApp => 'Выйти из приложения';

  @override
  String get exitAppConfirm => 'Вы хотите выйти?';

  @override
  String get expandLyrics => 'Показать текст песни';

  @override
  String get extraLarge => 'Огромный';

  @override
  String get favoriteSongs => 'Любимые песни';

  @override
  String get fileInfo => 'Сведения о файле';

  @override
  String get fileInfoDesc =>
      'Нажмите и удерживайте значения, чтобы скопировать их';

  @override
  String get fileName => 'Имя файла';

  @override
  String get filePath => 'Путь к файлу';

  @override
  String get folder => 'Папка';

  @override
  String get folders => 'Папки';

  @override
  String get fontSize => 'Размер шрифта';

  @override
  String get format => 'Формат';

  @override
  String get forYou => 'Для вас';

  @override
  String get genre => 'Жанр';

  @override
  String get goodQuality => 'Хорошее качество';

  @override
  String get gotIt => 'Понял!';

  @override
  String get grantPermission => 'Предоставить разрешение';

  @override
  String get highQuality => 'Высокое качество';

  @override
  String get home => 'Главная';

  @override
  String get kofi => 'Ko-fi';

  @override
  String get buyMeACoffee => 'Купите мне кофе';

  @override
  String get donationNote =>
      'Необязательно - вы можете нас всегда поддержать в настройках';

  @override
  String get language => 'Язык';

  @override
  String get large => 'Большой';

  @override
  String get later => 'Позже';

  @override
  String get library => 'Библиотека';

  @override
  String get libraryError => 'Ошибка загрузки музыкальной библиотеки';

  @override
  String get libraryLoaded => 'Музыкальная библиотека загружена';

  @override
  String get libraryUpdated => 'Библиотека обновлена';

  @override
  String get loading => 'Загрузка';

  @override
  String get loadingLibrary => 'Загрузка библиотеки';

  @override
  String get lossless => 'Без потерь';

  @override
  String get lowQuality => 'Низкое Качество';

  @override
  String get lyrics => 'Текст';

  @override
  String get lyricsAhead => 'Текст опережает';

  @override
  String get lyricsBehind => 'Текст отстаёт';

  @override
  String get lyricsSynced => 'Текст синхронизирован';

  @override
  String get maybeLater => 'Позже';

  @override
  String get medium => 'Средний';

  @override
  String get metadata => 'Метаданные';

  @override
  String get metadataSaved => 'Метаданные успешно изменены';

  @override
  String get metadataApplied => 'Метаданные успешно загружены';

  @override
  String get metadataDownloadFailed =>
      'Загрузка не удалась. Проверьте подключение и попробуйте ещё раз.';

  @override
  String get chooseArtworkFromDevice => 'Выберите устройство';

  @override
  String get mostPlayed => 'Часто Прослушиваемое';

  @override
  String get newPlaylist => 'Новый Плейлист';

  @override
  String get next => 'Следующее';

  @override
  String get no => 'Нет';

  @override
  String get noAlbumsFound => 'Альбомов не найдено';

  @override
  String get noArtistInfo => 'Информация об артисте не доступна';

  @override
  String get noArtistsFound => 'Артистов не найдено';

  @override
  String get noData => 'Нет данных для отображения';

  @override
  String get noExclusions => 'Исключения не настроены';

  @override
  String get noLyrics => 'Текст недоступен';

  @override
  String get noLyricsDesc => 'Мы не нашли текст для этой песни';

  @override
  String get noLyricsFound => 'Текст не найден';

  @override
  String get noPermissionExplanation =>
      'Без разрешений Noxira Music не сможет получить доступ к вашей библиотеке музыки.';

  @override
  String get noPlaylists => 'Плейлистов нет';

  @override
  String get noResults => 'Результатов не найдено';

  @override
  String get noSeparators => 'Разделители не настроены';

  @override
  String get noSongPlaying => 'Никакая песня не воспроизводится';

  @override
  String get noSongsAvailable => 'Песен нет';

  @override
  String get noSongsInPlaylist => 'В этом плейлисте нет песен';

  @override
  String get nowPlaying => 'Сейчас играет';

  @override
  String get onboardingAlbumArtwork => 'Обложка альбома';

  @override
  String get onboardingAlbumArtworkDesc =>
      'Загружает высококачественные обложки альбомов для улучшения вашей медиатеки';

  @override
  String get onboardingAnalytics => 'Анонимная аналитика и отчёты о сбоях';

  @override
  String get onboardingAnalyticsDesc =>
      'Помогает нам исправлять ошибки и улучшать производительность. Никогда не включает историю прослушивания или личные данные.';

  @override
  String get onboardingAppInfoSubtitle => 'Ваш личный музыкальный спутник';

  @override
  String get onboardingAudioAccess => 'Доступ к аудиоматериалам';

  @override
  String get onboardingAudioAccessDesc =>
      'Необходимо для воспроизведения и управления вашей музыкальной библиотекой';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get onboardingBeautifulArtwork => 'Красивая обложка альбома';

  @override
  String get onboardingBeautifulArtworkDesc =>
      'Автоматически загружать и отображать обложки альбомов так, как их задумывали авторы';

  @override
  String get onboardingBluetooth => 'Bluetooth';

  @override
  String get onboardingBluetoothDesc =>
      'Необходимо для подключения к устройствам Bluetooth';

  @override
  String get onboardingChooseLanguage => 'Выберите язык';

  @override
  String get onboardingCompletionSubtitle => 'Начните наслаждаться музыкой';

  @override
  String get onboardingCompletionTitle => 'Всё готово!';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboardingDynamicColors => 'Динамические цвета';

  @override
  String get onboardingDynamicColorsDesc =>
      'Подбор цветов обоев в соответствии с системой';

  @override
  String get onboardingGrantPermissions => 'Предоставить права доступа';

  @override
  String get onboardingInternetSubtitle =>
      'Как компания «Noxira Music» использует Интернет';

  @override
  String get onboardingInternetTitle => 'Использование Интернета';

  @override
  String get onboardingLocalMusic => 'Музыка на вашем устройстве';

  @override
  String get onboardingLocalMusicDesc =>
      'Ваши музыкальные файлы всегда под рукой';

  @override
  String get onboardingLyrics => 'Текст';

  @override
  String get onboardingLyricsDesc =>
      'Скачивает синхронизированные тексты песен с LRCLIB, Better Lyrics, YouLyPlus и KuGou. Эти сервисы получают название, исполнителя, альбом и длительность трека. Отдельные источники можно отключить в настройках.';

  @override
  String get onboardingLyricsSupport => 'Поддержка текстов песен';

  @override
  String get onboardingLyricsSupportDesc =>
      'Просматривайте синхронизированные тексты песен во время прослушивания';

  @override
  String get onboardingMaterialDesign => 'Дизайн «Material You»';

  @override
  String get onboardingMaterialDesignDesc =>
      'Динамичные цвета, которые подстраиваются под ваши предпочтения';

  @override
  String get onboardingMusicMetadata => 'Метаданные музыки';

  @override
  String get onboardingMusicMetadataDesc =>
      'Получает сведения об исполнителе, данные об альбоме и информацию о треках';

  @override
  String get onboardingNotifications => 'Уведомления';

  @override
  String get onboardingNotificationsDesc =>
      'Показать элементы управления воспроизведением и обновления';

  @override
  String get onboardingPermissionsSubtitle =>
      'Для правильной работы приложению «Noxira Music» необходимы следующие разрешения';

  @override
  String get onboardingPermissionsTitle => 'Предоставить права доступа';

  @override
  String get onboardingPrivacyNote =>
      'Ваша конфиденциальность важна для нас. Все музыкальные файлы хранятся на вашем устройстве.';

  @override
  String get onboardingRequesting => 'Ожидается запрос...';

  @override
  String get onboardingRequired => 'Обязательно';

  @override
  String get onboardingAudioRequired =>
      'Для продолжения требуется доступ к аудио. Пожалуйста, предоставьте указанное выше разрешение.';

  @override
  String get onboardingSelectLanguage => 'Выберите желаемый язык';

  @override
  String get onboardingSmartPlaylists => 'Умный Плейлист';

  @override
  String get onboardingSmartPlaylistsDesc =>
      'Создавайте и управляйте своими музыкальными коллекциями';

  @override
  String get onboardingStartListening => 'Начать прослушивание';

  @override
  String get onboardingStorageAccess => 'Доступ к хранилищу';

  @override
  String get onboardingStorageAccessDesc =>
      'Требуется доступ к музыкальным файлам на вашем устройстве';

  @override
  String get onboardingVisualizerAccess => 'Визуализатор';

  @override
  String get onboardingVisualizerAccessDesc =>
      'Позволяет визуализатору считывать данные аудиосессии вашего устройства для отображения спектра в режиме реального времени. Аудио никогда не записывается.';

  @override
  String get onboardingThemeSubtitle =>
      'Выберите тему, которая соответствует вашему стилю';

  @override
  String get onboardingThemeTitle => 'Создайте свой собственный образ';

  @override
  String get oneTimeSupport => 'Быстрая разовая поддержка';

  @override
  String get openFolder => 'Открыть в диспетчере файлов';

  @override
  String get openFolderInfo =>
      'Воспользуйтесь файловым менеджером, чтобы перейти в этот каталог';

  @override
  String get ownTimer => 'Собственный таймер';

  @override
  String get permDeny => 'Доступ запрещен';

  @override
  String get permissionExplanation =>
      'Приложению Noxira Music требуются эти разрешения для правильной работы. Пожалуйста, предоставьте эти разрешения в настройках приложения.';

  @override
  String get permissionLater =>
      'Вы можете предоставить разрешения позже в настройках приложения';

  @override
  String get permissionRequired => 'Требуется разрешение';

  @override
  String get playAll => 'Воспроизвести всё';

  @override
  String get playingFrom => 'Воспроизведение с';

  @override
  String get playlist => 'Плейлист';

  @override
  String get playlistName => 'Название плейлиста';

  @override
  String get playlists => 'Плейлисты';

  @override
  String get possibleReasons => 'Возможные причины:';

  @override
  String get privacyNotice =>
      'Продолжая пользоваться этим приложением, вы соглашаетесь с нашей Политикой конфиденциальности.';

  @override
  String get privacyPolicyLink =>
      'Ознакомьтесь с нашей Политикой конфиденциальности';

  @override
  String get quality => 'Качество';

  @override
  String get queue => 'Очередь';

  @override
  String get queueEmpty => 'Очередь пуста';

  @override
  String get reasonFormat =>
      'Данный формат файла не поддерживает редактирование метаданных';

  @override
  String get reasonPermissions => 'Права на хранение не предоставлены';

  @override
  String get reasonReadonly =>
      'Файл доступен только для чтения или находится на внешнем носителе';

  @override
  String get recentlyAdded => 'Недавно добавленные';

  @override
  String get recentlyPlayed => 'Недавно воспроизведенные';

  @override
  String get recentlyPlayedArtists => 'Недавно прослушанные исполнители';

  @override
  String get recentlyPlayedSongs => 'Недавно прослушанные песни';

  @override
  String get refreshing => 'Освежает...';

  @override
  String get refreshLyrics => 'Обновить тексты песен';

  @override
  String get remove => 'Удалить';

  @override
  String get removeSong => 'Удалить песню';

  @override
  String get removeSongConfirmation => 'Удалить эту песню из плейлиста?';

  @override
  String get rename => 'Переименовать';

  @override
  String get renamePlaylist => 'Переименовать плейлист';

  @override
  String get repeat => 'Повторить';

  @override
  String get reset => 'Сброс';

  @override
  String get resetArtistSeparationDesc =>
      'Это приведет к восстановлению всех разделителей и исключений по умолчанию.';

  @override
  String get resetToDefaults => 'Сброс на настройки по умолчанию';

  @override
  String get result => 'Результат';

  @override
  String get results => 'Результаты';

  @override
  String get retry => 'Повторить попытку';

  @override
  String get sampleRate => 'Частота дискретизации';

  @override
  String get save => 'Сохранить';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get saveChangesDesc => 'Хотите сохранить изменения?';

  @override
  String get saveFailed => 'Сохранение не удалось';

  @override
  String get saveFailedDesc => 'Не удалось сохранить метаданные в этом файле.';

  @override
  String get scanFailed => 'Сканирование не удалось';

  @override
  String get scanningSongs => 'Сканирование песен';

  @override
  String get search => 'Поиск';

  @override
  String get searchAlbums => 'Поиск альбомов';

  @override
  String get searchArtists => 'Поиск исполнителей';

  @override
  String get searchFailed => 'Поиск не удался';

  @override
  String get lyricsSource => 'Источник текста';

  @override
  String get inPlaylistHint => 'В плейлисте';

  @override
  String get removeDuplicates => 'Удалить дубликаты';

  @override
  String get noDuplicatesFound => 'Дубликаты песен не найдены';

  @override
  String duplicatesRemoved(int count) {
    return 'Удалено дубликатов песен: $count';
  }

  @override
  String get supportNoxiraTitle => 'Поддержите Noxira!';

  @override
  String get supportButton => 'Поддержать';

  @override
  String supportGoalProgress(String raised, String goal) {
    return '$raised из $goal в этом месяце';
  }

  @override
  String get onboardingSupportGoal => 'Цель поддержки';

  @override
  String get onboardingSupportGoalDesc =>
      'Время от времени скачивает крошечный общедоступный файл с целью поддержки на этот месяц и уже собранной суммой. Это обычная загрузка: ничего о вас и вашей музыке не отправляется.';

  @override
  String get songAddedChip => 'Добавлено';

  @override
  String get tapToRemove => 'Нажмите, чтобы удалить';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingYourLanguage => 'Ваш язык?';

  @override
  String get onboardingAllow => 'Разрешить';

  @override
  String get onboardingSummaryLanguage => 'Язык';

  @override
  String get onboardingSummaryTheme => 'Внешний вид';

  @override
  String get onboardingSummaryLibrary => 'Доступ к музыкальной медиатеке';

  @override
  String get onboardingAllowed => 'Разрешено';

  @override
  String get onboardingNotAllowed => 'Пока не разрешено';

  @override
  String get searchLyrics => 'Поиск текстов песен';

  @override
  String get searchMetadata => 'Поиск по метаданным';

  @override
  String get searchTracks => 'Поиск треков';

  @override
  String get selectAll => 'Выделить всё';

  @override
  String get selectArtist => 'Выбрать исполнителя';

  @override
  String get selected => 'выбранный';

  @override
  String get separator => 'Разделитель';

  @override
  String get separatorHint => 'например, / или при участии';

  @override
  String get separators => 'Разделители';

  @override
  String get set => 'Набор';

  @override
  String get setMinutes => 'Установить продолжительность';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsAbout => 'О нас';

  @override
  String get settingsAboutApp => 'О компании «Noxira Music»';

  @override
  String get settingsAboutSubtitle => 'Версия, отзывы и обновления';

  @override
  String get settingsGroupExperience => 'Впечатления';

  @override
  String get settingsGroupLibrary => 'Медиатека и данные';

  @override
  String get settingsGroupApp => 'Приложение';

  @override
  String get settingsAccentColor => 'Акцентный цвет';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsAppearanceSubtitle => 'Тема, цвета и макет';

  @override
  String get settingsAudio => 'Аудио';

  @override
  String get settingsBackground => 'Общая информация';

  @override
  String get settingsCacheCleared => 'Кэш очищен';

  @override
  String get settingsCacheInfo => 'Информация о кэше';

  @override
  String get settingsCacheInfoDesc =>
      'Просмотреть использование дискового пространства';

  @override
  String get settingsCheckingUpdates => 'Проверка наличия обновлений...';

  @override
  String get settingsCheckUpdates => 'Проверить наличие обновлений';

  @override
  String get settingsCheckUpdatesDesc => 'Скачать последнюю версию';

  @override
  String get settingsClearCache => 'Очистить кэш';

  @override
  String get settingsClearCacheDesc => 'Удалить все данные из кэша';

  @override
  String get settingsClearCacheMessage =>
      'Все данные из кэша будут удалены и при необходимости восстановлены.';

  @override
  String get settingsClearCacheTitle => 'Очистить кэш?';

  @override
  String get settingsDataWindow => 'Окно данных';

  @override
  String get settingsDataWindowDesc =>
      'Насколько далеко назад отображается экран с кратким обзором';

  @override
  String get settingsGapless => 'Воспроизведение без пауз';

  @override
  String get settingsGaplessDesc => 'Плавные переходы между треками';

  @override
  String get settingsAutomix => 'Automix';

  @override
  String get settingsAutomixDesc =>
      'Автоматически создаёт плавный переход между треками';

  @override
  String get settingsCrossfade => 'Переход';

  @override
  String get settingsCrossfadeDesc =>
      'Плавный переход от конца одной дорожки к следующей';

  @override
  String get crossfadeDuration => 'Продолжительность плавного перехода';

  @override
  String get crossfadeDurationDesc =>
      'Как долго длится перекрытие между треками';

  @override
  String get settingsInsights => 'Аналитика';

  @override
  String get settingsInsightsSubtitle =>
      'Период повторения прослушанного материала';

  @override
  String get settingsLast7Days => 'Последние 7 дней';

  @override
  String get settingsLast30Days => 'Последние 30 дней';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLayout => 'Макет';

  @override
  String get settingsLibraryFolders => 'Пакеты библиотеки';

  @override
  String get settingsLibraryFoldersSubtitle =>
      'Включить или исключить папки для сканирования';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouDesc => 'Динамичные цвета из обоев';

  @override
  String get settingsMonthlyRecap => 'Ежемесячный обзор';

  @override
  String get settingsMonthlyRecapDesc =>
      'Показывать баннер каждый месяц (имеет приоритет над еженедельным)';

  @override
  String get settingsNormalization => 'Нормализация громкости';

  @override
  String get settingsNormalizationDesc =>
      'Стабильный уровень громкости · Требуется наличие тегов ReplayGain в файлах';

  @override
  String get playbackSpeed => 'Скорость воспроизведения';

  @override
  String get playbackSpeedDesc => 'Настройка скорости воспроизведения звука';

  @override
  String get adjustPitchWithSpeed =>
      'Регулировка высоты тона в зависимости от скорости';

  @override
  String get adjustPitchWithSpeedDesc =>
      'В выключенном состоянии темп изменяется без изменения высоты тона';

  @override
  String get playbackPitch => 'Высота тона';

  @override
  String get playbackPitchDesc =>
      'Сдвигает звук выше или ниже независимо от скорости';

  @override
  String get playbackPitchLinkedDesc => 'Следует скорости воспроизведения';

  @override
  String get settingsPlayback => 'Воспроизведение';

  @override
  String get settingsPlaybackSubtitle =>
      'Скорость, воспроизведение без пауз и нормализация';

  @override
  String get settingsRecapBannerDesc =>
      'Баннер появляется на главном экране в начале каждой новой недели или месяца, отсчитываемых с момента вашего первого запуска игры. Нажатие кнопки «Позже» скрывает его на время текущего сеанса; нажатие кнопки «Показать» помечает его как просмотренный.';

  @override
  String get settingsRecapContent => 'Краткое содержание';

  @override
  String get settingsRecapContentDesc =>
      'Определяет, какой объем истории отображается на экране сводки при его открытии вручную или через баннер.';

  @override
  String get settingsPreviewRecap => 'Краткий обзор предварительного просмотра';

  @override
  String get settingsPreviewRecapDesc =>
      'Посмотрите, как выглядит ваш обзор в данный момент с текущими настройками';

  @override
  String get settingsRecapSchedule => 'Расписание повторов';

  @override
  String get settingsStorage => 'Хранение';

  @override
  String settingsCacheItems(String count) {
    return '$count товаров';
  }

  @override
  String get settingsMemoryCache => 'Кэш-память';

  @override
  String get settingsStorageSubtitle => 'Кэш и мультимедийные файлы';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsTools => 'Инструменты';

  @override
  String get settingsResetSetup => 'Сброс настроек';

  @override
  String get settingsResetSetupDesc =>
      'Перезапустить процесс адаптации новых сотрудников';

  @override
  String get settingsUpdateAvailable => 'Доступно обновление!';

  @override
  String get settingsUpToDate => 'Вы в курсе последних новостей';

  @override
  String get settingsUpdateCheckFailed =>
      'Не удалось проверить обновления. Обновления приходят из Google Play.';

  @override
  String get settingsWeeklyRecap => 'Еженедельный обзор';

  @override
  String get settingsWeeklyRecapDesc =>
      'Показывать баннер каждую неделю после первого прослушивания';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get share => 'Поделиться';

  @override
  String get shuffle => 'Перемешать';

  @override
  String get size => 'Размер';

  @override
  String get sleepTimer => 'Таймер выключения';

  @override
  String get small => 'Маленький';

  @override
  String get songInfo => 'Информация о песне';

  @override
  String get songs => 'Песни';

  @override
  String get songsLoaded => 'Песни загружены';

  @override
  String get standardQuality => 'Стандартное качество';

  @override
  String get startType => 'Начните вводить текст для поиска';

  @override
  String get storagePermissionNeeded =>
      'Для редактирования метаданных приложению Noxira Music требуется разрешение на управление файлами. Пожалуйста, предоставьте доступ ко «всем файлам» в настройках.';

  @override
  String get suggestedArtists => 'Художники для вас';

  @override
  String get suggestedTracks => 'Рекомендуемые треки';

  @override
  String get supportAurora => 'Поддержите «Noxira»';

  @override
  String get supportAuroraBtn => 'Поддержите «Noxira»';

  @override
  String get supportAuroraDescShort =>
      'Помогите сохранить приложение бесплатным';

  @override
  String get supportAuroraMessage =>
      'Помогите сохранить бесплатный доступ к Noxira Music и поддержать его дальнейшее развитие. Каждый вклад имеет огромное значение!';

  @override
  String get supportAuroraTitle => 'Поддержите «Noxira Music»';

  @override
  String get updatedTitle => 'Noxira Music обновлена';

  @override
  String get tapAddToAddSongs => 'Нажмите «+», чтобы добавить песни';

  @override
  String get reorderSongs => 'Изменить порядок песен';

  @override
  String get done => 'Готово';

  @override
  String get thankYouSupport => 'Спасибо за вашу поддержку!';

  @override
  String get theme => 'Тема';

  @override
  String get title => 'Название';

  @override
  String get topResult => 'Лучший результат';

  @override
  String get total => 'Итого';

  @override
  String get track => 'Трек';

  @override
  String get trackInfo => 'Информация о треке';

  @override
  String get trackInfoDesc =>
      'Нажмите на значок редактирования, чтобы изменить информацию о треке';

  @override
  String get trackInfoEditDesc =>
      'Измените данные в полях ниже, а затем нажмите на значок галочки, чтобы сохранить';

  @override
  String get tracks => 'Треки';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get unknownArtist => 'Неизвестный художник';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String get updateMessage => 'Доступна новая версия';

  @override
  String get updateNow => 'Обновить сейчас';

  @override
  String get viewArtist => 'Посмотреть информацию об исполнителе';

  @override
  String get viewDetails => 'Посмотреть подробности';

  @override
  String get welcomeBack => 'С возвращением!';

  @override
  String get whatsNew => 'Что нового';

  @override
  String get view_changelog => 'Просмотреть журнал изменений и новые функции';

  @override
  String get year => 'Год';

  @override
  String get yes => 'Да';

  @override
  String get yourLibrary => 'Ваша библиотека';

  @override
  String get yourPlaylists => 'Ваши плейлисты';

  @override
  String get homeLayout => 'Планировка дома';

  @override
  String get homeLayoutDesc =>
      'Настройка порядка разделов на вкладке «Главная»';

  @override
  String get customizeHomeTab => 'Настройка вкладки «Главная»';

  @override
  String get dragToReorder => 'Перетащите, чтобы изменить порядок разделов';

  @override
  String get resetToDefault => 'Сброс к настройкам по умолчанию';

  @override
  String get resetLayoutConfirm => 'Сбросить макет до значений по умолчанию?';

  @override
  String get resetLayoutMessage =>
      'Это восстановит исходный порядок разделов и их отображение.';

  @override
  String get listeningHistory => 'История прослушиваний';

  @override
  String get libraryStats => 'Статистика библиотеки';

  @override
  String get back => 'Назад';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get skip => 'Пропустить';

  @override
  String get send_feedback => 'Отправить отзыв';

  @override
  String get send_feedback_desc =>
      'Сообщите об ошибках или предложите новые функции';

  @override
  String get rateApp => 'Оценить Noxira Music';

  @override
  String get rateAppDesc => 'Нравится приложение? Оставьте отзыв в Google Play';

  @override
  String get feedbackTypeBug => 'Ошибка';

  @override
  String get feedbackTypeSuggestion => 'Предложение';

  @override
  String get feedbackHint => 'Опишите ошибку или предложение...';

  @override
  String get feedbackSend => 'Отправить';

  @override
  String get feedbackSentThanks => 'Спасибо за ваш отзыв!';

  @override
  String get feedbackSentError =>
      'Не удалось отправить отзыв. Повторите попытку позже.';

  @override
  String get contributeTranslations => 'Присылайте переводы';

  @override
  String get contributeTranslationsDesc =>
      'Помогите перевести «Noxira Music» на Crowdin';

  @override
  String get contributeTranslationsTitle => 'Помогите нам с переводом';

  @override
  String get contributeTranslationsSubtitle =>
      'Приложение Noxira Music доступно на нескольких языках благодаря нашему замечательному сообществу. Помогите нам охватить ещё больше пользователей, переведя приложение на ваш язык — начать работу можно всего за несколько минут.';

  @override
  String get contributeTranslationsOpenCrowdin => 'Открыть Crowdin';

  @override
  String get close => 'Закрыть';

  @override
  String get settingsHighendUi => 'Интерфейс пользователя премиум-класса';

  @override
  String get settingsHighendUiDesc =>
      'Включить расширенные визуальные эффекты и анимацию';

  @override
  String get clearUpcoming => 'Очистить предстоящие';

  @override
  String get addToQueue => 'Добавить в очередь';

  @override
  String get playNext => 'Следующий трек';

  @override
  String get removeFromQueue => 'Удалить из очереди';

  @override
  String get play => 'Играть';

  @override
  String get viewAlbum => 'Посмотреть альбом';

  @override
  String get shuffleAll => 'Перемешать всё';

  @override
  String get noSongsFound => 'Песни не найдены';

  @override
  String get noFoldersFound => 'Папки не найдены';

  @override
  String get deleteSong => 'Удалить песню';

  @override
  String get modifySystemSettingsPermission =>
      'На открывшейся странице разрешите «Изменение системных настроек», а затем попробуйте ещё раз.';

  @override
  String errorMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String songsAddedToQueue(int count) {
    return '$count песен добавлено в очередь';
  }

  @override
  String songAddedToQueue(String title) {
    return '«$title» добавлено в очередь';
  }

  @override
  String songSetAsRingtone(String title) {
    return '«$title» установлено в качестве мелодии звонка';
  }

  @override
  String failedToSetRingtone(String error) {
    return 'Не удалось установить мелодию звонка: $error';
  }

  @override
  String deleteSongConfirm(String title) {
    return 'Удалить «$title» с вашего устройства? Это действие нельзя отменить.';
  }

  @override
  String songDeleted(String title) {
    return '«$title» удалено';
  }

  @override
  String failedToDelete(String error) {
    return 'Не удалось удалить: $error';
  }

  @override
  String songCount(int count) {
    return '$count песен';
  }

  @override
  String get badgeNew => 'НОВОЕ';

  @override
  String get paused => 'Приостановлено';

  @override
  String get readyToPlay => 'Готовы к игре';

  @override
  String get tapSongToStartListening =>
      'Нажмите на песню, чтобы начать прослушивание';

  @override
  String get clearCachedLyrics => 'Очистить кэшированные тексты песен';

  @override
  String lyricsCleared(String title) {
    return 'Кэшированные тексты песен для «$title» удалены';
  }

  @override
  String lyricsAdded(String title) {
    return 'Текст добавлен для «$title»';
  }

  @override
  String get noLyricsCached => 'Текст песни в кэше не найден';

  @override
  String get setAsRingtone => 'Установить в качестве мелодии звонка';

  @override
  String get songInfoEdit => 'Информация о песне / Редактировать';

  @override
  String get goToAlbum => 'Перейти к альбому';

  @override
  String get goToArtist => 'Перейти к исполнителю';

  @override
  String get deleteFromDevice => 'Удалить с устройства';

  @override
  String get checkOutThisSong => 'Послушайте эту песню!';

  @override
  String get backgroundSolid => 'Однотонный';

  @override
  String get backgroundHighEndStyle => 'Фон для текущего воспроизведения';

  @override
  String get backgroundHighEndStyleDesc =>
      'Стиль фона на экране «Воспроизведение»';

  @override
  String get backgroundBlurredArtwork => 'Размытые иллюстрации';

  @override
  String get accentColor => 'Акцентный цвет';

  @override
  String get accentColorDesc => 'Выберите цвет акцента для приложения';

  @override
  String get backgroundBlur => 'Размытие фона';

  @override
  String get backgroundBlurDesc => 'Интенсивность размытия изображения';

  @override
  String get backgroundDarkness => 'Темнота на заднем плане';

  @override
  String get backgroundDarknessDesc => 'Прозрачность наложения на иллюстрацию';

  @override
  String get microphoneAccessNeeded => 'Требуется доступ к микрофону';

  @override
  String get microphoneAccessDesc =>
      'Приложению Noxira требуется доступ к микрофону для подключения к аудиосессии вашего устройства с целью работы визуализатора в режиме реального времени. Аудиосигнал не записывается и не сохраняется.';

  @override
  String get recapWeek => 'неделя';

  @override
  String get recapMonth => 'месяц';

  @override
  String get recapPeriodWeek => 'Неделя';

  @override
  String get recapPeriodMonth => 'Месяц';

  @override
  String get recapWeekly => 'Еженедельно';

  @override
  String get recapMonthly => 'Ежемесячно';

  @override
  String get recapIntroAppName => 'NOXIRA MUSIC';

  @override
  String recapIntroTitle(String period) {
    return 'Ваш $period\nКраткое изложение';
  }

  @override
  String get recapIntroSubtitle => 'Давай посмотрим, что ты\nслушал.';

  @override
  String recapPlayedEyebrow(String period) {
    return 'В этом $period вы слушали музыку';
  }

  @override
  String get recapTimeSingular => 'время';

  @override
  String get recapTimePlural => 'раз';

  @override
  String get recapListenedForEyebrow => 'Вы прислушались к';

  @override
  String get recapListenedForLabel => 'музыки';

  @override
  String get recapTopTrackEyebrow => 'Ваш трек № 1';

  @override
  String get recapPlays => 'спектакли';

  @override
  String get recapTopTracksTitle => 'Лучшие треки';

  @override
  String get recapTopArtistEyebrow => 'Ваш любимый исполнитель';

  @override
  String get recapTopArtistsTitle => 'Лучшие артисты';

  @override
  String get recapNothingToWrap => 'Пока нечего заворачивать';

  @override
  String recapNothingToWrapBody(String period) {
    return 'Послушай немного музыки, $period, а потом вернись.';
  }

  @override
  String get recapSwipeUp => 'ПРОВЕДИ ПАЛЬЦЕМ ВВЕРХ';

  @override
  String get recapYourSoundLabel => 'ВАШ ЗВУК';

  @override
  String get recapYouListenMost => 'ЧТО ВЫ СЛУШАЕТЕ ЧАЩЕ ВСЕГО';

  @override
  String recapOnDay(String day) {
    return 'за $day секунд';
  }

  @override
  String recapAroundTime(String time) {
    return 'около $time';
  }

  @override
  String get recapVibesHitDifferent =>
      'И вот тогда атмосфера стала совсем другой.';

  @override
  String get recapThatsAWrap => 'НА ЭТОМ ВСЁ';

  @override
  String recapInNumbers(String period) {
    return 'Ваш $period\nв цифрах';
  }

  @override
  String get recapNumberOneTrack => '#1 ТРЕК';

  @override
  String get recapStatTotalPlays => 'Общее количество просмотров';

  @override
  String get recapStatTimeListened => 'Время прослушивания';

  @override
  String get recapStatUniqueTracks => 'Уникальные треки';

  @override
  String get recapStatTopArtist => 'Лучший артист';

  @override
  String get recapDone => 'Готово';

  @override
  String get recapWeekdayMonday => 'Понедельник';

  @override
  String get recapWeekdayTuesday => 'вторник';

  @override
  String get recapWeekdayWednesday => 'среда';

  @override
  String get recapWeekdayThursday => 'четверг';

  @override
  String get recapWeekdayFriday => 'Пятница';

  @override
  String get recapWeekdaySaturday => 'Суббота';

  @override
  String get recapWeekdaySunday => 'Воскресенье';

  @override
  String get recapBannerTitle => 'Обзор музыкальных событий можно найти здесь';

  @override
  String get recapBannerShow => 'Показать';

  @override
  String get recapBannerLater => 'Позже';

  @override
  String get rebrandTitle => 'Aurora теперь Noxira';

  @override
  String get rebrandSubtitle =>
      'То же музыкальное приложение, которое вы знаете, — с новым названием, свежим видом и несколькими новыми функциями.';

  @override
  String get rebrandNewHeading => 'Что нового';

  @override
  String get rebrandSlideLyricsTitle => 'Тексты песен — заново';

  @override
  String get rebrandSlideLyricsBody =>
      'Новая страница текстов и больше источников, чтобы тексты находились у большего числа песен. Коснитесь строки, чтобы перейти к ней. Теперь тексты можно перевести на любой язык.';

  @override
  String get rebrandSlideWidgetTitle => 'Новый виджет на главном экране';

  @override
  String get rebrandSlideWidgetBody =>
      'Стекло в цветах обложки и кнопки «назад», «пуск» и «вперёд», которые работают без открытия приложения.';

  @override
  String get rebrandSlideQueueTitle => 'Настоящая очередь';

  @override
  String get rebrandSlideQueueBody =>
      'Смотрите, что играло и что дальше. Перетащите, чтобы изменить порядок, смахните, чтобы удалить.';

  @override
  String get rebrandSlideOutputTitle => 'Выбирайте, где играет';

  @override
  String get rebrandSlideOutputBody =>
      'Нажмите на чип Bluetooth на главном экране или новую кнопку на экране «Сейчас играет», чтобы переключать воспроизведение между динамиком телефона и подключёнными устройствами прямо в приложении.';

  @override
  String get rebrandSlideLibraryTitle => 'Более аккуратная медиатека';

  @override
  String get rebrandSlideLibraryBody =>
      'Noxira находит дубликаты треков и позволяет выбрать, какую копию оставить. У плейлистов новый вид: «Избранное», автоматические и умные плейлисты в одном месте.';

  @override
  String get rebrandMoreMessages =>
      'Сообщения теперь появляются маленьким островком внизу экрана.';

  @override
  String get rebrandMorePerformance =>
      'Более быстрый поиск, быстрый запуск и более лёгкая загрузка изображений.';

  @override
  String get translateLyricsTo => 'Перевести текст на';

  @override
  String get translateLyricsAppLanguage => 'Язык приложения';

  @override
  String get translateLyricsChooseLanguage => 'Выбрать язык…';

  @override
  String get rebrandSlideMoreTitle => 'И ещё кое-что';

  @override
  String get rebrandMoreSetup =>
      'Настройка теперь рекомендует подходящий режим для вашего телефона.';

  @override
  String get rebrandMoreLook =>
      'Более спокойный баннер поддержки, скруглённая кнопка воспроизведения в «Избранном» и элементы управления текстом, которые не прячутся.';

  @override
  String get rebrandMoreMotion =>
      'Более плавные и красивые переходы по всему приложению.';

  @override
  String get rebrandMorePlayback =>
      'Отдельные ползунки скорости и высоты тона, которые можно связать.';

  @override
  String get rebrandMoreSearch =>
      'Обновлённая вкладка поиска и страница настроек, разбитая на группы.';

  @override
  String get rebrandMoreFixes =>
      'Улучшения стабильности и исправления ошибок по всему приложению, включая мерцание текстов.';

  @override
  String get eqTitle => 'Эквалайзер';

  @override
  String get eqOn => 'ВКЛ.';

  @override
  String get eqOff => 'ВЫКЛ.';

  @override
  String get eqNotAvailable =>
      'На данном устройстве функция эквалайзера недоступна.';

  @override
  String get eqWaitingForAudio =>
      'Запустите песню, чтобы настроить эквалайзер.';

  @override
  String get eqOpenSystem => 'Эквалайзер с открытой системой';

  @override
  String get eqSavePreset => 'Сохранить пресет';

  @override
  String get eqPresetNameHint => 'например, «My Bass Boost»';

  @override
  String get eqPresetNameEmpty => 'Поле «Имя» не может быть пустым.';

  @override
  String eqPresetNameBuiltIn(String name) {
    return '«$name» — это название встроенной предустановки.';
  }

  @override
  String get eqResetAllBands => 'Сбросить настройки всех диапазонов';

  @override
  String get eqPresetsLabel => 'ПРЕДУСТАНОВКИ';

  @override
  String get eqYourPresetsLabel => 'ВАШИ ПРЕДУСТАНОВКИ';

  @override
  String get eqSaveCurrent => 'Сохранить текущее';

  @override
  String get eqSettingsSubtitle =>
      'Настройка частот звука по каждому диапазону';

  @override
  String get eqEmptyPresets =>
      'Настройте звук, а затем нажмите «Сохранить текущие настройки».';

  @override
  String get lyricsHint =>
      'Вставьте сюда несинхронизированные тексты песен…\n\nПо одной строке на каждую строку куплета.';

  @override
  String get lyricsSelectLrcFile => 'Пожалуйста, выберите файл .lrc';

  @override
  String get lyricsNoLyricsInFile => 'В этом файле не найдено текстов песен';

  @override
  String importFailed(String error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get lyricsImportTooltip => 'Импортировать файл .lrc';

  @override
  String get importPlaylistM3u => 'Импортировать плейлист (.m3u)';

  @override
  String get setSyncFolder => 'Установить папку для синхронизации…';

  @override
  String get syncNow => 'Синхронизировать сейчас';

  @override
  String get searchPlaylists => 'Поиск плейлистов…';

  @override
  String get pleaseSelectM3uFile =>
      'Пожалуйста, выберите файл с расширением .m3u или .m3u8';

  @override
  String get noMatchingSongsForPlaylist =>
      'Песен, соответствующих этому плейлисту, не найдено';

  @override
  String importedPlaylist(String name, int count) {
    return 'Импортировано «$name» ($count песен)';
  }

  @override
  String playlistsSyncWith(String folder) {
    return 'Плейлисты будут синхронизированы с: $folder';
  }

  @override
  String couldNotSetSyncFolder(String error) {
    return 'Не удалось настроить папку синхронизации: $error';
  }

  @override
  String get setSyncFolderFirst => 'Сначала настройте папку для синхронизации';

  @override
  String get playlistsSynced => 'Синхронизированы плейлисты';

  @override
  String get alreadyUpToDate => 'Уже актуально';

  @override
  String syncFailed(String error) {
    return 'Ошибка синхронизации: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get searchFolders => 'Поиск папок…';

  @override
  String get songInfoPath => 'Путь';

  @override
  String get closeVisualiser => 'Закрыть визуализатор';

  @override
  String get visualizerWaitingForAudio => 'Ожидание звука воспроизведения...';

  @override
  String get visualizerUnavailable =>
      'Для этого вывода анализ звука в реальном времени недоступен.';

  @override
  String get previousMode => 'Предыдущий режим';

  @override
  String get nextMode => 'Следующий режим';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get colorTheme => 'Цветовая схема';

  @override
  String get insightsTotalPlays => 'Всего\nПросмотров';

  @override
  String get insightsTracksHeard => 'Треки\nПрослушано';

  @override
  String get insightsEstListening => 'Приблизительно\nПрослушивание';

  @override
  String get dismiss => 'Отклонить';

  @override
  String updateVersionAvailable(String version) {
    return 'Теперь доступна версия $version.';
  }

  @override
  String get updateNewVersionAvailable => 'Теперь доступна новая версия.';

  @override
  String get lyricsPasteLyricsTitle => 'Вставить текст песни';

  @override
  String get lyricsUseLyrics => 'Использовать тексты песен';

  @override
  String get lyricsPaste => 'Вставить';

  @override
  String get lyricsNoLyricsYet => 'Текста песни пока нет';

  @override
  String get lyricsPasteToGetStarted => 'Вставьте текст песни, чтобы начать';

  @override
  String get lyricsNoTimestampsYet =>
      'Метки времени пока отсутствуют — нажмите кнопку с отметкой во время воспроизведения песни.';

  @override
  String get lyricsAllLinesStampedHint =>
      'Все строки отмечены — нажмите «Сохранить», чтобы завершить.';

  @override
  String get lyricsAllStamped => '✓  Все строки проштампованы';

  @override
  String get lyricsPasteFirst => 'Сначала вставьте текст песни';

  @override
  String lyricsTapToStamp(int current, int total) {
    return '⏱  Нажмите, чтобы поставить отметку на строке $current / $total';
  }

  @override
  String get lyricsNextLabel => 'Далее';

  @override
  String get translationDisclaimerNote =>
      'Некоторые переводы созданы ИИ или предоставлены сообществом и могут содержать ошибки. Помогите улучшить их на Crowdin.';

  @override
  String get newLanguagesAvailableTitle => 'Доступны новые языки';

  @override
  String get newLanguagesAvailableBody =>
      'Noxira Music теперь поддерживает немецкий, испанский, хинди и русский языки. Язык можно изменить в настройках.';

  @override
  String get newLanguagesGoToSettings => 'Сменить язык';

  @override
  String get newLanguagesDismiss => 'Понятно';

  @override
  String get settingsLyricsSources => 'Источники текстов';

  @override
  String get lyricsProviderDesc =>
      'Используется, если на LRCLIB нет текста. Получает название, исполнителя, альбом и длительность.';

  @override
  String get onlineAboutArtist => 'Об исполнителе';

  @override
  String get onlineFansAlsoLike => 'Фанатам также нравится';

  @override
  String get onlinePopularTracks => 'Популярное сейчас';

  @override
  String get onlineReadMore => 'Читать далее';

  @override
  String get onlineBioDisclaimer =>
      'Собрано автоматически из открытых источников. Точность не гарантируется.';

  @override
  String get onlineShowLess => 'Свернуть';

  @override
  String get onlineWikipedia => 'Википедия';

  @override
  String onlineFansCount(String count) {
    return 'Фанатов: $count';
  }

  @override
  String get settingsOnlineSuggestions => 'Онлайн-подсказки';

  @override
  String get settingsOnlineSuggestionsDesc =>
      'Искать сведения об исполнителях и похожих исполнителей в Deezer и Википедии. Отправляется только имя исполнителя.';

  @override
  String get onboardingUiModeTitle => 'Стиль интерфейса';

  @override
  String get onboardingUiModeDesc =>
      'Сколько стекла и анимации использует приложение';

  @override
  String get onboardingUiHighEnd => 'Максимальный';

  @override
  String get onboardingUiLowEnd => 'Лёгкий';

  @override
  String get onboardingRecommendedBadge => 'Рекомендуется';

  @override
  String get onboardingRecommendedForDevice =>
      'Рекомендуется для вашего устройства.';

  @override
  String onboardingTryNote(String recommended, String selected) {
    return 'Исходя из характеристик вашего устройства мы рекомендуем «$recommended», но вы можете попробовать «$selected».';
  }

  @override
  String onboardingHeaviestNote(String option) {
    return '«$option» — самый ресурсоёмкий вариант, на вашем устройстве он может работать менее плавно.';
  }

  @override
  String get audioOutput => 'Вывод звука';

  @override
  String get audioOutputBluetoothDevice => 'Устройство Bluetooth';

  @override
  String get audioOutputPhoneSpeaker => 'Динамик телефона';

  @override
  String get audioOutputWired => 'Проводные наушники';

  @override
  String get audioOutputUsb => 'USB-аудио';

  @override
  String get audioOutputOther => 'Другой вывод';

  @override
  String get audioOutputNoOthers => 'Других устройств не обнаружено';

  @override
  String get audioOutputCurrentDevice => 'Текущее устройство';

  @override
  String get audioOutputSwitchFailed => 'Не удалось переключить вывод звука';

  @override
  String get duplicatesBannerTitle => 'Найдены дубликаты треков';

  @override
  String duplicatesBannerSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count трека существуют в нескольких копиях',
      many: '$count треков существуют в нескольких копиях',
      few: '$count трека существуют в нескольких копиях',
      one: '$count трек существует в нескольких копиях',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesReview => 'Проверить';

  @override
  String get duplicatesScreenTitle => 'Дубликаты треков';

  @override
  String get duplicatesEmpty => 'Дубликаты не найдены';

  @override
  String get duplicatesIgnore => 'Игнорировать';

  @override
  String get duplicatesIgnoreAll => 'Игнорировать все';

  @override
  String get duplicatesKeepBest => 'Лучшее качество';

  @override
  String duplicatesCopies(int count) {
    return 'Копий: $count';
  }

  @override
  String duplicatesDeleteOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Оставить выбранную, удалить $count других',
      many: 'Оставить выбранную, удалить $count других',
      few: 'Оставить выбранную, удалить $count другие',
      one: 'Оставить выбранную, удалить $count другую',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesDeleteFailed => 'Не удалось удалить некоторые копии';

  @override
  String get duplicatesResolved => 'Дубликаты удалены';

  @override
  String get duplicatesHint =>
      'Выберите копию, которую нужно оставить. Остальные будут удалены с вашего устройства.';

  @override
  String get remoteAnnouncementOpenLink => 'Подробнее';

  @override
  String get remoteAnnouncementOpenScreen => 'Открыть';

  @override
  String get updateRequiredTitle => 'Требуется обновление';

  @override
  String get updateRequiredMessage =>
      'Эта версия больше не поддерживается. Обновите Noxira Music, чтобы продолжить пользоваться приложением.';

  @override
  String get settingsSupport => 'Поддержка';

  @override
  String get settingsSupportSubtitle => 'Спонсоры и способы помочь';

  @override
  String get supportSupporters => 'Спонсоры';

  @override
  String get supportNoSupportersYet => 'Пока никого нет. Станьте первым!';

  @override
  String get musicInsightsTitle => 'Музыкальная статистика';

  @override
  String get insightsActivityByTimeOfDay => 'Активность по времени суток';

  @override
  String get insightsActivityByDay => 'Активность по дням';

  @override
  String get insightsGenreBreakdown => 'Разбивка по жанрам';

  @override
  String get insightsNoDataTitle => 'Данных о прослушивании пока нет';

  @override
  String get insightsNoDataBody =>
      'Включите музыку, чтобы начать собирать статистику.';

  @override
  String insightsMostActiveAround(String time) {
    return 'Больше всего активности около $time';
  }

  @override
  String insightsMostActiveOn(String day) {
    return 'Больше всего активности: $day';
  }

  @override
  String moreFromArtist(String artist) {
    return 'Ещё от $artist';
  }

  @override
  String tracksCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count трека',
      many: '$count треков',
      few: '$count трека',
      one: '$count трек',
    );
    return '$_temp0';
  }

  @override
  String songsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count песни',
      many: '$count песен',
      few: '$count песни',
      one: '$count песня',
    );
    return '$_temp0';
  }

  @override
  String albumsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count альбома',
      many: '$count альбомов',
      few: '$count альбома',
      one: '$count альбом',
    );
    return '$_temp0';
  }

  @override
  String playlistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count плейлиста',
      many: '$count плейлистов',
      few: '$count плейлиста',
      one: '$count плейлист',
    );
    return '$_temp0';
  }

  @override
  String foldersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count папки',
      many: '$count папок',
      few: '$count папки',
      one: '$count папка',
    );
    return '$_temp0';
  }

  @override
  String foldersExcludedCount(int count) {
    return 'исключено: $count';
  }

  @override
  String get unknownAlbum => 'Неизвестный альбом';

  @override
  String get queueNextUp => 'Далее';

  @override
  String queueNextFrom(String source) {
    return 'Далее из: $source';
  }

  @override
  String get queueNothingElse => 'В очереди больше ничего нет';

  @override
  String get queueMoveToEnd => 'Переместить в конец';

  @override
  String get translateLyrics => 'Перевести текст';

  @override
  String get translateFailedTapToRetry =>
      'Не удалось перевести — нажмите, чтобы повторить';

  @override
  String get translateShowOriginal => 'Показать оригинал';

  @override
  String get translateShowTranslation => 'Показать перевод';

  @override
  String get lyricsAiTranslatedNote =>
      'Переведено ИИ · точность может отличаться';

  @override
  String lyricsCantTranslateSameLanguage(String language) {
    return 'Невозможно перевести — текст уже на целевом языке ($language)';
  }

  @override
  String get lyricsAddLyrics => 'Добавить текст';

  @override
  String get lyricsBlurOn => 'Размытие текста: вкл.';

  @override
  String get lyricsBlurOff => 'Размытие текста: выкл.';

  @override
  String get lyricsAutoHideOn => 'Автоскрытие элементов управления: вкл.';

  @override
  String get lyricsAutoHideOff => 'Автоскрытие элементов управления: выкл.';

  @override
  String get lyricsEditCreate => 'Изменить / создать текст';

  @override
  String get sleepTimerMinShort => 'мин';

  @override
  String sleepTimerMinutesValue(int minutes) {
    return '$minutes мин';
  }

  @override
  String get sleepTimerMusicStopsAfter => 'Музыка остановится через…';

  @override
  String get sleepTimerPickDuration => 'Выберите длительность ниже';

  @override
  String get visualizerBarSpectrum => 'Столбчатый спектр';

  @override
  String get visualizerCircularBars => 'Круговые столбцы';

  @override
  String get visualizerMirrorBars => 'Зеркальные столбцы';

  @override
  String get visualizerFrequencyLine => 'Линия частот';

  @override
  String get visualizerDotMatrix => 'Точечная матрица';

  @override
  String get visualizerPeakBars => 'Пиковые столбцы';

  @override
  String get visualizerCircularWave => 'Круговая волна';

  @override
  String get visualizerAuroraWaves => 'Волны сияния';

  @override
  String get visualizerPulseRings => 'Пульсирующие кольца';

  @override
  String get smartFieldFolderPath => 'Путь к папке';

  @override
  String get smartFieldLiked => 'Понравившиеся';

  @override
  String get smartFieldPlayCount => 'Число прослушиваний';

  @override
  String get smartFieldDurationSeconds => 'Длительность (сек.)';

  @override
  String get smartFieldDaysSinceAdded => 'Дней с момента добавления';

  @override
  String get smartOpContains => 'содержит';

  @override
  String get smartOpNotContains => 'не содержит';

  @override
  String get smartOpEquals => 'равно';

  @override
  String get smartOpNotEquals => 'не равно';

  @override
  String get smartOpGreaterThan => 'больше чем';

  @override
  String get smartOpLessThan => 'меньше чем';

  @override
  String get smartOpIsTrue => 'истина';

  @override
  String get smartOpIsFalse => 'ложь';

  @override
  String get smartSortTitleAZ => 'Название (А–Я)';

  @override
  String get smartSortArtistAZ => 'Исполнитель (А–Я)';

  @override
  String get smartSortDateAddedNewest => 'Дата добавления (новые)';

  @override
  String get smartSortPlayCountHighest => 'Прослушивания (больше)';

  @override
  String get smartSortDurationLongest => 'Длительность (длинные)';

  @override
  String get smartSortRandom => 'Случайно';

  @override
  String get folderFilterTitle => 'Фильтр папок';

  @override
  String get artistSeparatorTestHint =>
      'напр. Исполнитель 1 / Исполнитель 2 feat. 3';

  @override
  String get tracksPermissionRequired =>
      'Требуется разрешение на доступ к медиатеке. Предоставьте разрешения при первоначальной настройке или в настройках приложения.';

  @override
  String tracksErrorFetching(String error) {
    return 'Ошибка при получении песен: $error';
  }

  @override
  String get seeAll => 'Показать все';

  @override
  String get selectItemToViewDetails =>
      'Выберите элемент, чтобы увидеть подробности';

  @override
  String get takeMeThere => 'Перейти';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get aboutCodename => 'Кодовое имя';

  @override
  String get aboutDeveloper => 'Разработчик';

  @override
  String get aboutCopyright => 'Авторские права';

  @override
  String get aboutWebsite => 'Сайт';

  @override
  String get openSourcePackages => 'Пакеты с открытым исходным кодом';

  @override
  String packagesUsedCount(int count) {
    return 'Используется пакетов: $count';
  }

  @override
  String get packagesThanks => 'Спасибо всем участникам open source!';

  @override
  String versionWithCodename(String version, String codename) {
    return 'Версия $version ($codename)';
  }

  @override
  String get customColor => 'Свой цвет';

  @override
  String exportPlaylistAs(String format) {
    return 'Экспорт ($format)';
  }

  @override
  String get shareClipListeningTo => 'СЛУШАЮ';

  @override
  String get shareClipNowOn => 'СЕЙЧАС В';

  @override
  String get splashInitializingServices => 'Инициализация служб';

  @override
  String get splashLoadingLibrary => 'Загрузка библиотеки';

  @override
  String get splashPreparingHome => 'Подготовка главной';

  @override
  String get splashCachingArtwork => 'Кэширование обложек';

  @override
  String get splashFinalPreparations => 'Завершающие приготовления';

  @override
  String get queueHistory => 'История';

  @override
  String get sortName => 'Название';

  @override
  String get bannerInsightsNewTitle =>
      'Ваша музыкальная статистика уже здесь ✦';

  @override
  String get bannerInsightsNewBody =>
      'Узнайте свои любимые треки, исполнителей и привычки прослушивания';

  @override
  String get bannerRecapTitle => 'Ваш музыкальный итог ждёт вас';

  @override
  String get bannerRecapBody =>
      'Узнайте свои любимые песни и тенденции прослушивания';

  @override
  String get musicalArtist => 'Музыкальный исполнитель';

  @override
  String get eqPresetFlat => 'Плоский';

  @override
  String get eqPresetBassBoost => 'Усиление басов';

  @override
  String get eqPresetBassCut => 'Срез басов';

  @override
  String get eqPresetTrebleBoost => 'Усиление высоких';

  @override
  String get eqPresetTrebleCut => 'Срез высоких';

  @override
  String get eqPresetRock => 'Рок';

  @override
  String get eqPresetPop => 'Поп';

  @override
  String get eqPresetJazz => 'Джаз';

  @override
  String get eqPresetClassical => 'Классика';

  @override
  String get eqPresetElectronic => 'Электронная';

  @override
  String get eqPresetHipHop => 'Хип-хоп';

  @override
  String get eqPresetRnB => 'R&B';

  @override
  String get eqPresetVocal => 'Вокал';

  @override
  String get eqPresetAcoustic => 'Акустика';

  @override
  String get eqPresetDance => 'Танцевальная';

  @override
  String get eqPresetMetal => 'Метал';

  @override
  String get eqPresetLounge => 'Лаунж';

  @override
  String get eqPresetSpokenWord => 'Разговорная речь';

  @override
  String get supportOfMonthlyGoal => 'от цели этого месяца';

  @override
  String get cl200Hl1 =>
      'Aurora Music теперь Noxira Music, с новым внешним видом';

  @override
  String get cl200Hl2 =>
      'Переводите тексты песен на любой язык из большего числа источников';

  @override
  String get cl200Hl3 =>
      'Обновлённый виджет главного экрана с управлением воспроизведением';

  @override
  String get cl200Hl4 => 'Обновлённая очередь';

  @override
  String get cl200Hl5 =>
      'Выбирайте, где играет звук, через чип Bluetooth или экран «Сейчас играет»';

  @override
  String get cl200Hl6 => 'Тексты по словам, если источник содержит тайминг';

  @override
  String get cl200Hl7 =>
      'Дубликаты треков находятся автоматически, а вы выбираете, какую копию оставить';

  @override
  String get cl200Hl8 =>
      'Стеклянные поверхности, подстраивающиеся под ваш телефон';

  @override
  String get cl200Hl9 =>
      'Более плавные переходы и быстрые страницы с подробностями';

  @override
  String get cl200SecWelcome => 'Добро пожаловать в Noxira';

  @override
  String get cl200SecNew => 'Новые возможности';

  @override
  String get cl200SecLibrary => 'Плейлисты и медиатека';

  @override
  String get cl200SecSetup => 'Настройка';

  @override
  String get cl200SecLook => 'Внешний вид';

  @override
  String get cl200SecPerf => 'Производительность';

  @override
  String get cl200SecHood => 'Под капотом';

  @override
  String get cl200Welcome1 =>
      'Aurora Music теперь Noxira Music — с новым названием, логотипом и значком приложения';

  @override
  String get cl200Welcome2 =>
      'Новая анимированная заставка рисует логотип Noxira';

  @override
  String get cl200Welcome3 =>
      'Существующие пользователи увидят короткую приветственную страницу о новинках, которую можно снова открыть в настройках';

  @override
  String get cl200New1 =>
      'Переводите тексты песен на любой язык, а не только на языки приложения';

  @override
  String get cl200New2 =>
      'Обновлённый виджет главного экрана: стекло в цветах обложки, кнопки «назад / играть / вперёд», работающие без открытия приложения, и рекомендуемые песни, когда виджет высокий';

  @override
  String get cl200New3 =>
      'Обновлённая страница очереди — видно, что играло и что дальше, перетаскивайте для смены порядка, смахивайте для удаления; на экране «Сейчас играет» теперь есть предпросмотр «Далее»';

  @override
  String get cl200New4 =>
      'Ежемесячная цель поддержки время от времени появляется в верхней панели главного экрана и в настройках в разделе «О приложении»';

  @override
  String get cl200New5 => 'Потяните вниз в медиатеке, чтобы обновить её';

  @override
  String get cl200New6 =>
      'Выбирайте, где играет звук: нажмите на чип Bluetooth на главном экране или на новый остров вывода на экране «Сейчас играет», чтобы переключать воспроизведение между динамиком телефона и подключёнными устройствами, не выходя из приложения';

  @override
  String get cl200New7 =>
      'У скорости и высоты тона теперь свои ползунки, а высоту тона можно связать со скоростью';

  @override
  String get cl200New8 =>
      'Пять новых стилей визуализатора и более тонкий спектр с большим числом полос';

  @override
  String get cl200New9 =>
      'На главном экране могут появляться необязательные объявления от команды Noxira с кнопкой, открывающей ссылку или экран приложения';

  @override
  String get cl200Lyrics1 =>
      'Обновлённая страница текстов: нажмите на строку, чтобы перейти к ней, точки отмечают инструментальные паузы, а блок текста на экране «Сейчас играет» следует за музыкой';

  @override
  String get cl200Lyrics2 =>
      'Если в LRCLIB ничего нет, пробуются другие источники текстов (BetterLyrics, YouLyPlus и KuGou); выбрать, какие использовать, можно в настройках';

  @override
  String get cl200Lyrics3 =>
      'Тексты, сохранённые в аудиофайле или в файле .lrc рядом с песней, используются в первую очередь и работают офлайн';

  @override
  String get cl200Lyrics4 =>
      'Автоскрытие элементов управления на полноэкранных текстах теперь опция и по умолчанию выключено';

  @override
  String get cl200Lyrics5 =>
      'Исправлены тексты, которые мигали и пропадали с сообщением «текст недоступен», в том числе после обновления или ручного поиска';

  @override
  String get cl200Lyrics6 =>
      'Тексты по словам: если у источника есть тайминг по словам, каждое слово подсвечивается, когда звучит';

  @override
  String get cl200Library1 =>
      'Новая панель добавления в плейлист: добавляйте, удаляйте и создавайте плейлисты в одном месте, песни, уже входящие в плейлист, отмечены';

  @override
  String get cl200Library2 =>
      'Песню больше нельзя добавить в один плейлист дважды, а опция «Удалить дубликаты» очищает уже имеющиеся';

  @override
  String get cl200Library3 =>
      'Noxira теперь замечает дубликаты треков в медиатеке и на вкладке «Медиатека» предлагает их проверить: вы выбираете, какую копию оставить';

  @override
  String get cl200Library4 =>
      'Обновлённая страница плейлистов: сверху «Избранное», автоматические плейлисты плитками, а ваши плейлисты — сеткой с мозаикой обложек';

  @override
  String get cl200Library5 =>
      'Обновлённая вкладка поиска: стеклянная строка поиска, количество результатов и более понятные состояния «пусто» и «ничего не найдено»';

  @override
  String get cl200Library6 =>
      'Значок воспроизводимой песни теперь следует за треком в плейлистах';

  @override
  String get cl200Library7 =>
      'Необязательные онлайн-подсказки: сведения об исполнителях и похожие исполнители из Deezer и Википедии (отправляется только имя исполнителя)';

  @override
  String get cl200Library8 =>
      'Эквалайзер больше не сообщает по ошибке, что он недоступен; он сам пробует снова и предлагает «Повторить» и «Открыть системный эквалайзер»';

  @override
  String get cl200Library9 =>
      '«Сведения о кэше» теперь показывают реальные размеры, кнопка закрывает диалог, а «Очистить кэш» удаляет и загруженные изображения исполнителей';

  @override
  String get cl200Setup1 =>
      'Обновлённая первоначальная настройка со стеклянными панелями, анимациями появления и плавным фоном';

  @override
  String get cl200Setup2 =>
      'Настройка рекомендует стиль интерфейса, подходящий вашему телефону (производительный или облегчённый), и соответствующий фон, а также позволяет попробовать другой';

  @override
  String get cl200Setup3 =>
      'Облегчённый интерфейс теперь всегда использует простой фон; опция «Анимированные пятна» удалена';

  @override
  String get cl200Setup4 =>
      'Настройки теперь разбиты на группы (Впечатления, Медиатека и данные, Приложение) в том же простом стеклянном стиле, что и первоначальная настройка';

  @override
  String get cl200Setup5 =>
      'Сообщения появляются маленьким островком внизу экрана вместо снекбаров';

  @override
  String get cl200Look1 =>
      'Новый шрифт приложения (Cal Sans) и чуть более компактный текст во всём приложении';

  @override
  String get cl200Look2 =>
      'Матовые стеклянные поверхности везде, на слабых телефонах рисуются как простые сплошные';

  @override
  String get cl200Look3 =>
      'Обложка перелетает с карточек на страницы альбомов, исполнителей, папок и плейлистов; нажатые карточки реагируют, любимые песни рассыпаются сердечками, а метки времени прокручиваются';

  @override
  String get cl200Look4 =>
      'Скруглённая квадратная кнопка воспроизведения в «Любимых песнях»';

  @override
  String get cl200Look5 =>
      'Карточки главной и медиатеки используют тот же стеклянный стиль, что и первоначальная настройка, без лишнего размытия поверх размытого фона';

  @override
  String get cl200Perf1 =>
      'Noxira определяет оборудование телефона и подстраивает под него стеклянные эффекты, кэши изображений и переходы';

  @override
  String get cl200Perf2 =>
      'Страницы альбомов, исполнителей, папок и плейлистов открываются плавно: они загружаются после анимации открытия, строят короткую первую страницу песен и заранее размывают обложку заголовка';

  @override
  String get cl200Perf3 =>
      'Пересекающиеся запросы к медиатеке теперь выполняются совместно, а не повторяются, что снижает расход памяти на больших медиатеках';

  @override
  String get cl200Perf4 =>
      'Более быстрый поиск и пересканирование медиатеки, более лёгкая загрузка изображений и меньше работы при прокрутке списков';

  @override
  String get cl200Hood1 =>
      'Исправлено несколько сбоев: нажатие «Закрыть» в редакторе текстов, редакторе тегов или таймере сна после закрытия страницы, добавление в очередь или установка рингтона из меню песни, перевод текстов и открытие Noxira из виджета';

  @override
  String get cl200Hood2 =>
      'Приложение больше не вылетает, когда нет разрешения на доступ к хранилищу';

  @override
  String get cl200Hood3 =>
      'Плейлисты, любимые песни, счётчики прослушиваний и настройки сохраняются безопасно, поэтому прерванное сохранение больше не оставляет пустой файл';

  @override
  String get cl200Hood4 =>
      'FLAC-файлы, у которых блоки метаданных остались неполными после редактора тегов, исправляются при сохранении и снова воспроизводятся';

  @override
  String get cl200Hood5 =>
      'Обложка в уведомлении о медиа уменьшается, чтобы избежать зависаний при его создании';

  @override
  String get cl200Hood6 =>
      'Редактирование тегов у голосовых записей (M4A) больше не завершается ошибкой из-за остатков данных в конце файла';

  @override
  String get cl200Hood7 =>
      'Визуализатор больше не искажает треки Dolby Atmos; для них используется имитированная анимация';

  @override
  String get cl200Hood8 =>
      'Телефоны, не способные создать эффект эквалайзера, теперь воспроизводят как обычно, а эквалайзер ждёт первую песню вместо тайм-аута';

  @override
  String get cl200Hood9 =>
      '«Проверка обновлений» теперь показывает результат и сообщает, когда обновления приходят из Google Play';

  @override
  String get cl200Hood10 =>
      'Объявления, цель поддержки и некоторые онлайн-сервисы можно менять без обновления приложения';

  @override
  String get cl200Hood11 => 'Обновлены зависимости';

  @override
  String get pkgJustAudio => 'Многофункциональный аудиоплеер для Flutter';

  @override
  String get pkgAudioService => 'Фоновое воспроизведение и управление медиа';

  @override
  String get pkgAudioSession =>
      'Управление аудиосессией для корректного аудиофокуса';

  @override
  String get pkgOnAudioQuery => 'Запрос аудиофайлов из памяти устройства';

  @override
  String get pkgHaudiotagger => 'Чтение и запись тегов метаданных аудио';

  @override
  String get pkgProvider => 'Решение для управления состоянием во Flutter';

  @override
  String get pkgSharedPreferences => 'Постоянное хранилище «ключ — значение»';

  @override
  String get pkgPathProvider => 'Доступ к путям файловой системы устройства';

  @override
  String get pkgPermissionHandler => 'Управление разрешениями во время работы';

  @override
  String get pkgDynamicColor => 'Динамические цветовые темы Material You';

  @override
  String get pkgPaletteGenerator => 'Извлечение цветов из изображений';

  @override
  String get pkgStaggeredAnimations => 'Каскадные анимации списков';

  @override
  String get pkgHttp => 'HTTP-запросы для вызовов API';

  @override
  String get pkgUrlLauncher => 'Открытие ссылок в браузере';

  @override
  String get pkgSharePlus => 'Отправка контента в другие приложения';

  @override
  String get pkgPackageInfoPlus =>
      'Получение версии приложения и сведений о пакете';

  @override
  String get pkgDeviceInfoPlus => 'Получение сведений об устройстве';

  @override
  String get pkgFlutterDotenv => 'Загрузка переменных окружения из файла .env';

  @override
  String get pkgCrypto => 'Криптографические хеш-функции';

  @override
  String get pkgIntl => 'Интернационализация и локализация';

  @override
  String get pkgPubSemver => 'Инструменты семантического версионирования';

  @override
  String get pkgClarityFlutter => 'Аналитика Microsoft Clarity';

  @override
  String get pkgFlutterHooks => 'Хуки в стиле React для Flutter';

  @override
  String get themeAurora => 'Аврора';

  @override
  String get themeMidnight => 'Полночь';

  @override
  String get themeOcean => 'Океан';

  @override
  String get themeTeal => 'Бирюзовый';

  @override
  String get themeForest => 'Лес';

  @override
  String get themeNeon => 'Неон';

  @override
  String get themeGold => 'Золото';

  @override
  String get themeEmber => 'Тлеющий уголь';

  @override
  String get themeRose => 'Роза';

  @override
  String get themeSakura => 'Сакура';

  @override
  String artistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count исполнителя',
      many: '$count исполнителей',
      few: '$count исполнителя',
      one: '$count исполнитель',
    );
    return '$_temp0';
  }

  @override
  String get playbackInvalidPlaylist =>
      'Недопустимый плейлист или начальная позиция';

  @override
  String playbackCouldNotPlayTitleSkipping(String title) {
    return 'Не удалось воспроизвести «$title» — пропускаем';
  }

  @override
  String get playbackCouldNotPlaySkipping =>
      'Не удалось воспроизвести эту песню — пропускаем';

  @override
  String playbackCouldNotPlayTitle(String title) {
    return 'Не удалось воспроизвести «$title»';
  }

  @override
  String get playbackFailed => 'Ошибка воспроизведения';

  @override
  String playbackSetPlaylistFailed(String error) {
    return 'Не удалось задать плейлист: $error';
  }

  @override
  String playbackUpdatePlaylistFailed(String error) {
    return 'Не удалось обновить плейлист: $error';
  }
}
