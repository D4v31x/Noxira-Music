import 'package:flutter/material.dart' show IconData, Icons;

class ChangelogContent {
  /// Short, user-facing summaries shown in the post-update popup.
  static const Map<String, List<({IconData icon, String text})>> highlights = {
    '2.0.0': [
      (
        icon: Icons.stars_rounded,
        text: 'Aurora Music is now Noxira Music, with a new look'
      ),
      (
        icon: Icons.translate_rounded,
        text: 'Translate lyrics into any language, from more lyric sources'
      ),
      (
        icon: Icons.widgets_rounded,
        text: 'A redesigned home screen widget with playback controls'
      ),
      (icon: Icons.queue_music_rounded, text: 'A redesigned queue'),
      (
        icon: Icons.blur_on_rounded,
        text: 'Glass surfaces that adapt to your phone'
      ),
      (
        icon: Icons.bolt_rounded,
        text: 'Smoother transitions and faster detail pages'
      ),
    ],
    '1.5.0': [
      (
        icon: Icons.open_in_full_rounded,
        text: 'The mini player now expands smoothly into Now Playing'
      ),
      (
        icon: Icons.auto_awesome_rounded,
        text: 'Smart Playlists built from your own rules'
      ),
      (
        icon: Icons.bookmarks_rounded,
        text: 'Track Tags to jump to any moment in a song'
      ),
      (
        icon: Icons.content_cut_rounded,
        text: 'Save and share short clips of songs'
      ),
      (icon: Icons.swap_horiz_rounded, text: 'Crossfade between tracks'),
      (
        icon: Icons.translate_rounded,
        text: 'Now in German, Spanish, Hindi and Russian'
      ),
    ],
    '1.4.0': [
      (
        icon: Icons.drag_indicator_rounded,
        text: 'Reorder songs in your playlists'
      ),
      (icon: Icons.swap_vert_rounded, text: 'Import and export M3U playlists'),
      (icon: Icons.sort_rounded, text: 'Your sort choices are remembered'),
      (icon: Icons.bolt_rounded, text: 'Smoother lists and a faster start'),
      (icon: Icons.insights_rounded, text: 'More accurate listening stats'),
    ],
  };

  /// Highlights for [version], falling back to the latest known release.
  static List<({IconData icon, String text})> getHighlightsForVersion(
      String version) {
    return highlights[version] ?? highlights.values.first;
  }

