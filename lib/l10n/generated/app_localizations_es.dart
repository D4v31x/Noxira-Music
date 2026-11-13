// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutArtist => 'Acerca del artista';

  @override
  String get add => 'Añadir';

  @override
  String get addExclusion => 'Añadir exclusión';

  @override
  String get addSeparator => 'Añadir separador';

  @override
  String get addSongs => 'Añadir canciones';

  @override
  String get addSongsToPlaylist =>
      'Añadir canciones a la lista de reproducción';

  @override
  String get addToPlaylist => 'Añadir a la lista de reproducción';

  @override
  String get adjustSync => 'Ajustar la sincronización';

  @override
  String get album => 'Álbum';

  @override
  String get albums => 'Álbumes';

  @override
  String get allSongs => 'Todas las canciones';

  @override
  String get appName => 'Noxira Music';

  @override
  String get artist => 'Artista';

  @override
  String get artistName => 'Nombre del artista';

  @override
  String get artists => 'Artistas';

  @override
  String get artistSeparation => 'Separación de artistas';

  @override
  String get artistSeparationDesc =>
      'Configurar cómo se reparten los ingresos entre varios artistas';

  @override
  String get audioQuality => 'Calidad de audio';

  @override
  String get audioQualityDesc =>
      'Especificaciones técnicas del archivo de audio';

  @override
  String get auroraMusic => 'Noxira Music';

  @override
  String get autoPlaylists => 'Listas de reproducción automáticas';

  @override
  String get autoTag => 'Etiqueta automática';

  @override
  String get smartPlaylists => 'Listas de reproducción inteligentes';

  @override
  String get createSmartPlaylist =>
      'Crear una lista de reproducción inteligente…';

  @override
  String get editSmartPlaylist => 'Editar lista de reproducción inteligente';

  @override
  String get smartPlaylistNameHint => 'Nombre de la lista de reproducción';

  @override
  String get smartPlaylistRules => 'Normas';

  @override
  String get addRule => 'Añadir regla';

  @override
  String get saveSmartPlaylist => 'Guardar';

  @override
  String get matchAll => 'Cumplir TODAS las normas';

  @override
  String get matchAny => 'Cualquier regla';

  @override
  String get limitResultsLabel => 'Limitar los resultados';

  @override
  String get noLimit => 'Sin límite';

  @override
  String get deleteSmartPlaylistConfirm =>
      '¿Quieres eliminar esta lista de reproducción inteligente? Esto solo elimina las reglas guardadas; tus canciones no se verán afectadas.';

  @override
  String smartPlaylistPreviewCount(int count) {
    return 'Ahora mismo hay $count canciones que coinciden';
  }

  @override
  String get saveAsClip => 'Guardar como clip';

  @override
  String get generatingClip => 'Generando el vídeo…';

  @override
  String get clipDuration => 'Duración del vídeo';

  @override
  String get clipStartOffset => 'Punto de partida';

  @override
  String get saveClip => 'Guardar clip';

  @override
  String get clipSavedToDevice => 'El vídeo se ha guardado en el dispositivo';

  @override
  String get clipSaveFailed =>
      'No se ha podido guardar el vídeo. Inténtalo de nuevo, por favor.';

  @override
  String get playlistSavedToDevice =>
      'Lista de reproducción guardada en el dispositivo';

  @override
  String get trackTags => 'Etiquetas de pista';

  @override
  String get editTrackTags => 'Editar etiquetas';

  @override
  String get addTrackTag => 'Añadir etiqueta';

  @override
  String get noTrackTagsYet =>
      'Aún no hay etiquetas. Añade una para ir directamente a una parte de esta pista.';

  @override
  String get trackTagNameHint =>
      'p. ej., título de la canción o nombre del artista';

  @override
  String get trackTagPosition => 'Cargo';

  @override
  String get useCurrentPosition => 'Utilizar la posición actual';

  @override
  String get isThisASet => 'Añadir marcas de tiempo a esta pista';

  @override
  String get tagPartsForEasySwitching =>
      'Marca cualquier momento: capítulos, pasajes destacados, marcadores o cualquier otra cosa.';

  @override
  String get tagThisTrack => 'Añadir etiquetas';

  @override
  String get pasteSetlist => 'Importar marcas de tiempo';

  @override
  String get pasteSetlistDialogTitle => 'Importar marcas de tiempo';

  @override
  String get pasteSetlistHint =>
      'Pega aquí las marcas de tiempo, por ejemplo:\n0:00 Introducción\n3:45 Nombre del capítulo';

  @override
  String get importAction => 'Importar';

  @override
  String tagsImportedMessage(int count) {
    return 'Etiquetas $count importadas';
  }

  @override
  String get noTagsFoundInPaste =>
      'No se han encontrado marcas de tiempo en el texto pegado.';

  @override
  String get bitrate => 'Velocidad de bits';

  @override
  String get buyMeCoffee => 'Invítame a un café';

  @override
  String get cancel => 'Cancelar';

  @override
  String get coffeeSupport => 'Apóyanos con un café';

  @override
  String get composer => 'Compositor';

  @override
  String get connectWithUs => 'Ponte en contacto con nosotros';

  @override
  String get copied => 'Copiado';

  @override
  String get copy => 'Copiar';

  @override
  String get create => 'Crear';

  @override
  String get createFirstPlaylist =>
      'Pulsa el botón de arriba para crear tu primera lista de reproducción';

  @override
  String get createPlaylist => 'Crear lista de reproducción';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get dateAdded => 'Fecha de incorporación';

  @override
  String get dateModified => 'Fecha de modificación';

  @override
  String get delete => 'Eliminar';

  @override
  String get deletePlaylist => 'Eliminar lista de reproducción';

  @override
  String get deletePlaylistConfirm => '¿Estás seguro de que quieres borrar?';

  @override
  String get deletePlaylistConfirmation =>
      '¿Estás seguro de que quieres eliminar esta lista de reproducción?';

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String get details => 'Ver detalles';

  @override
  String get discard => 'Descartar';

  @override
  String get dontShowAgain => 'No volver a mostrar';

  @override
  String get duration => 'Duración';

  @override
  String get enableArtistSeparation => 'Activar separación por artista';

  @override
  String get enableArtistSeparationDesc =>
      'Separar automáticamente los nombres de artistas compuestos';

  @override
  String get enjoyingAurora => '¿Te está gustando Noxira?';

  @override
  String get enjoyingAuroraDesc =>
      'Si te encanta usar Noxira Music, plantéate apoyar su desarrollo. ¡Tu apoyo ayuda a que siga siendo gratuita!';

  @override
  String get error => 'Error';

  @override
  String get exclusionHint => 'p. ej., CA/CC';

  @override
  String get exclusions => 'Exclusiones';

  @override
  String get exclusionsDesc => 'Nombres de artistas que nunca deben separarse';

  @override
  String get exit => 'Salir';

  @override
  String get exitApp => 'Salir de la aplicación';

  @override
  String get exitAppConfirm => '¿Quieres salir?';

  @override
  String get expandLyrics => 'Ver la letra completa';

  @override
  String get extraLarge => 'Extragrande';

  @override
  String get favoriteSongs => 'Canciones favoritas';

  @override
  String get fileInfo => 'Información del archivo';

  @override
  String get fileInfoDesc => 'Mantén pulsado sobre los valores para copiarlos';

  @override
  String get fileName => 'Nombre del archivo';

  @override
  String get filePath => 'Ruta del archivo';

  @override
  String get folder => 'Carpeta';

  @override
  String get folders => 'Carpetas';

  @override
  String get fontSize => 'Tamaño de la fuente';

  @override
  String get format => 'Formato';

  @override
  String get forYou => 'Para ti';

  @override
  String get genre => 'Género';

  @override
  String get goodQuality => 'Buena calidad';

  @override
  String get gotIt => '¡Entendido!';

  @override
  String get grantPermission => 'Conceder permiso';

  @override
  String get highQuality => 'Alta calidad';

  @override
  String get home => 'Inicio';

  @override
  String get kofi => 'Ko-fi';

  @override
  String get buyMeACoffee => 'Invítame a un café';

  @override
  String get donationNote =>
      'No te preocupes, siempre puedes hacer una donación más adelante en «Configuración».';

  @override
  String get language => 'Idioma';

  @override
  String get large => 'Grande';

  @override
  String get later => 'Más tarde';

  @override
  String get library => 'Biblioteca';

  @override
  String get libraryError => 'Error al cargar la biblioteca de música';

  @override
  String get libraryLoaded => 'Se ha cargado la biblioteca musical';

  @override
  String get libraryUpdated => 'Se ha actualizado la biblioteca';

  @override
  String get loading => 'Cargando';

  @override
  String get loadingLibrary => 'Cargando la biblioteca';

  @override
  String get lossless => 'Sin pérdidas';

  @override
  String get lowQuality => 'Baja calidad';

  @override
  String get lyrics => 'Letra de la canción';

  @override
  String get lyricsAhead => 'A continuación están las letras de las canciones';

  @override
  String get lyricsBehind => 'Las letras están más abajo';

  @override
  String get lyricsSynced => 'Las letras están sincronizadas';

  @override
  String get maybeLater => 'Quizás más tarde';

  @override
  String get medium => 'Medio';

  @override
  String get metadata => 'Metadatos';

  @override
  String get metadataSaved => 'Los metadatos se han guardado correctamente';

  @override
  String get metadataApplied => 'Los metadatos se han descargado correctamente';

  @override
  String get metadataDownloadFailed =>
      'La descarga ha fallado. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get chooseArtworkFromDevice => 'Elige un dispositivo';

  @override
  String get mostPlayed => 'Los más reproducidos';

  @override
  String get newPlaylist => 'Nueva lista de reproducción';

  @override
  String get next => 'Siguiente';

  @override
  String get no => 'No';

  @override
  String get noAlbumsFound => 'No se han encontrado álbumes';

  @override
  String get noArtistInfo => 'No hay información disponible sobre el artista';

  @override
  String get noArtistsFound => 'No se han encontrado artistas';

  @override
  String get noData => 'No hay datos que mostrar';

  @override
  String get noExclusions => 'No hay exclusiones configuradas';

  @override
  String get noLyrics => 'Letra no disponible';

  @override
  String get noLyricsDesc =>
      'No hemos podido encontrar la letra de esta canción';

  @override
  String get noLyricsFound => 'No se han encontrado letras';

  @override
  String get noPermissionExplanation =>
      'Si no concedes los permisos necesarios, Noxira Music no podrá acceder a tu biblioteca musical.';

  @override
  String get noPlaylists => 'No hay listas de reproducción disponibles';

  @override
  String get noResults => 'No se han encontrado resultados';

  @override
  String get noSeparators => 'No hay separadores configurados';

  @override
  String get noSongPlaying => 'No se está reproduciendo ninguna canción';

  @override
  String get noSongsAvailable => 'No hay canciones disponibles';

  @override
  String get noSongsInPlaylist =>
      'No hay canciones en esta lista de reproducción';

  @override
  String get nowPlaying => 'Ahora en pantalla';

  @override
  String get onboardingAlbumArtwork => 'Portada del álbum';

  @override
  String get onboardingAlbumArtworkDesc =>
      'Obtiene carátulas de álbumes de alta calidad para mejorar tu biblioteca';

  @override
  String get onboardingAnalytics => 'Análisis anónimos e informes de fallos';

  @override
  String get onboardingAnalyticsDesc =>
      'Nos ayuda a corregir errores y mejorar el rendimiento. Nunca incluye tu historial de reproducción ni datos personales.';

  @override
  String get onboardingAppInfoSubtitle => 'Tu compañero musical personal';

  @override
  String get onboardingAudioAccess => 'Acceso al audio';

  @override
  String get onboardingAudioAccessDesc =>
      'Es necesario para reproducir y gestionar tu biblioteca musical';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingBeautifulArtwork => 'Preciosa portada del álbum';

  @override
  String get onboardingBeautifulArtworkDesc =>
      'Recupera y muestra automáticamente las carátulas de los álbumes tal y como deben verse';

  @override
  String get onboardingBluetooth => 'Bluetooth';

  @override
  String get onboardingBluetoothDesc =>
      'Es necesario para conectarse a dispositivos Bluetooth';

  @override
  String get onboardingChooseLanguage => 'Elige tu idioma';

  @override
  String get onboardingCompletionSubtitle => 'Empieza a disfrutar de tu música';

  @override
  String get onboardingCompletionTitle => '¡Ya está todo listo!';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingDynamicColors => 'Colores dinámicos';

  @override
  String get onboardingDynamicColorsDesc =>
      'Combinar los colores del fondo de pantalla con los del sistema';

  @override
  String get onboardingGrantPermissions => 'Conceder permisos';

  @override
  String get onboardingInternetSubtitle => 'Cómo utiliza Noxira Music Internet';

  @override
  String get onboardingInternetTitle => 'Uso de Internet';

  @override
  String get onboardingLocalMusic => 'Música en tu dispositivo';

  @override
  String get onboardingLocalMusicDesc =>
      'Lleva tus archivos de música en la palma de tu mano';

  @override
  String get onboardingLyrics => 'Letra de la canción';

  @override
  String get onboardingLyricsDesc =>
      'Descarga letras sincronizadas para tus canciones desde LRCLIB, Better Lyrics, YouLyPlus y KuGou. Estos servicios reciben el título, el artista, el álbum y la duración de la canción. Puedes desactivar cada fuente en Ajustes.';

  @override
  String get onboardingLyricsSupport => 'Ayuda con las letras de las canciones';

  @override
  String get onboardingLyricsSupportDesc =>
      'Ver la letra sincronizada mientras escuchas';

  @override
  String get onboardingMaterialDesign => 'Diseño «Material You»';

  @override
  String get onboardingMaterialDesignDesc =>
      'Colores dinámicos que se adaptan a tus preferencias';

  @override
  String get onboardingMusicMetadata => 'Metadatos musicales';

  @override
  String get onboardingMusicMetadataDesc =>
      'Obtiene información sobre el artista, detalles del álbum e información sobre las canciones';

  @override
  String get onboardingNotifications => 'Notificaciones';

  @override
  String get onboardingNotificationsDesc =>
      'Mostrar controles de reproducción y actualizaciones';

  @override
  String get onboardingPermissionsSubtitle =>
      'Noxira Music necesita estos permisos para funcionar correctamente';

  @override
  String get onboardingPermissionsTitle => 'Conceder permisos';

  @override
  String get onboardingPrivacyNote =>
      'Tu privacidad es importante. Todos los archivos de música permanecen en tu dispositivo.';

  @override
  String get onboardingRequesting => 'Solicitando...';

  @override
  String get onboardingRequired => 'Obligatorio';

  @override
  String get onboardingAudioRequired =>
      'Es necesario tener acceso al audio para continuar. Por favor, concede el permiso indicado anteriormente.';

  @override
  String get onboardingSelectLanguage => 'Selecciona tu idioma preferido';

  @override
  String get onboardingSmartPlaylists => 'Listas de reproducción inteligentes';

  @override
  String get onboardingSmartPlaylistsDesc =>
      'Crea y gestiona tus colecciones de música';

  @override
  String get onboardingStartListening => 'Empieza a escuchar';

  @override
  String get onboardingStorageAccess => 'Acceso al almacenamiento';

  @override
  String get onboardingStorageAccessDesc =>
      'Es necesario para leer archivos de música de tu dispositivo';

  @override
  String get onboardingVisualizerAccess => 'Visualizador';

  @override
  String get onboardingVisualizerAccessDesc =>
      'Permite que el visualizador lea la sesión de audio de tu dispositivo para mostrar el espectro en tiempo real. No se graba ningún audio en ningún momento.';

  @override
  String get onboardingThemeSubtitle =>
      'Elige un tema que se adapte a tu estilo';

  @override
  String get onboardingThemeTitle => 'Personaliza tu look';

  @override
  String get oneTimeSupport => 'Asistencia rápida y puntual';

  @override
  String get openFolder => 'Abrir en el Gestor de archivos';

  @override
  String get openFolderInfo =>
      'Utiliza tu gestor de archivos para acceder a esta ubicación';

  @override
  String get ownTimer => 'Temporizador propio';

  @override
  String get permDeny => 'Permisos denegados';

  @override
  String get permissionExplanation =>
      'Noxira Music necesita estos permisos para funcionar correctamente. Concede los permisos en los ajustes de la aplicación.';

  @override
  String get permissionLater =>
      'Puedes conceder permisos más adelante en la configuración de la aplicación.';

  @override
  String get permissionRequired => 'Se requiere autorización';

  @override
  String get playAll => 'Reproducir todo';

  @override
  String get playingFrom => 'Reproducción desde';

  @override
  String get playlist => 'Lista de reproducción';

  @override
  String get playlistName => 'Nombre de la lista de reproducción';

  @override
  String get playlists => 'Listas de reproducción';

  @override
  String get possibleReasons => 'Posibles motivos:';

  @override
  String get privacyNotice =>
      'Al seguir utilizando esta aplicación, aceptas nuestra Política de privacidad.';

  @override
  String get privacyPolicyLink => 'Lee nuestra Política de privacidad';

  @override
  String get quality => 'Calidad';

  @override
  String get queue => 'Cola';

  @override
  String get queueEmpty => 'La cola está vacía';

  @override
  String get reasonFormat =>
      'El formato de archivo no permite editar los metadatos';

  @override
  String get reasonPermissions =>
      'No se han concedido los permisos de almacenamiento';

  @override
  String get reasonReadonly =>
      'El archivo es de solo lectura o se encuentra en un dispositivo de almacenamiento externo';

  @override
  String get recentlyAdded => 'Añadidos recientemente';

  @override
  String get recentlyPlayed => 'Últimos juegos';

  @override
  String get recentlyPlayedArtists =>
      'Artistas que se han reproducido recientemente';

  @override
  String get recentlyPlayedSongs => 'Canciones escuchadas recientemente';

  @override
  String get refreshing => 'Qué refrescante...';

  @override
  String get refreshLyrics => 'Actualizar la letra de la canción';

  @override
  String get remove => 'Eliminar';

  @override
  String get removeSong => 'Eliminar canción';

  @override
  String get removeSongConfirmation =>
      '¿Quieres eliminar esta canción de la lista de reproducción?';

  @override
  String get rename => 'Cambiar nombre';

  @override
  String get renamePlaylist => 'Cambiar el nombre de la lista de reproducción';

  @override
  String get repeat => 'Repetir';

  @override
  String get reset => 'Restablecer';

  @override
  String get resetArtistSeparationDesc =>
      'Esto restablecerá todos los separadores y exclusiones predeterminados.';

  @override
  String get resetToDefaults => 'Restablecer valores predeterminados';

  @override
  String get result => 'Resultado';

  @override
  String get results => 'Resultados';

  @override
  String get retry => 'Volver a intentarlo';

  @override
  String get sampleRate => 'Frecuencia de muestreo';

  @override
  String get save => 'Guardar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get saveChangesDesc => '¿Quieres guardar los cambios?';

  @override
  String get saveFailed => 'Error al guardar';

  @override
  String get saveFailedDesc =>
      'No se han podido guardar los metadatos en este archivo.';

  @override
  String get scanFailed => 'Error al escanear';

  @override
  String get scanningSongs => 'Escanear canciones';

  @override
  String get search => 'Buscar';

  @override
  String get searchAlbums => 'Buscar álbumes';

  @override
  String get searchArtists => 'Buscar artistas';

  @override
  String get searchFailed => 'La búsqueda no se ha podido realizar';

  @override
  String get lyricsSource => 'Fuente de letras';

  @override
  String get inPlaylistHint => 'En una lista';

  @override
  String get removeDuplicates => 'Quitar duplicados';

  @override
  String get noDuplicatesFound => 'No se encontraron canciones duplicadas';

  @override
  String duplicatesRemoved(int count) {
    return '$count canciones duplicadas eliminadas';
  }

  @override
  String get supportNoxiraTitle => '¡Apoya Noxira!';

  @override
  String get supportButton => 'Apoyar';

  @override
  String supportGoalProgress(String raised, String goal) {
    return '$raised de $goal este mes';
  }

  @override
  String get onboardingSupportGoal => 'Objetivo de apoyo';

  @override
  String get onboardingSupportGoalDesc =>
      'De vez en cuando descarga un pequeño archivo público con el objetivo de apoyo de este mes y lo recaudado. Es una descarga simple: no se envía nada sobre ti ni sobre tu música.';

  @override
  String get songAddedChip => 'Añadida';

  @override
  String get tapToRemove => 'Toca para quitar';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingYourLanguage => '¿Tu idioma?';

  @override
  String get onboardingAllow => 'Permitir';

  @override
  String get onboardingSummaryLanguage => 'Idioma';

  @override
  String get onboardingSummaryTheme => 'Aspecto';

  @override
  String get onboardingSummaryLibrary => 'Acceso a la biblioteca de música';

  @override
  String get onboardingAllowed => 'Permitido';

  @override
  String get onboardingNotAllowed => 'Aún no permitido';

  @override
  String get searchLyrics => 'Buscar letras de canciones';

  @override
  String get searchMetadata => 'Buscar metadatos';

  @override
  String get searchTracks => 'Buscar canciones';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get selectArtist => 'Seleccionar artista';

  @override
  String get selected => 'seleccionado';

  @override
  String get separator => 'Separador';

  @override
  String get separatorHint => 'p. ej. / o con la participación de';

  @override
  String get separators => 'Separadores';

  @override
  String get set => 'Conjunto';

  @override
  String get setMinutes => 'Establecer la duración de las reuniones';

  @override
  String get settings => 'Configuración';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutApp => 'Acerca de Noxira Music';

  @override
  String get settingsAboutSubtitle => 'Versión, comentarios y actualizaciones';

  @override
  String get settingsGroupExperience => 'Experiencia';

  @override
  String get settingsGroupLibrary => 'Biblioteca y datos';

  @override
  String get settingsGroupApp => 'Aplicación';

  @override
  String get settingsAccentColor => 'Color de contraste';

  @override
  String get settingsAppearance => 'Aspecto';

  @override
  String get settingsAppearanceSubtitle => 'Tema, colores y diseño';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsBackground => 'Fondo';

  @override
  String get settingsCacheCleared => 'Caché borrada';

  @override
  String get settingsCacheInfo => 'Información de la caché';

  @override
  String get settingsCacheInfoDesc => 'Ver el uso de almacenamiento';

  @override
  String get settingsCheckingUpdates => 'Buscando actualizaciones...';

  @override
  String get settingsCheckUpdates => 'Buscar actualizaciones';

  @override
  String get settingsCheckUpdatesDesc => 'Obtén la última versión';

  @override
  String get settingsClearCache => 'Borrar caché';

  @override
  String get settingsClearCacheDesc => 'Elimina todos los datos en caché';

  @override
  String get settingsClearCacheMessage =>
      'Todos los datos en caché se eliminarán y se reconstruirán cuando haga falta.';

  @override
  String get settingsClearCacheTitle => '¿Borrar la caché?';

  @override
  String get settingsDataWindow => 'Ventana de datos';

  @override
  String get settingsDataWindowDesc =>
      'Cuánto tiempo atrás mira la pantalla de resumen';

  @override
  String get settingsGapless => 'Reproducción sin pausas';

  @override
  String get settingsGaplessDesc => 'Transiciones fluidas entre pistas';

  @override
  String get settingsAutomix => 'Automix';

  @override
  String get settingsAutomixDesc =>
      'Crea automáticamente una transición continua entre canciones';

  @override
  String get settingsCrossfade => 'Fundido cruzado';

  @override
  String get settingsCrossfadeDesc =>
      'Mezcla suavemente el final de una pista con la siguiente';

  @override
  String get crossfadeDuration => 'Duración del fundido cruzado';

  @override
  String get crossfadeDurationDesc =>
      'Cuánto dura el solapamiento entre pistas';

  @override
  String get settingsInsights => 'Estadísticas';

  @override
  String get settingsInsightsSubtitle => 'Periodo del resumen de escucha';

  @override
  String get settingsLast7Days => 'Últimos 7 días';

  @override
  String get settingsLast30Days => 'Últimos 30 días';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLayout => 'Diseño';

  @override
  String get settingsLibraryFolders => 'Carpetas de la biblioteca';

  @override
  String get settingsLibraryFoldersSubtitle =>
      'Incluir o excluir carpetas de análisis';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouDesc =>
      'Colores dinámicos del fondo de pantalla';

  @override
  String get settingsMonthlyRecap => 'Resumen mensual';

  @override
  String get settingsMonthlyRecapDesc =>
      'Muestra un banner cada mes (tiene prioridad sobre el semanal)';

  @override
  String get settingsNormalization => 'Normalización de volumen';

  @override
  String get settingsNormalizationDesc =>
      'Niveles de volumen uniformes · Requiere etiquetas ReplayGain en tus archivos';

  @override
  String get playbackSpeed => 'Velocidad de reproducción';

  @override
  String get playbackSpeedDesc =>
      'Ajusta la velocidad de reproducción del audio';

  @override
  String get adjustPitchWithSpeed => 'Adjust pitch with speed';

  @override
  String get adjustPitchWithSpeedDesc =>
      'When off, tempo changes without pitch shift';

  @override
  String get playbackPitch => 'Tono';

  @override
  String get playbackPitchDesc =>
      'Sube o baja el sonido, independientemente de la velocidad';

  @override
  String get playbackPitchLinkedDesc => 'Sigue la velocidad de reproducción';

  @override
  String get settingsPlayback => 'Reproducción';

  @override
  String get settingsPlaybackSubtitle =>
      'Velocidad, sin pausas y normalización';

  @override
  String get settingsRecapBannerDesc =>
      'El banner aparece en la pantalla de inicio al comienzo de cada nueva semana o mes, contados desde tu primera reproducción. Al tocar «Más tarde» se oculta durante la sesión; al tocar «Mostrar» se marca como visto.';

  @override
  String get settingsRecapContent => 'Contenido del resumen';

  @override
  String get settingsRecapContentDesc =>
      'Controla cuánto historial muestra la pantalla de resumen cuando la abres manualmente o desde el banner.';

  @override
  String get settingsPreviewRecap => 'Vista previa del resumen';

  @override
  String get settingsPreviewRecapDesc =>
      'Mira cómo queda tu resumen ahora mismo con los ajustes actuales';

  @override
  String get settingsRecapSchedule => 'Programación del resumen';

  @override
  String get settingsStorage => 'Almacenamiento';

  @override
  String settingsCacheItems(String count) {
    return '$count elementos';
  }

  @override
  String get settingsMemoryCache => 'Caché de memoria';

  @override
  String get settingsStorageSubtitle => 'Caché y archivos multimedia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsTools => 'Herramientas';

  @override
  String get settingsResetSetup => 'Reset Setup';

  @override
  String get settingsResetSetupDesc => 'Restart the onboarding flow';

  @override
  String get settingsUpdateAvailable => '¡Actualización disponible!';

  @override
  String get settingsUpToDate => 'Estás al día';

  @override
  String get settingsUpdateCheckFailed =>
      'No se pudo buscar actualizaciones. Las actualizaciones llegan desde Google Play.';

  @override
  String get settingsWeeklyRecap => 'Resumen semanal';

  @override
  String get settingsWeeklyRecapDesc =>
      'Muestra un banner cada semana tras tu primera reproducción';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get share => 'Compartir';

  @override
  String get shuffle => 'Aleatorio';

  @override
  String get size => 'Tamaño';

  @override
  String get sleepTimer => 'Temporizador de sueño';

  @override
  String get small => 'Pequeño';

  @override
  String get songInfo => 'Información de la canción';

  @override
  String get songs => 'Canciones';

  @override
  String get songsLoaded => 'Canciones cargadas';

  @override
  String get standardQuality => 'Calidad estándar';

  @override
  String get startType => 'Empieza a escribir para buscar';

  @override
  String get storagePermissionNeeded =>
      'Para editar los metadatos, Noxira Music necesita permiso para gestionar archivos. Concede «Acceso a todos los archivos» en los ajustes.';

  @override
  String get suggestedArtists => 'Artistas para ti';

  @override
  String get suggestedTracks => 'Pistas sugeridas';

  @override
  String get supportAurora => 'Apoya Noxira';

  @override
  String get supportAuroraBtn => 'Apoya Noxira';

  @override
  String get supportAuroraDescShort =>
      'Ayuda a mantener la aplicación gratuita';

  @override
  String get supportAuroraMessage =>
      'Ayuda a mantener Noxira Music gratuita y apoya su desarrollo futuro. ¡Cada contribución significa mucho!';

  @override
  String get supportAuroraTitle => 'Apoya Noxira Music';

  @override
  String get updatedTitle => 'Noxira Music se ha actualizado';

  @override
  String get tapAddToAddSongs => 'Toca + para añadir canciones';

  @override
  String get reorderSongs => 'Reordenar canciones';

  @override
  String get done => 'Hecho';

  @override
  String get thankYouSupport => '¡Gracias por tu apoyo!';

  @override
  String get theme => 'Tema';

  @override
  String get title => 'Título';

  @override
  String get topResult => 'Mejor resultado';

  @override
  String get total => 'Total';

  @override
  String get track => 'Pista';

  @override
  String get trackInfo => 'Información de la pista';

  @override
  String get trackInfoDesc =>
      'Toca el icono de edición para modificar la información de la pista';

  @override
  String get trackInfoEditDesc =>
      'Edita los campos de abajo y toca el icono de verificación para guardar';

  @override
  String get tracks => 'Pistas';

  @override
  String get unknown => 'Desconocido';

  @override
  String get unknownArtist => 'Artista desconocido';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String get updateMessage => 'Hay una nueva versión disponible';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get viewArtist => 'Ver artista';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get welcomeBack => 'Te damos la bienvenida de nuevo';

  @override
  String get whatsNew => 'Novedades';

  @override
  String get view_changelog => 'Ver el registro de cambios y las novedades';

  @override
  String get year => 'Año';

  @override
  String get yes => 'Yes';

  @override
  String get yourLibrary => 'Tu biblioteca';

  @override
  String get yourPlaylists => 'Tus listas';

  @override
  String get homeLayout => 'Diseño de inicio';

  @override
  String get homeLayoutDesc =>
      'Personaliza el orden de las secciones de la pestaña Inicio';

  @override
  String get customizeHomeTab => 'Personalizar pestaña Inicio';

  @override
  String get dragToReorder => 'Arrastra para reordenar las secciones';

  @override
  String get resetToDefault => 'Restablecer valores predeterminados';

  @override
  String get resetLayoutConfirm => '¿Restablecer el diseño predeterminado?';

  @override
  String get resetLayoutMessage =>
      'Esto restaurará el orden y la visibilidad originales de las secciones.';

  @override
  String get listeningHistory => 'Historial de escucha';

  @override
  String get libraryStats => 'Estadísticas de la biblioteca';

  @override
  String get back => 'Atrás';

  @override
  String get continueButton => 'Continuar';

  @override
  String get skip => 'Omitir';

  @override
  String get send_feedback => 'Enviar comentarios';

  @override
  String get send_feedback_desc => 'Informa de errores o sugiere funciones';

  @override
  String get rateApp => 'Valorar Noxira Music';

  @override
  String get rateAppDesc =>
      '¿Te gusta la aplicación? Deja una reseña en Google Play';

  @override
  String get feedbackTypeBug => 'Error';

  @override
  String get feedbackTypeSuggestion => 'Sugerencia';

  @override
  String get feedbackHint => 'Describe el error o la sugerencia...';

  @override
  String get feedbackSend => 'Enviar';

  @override
  String get feedbackSentThanks => '¡Gracias por tus comentarios!';

  @override
  String get feedbackSentError =>
      'No se pudieron enviar los comentarios. Inténtalo de nuevo más tarde.';

  @override
  String get contributeTranslations => 'Contribuir con traducciones';

  @override
  String get contributeTranslationsDesc =>
      'Ayuda a traducir Noxira Music en Crowdin';

  @override
  String get contributeTranslationsTitle => 'Ayúdanos a traducir';

  @override
  String get contributeTranslationsSubtitle =>
      'Noxira Music está disponible en varios idiomas gracias a nuestra increíble comunidad. Ayúdanos a llegar a más usuarios traduciendo la aplicación a tu idioma: solo lleva unos minutos empezar.';

  @override
  String get contributeTranslationsOpenCrowdin => 'Abrir Crowdin';

  @override
  String get close => 'Cerrar';

  @override
  String get settingsHighendUi => 'Interfaz de gama alta';

  @override
  String get settingsHighendUiDesc =>
      'Activa efectos visuales y animaciones avanzados';

  @override
  String get clearUpcoming => 'Borrar próximas';

  @override
  String get addToQueue => 'Añadir a la cola';

  @override
  String get playNext => 'Reproducir a continuación';

  @override
  String get removeFromQueue => 'Quitar de la cola';

  @override
  String get play => 'Reproducir';

  @override
  String get viewAlbum => 'Ver álbum';

  @override
  String get shuffleAll => 'Reproducir todo al azar';

  @override
  String get noSongsFound => 'No se encontraron canciones';

  @override
  String get noFoldersFound => 'No se encontraron carpetas';

  @override
  String get deleteSong => 'Eliminar canción';

  @override
  String get modifySystemSettingsPermission =>
      'Permite «Modificar los ajustes del sistema» en la página que se ha abierto y vuelve a intentarlo.';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String songsAddedToQueue(int count) {
    return '$count canciones añadidas a la cola';
  }

  @override
  String songAddedToQueue(String title) {
    return '«$title» añadida a la cola';
  }

  @override
  String songSetAsRingtone(String title) {
    return '«$title» establecida como tono de llamada';
  }

  @override
  String failedToSetRingtone(String error) {
    return 'No se pudo establecer el tono: $error';
  }

  @override
  String deleteSongConfirm(String title) {
    return '¿Eliminar «$title» de tu dispositivo? No se puede deshacer.';
  }

  @override
  String songDeleted(String title) {
    return '«$title» eliminada';
  }

  @override
  String failedToDelete(String error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String songCount(int count) {
    return '$count canciones';
  }

  @override
  String get badgeNew => 'NEW';

  @override
  String get paused => 'En pausa';

  @override
  String get readyToPlay => 'Listo para reproducir';

  @override
  String get tapSongToStartListening =>
      'Toca una canción para empezar a escuchar';

  @override
  String get clearCachedLyrics => 'Borrar letras en caché';

  @override
  String lyricsCleared(String title) {
    return 'Letras en caché borradas para «$title»';
  }

  @override
  String lyricsAdded(String title) {
    return 'Letra añadida para «$title»';
  }

  @override
  String get noLyricsCached => 'No hay letras en caché para esta canción';

  @override
  String get setAsRingtone => 'Establecer como tono de llamada';

  @override
  String get songInfoEdit => 'Información de la canción / Editar';

  @override
  String get goToAlbum => 'Ir al álbum';

  @override
  String get goToArtist => 'Ir al artista';

  @override
  String get deleteFromDevice => 'Eliminar del dispositivo';

  @override
  String get checkOutThisSong => '¡Escucha esta canción!';

  @override
  String get backgroundSolid => 'Color sólido';

  @override
  String get backgroundHighEndStyle => 'Fondo de Reproduciendo ahora';

  @override
  String get backgroundHighEndStyleDesc =>
      'Estilo de fondo en la pantalla Reproduciendo ahora';

  @override
  String get backgroundBlurredArtwork => 'Carátula desenfocada';

  @override
  String get accentColor => 'Color de énfasis';

  @override
  String get accentColorDesc => 'Elige el color de énfasis de la aplicación';

  @override
  String get backgroundBlur => 'Desenfoque del fondo';

  @override
  String get backgroundBlurDesc => 'Intensidad del desenfoque de la carátula';

  @override
  String get backgroundDarkness => 'Oscuridad del fondo';

  @override
  String get backgroundDarknessDesc => 'Opacidad de la capa sobre la carátula';

  @override
  String get microphoneAccessNeeded => 'Se necesita acceso al micrófono';

  @override
  String get microphoneAccessDesc =>
      'Noxira necesita acceso al micrófono para captar la sesión de audio de tu dispositivo para el visualizador en vivo. Nunca se graba ni se guarda audio.';

  @override
  String get recapWeek => 'semanal';

  @override
  String get recapMonth => 'mensual';

  @override
  String get recapPeriodWeek => 'Semana';

  @override
  String get recapPeriodMonth => 'Mes';

  @override
  String get recapWeekly => 'Semanal';

  @override
  String get recapMonthly => 'Mensual';

  @override
  String get recapIntroAppName => 'NOXIRA MUSIC';

  @override
  String recapIntroTitle(String period) {
    return 'Tu resumen\n$period';
  }

  @override
  String get recapIntroSubtitle => 'Veamos qué has estado\nescuchando.';

  @override
  String recapPlayedEyebrow(String period) {
    return 'En tu resumen $period reprodujiste música';
  }

  @override
  String get recapTimeSingular => 'vez';

  @override
  String get recapTimePlural => 'veces';

  @override
  String get recapListenedForEyebrow => 'Escuchaste durante';

  @override
  String get recapListenedForLabel => 'de música';

  @override
  String get recapTopTrackEyebrow => 'Tu pista n.º 1';

  @override
  String get recapPlays => 'reproducciones';

  @override
  String get recapTopTracksTitle => 'Pistas más escuchadas';

  @override
  String get recapTopArtistEyebrow => 'Tu artista favorito';

  @override
  String get recapTopArtistsTitle => 'Artistas más escuchados';

  @override
  String get recapNothingToWrap => 'Aún no hay nada que resumir';

  @override
  String recapNothingToWrapBody(String period) {
    return 'Reproduce algo de música y vuelve para ver tu resumen $period.';
  }

  @override
  String get recapSwipeUp => 'DESLIZA HACIA ARRIBA';

  @override
  String get recapYourSoundLabel => 'TU SONIDO';

  @override
  String get recapYouListenMost => 'ESCUCHAS MÁS';

  @override
  String recapOnDay(String day) {
    return 'on ${day}s';
  }

  @override
  String recapAroundTime(String time) {
    return 'sobre las $time';
  }

  @override
  String get recapVibesHitDifferent => 'Es cuando el ambiente suena distinto.';

  @override
  String get recapThatsAWrap => 'ESO ES TODO';

  @override
  String recapInNumbers(String period) {
    return 'Tu resumen $period\nen cifras';
  }

  @override
  String get recapNumberOneTrack => 'PISTA N.º 1';

  @override
  String get recapStatTotalPlays => 'Reproducciones totales';

  @override
  String get recapStatTimeListened => 'Tiempo escuchado';

  @override
  String get recapStatUniqueTracks => 'Pistas únicas';

  @override
  String get recapStatTopArtist => 'Artista favorito';

  @override
  String get recapDone => 'Hecho';

  @override
  String get recapWeekdayMonday => 'Lunes';

  @override
  String get recapWeekdayTuesday => 'Martes';

  @override
  String get recapWeekdayWednesday => 'Miércoles';

  @override
  String get recapWeekdayThursday => 'Jueves';

  @override
  String get recapWeekdayFriday => 'Viernes';

  @override
  String get recapWeekdaySaturday => 'Sábado';

  @override
  String get recapWeekdaySunday => 'Domingo';

  @override
  String get recapBannerTitle => 'Tu resumen musical está aquí';

  @override
  String get recapBannerShow => 'Mostrar';

  @override
  String get recapBannerLater => 'Más tarde';

  @override
  String get rebrandTitle => 'Aurora ahora es Noxira';

  @override
  String get rebrandSubtitle =>
      'La misma app de música que conoces, con un nuevo nombre, un aspecto renovado y algunas funciones nuevas.';

  @override
  String get rebrandNewHeading => 'Novedades';

  @override
  String get rebrandSlideLyricsTitle => 'Letras, reconstruidas';

  @override
  String get rebrandSlideLyricsBody =>
      'Una nueva página de letras y más fuentes, para que más canciones encuentren su letra. Toca una línea para saltar a ella. Ahora puedes traducir las letras al idioma que quieras.';

  @override
  String get rebrandSlideWidgetTitle => 'Un nuevo widget de inicio';

  @override
  String get rebrandSlideWidgetBody =>
      'Cristal teñido con tu carátula y botones de anterior, reproducir y siguiente que funcionan sin abrir la app.';

  @override
  String get rebrandSlideQueueTitle => 'Una cola de verdad';

  @override
  String get rebrandSlideQueueBody =>
      'Mira lo que sonó y lo que viene. Arrastra para reordenar, desliza para quitar.';

  @override
  String get rebrandSlideOutputTitle => 'Elige dónde suena';

  @override
  String get rebrandSlideOutputBody =>
      'Toca el chip de Bluetooth en la pantalla de inicio, o el nuevo botón en Reproduciendo ahora, para pasar la reproducción entre el altavoz del teléfono y los dispositivos conectados, sin salir de la aplicación.';

  @override
  String get rebrandSlideLibraryTitle => 'Una biblioteca más ordenada';

  @override
  String get rebrandSlideLibraryBody =>
      'Noxira detecta pistas duplicadas y te deja elegir qué copia conservar. Las listas tienen un nuevo diseño con Favoritas, automáticas e inteligentes en un solo lugar.';

  @override
  String get rebrandMoreMessages =>
      'Los mensajes ahora aparecen como una pequeña isla en la parte inferior de la pantalla.';

  @override
  String get rebrandMorePerformance =>
      'Búsqueda más rápida, inicio más ágil y carga de imágenes más ligera.';

  @override
  String get translateLyricsTo => 'Traducir la letra a';

  @override
  String get translateLyricsAppLanguage => 'Idioma de la app';

  @override
  String get translateLyricsChooseLanguage => 'Elegir idioma…';

  @override
  String get rebrandSlideMoreTitle => 'Y algunas cosas más';

  @override
  String get rebrandMoreSetup =>
      'La configuración ahora recomienda el modo adecuado para tu teléfono.';

  @override
  String get rebrandMoreLook =>
      'Un banner de apoyo más discreto, un botón de reproducción redondeado en Canciones favoritas y controles de letras que ya no se ocultan.';

  @override
  String get rebrandMoreMotion =>
      'Transiciones más fluidas y mejores en toda la app.';

  @override
  String get rebrandMorePlayback =>
      'Deslizadores de velocidad y tono independientes, que puedes vincular.';

  @override
  String get rebrandMoreSearch =>
      'Una pestaña de búsqueda rediseñada y una página de Ajustes ordenada en grupos.';

  @override
  String get rebrandMoreFixes =>
      'Mejoras de estabilidad y corrección de errores en toda la app, incluido el parpadeo de las letras.';

  @override
  String get eqTitle => 'Ecualizador';

  @override
  String get eqOn => 'ON';

  @override
  String get eqOff => 'OFF';

  @override
  String get eqNotAvailable => 'Ecualizador no disponible en este dispositivo.';

  @override
  String get eqWaitingForAudio =>
      'Reproduce una canción para ajustar el ecualizador.';

  @override
  String get eqOpenSystem => 'Abrir ecualizador del sistema';

  @override
  String get eqSavePreset => 'Guardar preajuste';

  @override
  String get eqPresetNameHint => 'p. ej. Mis graves reforzados';

  @override
  String get eqPresetNameEmpty => 'El nombre no puede estar vacío.';

  @override
  String eqPresetNameBuiltIn(String name) {
    return '«$name» es el nombre de un preajuste integrado.';
  }

  @override
  String get eqResetAllBands => 'Restablecer todas las bandas';

  @override
  String get eqPresetsLabel => 'PREAJUSTES';

  @override
  String get eqYourPresetsLabel => 'TUS PREAJUSTES';

  @override
  String get eqSaveCurrent => 'Guardar actual';

  @override
  String get eqSettingsSubtitle => 'Ajusta las frecuencias de audio por banda';

  @override
  String get eqEmptyPresets => 'Ajusta tu sonido y toca «Guardar actual».';

  @override
  String get lyricsHint =>
      'Pega aquí letras sin sincronizar…\n\nUna línea por cada verso.';

  @override
  String get lyricsSelectLrcFile => 'Selecciona un archivo .lrc';

  @override
  String get lyricsNoLyricsInFile => 'No se encontraron letras en ese archivo';

  @override
  String importFailed(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get lyricsImportTooltip => 'Importar archivo .lrc';

  @override
  String get importPlaylistM3u => 'Importar lista (.m3u)';

  @override
  String get setSyncFolder => 'Establecer carpeta de sincronización…';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get searchPlaylists => 'Buscar listas…';

  @override
  String get pleaseSelectM3uFile => 'Selecciona un archivo .m3u o .m3u8';

  @override
  String get noMatchingSongsForPlaylist =>
      'No se encontraron canciones coincidentes para esa lista';

  @override
  String importedPlaylist(String name, int count) {
    return '«$name» importada ($count canciones)';
  }

  @override
  String playlistsSyncWith(String folder) {
    return 'Las listas se sincronizarán con: $folder';
  }

  @override
  String couldNotSetSyncFolder(String error) {
    return 'No se pudo establecer la carpeta de sincronización: $error';
  }

  @override
  String get setSyncFolderFirst =>
      'Establece primero una carpeta de sincronización';

  @override
  String get playlistsSynced => 'Listas sincronizadas';

  @override
  String get alreadyUpToDate => 'Ya está actualizado';

  @override
  String syncFailed(String error) {
    return 'Error de sincronización: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get searchFolders => 'Buscar carpetas…';

  @override
  String get songInfoPath => 'Ruta';

  @override
  String get closeVisualiser => 'Cerrar visualizador';

  @override
  String get visualizerWaitingForAudio =>
      'Esperando el audio de reproducción...';

  @override
  String get visualizerUnavailable =>
      'El análisis de audio en vivo no está disponible para esta salida.';

  @override
  String get previousMode => 'Modo anterior';

  @override
  String get nextMode => 'Modo siguiente';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get colorTheme => 'Tema de color';

  @override
  String get insightsTotalPlays => 'Reproducciones\ntotales';

  @override
  String get insightsTracksHeard => 'Pistas\nescuchadas';

  @override
  String get insightsEstListening => 'Escucha\nestimada';

  @override
  String get dismiss => 'Descartar';

  @override
  String updateVersionAvailable(String version) {
    return 'La versión $version ya está disponible.';
  }

  @override
  String get updateNewVersionAvailable =>
      'Ya hay una nueva versión disponible.';

  @override
  String get lyricsPasteLyricsTitle => 'Pegar letra';

  @override
  String get lyricsUseLyrics => 'Usar letra';

  @override
  String get lyricsPaste => 'Pegar';

  @override
  String get lyricsNoLyricsYet => 'Aún no hay letra';

  @override
  String get lyricsPasteToGetStarted => 'Pega la letra para empezar';

  @override
  String get lyricsNoTimestampsYet =>
      'Aún no hay marcas de tiempo — toca el botón de marca mientras suena la canción.';

  @override
  String get lyricsAllLinesStampedHint =>
      'Todas las líneas marcadas — toca Guardar para terminar.';

  @override
  String get lyricsAllStamped => '✓  Todas las líneas marcadas';

  @override
  String get lyricsPasteFirst => 'Pega primero la letra';

  @override
  String lyricsTapToStamp(int current, int total) {
    return '⏱  TOCA PARA MARCAR LA LÍNEA $current / $total';
  }

  @override
  String get lyricsNextLabel => 'Siguiente';

  @override
  String get translationDisclaimerNote =>
      'Algunas traducciones están generadas por IA o aportadas por la comunidad y pueden contener errores. Ayúdanos a mejorarlas en Crowdin.';

  @override
  String get newLanguagesAvailableTitle => 'Nuevos idiomas disponibles';

  @override
  String get newLanguagesAvailableBody =>
      'Noxira Music ahora admite alemán, español, hindi y ruso. Puedes cambiar el idioma en Ajustes.';

  @override
  String get newLanguagesGoToSettings => 'Cambiar idioma';

  @override
  String get newLanguagesDismiss => 'Entendido';

  @override
  String get settingsLyricsSources => 'Fuentes de letras';

  @override
  String get lyricsProviderDesc =>
      'Se usa cuando LRCLIB no tiene la letra. Recibe el título, el artista, el álbum y la duración.';

  @override
  String get onlineAboutArtist => 'Acerca de';

  @override
  String get onlineFansAlsoLike => 'A los fans también les gusta';

  @override
  String get onlinePopularTracks => 'Popular ahora mismo';

  @override
  String get onlineReadMore => 'Leer más';

  @override
  String get onlineBioDisclaimer =>
      'Recopilado automáticamente de fuentes públicas. No se garantiza su exactitud.';

  @override
  String get onlineShowLess => 'Mostrar menos';

  @override
  String get onlineWikipedia => 'Wikipedia';

  @override
  String onlineFansCount(String count) {
    return '$count fans';
  }

  @override
  String get settingsOnlineSuggestions => 'Sugerencias en línea';

  @override
  String get settingsOnlineSuggestionsDesc =>
      'Busca información de artistas y artistas similares en Deezer y Wikipedia. Solo se envía el nombre del artista.';

  @override
  String get onboardingUiModeTitle => 'Estilo de interfaz';

  @override
  String get onboardingUiModeDesc => 'Cuánto cristal y animación usa la app';

  @override
  String get onboardingUiHighEnd => 'Alto rendimiento';

  @override
  String get onboardingUiLowEnd => 'Ligero';

  @override
  String get onboardingRecommendedBadge => 'Recomendado';

  @override
  String get onboardingRecommendedForDevice =>
      'Recomendado para tu dispositivo.';

  @override
  String onboardingTryNote(String recommended, String selected) {
    return 'Según las especificaciones de tu dispositivo recomendamos $recommended, pero puedes probar $selected.';
  }

  @override
  String onboardingHeaviestNote(String option) {
    return '$option es la opción más pesada y puede ir menos fluida en tu dispositivo.';
  }

  @override
  String get audioOutput => 'Salida de audio';

  @override
  String get audioOutputBluetoothDevice => 'Dispositivo Bluetooth';

  @override
  String get audioOutputPhoneSpeaker => 'Altavoz del teléfono';

  @override
  String get audioOutputWired => 'Auriculares con cable';

  @override
  String get audioOutputUsb => 'Audio USB';

  @override
  String get audioOutputOther => 'Otra salida';

  @override
  String get audioOutputNoOthers => 'No se detectaron otros dispositivos';

  @override
  String get audioOutputCurrentDevice => 'Dispositivo actual';

  @override
  String get audioOutputSwitchFailed => 'No se pudo cambiar la salida de audio';

  @override
  String get duplicatesBannerTitle => 'Pistas duplicadas encontradas';

  @override
  String duplicatesBannerSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas existen en varias copias',
      one: '1 pista existe en varias copias',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesReview => 'Revisar';

  @override
  String get duplicatesScreenTitle => 'Pistas duplicadas';

  @override
  String get duplicatesEmpty => 'No se encontraron duplicados';

  @override
  String get duplicatesIgnore => 'Ignorar';

  @override
  String get duplicatesIgnoreAll => 'Ignorar todo';

  @override
  String get duplicatesKeepBest => 'Mejor calidad';

  @override
  String duplicatesCopies(int count) {
    return '$count copias';
  }

  @override
  String duplicatesDeleteOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Conservar la seleccionada, eliminar $count más',
      one: 'Conservar la seleccionada, eliminar 1 más',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesDeleteFailed => 'No se pudieron eliminar algunas copias';

  @override
  String get duplicatesResolved => 'Duplicados eliminados';

  @override
  String get duplicatesHint =>
      'Elige la copia que quieres conservar. Las demás se eliminarán de tu dispositivo.';

  @override
  String get remoteAnnouncementOpenLink => 'Más información';

  @override
  String get remoteAnnouncementOpenScreen => 'Abrir';

  @override
  String get updateRequiredTitle => 'Actualización necesaria';

  @override
  String get updateRequiredMessage =>
      'Esta versión ya no es compatible. Actualiza Noxira Music para seguir usándola.';

  @override
  String get settingsSupport => 'Apoyo';

  @override
  String get settingsSupportSubtitle => 'Colaboradores y formas de ayudar';

  @override
  String get supportSupporters => 'Colaboradores';

  @override
  String get supportNoSupportersYet =>
      'Aún no hay colaboradores. ¡Sé el primero!';

  @override
  String get musicInsightsTitle => 'Estadísticas musicales';

  @override
  String get insightsActivityByTimeOfDay => 'Actividad por hora del día';

  @override
  String get insightsActivityByDay => 'Actividad por día';

  @override
  String get insightsGenreBreakdown => 'Desglose por género';

  @override
  String get insightsNoDataTitle => 'Aún no hay datos de escucha';

  @override
  String get insightsNoDataBody =>
      'Reproduce algo de música para empezar a crear tus estadísticas.';

  @override
  String insightsMostActiveAround(String time) {
    return 'Más activo alrededor de las $time';
  }

  @override
  String insightsMostActiveOn(String day) {
    return 'Más activo el $day';
  }

  @override
  String moreFromArtist(String artist) {
    return 'Más de $artist';
  }

  @override
  String tracksCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
    );
    return '$_temp0';
  }

  @override
  String songsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$_temp0';
  }

  @override
  String albumsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count álbumes',
      one: '1 álbum',
    );
    return '$_temp0';
  }

  @override
  String playlistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas de reproducción',
      one: '1 lista de reproducción',
    );
    return '$_temp0';
  }

  @override
  String foldersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carpetas',
      one: '1 carpeta',
    );
    return '$_temp0';
  }

  @override
  String foldersExcludedCount(int count) {
    return '$count excluidas';
  }

  @override
  String get unknownAlbum => 'Álbum desconocido';

  @override
  String get queueNextUp => 'A continuación';

  @override
  String queueNextFrom(String source) {
    return 'A continuación de $source';
  }

  @override
  String get queueNothingElse => 'No hay nada más en la cola';

  @override
  String get queueMoveToEnd => 'Mover al final';

  @override
  String get translateLyrics => 'Traducir letra';

  @override
  String get translateFailedTapToRetry =>
      'Error al traducir: toca para reintentar';

  @override
  String get translateShowOriginal => 'Mostrar original';

  @override
  String get translateShowTranslation => 'Mostrar traducción';

  @override
  String get lyricsAiTranslatedNote =>
      'Traducido con IA · la precisión puede variar';

  @override
  String lyricsCantTranslateSameLanguage(String language) {
    return 'No se puede traducir: la letra ya está en el idioma de destino ($language)';
  }

  @override
  String get lyricsAddLyrics => 'Añadir letra';

  @override
  String get lyricsBlurOn => 'Desenfoque de letra: activado';

  @override
  String get lyricsBlurOff => 'Desenfoque de letra: desactivado';

  @override
  String get lyricsAutoHideOn => 'Ocultar controles automáticamente: activado';

  @override
  String get lyricsAutoHideOff =>
      'Ocultar controles automáticamente: desactivado';

  @override
  String get lyricsEditCreate => 'Editar / crear letra';

  @override
  String get sleepTimerMinShort => 'min';

  @override
  String sleepTimerMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get sleepTimerMusicStopsAfter => 'La música se detiene en…';

  @override
  String get sleepTimerPickDuration => 'Elige una duración abajo';

  @override
  String get visualizerBarSpectrum => 'Espectro de barras';

  @override
  String get visualizerCircularBars => 'Barras circulares';

  @override
  String get visualizerMirrorBars => 'Barras espejo';

  @override
  String get visualizerFrequencyLine => 'Línea de frecuencia';

  @override
  String get visualizerDotMatrix => 'Matriz de puntos';

  @override
  String get visualizerPeakBars => 'Barras de picos';

  @override
  String get visualizerCircularWave => 'Onda circular';

  @override
  String get visualizerAuroraWaves => 'Ondas de aurora';

  @override
  String get visualizerPulseRings => 'Anillos de pulso';

  @override
  String get smartFieldFolderPath => 'Ruta de carpeta';

  @override
  String get smartFieldLiked => 'Favorita';

  @override
  String get smartFieldPlayCount => 'Reproducciones';

  @override
  String get smartFieldDurationSeconds => 'Duración (segundos)';

  @override
  String get smartFieldDaysSinceAdded => 'Días desde que se añadió';

  @override
  String get smartOpContains => 'contiene';

  @override
  String get smartOpNotContains => 'no contiene';

  @override
  String get smartOpEquals => 'es igual a';

  @override
  String get smartOpNotEquals => 'no es igual a';

  @override
  String get smartOpGreaterThan => 'es mayor que';

  @override
  String get smartOpLessThan => 'es menor que';

  @override
  String get smartOpIsTrue => 'es verdadero';

  @override
  String get smartOpIsFalse => 'es falso';

  @override
  String get smartSortTitleAZ => 'Título (A-Z)';

  @override
  String get smartSortArtistAZ => 'Artista (A-Z)';

  @override
  String get smartSortDateAddedNewest => 'Fecha de adición (más reciente)';

  @override
  String get smartSortPlayCountHighest => 'Reproducciones (más)';

  @override
  String get smartSortDurationLongest => 'Duración (más larga)';

  @override
  String get smartSortRandom => 'Aleatorio';

  @override
  String get folderFilterTitle => 'Filtro de carpetas';

  @override
  String get artistSeparatorTestHint =>
      'p. ej. Artista Uno / Artista Dos feat. Tres';

  @override
  String get tracksPermissionRequired =>
      'Se necesita permiso para acceder a la biblioteca multimedia. Concede los permisos en la configuración inicial o en los ajustes de la aplicación.';

  @override
  String tracksErrorFetching(String error) {
    return 'Error al obtener las canciones: $error';
  }

  @override
  String get seeAll => 'Ver todo';

  @override
  String get selectItemToViewDetails =>
      'Selecciona un elemento para ver los detalles';

  @override
  String get takeMeThere => 'Llévame allí';

  @override
  String get notNow => 'Ahora no';

  @override
  String get aboutCodename => 'Nombre en clave';

  @override
  String get aboutDeveloper => 'Desarrollador';

  @override
  String get aboutCopyright => 'Derechos de autor';

  @override
  String get aboutWebsite => 'Sitio web';

  @override
  String get openSourcePackages => 'Paquetes de código abierto';

  @override
  String packagesUsedCount(int count) {
    return '$count paquetes usados';
  }

  @override
  String get packagesThanks =>
      '¡Gracias a todos los colaboradores de código abierto!';

  @override
  String versionWithCodename(String version, String codename) {
    return 'Versión $version ($codename)';
  }

  @override
  String get customColor => 'Color personalizado';

  @override
  String exportPlaylistAs(String format) {
    return 'Exportar ($format)';
  }

  @override
  String get shareClipListeningTo => 'ESCUCHANDO';

  @override
  String get shareClipNowOn => 'AHORA EN';

  @override
  String get splashInitializingServices => 'Inicializando servicios';

  @override
  String get splashLoadingLibrary => 'Cargando biblioteca';

  @override
  String get splashPreparingHome => 'Preparando el inicio';

  @override
  String get splashCachingArtwork => 'Guardando carátulas en caché';

  @override
  String get splashFinalPreparations => 'Preparativos finales';

  @override
  String get queueHistory => 'Historial';

  @override
  String get sortName => 'Nombre';

  @override
  String get bannerInsightsNewTitle =>
      'Tus estadísticas musicales ya están aquí ✦';

  @override
  String get bannerInsightsNewBody =>
      'Descubre tus canciones y artistas favoritos y tus hábitos de escucha';

  @override
  String get bannerRecapTitle => 'Tu resumen musical te espera';

  @override
  String get bannerRecapBody =>
      'Descubre tus canciones favoritas y tus tendencias de escucha';

  @override
  String get musicalArtist => 'Artista musical';

  @override
  String get eqPresetFlat => 'Plano';

  @override
  String get eqPresetBassBoost => 'Refuerzo de graves';

  @override
  String get eqPresetBassCut => 'Reducción de graves';

  @override
  String get eqPresetTrebleBoost => 'Refuerzo de agudos';

  @override
  String get eqPresetTrebleCut => 'Reducción de agudos';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetClassical => 'Clásica';

  @override
  String get eqPresetElectronic => 'Electrónica';

  @override
  String get eqPresetHipHop => 'Hip hop';

  @override
  String get eqPresetRnB => 'R&B';

  @override
  String get eqPresetVocal => 'Voces';

  @override
  String get eqPresetAcoustic => 'Acústica';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetMetal => 'Metal';

  @override
  String get eqPresetLounge => 'Lounge';

  @override
  String get eqPresetSpokenWord => 'Palabra hablada';

  @override
  String get supportOfMonthlyGoal => 'del objetivo de este mes';

  @override
  String get cl200Hl1 =>
      'Aurora Music ahora es Noxira Music, con un nuevo aspecto';

  @override
  String get cl200Hl2 =>
      'Traduce letras a cualquier idioma, desde más fuentes de letras';

  @override
  String get cl200Hl3 =>
      'Un widget de inicio rediseñado con controles de reproducción';

  @override
  String get cl200Hl4 => 'Una cola rediseñada';

  @override
  String get cl200Hl5 =>
      'Elige dónde suena el audio desde el chip de Bluetooth o Reproduciendo ahora';

  @override
  String get cl200Hl6 =>
      'Letras palabra por palabra cuando la fuente incluye la sincronización';

  @override
  String get cl200Hl7 =>
      'Se detectan las canciones duplicadas y tú eliges qué copia conservar';

  @override
  String get cl200Hl8 => 'Superficies de cristal que se adaptan a tu teléfono';

  @override
  String get cl200Hl9 =>
      'Transiciones más fluidas y páginas de detalle más rápidas';

  @override
  String get cl200SecWelcome => 'Te damos la bienvenida a Noxira';

  @override
  String get cl200SecNew => 'Novedades';

  @override
  String get cl200SecLibrary => 'Listas y biblioteca';

  @override
  String get cl200SecSetup => 'Configuración';

  @override
  String get cl200SecLook => 'Aspecto y sensación';

  @override
  String get cl200SecPerf => 'Rendimiento';

  @override
  String get cl200SecHood => 'Bajo el capó';

  @override
  String get cl200Welcome1 =>
      'Aurora Music ahora es Noxira Music, con nuevo nombre, logotipo e icono de la aplicación';

  @override
  String get cl200Welcome2 =>
      'Una nueva pantalla de inicio animada dibuja el logotipo de Noxira';

  @override
  String get cl200Welcome3 =>
      'Los usuarios actuales ven una breve página de bienvenida que explica las novedades, y puedes abrirla de nuevo desde Ajustes';

  @override
  String get cl200New1 =>
      'Traduce letras a cualquier idioma, no solo a los idiomas de la aplicación';

  @override
  String get cl200New2 =>
      'Widget de inicio rediseñado: cristal teñido con tu carátula, botones de anterior / reproducir / siguiente que funcionan sin abrir la aplicación y canciones recomendadas cuando el widget es alto';

  @override
  String get cl200New3 =>
      'Página de cola rediseñada: mira lo que sonó y lo que viene, arrastra para reordenar y desliza para quitar; ahora hay una vista previa de «A continuación» en Reproduciendo ahora';

  @override
  String get cl200New4 =>
      'Un objetivo de apoyo mensual aparece de vez en cuando en la barra superior de inicio y en Ajustes, en Acerca de';

  @override
  String get cl200New5 =>
      'Desliza hacia abajo en la biblioteca para actualizarla';

  @override
  String get cl200New6 =>
      'Elige dónde suena el audio: toca el chip de Bluetooth en la pantalla de inicio, o la nueva isla de salida en Reproduciendo ahora, para pasar la reproducción entre el altavoz del teléfono y los dispositivos conectados sin salir de la aplicación';

  @override
  String get cl200New7 =>
      'La velocidad y el tono tienen ahora sus propios deslizadores, y puedes vincular el tono a la velocidad';

  @override
  String get cl200New8 =>
      'Cinco nuevos estilos de visualizador y un espectro más fino con más barras';

  @override
  String get cl200New9 =>
      'Pueden aparecer anuncios opcionales del equipo de Noxira en la pantalla de inicio, con un botón que abre un enlace o una pantalla de la aplicación';

  @override
  String get cl200Lyrics1 =>
      'Página de letras rediseñada: toca una línea para saltar a ella, los puntos marcan las pausas instrumentales y el cuadro de letras de Reproduciendo ahora sigue la música';

  @override
  String get cl200Lyrics2 =>
      'Se prueban más fuentes de letras (BetterLyrics, YouLyPlus y KuGou) cuando LRCLIB no tiene nada; elige cuáles usar en Ajustes';

  @override
  String get cl200Lyrics3 =>
      'Las letras guardadas en el archivo de audio, o en un archivo .lrc junto a la canción, se usan primero y funcionan sin conexión';

  @override
  String get cl200Lyrics4 =>
      'Ocultar automáticamente los controles en las letras a pantalla completa ahora es una opción y está desactivada por defecto';

  @override
  String get cl200Lyrics5 =>
      'Corregidas las letras que parpadeaban y luego desaparecían con «letra no disponible», incluso tras actualizar o buscar manualmente';

  @override
  String get cl200Lyrics6 =>
      'Letras palabra por palabra: cuando una fuente tiene sincronización por palabra, cada palabra se ilumina mientras se canta';

  @override
  String get cl200Library1 =>
      'Nueva hoja para añadir a listas: añade, quita y crea listas en un solo lugar, con las canciones que ya están en una lista marcadas';

  @override
  String get cl200Library2 =>
      'Una canción ya no puede añadirse dos veces a la misma lista, y la opción Quitar duplicados limpia las existentes';

  @override
  String get cl200Library3 =>
      'Noxira ahora detecta pistas duplicadas en tu biblioteca y, en la pestaña Biblioteca, ofrece revisarlas: tú eliges qué copia conservar';

  @override
  String get cl200Library4 =>
      'Página de Listas rediseñada: Favoritas arriba, listas automáticas como mosaicos y tus propias listas en una cuadrícula con mosaicos de carátulas';

  @override
  String get cl200Library5 =>
      'Pestaña de búsqueda rediseñada: una barra de búsqueda de cristal, recuentos de resultados y estados vacíos y sin resultados más claros';

  @override
  String get cl200Library6 =>
      'El icono de la canción en reproducción ahora sigue a la pista en las listas';

  @override
  String get cl200Library7 =>
      'Sugerencias en línea opcionales: información de artistas y artistas similares de Deezer y Wikipedia (solo se envía el nombre del artista)';

  @override
  String get cl200Library8 =>
      'El ecualizador ya no se declara no disponible por error; lo reintenta solo y ofrece Reintentar y Abrir ecualizador del sistema';

  @override
  String get cl200Library9 =>
      'La información de caché ahora muestra tamaños reales, su botón cierra el diálogo y Borrar caché también borra las imágenes de artistas descargadas';

  @override
  String get cl200Setup1 =>
      'Configuración inicial rediseñada con paneles de cristal, animaciones de entrada y un fondo fluido';

  @override
  String get cl200Setup2 =>
      'La configuración recomienda el estilo de interfaz que mejor encaja con tu teléfono (de gama alta o ligero) y el fondo correspondiente, y te deja probar el otro';

  @override
  String get cl200Setup3 =>
      'La interfaz ligera ahora usa siempre un fondo liso; se eliminó la opción Manchas animadas';

  @override
  String get cl200Setup4 =>
      'Ajustes ahora está ordenado en grupos (Experiencia, Biblioteca y datos, Aplicación) con el mismo aspecto sencillo de cristal que la configuración inicial';

  @override
  String get cl200Setup5 =>
      'Los mensajes aparecen como una pequeña isla en la parte inferior de la pantalla en lugar de snackbars';

  @override
  String get cl200Look1 =>
      'Nueva tipografía de la aplicación (Cal Sans) y texto algo más compacto en toda la aplicación';

  @override
  String get cl200Look2 =>
      'Superficies de cristal esmerilado en todas partes, dibujadas como superficies sólidas lisas en teléfonos modestos';

  @override
  String get cl200Look3 =>
      'La carátula vuela de las tarjetas a las páginas de álbum, artista, carpeta y lista; las tarjetas pulsadas responden, las canciones favoritas estallan en corazones y las etiquetas de tiempo ruedan';

  @override
  String get cl200Look4 =>
      'Botón de reproducir cuadrado redondeado en Canciones favoritas';

  @override
  String get cl200Look5 =>
      'Las tarjetas de Inicio y Biblioteca usan el mismo aspecto de cristal que la configuración inicial, sin un desenfoque adicional sobre el fondo ya desenfocado';

  @override
  String get cl200Perf1 =>
      'Noxira detecta el hardware de tu teléfono y ajusta los efectos de cristal, las cachés de imágenes y las transiciones';

  @override
  String get cl200Perf2 =>
      'Las páginas de álbum, artista, carpeta y lista se abren con fluidez: cargan tras la animación de apertura, crean una breve primera página de canciones y desenfocan de antemano la carátula de su cabecera';

  @override
  String get cl200Perf3 =>
      'Las consultas de biblioteca que se solapan se comparten en lugar de repetirse, lo que reduce el uso de memoria en bibliotecas grandes';

  @override
  String get cl200Perf4 =>
      'Búsqueda y reescaneos de biblioteca más rápidos, carga de imágenes más ligera y menos trabajo al desplazar las listas';

  @override
  String get cl200Hood1 =>
      'Corregidos varios cierres inesperados: tocar Cerrar en el editor de letras, el editor de etiquetas o el temporizador de sueño después de que la página desapareciera, añadir a la cola o establecer un tono desde el menú de una canción, traducir letras y abrir Noxira desde el widget';

  @override
  String get cl200Hood2 =>
      'La aplicación ya no se cierra cuando falta el permiso de almacenamiento';

  @override
  String get cl200Hood3 =>
      'Las listas, las canciones favoritas, los recuentos de reproducciones y los ajustes se guardan de forma segura, así que un guardado interrumpido ya no deja un archivo vacío';

  @override
  String get cl200Hood4 =>
      'Los archivos FLAC cuyos bloques de metadatos quedaron incompletos por un editor de etiquetas se reparan al guardar, así que vuelven a reproducirse';

  @override
  String get cl200Hood5 =>
      'La carátula de la notificación multimedia se reduce para evitar bloqueos mientras se crea la notificación';

  @override
  String get cl200Hood6 =>
      'Editar etiquetas en grabaciones de voz (M4A) ya no falla por datos sobrantes al final del archivo';

  @override
  String get cl200Hood7 =>
      'El visualizador ya no distorsiona las pistas Dolby Atmos; usan la animación simulada';

  @override
  String get cl200Hood8 =>
      'Los teléfonos que no pueden crear un efecto de ecualizador ahora reproducen con normalidad, y el ecualizador espera a la primera canción en lugar de agotar el tiempo';

  @override
  String get cl200Hood9 =>
      'Buscar actualizaciones ahora muestra su resultado e indica cuando las actualizaciones vienen de Google Play';

  @override
  String get cl200Hood10 =>
      'Los anuncios, el objetivo de apoyo y algunos servicios en línea pueden ajustarse sin actualizar la aplicación';

  @override
  String get cl200Hood11 => 'Dependencias actualizadas';

  @override
  String get pkgJustAudio =>
      'Reproductor de audio con muchas funciones para Flutter';

  @override
  String get pkgAudioService =>
      'Reproducción en segundo plano y controles multimedia';

  @override
  String get pkgAudioSession =>
      'Gestión de sesiones de audio para un enfoque de audio correcto';

  @override
  String get pkgOnAudioQuery =>
      'Consulta de archivos de audio del almacenamiento del dispositivo';

  @override
  String get pkgHaudiotagger =>
      'Lectura y escritura de etiquetas de metadatos de audio';

  @override
  String get pkgProvider => 'Solución de gestión de estado para Flutter';

  @override
  String get pkgSharedPreferences => 'Almacenamiento persistente clave-valor';

  @override
  String get pkgPathProvider =>
      'Acceso a las rutas del sistema de archivos del dispositivo';

  @override
  String get pkgPermissionHandler =>
      'Gestión de permisos en tiempo de ejecución';

  @override
  String get pkgDynamicColor => 'Temas de color dinámico de Material You';

  @override
  String get pkgPaletteGenerator => 'Extracción de colores de imágenes';

  @override
  String get pkgStaggeredAnimations => 'Animaciones escalonadas de listas';

  @override
  String get pkgHttp => 'Solicitudes HTTP para llamadas a API';

  @override
  String get pkgUrlLauncher => 'Abrir URL en el navegador';

  @override
  String get pkgSharePlus => 'Compartir contenido con otras aplicaciones';

  @override
  String get pkgPackageInfoPlus =>
      'Obtener la versión de la aplicación y datos del paquete';

  @override
  String get pkgDeviceInfoPlus => 'Obtener información del dispositivo';

  @override
  String get pkgFlutterDotenv =>
      'Cargar variables de entorno desde un archivo .env';

  @override
  String get pkgCrypto => 'Funciones de hash criptográfico';

  @override
  String get pkgIntl => 'Internacionalización y localización';

  @override
  String get pkgPubSemver => 'Utilidades de versionado semántico';

  @override
  String get pkgClarityFlutter => 'Analítica de Microsoft Clarity';

  @override
  String get pkgFlutterHooks => 'Hooks al estilo React para Flutter';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeMidnight => 'Medianoche';

  @override
  String get themeOcean => 'Océano';

  @override
  String get themeTeal => 'Verde azulado';

  @override
  String get themeForest => 'Bosque';

  @override
  String get themeNeon => 'Neón';

  @override
  String get themeGold => 'Oro';

  @override
  String get themeEmber => 'Brasa';

  @override
  String get themeRose => 'Rosa';

  @override
  String get themeSakura => 'Sakura';

  @override
  String artistsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artistas',
      one: '1 artista',
    );
    return '$_temp0';
  }

  @override
  String get playbackInvalidPlaylist => 'Lista o posición inicial no válida';

  @override
  String playbackCouldNotPlayTitleSkipping(String title) {
    return 'No se pudo reproducir «$title»: se omite';
  }

  @override
  String get playbackCouldNotPlaySkipping =>
      'No se pudo reproducir esta canción: se omite';

  @override
  String playbackCouldNotPlayTitle(String title) {
    return 'No se pudo reproducir «$title»';
  }

  @override
  String get playbackFailed => 'Error de reproducción';

  @override
  String playbackSetPlaylistFailed(String error) {
    return 'No se pudo establecer la lista: $error';
  }

  @override
  String playbackUpdatePlaylistFailed(String error) {
    return 'No se pudo actualizar la lista: $error';
  }
}
