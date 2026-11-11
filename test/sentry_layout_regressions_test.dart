import 'package:aurora_music_v01/features/onboarding/pages/donation_page.dart';
import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:aurora_music_v01/shared/widgets/detail_header.dart';
import 'package:aurora_music_v01/shared/widgets/glassmorphic_card.dart';
import 'package:aurora_music_v01/shared/widgets/motion/musicfy_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app(Widget child, double scale) => ChangeNotifierProvider(
      create: (_) => PerformanceModeProvider(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (_, child) => MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    );

void main() {
  for (final scale in [0.8, 1.0, 2.0, 3.0]) {
    testWidgets('collapsed detail toolbar fits at text scale $scale',
        (tester) async {
      await tester.pumpWidget(_app(
        const CustomScrollView(slivers: [
          DetailHeader(
            title: 'A long album title',
            subtitle: 'A long artist name',
            badge: 'ALBUM',
          ),
          SliverToBoxAdapter(child: SizedBox(height: 2000)),
        ]),
        scale,
      ));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('horizontal cards fit their measured height at scale $scale',
        (tester) async {
      await tester.pumpWidget(_app(
        Builder(
            builder: (context) => Center(
                  child: SizedBox(
                    height: GlassmorphicCard.listHeight(context),
                    child: GlassmorphicCard(
                      artwork: const ColoredBox(color: Colors.blue),
                      title: 'Long song title',
                      subtitle: 'Long artist name',
                      onTap: () {},
                    ),
                  ),
                )),
        scale,
      ));
      expect(tester.takeException(), isNull);
      final press = await tester.press(find.byType(GlassmorphicCard));
      await tester.pump(const Duration(milliseconds: 100));
      await press.up();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('donation step scrolls on a short screen with large text',
      (tester) async {
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester
        .pumpWidget(_app(DonationPage(onContinue: () {}, onBack: () {}), 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('keepalive cards retain parent data during press and removal',
      (tester) async {
    await tester.pumpWidget(_app(
      ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (_, index) => _KeepAliveCard(index),
      ),
      1,
    ));
    final press =
        await tester.startGesture(tester.getCenter(find.text('Card 0')));
    await tester.pump(const Duration(milliseconds: 50));
    await press.up();
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(-1000, 0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

class _KeepAliveCard extends StatefulWidget {
  const _KeepAliveCard(this.index);
  final int index;
  @override
  State<_KeepAliveCard> createState() => _KeepAliveCardState();
}

class _KeepAliveCardState extends State<_KeepAliveCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Press3D(
        child: SizedBox(width: 150, child: Text('Card ${widget.index}')));
  }
}
