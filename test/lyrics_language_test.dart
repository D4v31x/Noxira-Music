import 'package:aurora_music_v01/shared/services/lyrics_providers/lyrics_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  trackMatchTests();
  const english = LyricsQuery(title: 'Breathe', artist: 'Jem Cooke');
  const japanese = LyricsQuery(title: '夜に駆ける', artist: 'YOASOBI');
  const chineseTags = LyricsQuery(title: '晴天', artist: '周杰伦');

  const englishLrc = '[00:01.00]Hold on to me\n[00:05.00]I can feel it breathe';
  const chineseLrc = '[00:01.00]故事的小黄花\n[00:05.00]从出生那年就飘着';
  const bilingual =
      '[00:01.00]Hold on to me\n[00:02.00]抱紧我\n[00:05.00]I can feel\n[00:06.00]我能感觉到';
  const japaneseLrc = '[00:01.00]沈むように溶けてゆくように\n[00:05.00]二人だけの空が広がる夜に';

  test('latin song rejects Chinese and bilingual lyrics', () {
    expect(lyricsMatchSongLanguage(englishLrc, english), isTrue);
    expect(lyricsMatchSongLanguage(chineseLrc, english), isFalse);
    expect(lyricsMatchSongLanguage(bilingual, english), isFalse);
  });

  test('East Asian songs keep their own language', () {
    expect(lyricsMatchSongLanguage(japaneseLrc, japanese), isTrue);
    expect(lyricsMatchSongLanguage(chineseLrc, chineseTags), isTrue);
    expect(lyricsMatchSongLanguage(englishLrc, chineseTags), isTrue);
  });
}

void trackMatchTests() {
  group('tracksMatch', () {
    test('accepts the same song with decorations', () {
      expect(
          tracksMatch('Reflections', 'Kanine', 'Reflections', 'Kanine、Heights'),
          isTrue);
      expect(
          tracksMatch('Creep', 'Radiohead', 'Creep (Remastered)', 'Radiohead'),
          isTrue);
      expect(
          tracksMatch('Surrender', 'Natalie Taylor', 'Surrender - Radio Edit',
              'Natalie Taylor'),
          isTrue);
    });

    test('rejects other songs and other artists', () {
      expect(
          tracksMatch(
              'Surrender', 'Natalie Taylor', 'Love Story', 'Taylor Swift'),
          isFalse);
      expect(tracksMatch('Reflections', 'Kanine', 'Reflections', 'Faraon'),
          isFalse);
      expect(
          tracksMatch('Creep', 'Radiohead', 'Creeper', 'Radiohead'), isFalse);
    });
  });
}
