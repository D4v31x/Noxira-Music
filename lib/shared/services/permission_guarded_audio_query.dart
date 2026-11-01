import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_query_platform_interface/method_channel_on_audio_query.dart';

/// on_audio_query_android answers a call made without audio permission with an
/// error and then answers it a second time, which crashes the whole app natively
/// ("Reply already submitted") and cannot be caught from Dart. This platform
/// implementation therefore never forwards a call to the plugin until the
/// permission is granted; without it queries just come back empty.
class PermissionGuardedAudioQuery extends MethodChannelOnAudioQuery {
  bool _granted = false;

  /// Installs the guard for every [OnAudioQuery] instance in the app.
  static void install() {
    OnAudioQueryPlatform.instance = PermissionGuardedAudioQuery();
  }

  Future<bool> _hasPermission() async {
    if (_granted) return true;
    try {
      _granted = await super.permissionsStatus();
    } catch (_) {
      _granted = false;
    }
    return _granted;
  }

  @override
  Future<bool> permissionsRequest({bool retryRequest = false}) async {
    final result = await super.permissionsRequest(retryRequest: retryRequest);
    _granted = result;
    return result;
  }

  @override
  Future<List<SongModel>> querySongs({
    SongSortType? sortType,
    OrderType? orderType,
    UriType? uriType,
    bool? ignoreCase,
    String? path,
  }) async {
    if (!await _hasPermission()) return <SongModel>[];
    return super.querySongs(
      sortType: sortType,
      orderType: orderType,
      uriType: uriType,
      ignoreCase: ignoreCase,
      path: path,
    );
  }

  @override
  Future<List<AlbumModel>> queryAlbums({
    AlbumSortType? sortType,
    OrderType? orderType,
    UriType? uriType,
    bool? ignoreCase,
  }) async {
    if (!await _hasPermission()) return <AlbumModel>[];
    return super.queryAlbums(
      sortType: sortType,
      orderType: orderType,
      uriType: uriType,
      ignoreCase: ignoreCase,
    );
  }

  @override
  Future<List<ArtistModel>> queryArtists({
    ArtistSortType? sortType,
    OrderType? orderType,
    UriType? uriType,
    bool? ignoreCase,
  }) async {
    if (!await _hasPermission()) return <ArtistModel>[];
    return super.queryArtists(
      sortType: sortType,
      orderType: orderType,
      uriType: uriType,
      ignoreCase: ignoreCase,
    );
  }

  @override
  Future<List<PlaylistModel>> queryPlaylists({
    PlaylistSortType? sortType,
    OrderType? orderType,
    UriType? uriType,
    bool? ignoreCase,
  }) async {
    if (!await _hasPermission()) return <PlaylistModel>[];
    return super.queryPlaylists(
      sortType: sortType,
      orderType: orderType,
      uriType: uriType,
      ignoreCase: ignoreCase,
    );
  }

  @override
  Future<List<GenreModel>> queryGenres({
    GenreSortType? sortType,
    OrderType? orderType,
    UriType? uriType,
    bool? ignoreCase,
  }) async {
    if (!await _hasPermission()) return <GenreModel>[];
    return super.queryGenres(
      sortType: sortType,
      orderType: orderType,
      uriType: uriType,
      ignoreCase: ignoreCase,
    );
  }

  @override
  Future<List<SongModel>> queryAudiosFrom(
    AudiosFromType type,
    Object where, {
    SongSortType? sortType,
    OrderType? orderType,
    bool? ignoreCase,
  }) async {
    if (!await _hasPermission()) return <SongModel>[];
    return super.queryAudiosFrom(
      type,
      where,
      sortType: sortType,
      orderType: orderType,
      ignoreCase: ignoreCase,
    );
  }

  @override
  Future<List<dynamic>> queryWithFilters(
    String argsVal,
    WithFiltersType withType,
    dynamic args,
  ) async {
    if (!await _hasPermission()) return <dynamic>[];
    return super.queryWithFilters(argsVal, withType, args);
  }

  @override
  Future<Uint8List?> queryArtwork(
    int id,
    ArtworkType type, {
    ArtworkFormat? format,
    int? size,
    int? quality,
  }) async {
    if (!await _hasPermission()) return null;
    return super.queryArtwork(
      id,
      type,
      format: format,
      size: size,
      quality: quality,
    );
  }

  @override
  Future<List<SongModel>> queryFromFolder(
    String path, {
    SongSortType? sortType,
    OrderType? orderType,
    UriType? uriType,
  }) async {
    if (!await _hasPermission()) return <SongModel>[];
    return super.queryFromFolder(
      path,
      sortType: sortType,
      orderType: orderType,
      uriType: uriType,
    );
  }

  @override
  Future<List<String>> queryAllPath() async {
    if (!await _hasPermission()) return <String>[];
    return super.queryAllPath();
  }

  @override
  Future<bool> createPlaylist(
    String name, {
    String? author,
    String? desc,
  }) async {
    if (!await _hasPermission()) return false;
    return super.createPlaylist(name, author: author, desc: desc);
  }

  @override
  Future<bool> removePlaylist(int playlistId) async {
    if (!await _hasPermission()) return false;
    return super.removePlaylist(playlistId);
  }

  @override
  Future<bool> addToPlaylist(int playlistId, int audioId) async {
    if (!await _hasPermission()) return false;
    return super.addToPlaylist(playlistId, audioId);
  }

  @override
  Future<bool> removeFromPlaylist(int playlistId, int audioId) async {
    if (!await _hasPermission()) return false;
    return super.removeFromPlaylist(playlistId, audioId);
  }

  @override
  Future<bool> moveItemTo(int playlistId, int from, int to) async {
    if (!await _hasPermission()) return false;
    return super.moveItemTo(playlistId, from, to);
  }

  @override
  Future<bool> renamePlaylist(int playlistId, String newName) async {
    if (!await _hasPermission()) return false;
    return super.renamePlaylist(playlistId, newName);
  }

  @override
  Future<bool> scanMedia(String path) async {
    if (!await _hasPermission()) return false;
    return super.scanMedia(path);
  }
}
