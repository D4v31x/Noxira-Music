/// Cover thumbnail in the lyrics page header (the landing spot of the shared
/// cover element).
library;

import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../../../shared/services/artwork_cache_service.dart';
import 'lyrics_constants.dart';

class LyricsHeaderCover extends StatefulWidget {
  const LyricsHeaderCover({super.key, required this.songId});

  final int songId;

  @override
  State<LyricsHeaderCover> createState() => _LyricsHeaderCoverState();
}

class _LyricsHeaderCoverState extends State<LyricsHeaderCover> {
  static final _service = ArtworkCacheService();

  ImageProvider<Object>? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(LyricsHeaderCover old) {
    super.didUpdateWidget(old);
    if (old.songId != widget.songId) _load();
  }

  void _load() {
    final id = widget.songId;
    _image = _service.getCachedImageProviderSync(id);
    if (_image != null) return;
    _service.getCachedImageProvider(id).then((provider) {
      if (mounted && widget.songId == id) setState(() => _image = provider);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kLyricsHeaderArtSize,
      height: kLyricsHeaderArtSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kLyricsHeaderArtRadius),
        child: _image != null
            ? Image(image: _image!, fit: BoxFit.cover, gaplessPlayback: true)
            : ColoredBox(
                color: Colors.white.withValues(alpha: 0.1),
                child: Center(
                  child: iconoir.MusicNote(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
      ),
    );
  }
}
