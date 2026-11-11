import 'package:aurora_music_v01/features/search/widgets/search_tab.dart';
import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:aurora_music_v01/shared/providers/performance_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

Widget _app(Size size, {required double keyboard, double textScale = 1}) {
  return ChangeNotifierProvider(
    create: (_) => PerformanceModeProvider(),
    child: MaterialApp(
      theme: ThemeData.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          viewInsets: EdgeInsets.only(bottom: keyboard),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SearchTab(
            songs: [
              SongModel({'_id': 1, 'title': 'A song', 'artist': 'An artist'}),
            ],
            artists: const [],
            isInitialized: true,
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final (width, available, keyboard, textScale, noResults) in [
    (411.4, 400.0, 0.0, 1.0, false),
    (411.4, 124.2, 300.0, 1.0, false),
    (411.4, 64.0, 300.0, 1.0, true),
    (320.0, 64.0, 0.0, 1.0, false),
    (320.0, 64.0, 300.0, 2.0, false),
  ]) {
    testWidgets(
        '${noResults ? 'no results' : 'empty search'} fits $available px '
        'at scale $textScale with $keyboard px keyboard', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
          _app(Size(width, 800), keyboard: keyboard, textScale: textScale));
      await tester.pumpAndSettle();

      final root = tester.renderObject<RenderFlex>(
        find
            .descendant(
                of: find.byType(SearchTab), matching: find.byType(Column))
            .first,
      );
      final headerHeight = root.firstChild!.size.height;
      final size = Size(width, headerHeight + keyboard + 48 + available);
      tester.view.physicalSize = size;
      await tester
          .pumpWidget(_app(size, keyboard: keyboard, textScale: textScale));
      await tester.pumpAndSettle();

      if (noResults) {
        await tester.enterText(find.byType(TextField), 'unmatched query');
        await tester.pump(const Duration(milliseconds: 350));
      }
      expect(tester.takeException(), isNull);
      final scroll = find.byType(SingleChildScrollView);
      expect(scroll, findsOneWidget);
      expect(tester.getBottomLeft(scroll).dy,
          lessThanOrEqualTo(size.height - keyboard));
      if (available < 128) {
        final scrollable = tester.state<ScrollableState>(
          find.descendant(of: scroll, matching: find.byType(Scrollable)),
        );
        expect(scrollable.position.maxScrollExtent, greaterThan(0));
      }
      await tester.drag(scroll, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final l10n = AppLocalizations.of(tester.element(find.byType(SearchTab)));
      final message = find.text(noResults ? l10n.noResults : l10n.startType);
      expect(message, findsOneWidget);
      Future<void> checkReachable(Finder text) async {
        await Scrollable.ensureVisible(tester.element(text));
        await tester.pumpAndSettle();
        final viewport = tester.getRect(scroll);
        expect(tester.getTopLeft(text).dy,
            greaterThanOrEqualTo(viewport.top - 0.01));
        expect(tester.getTopLeft(text).dy, lessThan(viewport.bottom));
        await Scrollable.ensureVisible(tester.element(text), alignment: 1);
        await tester.pumpAndSettle();
        expect(tester.getBottomLeft(text).dy,
            lessThanOrEqualTo(viewport.bottom + 0.01));
        expect(tester.getBottomLeft(text).dy, greaterThan(viewport.top));
      }

      await checkReachable(message);
      if (!noResults) {
        final hint = find.textContaining('1 ${l10n.songs.toLowerCase()}');
        expect(hint, findsOneWidget);
        await checkReachable(hint);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
