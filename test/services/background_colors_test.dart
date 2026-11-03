import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aurora_music_v01/shared/services/background_manager_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// A song without artwork must not keep the colours of the song before it.
SongModel _song(int id) => SongModel({'_id': id, 'title': 'Song $id'});

Future<Uint8List> _png(Color color) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 64, 64),
    Paint()..color = color,
  );
  final image = await recorder.endRecording().toImage(64, 64);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Image decoding and the palette isolate need the real event loop.
  Future<void> settle(WidgetTester tester) => tester
      .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 700)));

  Future<void> push(
    WidgetTester tester,
    BackgroundManagerService bm,
    Uint8List? art,
    int id,
  ) =>
      tester.runAsync(() async => bm.pushArtwork(art, _song(id)));

  testWidgets('colours come from the artwork, then go white without it',
      (tester) async {
    final bm = BackgroundManagerService();
    final red = await tester.runAsync(() => _png(const Color(0xFFD32F2F)));

    await push(tester, bm, red, 1);
    await settle(tester);
    expect(bm.currentColors.first, isNot(Colors.white));
    final fromRed = bm.currentColors.first;
    expect(fromRed.r, greaterThan(fromRed.b));

    await push(tester, bm, null, 2);
    expect(bm.currentColors, everyElement(Colors.white));
    await settle(tester);
    expect(bm.currentColors, everyElement(Colors.white));
  });

  testWidgets('a palette still being computed cannot undo the white',
      (tester) async {
    final bm = BackgroundManagerService();
    final green = await tester.runAsync(() => _png(const Color(0xFF2E7D32)));

    await push(tester, bm, green, 1);
    // The next song has no artwork before the first palette is ready.
    await push(tester, bm, null, 2);
    await settle(tester);

    expect(bm.currentColors, everyElement(Colors.white));
  });

  testWidgets('the next song with artwork takes its own colours again',
      (tester) async {
    final bm = BackgroundManagerService();
    final red = await tester.runAsync(() => _png(const Color(0xFFD32F2F)));
    final blue = await tester.runAsync(() => _png(const Color(0xFF1565C0)));

    await push(tester, bm, red, 1);
    await settle(tester);
    await push(tester, bm, null, 2);
    await settle(tester);
    await push(tester, bm, blue, 3);
    await settle(tester);

    final c = bm.currentColors.first;
    expect(c, isNot(Colors.white));
    expect(c.b, greaterThan(c.r));
  });
}
