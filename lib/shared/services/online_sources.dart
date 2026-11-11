import 'remote_config_helper.dart';

/// Remote kill switch for the third-party services the app queries for
/// artist, album and cover data. List the ids in the Firebase console
/// (`online_disabled_sources`, comma-separated) to stop asking a service that
/// is down or misbehaving, without an app update.
///
/// Ids: `deezer`, `itunes`, `spotify`, `musicbrainz`, `audiodb`, `wikipedia`.
class OnlineSources {
  OnlineSources._();

  static bool isEnabled(String id) =>
      !RemoteConfigHelper.list('online_disabled_sources').contains(id);

  /// The source id a request to [uri] belongs to, or null for hosts that
  /// aren't covered.
  static String? idForHost(String host) {
    if (host == 'api.deezer.com') return 'deezer';
    if (host == 'itunes.apple.com') return 'itunes';
    if (host == 'api.spotify.com' || host == 'accounts.spotify.com') {
      return 'spotify';
    }
    if (host == 'musicbrainz.org') return 'musicbrainz';
    if (host == 'www.theaudiodb.com') return 'audiodb';
    if (host.endsWith('wikipedia.org') || host.endsWith('wikidata.org')) {
      return 'wikipedia';
    }
    return null;
  }

  static bool isUriEnabled(Uri uri) {
    final id = idForHost(uri.host);
    return id == null || isEnabled(id);
  }
}
