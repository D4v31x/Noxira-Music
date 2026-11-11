import 'package:aurora_music_v01/shared/services/artist_separator_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('splits on separators and keeps excluded names intact', () async {
    final service = ArtistSeparatorService();
    await service.resetToDefaults();
    expect(service.splitArtists('Artist1 feat. Artist2 & Artist3'),
        ['Artist1', 'Artist2', 'Artist3']);
    expect(service.splitArtists('AC/DC'), ['AC/DC']);
    expect(service.splitArtists('ac/dc / Someone'), ['ac/dc', 'Someone']);
  });

  test('picks up separator and exclusion changes after caching', () async {
    final service = ArtistSeparatorService();
    await service.resetToDefaults();
    expect(service.splitArtists('A + B'), ['A + B']);

    await service.addSeparator('+');
    expect(service.splitArtists('A + B'), ['A', 'B']);

    await service.addExclusion('A + B');
    expect(service.splitArtists('A + B'), ['A + B']);

    await service.resetToDefaults();
    expect(service.splitArtists('A + B'), ['A + B']);
  });
}
