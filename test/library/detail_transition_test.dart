import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/services/device_performance_service.dart';
import 'package:aurora_music_v01/shared/widgets/blurred_image.dart';
import 'package:aurora_music_v01/shared/widgets/detail_header.dart';
import 'package:aurora_music_v01/shared/widgets/motion/touch_and_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Detail pages (album, folder, playlist, artist) must not load while their
/// open transition runs, and their header artwork must be blurred before it
/// is shown.
class _Probe extends StatefulWidget {
  const _Probe(this.events);

  final List<String> events;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    whenDetailReady(context).then((_) => widget.events.add('ready'));
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('detail'));
}

Future<Uint8List> _png(int shade) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 64, 64),
    Paint()..color = Color.fromARGB(255, shade, 80, 160),
  );
  final image = await recorder.endRecording().toImage(64, 64);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  late PerformanceModeProvider perf;

  Future<void> setUpPerf(PerformanceLevel level) async {
    SharedPreferences.setMockInitialValues({});
    perf = PerformanceModeProvider();
    await perf.setPerformanceMode(level);
  }

  testWidgets('loading starts only after the transition and a head start',
      (tester) async {
    final events = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => _Probe(events),
          )),
          child: const Text('open'),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(events, isEmpty, reason: 'mid-transition');

    await tester.pump(const Duration(milliseconds: 250)); // transition done
    await tester.pump(const Duration(milliseconds: 40));
    expect(events, isEmpty,
        reason: 'settled, but the header gets a head start');

    await tester.pump(kDetailHeadStart);
    await tester.pump();
    expect(events, ['ready']);
  });

  test('the first page is small', () {
    expect(kDetailPageSize, lessThanOrEqualTo(50));
  });

  /// The image drawn by the header's blurred layer on its very first frame.
  ui.Image? firstFrameImage(WidgetTester tester) => tester
      .widget<RawImage>(find
          .descendant(
              of: find.byType(BlurredImage), matching: find.byType(RawImage))
          .first)
      .image;

  Future<void> pumpHeader(WidgetTester tester, Uint8List? bytes) async {
    // A fresh tree each time: a reused header would still be fading out its
    // previous image.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: perf,
      child: MaterialApp(
        home: Scaffold(
          body: CustomScrollView(slivers: [
            DetailHeader(artworkBytes: bytes, title: 'T', badge: 'ALBUM'),
          ]),
        ),
      ),
    ));
  }

  testWidgets('pre-blurred artwork is on screen from the first frame',
      (tester) async {
    await setUpPerf(PerformanceLevel.high);
    final withCache = await tester.runAsync(() => _png(30));
    final without = await tester.runAsync(() => _png(200));

    await pumpHeader(tester, null);
    final context = tester.element(find.byType(DetailHeader));
    await tester
        .runAsync(() => DetailHeader.precacheArtwork(context, withCache!));

    await pumpHeader(tester, withCache);
    expect(firstFrameImage(tester), isNotNull,
        reason: 'the blurred bitmap was ready, no live blur needed');

    // Without the head start the first frame has to fall back to a live blur.
    await pumpHeader(tester, without);
    expect(firstFrameImage(tester), isNull);
  });

  testWidgets('nothing is blurred ahead of time on a low-end device',
      (tester) async {
    await setUpPerf(PerformanceLevel.low);
    final bytes = await tester.runAsync(() => _png(90));

    await pumpHeader(tester, null);
    final context = tester.element(find.byType(DetailHeader));
    await tester.runAsync(() => DetailHeader.precacheArtwork(context, bytes!));
    await perf.setPerformanceMode(PerformanceLevel.high);
    await pumpHeader(tester, bytes);

    // Had it been blurred, the bitmap would be ready now.
    expect(firstFrameImage(tester), isNull);
  });
}
