import 'package:on_audio_query/on_audio_query.dart';

/// MediaStore's album query runs on the Android main thread and stalls
/// animations while it does. The result only changes with the song library,
/// so it is shared until the library list is replaced.
class AlbumQueryCache {
  AlbumQueryCache._();

  static List<SongModel>? _library;
  static Future<List<AlbumModel>>? _albums;

  static Future<List<AlbumModel>> get(
    OnAudioQuery query,
    List<SongModel> library,
  ) {
    if (_albums == null || !identical(_library, library)) {
      _library = library;
      final future = query.queryAlbums(
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      _albums = future;
      // A failed query must not stick.
      future.catchError((Object _) {
        if (identical(_albums, future)) _albums = null;
        return <AlbumModel>[];
      });
    }
    return _albums!;
  }
}
