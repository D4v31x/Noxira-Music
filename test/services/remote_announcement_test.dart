import 'package:aurora_music_v01/shared/services/remote_announcement_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  test('builds from the console values', () {
    final a = RemoteAnnouncement.fromValues({
      'enabled': 'true',
      'id': 'x',
      'title': 'Hi',
      'message': 'Body',
      'button_label': 'More',
      'url': 'https://example.com',
      'min_version': '1.0.0',
    })!;
    expect(a.id, 'x');
    expect(a.title, 'Hi');
    expect(a.message, 'Body');
    expect(a.buttonLabel, 'More');
    expect(a.url, Uri.parse('https://example.com'));
  });

  test('reads the in-app screen name, case-insensitively', () {
    final a = RemoteAnnouncement.fromValues({
      'enabled': 'true',
      'message': 'm',
      'screen': ' Equalizer ',
    })!;
    expect(a.screen, 'equalizer');
    expect(
      RemoteAnnouncement.fromValues({'enabled': 'true', 'message': 'm'})!
          .screen,
      isNull,
    );
  });

  test('needs enabled and a message', () {
    expect(RemoteAnnouncement.fromValues({'message': 'm'}), isNull);
    expect(RemoteAnnouncement.fromValues({'enabled': 'false', 'message': 'm'}),
        isNull);
    expect(RemoteAnnouncement.fromValues({'enabled': 'true'}), isNull);
    expect(RemoteAnnouncement.fromValues({'enabled': 'true', 'message': '  '}),
        isNull);
  });

  test('without an id it is derived from the text', () {
    RemoteAnnouncement? make(String message) => RemoteAnnouncement.fromValues(
        {'enabled': 'true', 'title': 'T', 'message': message});
    expect(make('one')!.id, make('one')!.id);
    expect(make('one')!.id, isNot(make('two')!.id));
  });

  test('ignores malformed optional values and non-web links', () {
    final a = RemoteAnnouncement.fromValues({
      'enabled': 'true',
      'message': 'm',
      'url': 'intent://evil',
      'min_version': 'not-a-version',
      'expires': 'someday',
    })!;
    expect(a.url, isNull);
    expect(a.minVersion, isNull);
    expect(a.expires, isNull);
  });

  test('respects expiry and version range', () {
    final a = RemoteAnnouncement.fromValues({
      'enabled': 'true',
      'message': 'm',
      'min_version': '1.2.0',
      'max_version': '1.4.0',
      'expires': '2026-12-01T00:00:00Z',
    })!;
    final now = DateTime.utc(2026, 11, 7);
    expect(a.isActive(appVersion: Version(1, 3, 0), now: now), isTrue);
    expect(a.isActive(appVersion: Version(1, 1, 0), now: now), isFalse);
    expect(a.isActive(appVersion: Version(1, 5, 0), now: now), isFalse);
    expect(a.isActive(appVersion: Version(1, 3, 0), now: DateTime.utc(2027)),
        isFalse);
  });
}
