import 'package:aurora_music_v01/shared/services/app_update_policy.dart';
import 'package:aurora_music_v01/shared/services/online_sources.dart';
import 'package:aurora_music_v01/shared/services/remote_config_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('AppUpdatePolicy.decide', () {
    final app = Version.parse('2.0.0');

    test('requires an update below the minimum version', () {
      final notice = AppUpdatePolicy.decide(
        appVersion: app,
        minVersion: '2.0.1',
        message: 'Please update',
      )!;
      expect(notice.level, UpdateLevel.required);
      expect(notice.version, '2.0.1');
      expect(notice.message, 'Please update');
    });

    test('does nothing at or above the minimum', () {
      expect(
          AppUpdatePolicy.decide(appVersion: app, minVersion: '2.0.0'), isNull);
      expect(
          AppUpdatePolicy.decide(appVersion: app, minVersion: '1.9.0'), isNull);
    });

    test('recommends once per version', () {
      expect(
        AppUpdatePolicy.decide(appVersion: app, recommendedVersion: '2.1.0')!
            .level,
        UpdateLevel.recommended,
      );
      expect(
        AppUpdatePolicy.decide(
          appVersion: app,
          recommendedVersion: '2.1.0',
          recommendedSeen: '2.1.0',
        ),
        isNull,
      );
    });

    test('the minimum wins over the recommendation', () {
      final notice = AppUpdatePolicy.decide(
        appVersion: app,
        minVersion: '2.0.5',
        recommendedVersion: '2.1.0',
      )!;
      expect(notice.level, UpdateLevel.required);
    });

    test('ignores malformed or empty values', () {
      expect(
        AppUpdatePolicy.decide(
          appVersion: app,
          minVersion: 'soon',
          recommendedVersion: '',
        ),
        isNull,
      );
    });
  });

  group('OnlineSources', () {
    test('maps hosts to source ids', () {
      expect(OnlineSources.idForHost('api.deezer.com'), 'deezer');
      expect(OnlineSources.idForHost('en.wikipedia.org'), 'wikipedia');
      expect(OnlineSources.idForHost('www.wikidata.org'), 'wikipedia');
      expect(OnlineSources.idForHost('musicbrainz.org'), 'musicbrainz');
      expect(OnlineSources.idForHost('lrclib.net'), isNull);
    });

    test('everything is on without console values', () {
      expect(OnlineSources.isEnabled('deezer'), isTrue);
      expect(OnlineSources.isUriEnabled(Uri.parse('https://api.deezer.com/x')),
          isTrue);
    });
  });

  group('RemoteConfigHelper defaults (no console values yet)', () {
    test('falls back to the built-in values', () {
      expect(RemoteConfigHelper.boolean('donation_enabled'), isTrue);
      expect(RemoteConfigHelper.string('donation_kofi_username'),
          'aurorasoftwarecz');
      expect(RemoteConfigHelper.integer('prompt_feedback_min_days'), 7);
      expect(RemoteConfigHelper.list('lyrics_disabled_providers'), isEmpty);
    });
  });
}
