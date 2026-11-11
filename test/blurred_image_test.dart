import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/widgets/blurred_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('rapid ready/fallback changes never reuse outgoing switcher keys',
      (tester) async {
    late MemoryImage ready;
    late MemoryImage pending;
    await tester.runAsync(() async {
      final image = await createTestImage(width: 20, height: 20, cache: false);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      ready = MemoryImage(data!.buffer.asUint8List());
      pending = MemoryImage(Uint8List.fromList(data.buffer.asUint8List()));
      image.dispose();
      await BlurredImage.precache(ready, sigma: 25, extent: 600);
    });
    final provider = ValueNotifier<ImageProvider>(ready);
    addTearDown(provider.dispose);
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => PerformanceModeProvider(),
      child: MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 600,
            child: ValueListenableBuilder<ImageProvider>(
              valueListenable: provider,
              builder: (_, image, __) => BlurredImage(
                provider: image,
                sigma: 25,
                fallback: const Text('fallback'),
              ),
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 4; i++) {
      provider.value = pending;
      await tester.pump(const Duration(milliseconds: 10));
      provider.value = ready;
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

}
