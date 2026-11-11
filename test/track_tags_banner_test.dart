import 'package:aurora_music_v01/features/player/widgets/track_tags_section.dart';
import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:aurora_music_v01/shared/models/track_tag_model.dart';
import 'package:aurora_music_v01/shared/services/audio_player_service.dart';
import 'package:aurora_music_v01/shared/services/track_tag_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class _FakeAudio extends ChangeNotifier implements AudioPlayerService {
  @override
  SongModel? get currentSong => SongModel({'_id': 1, 'title': 'Song'});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeTags extends ChangeNotifier implements TrackTagService {
  @override
  bool get loaded => true;

  @override
  bool get suggestionDismissed => false;

  @override
  List<TrackTag> tagsFor(int songId) => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// The "add tags to this track" banner keeps its text readable at the largest
/// font sizes instead of squeezing it to one letter per line.
void main() {
  testWidgets('the banner text stays readable at very large text sizes',
      (tester) async {
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<TrackTagService>.value(value: _FakeTags()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2.5)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: TrackTagsSection(audioPlayerService: _FakeAudio()),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)));
    final title = find.text(l10n.isThisASet);
    expect(title, findsOneWidget);
    // Wide enough for words, not one letter per line.
    expect(tester.getSize(title).width, greaterThan(120));
    expect(find.text(l10n.tagThisTrack), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
