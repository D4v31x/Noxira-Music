import 'package:aurora_music_v01/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counts use each language\'s plural rules', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.songsCountPlural(1), '1 song');
    expect(en.songsCountPlural(3), '3 songs');

    final cs = await AppLocalizations.delegate.load(const Locale('cs'));
    expect(cs.tracksCountPlural(1), '1 skladba');
    expect(cs.tracksCountPlural(3), '3 skladby');
    expect(cs.tracksCountPlural(5), '5 skladeb');

    final ru = await AppLocalizations.delegate.load(const Locale('ru'));
    expect(ru.songsCountPlural(1), '1 песня');
    expect(ru.songsCountPlural(2), '2 песни');
    expect(ru.songsCountPlural(5), '5 песен');
    expect(ru.songsCountPlural(21), '21 песня');
  });

  test('placeholders are filled in every language', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      expect(l10n.moreFromArtist('Abba'), contains('Abba'),
          reason: locale.languageCode);
      expect(l10n.versionWithCodename('2.0.0', 'Nova'), contains('2.0.0'),
          reason: locale.languageCode);
      expect(l10n.queueNextFrom('Mix'), contains('Mix'),
          reason: locale.languageCode);
    }
  });
}
