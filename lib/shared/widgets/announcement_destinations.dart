import 'package:flutter/widgets.dart';

import '../../features/home/screens/listening_insights_screen.dart';
import '../../features/library/screens/albums_screen.dart';
import '../../features/library/screens/artists_screen.dart';
import '../../features/library/screens/duplicate_tracks_screen.dart';
import '../../features/library/screens/tracks_screen.dart';
import '../../features/playlists/screens/playlists_screen.dart';
import '../../features/rebrand/rebrand_welcome_screen.dart';
import '../../features/settings/screens/appearance_settings_screen.dart';
import '../../features/settings/screens/equalizer_screen.dart';
import '../../features/settings/screens/folder_filter_settings_screen.dart';
import '../../features/settings/screens/insights_settings_screen.dart';
import '../../features/settings/screens/playback_settings_screen.dart';
import '../../features/settings/screens/support_settings_screen.dart';

/// Screens an announcement button can open, by the name used in the
/// `announcement_screen` Remote Config parameter.
final Map<String, Widget Function()> announcementScreens = {
  'equalizer': () => const EqualizerScreen(),
  'appearance': () => const AppearanceSettingsScreen(),
  'playback': () => const PlaybackSettingsScreen(),
  'library_folders': () => const FolderFilterSettingsScreen(),
  'insights': () => const InsightsSettingsScreen(),
  'support': () => const SupportSettingsScreen(),
  'listening_insights': () => const ListeningInsightsScreen(),
  'duplicates': () => const DuplicateTracksScreen(),
  'tracks': () => const TracksScreen(),
  'albums': () => const AlbumsScreen(),
  'artists': () => const ArtistsScreen(),
  'playlists': () => const PlaylistsScreenList(),
  'whats_new': () => const RebrandWelcomeScreen(fromSettings: true),
};