  static const Map<String, List<Map<String, List<String>>>> versions = {
    // Latest version at the top
    '2.0.0': [
      {
        '_': ['Noxira Music 2.0'],
      },
      {
        'Welcome to Noxira': [
          'Aurora Music is now Noxira Music, with a new name, wordmark and app icon',
          'A new animated splash screen draws the Noxira wordmark',
          'Existing users get a short welcome page explaining what is new, and you can open it again from Settings',
        ],
      },
      {
        'New Features': [
          'Translate lyrics into any language you like, not only the app languages',
          'Redesigned home screen widget: glass tinted with your artwork, previous / play / next buttons that work without opening the app, and recommended songs when the widget is tall',
          'Redesigned queue page — see what played and what is next, drag to reorder, swipe to remove; an Up next preview now sits on Now Playing',
          'A monthly support goal appears on the home app bar from time to time, and in Settings under About',
          'Pull down in the Library to refresh it',
        ],
      },
      {
        'Lyrics': [
          'Redesigned lyrics page: tap a line to jump to it, dots mark instrumental breaks, and the lyrics box on Now Playing follows along',
          'More lyric sources (BetterLyrics, YouLyPlus and KuGou) are tried when LRCLIB has nothing; choose which ones to use in Settings',
          'Lyrics stored in the audio file, or in a .lrc file next to the song, are used first and work offline',
          'Auto-hide controls on the full-screen lyrics is now an option and off by default',
          'Fixed lyrics that flickered and then disappeared with "no lyrics available", including after a refresh or a manual search',
        ],
      },
      {
        'Playlists & Library': [
          'New add-to-playlist sheet: add, remove and create playlists in one place, with songs already in a playlist marked',
          'A song can no longer be added to the same playlist twice, and a Remove duplicates option cleans up existing ones',
          'Optional online suggestions: artist info and similar artists from Deezer and Wikipedia (only the artist name is sent)',
          'The equalizer no longer reports itself as unavailable by mistake; it retries on its own and offers Retry and Open system equalizer',
          'Cache Information now shows real sizes, its button closes the dialog, and Clear Cache also clears downloaded artist images',
        ],
      },
      {
        'Setup': [
          'Redesigned onboarding with glass panels, entrance animations and a flowing background',
          'Setup recommends the interface style that suits your phone (high-end or lightweight) and the matching background, and lets you try the other one',
          'The lightweight interface now always uses a plain background; the Animated Blobs option was removed',
        ],
      },
      {
        'Look & Feel': [
          'New app font (Cal Sans) and slightly more compact text across the app',
          'Frosted glass surfaces throughout, drawn as plain solid surfaces on low-end phones',
          'Artwork flies from cards into album, artist, folder and playlist pages; pressed cards respond, liked songs burst into hearts, and the time labels roll',
          'Rounded-square play button on Favorite Songs',
        ],
      },
      {
        'Performance': [
          'Noxira detects your phone\'s hardware and tunes glass effects, image caches and transitions to it',
          'Album, artist, folder and playlist pages open smoothly: they load after the opening animation, build a short first page of songs and blur their header artwork ahead of time',
          'Library queries that overlap are shared instead of repeated, which lowers memory use on big libraries',
        ],
      },
      {
        'Under the Hood': [
          'Fixed several crashes: tapping Close in the lyrics editor, the tag editor or the sleep timer after the page was gone, adding to the queue or setting a ringtone from a song menu, translating lyrics, and opening Noxira from the widget',
          'The app no longer crashes when storage permission is missing',
          'Playlists, liked songs, play counts and settings are saved safely, so an interrupted save can no longer leave an empty file',
          'FLAC files whose metadata blocks were left incomplete by a tag editor are repaired when saved, so they play again',
          'Media notification artwork is downscaled to avoid freezes while the notification is built',
          'Updated dependencies',
        ],
      },
    ],
    '1.5.0': [
      {
        '_': ['Noxira Music 1.5'],
      },
      {
        'New Features': [
          'Smart Playlists — build a playlist from rules (match all or any), optionally limit the number of songs, and see how many songs match as you edit',
          'Track Tags — mark any moment in a track (chapters, highlights, bookmarks) and jump straight to it; import timestamps by pasting them',
          'Share as clip — cut part of a song (choose the start point and duration), then save it to your device or share it',
          'Crossfade — smoothly blend the end of one track into the next, with an adjustable duration, plus an Automix toggle',
          'The mini player now expands into Now Playing — tap it or swipe up, and the artwork, title and artist glide into place',
        ],
      },
      {
        'Languages': [
          'Noxira Music is now available in German, Spanish, Hindi and Russian',
          'A short notice tells existing users about the new languages, and you can pick your language during setup',
        ],
      },
      {
        'Lyrics': [
          'Lyrics editor: paste plain lyrics and stamp each line with a tap while the song plays, or import a .lrc file',
          'Fixed automatic lyric lookup and refined the lyrics views',
        ],
      },
      {
        'Now Playing & Library': [
          'Refreshed sleep timer',
          'Song info now shows the file path and sample rate',
          'Metadata editor can use artwork chosen from your device',
          'Visualizer has previous / next mode and close buttons',
          'Search for playlists and folders',
          'Albums grid shows at most 3 columns and defaults to list view',
        ],
      },
      {
        'Look & Feel': [
          'New app font (Host Grotesk)',
          'New Color Theme picker in Appearance settings',
        ],
      },
      {
        'Feedback & Updates': [
          'New update prompt that shows what is new in the latest version',
          'Send a bug report or suggestion from inside the app, and rate Noxira Music from Settings',
          'Onboarding now explains anonymous analytics and crash reports',
        ],
      },
      {
        'Performance': [
          'Long lists (Tracks, Albums, Artists, Folders, playlists and detail screens) load further ahead, so scrolling far no longer waits for items to appear',
          'The Now Playing transition is built to stay light: heavy parts load only once it has nearly finished opening',
        ],
      },
      {
        'Under the Hood': [
          'Fixed an error when opening the metadata editor, which could leave the mini player visible or hidden at the wrong time',
          'Now Playing scrolling no longer bounces at the top so pull-down-to-collapse works reliably',
          'Improved overall app stability and performance, flagged by user feedback',
          'Added support for API 36',
          'Updated Firebase, sharing, file picker and other dependencies',
        ],
      },
    ],
    '1.4.0': [
      {
        '_': ['Noxira Music 1.4 — Orbit'],
      },
      {
        'New Features': [
          'Playlist song reordering — tap ⋮ on any playlist and choose "Reorder Songs" to drag tracks into your preferred order',
          'M3U / M3U8 playlist import and export — share playlists with other apps or import from files; optional two-way folder sync (Poweramp-style)',
          'Sort order is now remembered — your chosen sort option and direction for Tracks, Albums, Artists, and Folders is restored after restarting the app',
        ],
      },
      {
        'Splash Screen': [
          'Redesigned splash screen ("Orbit")',
          'Home screen data (suggestions, artwork) is pre-warmed during the splash so the first frame of the home screen is ready immediately',
        ],
      },
      {
        'Listening Stats & Recap': [
          'Time-listened figures now reflect the actual time you spent on each song, not its full length — minutes in Recap and Insights are now accurate',
        ],
      },
      {
        'Performance': [
          'Smart Suggestions no longer re-queries device storage on each refresh — reuses the already-loaded library for a significant speed-up',
          'Library initialisation is guarded against double-init races; a future cache prevents redundant scans',
          'BlurDialog respects low-end device mode and skips backdrop blur where it would hurt performance',
        ],
      },
      {
        'Under the Hood': [
          'ReplayGain now reads MP4/M4A/AAC/ALAC files (iTunes freeform atoms), APEv2 tags on MP3, and Opus R128_TRACK_GAIN; tag matching is case-insensitive and whitespace-tolerant; album gain is used as a fallback when track gain is absent',
          'Metadata changes propagate instantly to playlists and the playback queue without requiring a library rescan',
          'Liked Songs playlist is always shown first in the Quick Access section',
          'Page transitions use a faster fade animation for snappier navigation',
        ],
      },
    ],
    '1.3.2': [
      {
        '_': ['Noxira Music 1.3 — Insights, Equalizer & Folder Filtering'],
      },
      {
        'New Features': [
          'Aurora Wrapped — a personalised year-in-review of your listening habits',
          'Listening Insights — detailed stats about your most played artists, albums, and tracks',
          'Equalizer — built-in 5-band EQ with presets and custom profiles',
          'Folder Filtering — exclude specific folders from your library in Settings',
          'Color themes - Pick your favorite color instead of using Material You colors and background artwork-based theming',
        ],
      },
      {
        'Now Playing': [
          'Improved artwork transitions and track info animations',
          'Sleep timer UI improvements',
        ],
      },
      {
        'Library': [
          'Refreshed Albums, Artists, and Tracks screens',
          'Smart suggestions algorithm improvements',
        ],
      },
      {
        'Settings': [
          'Appearance settings redesigned and expanded',
          'New Playback settings screen',
          'Insights settings for controlling listening data',
          'Folder filter management screen',
        ],
      },
      {
        'Performance': [
          'Fixed unnecessary full-screen rebuilds in Now Playing, Fullscreen Lyrics, and Lyrics Editor during active playback',
          'Eliminated redundant widget rebuilds in Library tab sections',
          'Optimised animated background — color blend listenable is now cached instead of recreated each frame',
          'Reduced list sort overhead in Recently Added section',
          'Various state management and rendering optimisations',
        ],
      },
      {
        'Under the Hood': [
          'Bluetooth playback service improvements',
          'Lyrics translation service refactored',
          'Play count tracking accuracy improved',
          'Minor code cleanup and dependency updates',
        ],
      },
    ],
    '1.0.5': [
      {
        '_': ['Noxira Music 1.0 — the first production release'],
      },
      {
        'Preface for beta testers': [
          'After over a year of development and testing, Noxira Music has reached its first stable release! This version includes all the core features I envisioned, along with numerous optimizations and bug fixes. I am incredibly grateful to our early adopters and beta testers for their invaluable feedback and support throughout this journey.',
          'This release marks a major milestone for me, but it’s just the beginning. I am committed to continuously enhancing Noxira Music based on user feedback and evolving needs. Thank you for being part of this journey, and I can’t wait to share what’s next!',
        ],
        'New Features': [
          'Music Visualizer — real-time audio visualization with multiple modes (accessible from Now Playing)',
          'Android Auto support — control playback from your car display',
          'Lyrics Editor — create and edit custom timed lyrics for any song',
          'In-app feedback form — send feedback or bug reports directly from the app',
        ],
      },
      {
        'Lyrics': [
          'Lyrics Editor for writing and fine-tuning timed (.lrc) lyrics',
          'Smoother lyric line animations and improved scroll behavior',
        ],
      },
      {
        'Bug Fixes': [
          'Fixed artwork not updating when skipping between tracks',
          'Fixed play count tracking not incrementing correctly',
        ],
      },
      {
        'UI': [
          'Various visual refinements across screens',
        ],
      },
      {
        'Under the Hood': [
          'Improved error tracking and logging',
          'Background service stability improvements',
        ],
      },
    ],
    '0.1.84': [
      {
        'UI': [
          'Added option to contribute to translate app via Crowdin in settings',
          'Replaced most Material icons with iconoir icon library throughout the app',
          'Added more customization options in settings',
          'Playback speed slider now has step arrow buttons (±0.05) and max speed capped at 2.0×',
          'Various UI improvements',
        ],
      },
      {
        'Lyrics': [
          'Lyrics translation — translate button lets you translate lyrics to your app language using online service'
        ],
      },
      {
        'Performance Fixes': [
          'Improved performance on high-end devices',
          'Fixed performance issues on all devices - users now have option to reduce the performance demand by reducing effects in settings',
          'Various performance and state management optimizations',
        ],
      },
      {
        'Under the Hood': [
          'Refactored audio_player_service',
          'Introduced error and performance tracking via Sentry service',
          'Removed redundant packages and files',
          'Added support for community translated strings via Crowdin',
          'Adjusted Spotify API usage for ToS compilance',
          'Minor code optimizations and refactoring',
        ],
      },
      {
        'Others': ['In-app update support via Google Play version checking'],
      },
    ],
    '0.1.21': [
      {
        'Screens': [
          'Added all used packages',
          'Added full screen artwork view from Now Playing screen',
          'Added donation options in settings',
        ],
      },
      {
        'Performance Fixes': [
          'Improved shaders warmup on app start',
          'Various performance optimizations',
        ],
      },
      {
        'Under the Hood': [
          'Upgrade to AGP 9.0.0',
          'Upgrade to ndk 29',
          'Recompiled native libraries to work with 16KB page size devices',
          'Fixed issues with state management for updating UI',
        ],
      },
      {
        'Others': [
          'Various fixes and optimizations',
        ],
      },
    ],
    '0.1.5': [
      {
        'New Features': [
          'Complete onboarding flow with theme selection, permissions, and feature introduction',
          'Asset download configuration (Album Art, Lyrics, Auto-download)',
          'Donation options integration (Buy Me a Coffee, Ko-fi, PayPal)',
          'Internet usage explanation screen',
          'Metadata Editor',
          'Timed Lyrics support in Now Playing screen',
        ],
      },
      {
        'UI/UX Improvements': [
          'Major UI redesign across all screens',
          'Consistent navigation buttons with smooth animations',
          'Standardized page transitions throughout the app',
          'Enhanced onboarding experience with animated pages',
          'Refined permissions request flow',
        ],
      },
      {
        'Core Functionality': [
          'Enhanced audio playback engine',
          'Improved metadata fetching and display',
          'Better album and artist information',
          'Optimized song recommendations algorithm',
          'Enhanced library management',
          'Improved search functionality',
        ],
      },
      {
        'Localization': [
          'Full app translation support',
          'Czech language support added',
          'Localized UI elements and buttons',
          'Multilingual settings and preferences',
        ],
      },
      {
        'Technical Improvements': [
          'Code optimization and refactoring',
          'Better state management',
          'Performance enhancements',
          'Bug fixes and stability improvements',
        ],
      },
    ],

    // Older versions below
    '0.0.9-alpha': [
      {
        'Now Playing': [
          'New Now Playing interface',
          'Timed Lyrics',
          'Search Tab',
          'Info about artist in Now Playing screen',
          'Sleep Timer',
        ],
      },
      {
        'Screens': [
          'Optimized songs recommendation',
          'Added Library Screen',
          'Added Album Screen',
          'Some items on Library Tab are now clickable',
          'Refined Welcome Screen',
        ],
      },
      {
        'Others': [
          'Audio Notification controls',
          'Background Playback',
          'Added Favourite Songs playlist',
          'Various fixes and optimizations',
        ],
      },
    ],
  };

  static List<Map<String, List<String>>> getChangelogForVersion(
      String version) {
    return versions[version] ?? [];
  }

  static String getLatestVersion() {
    return versions.keys.first;
  }

  static bool hasVersion(String version) {
    return versions.containsKey(version);
  }
}
