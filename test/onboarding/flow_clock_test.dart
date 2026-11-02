import 'package:aurora_music_v01/features/onboarding/widgets/onboarding_background.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const interval = Duration(milliseconds: 33);

  test('moves at full speed from the first frame when animated', () {
    final clock = FlowClock()
      ..target = 1
      ..speed = 1;
    expect(clock.tick(const Duration(milliseconds: 40), interval), isTrue);
    expect(clock.flowSeconds, closeTo(0.04, 1e-9));
  });

  test('eases to a stop, then reports it is settled', () {
    final clock = FlowClock()
      ..target = 1
      ..speed = 1;
    clock.tick(const Duration(seconds: 5), interval);
    clock.target = 0;

    var t = const Duration(seconds: 5);
    var stoppedAfter = 0;
    while (!clock.settledStill && stoppedAfter < 600) {
      t += const Duration(milliseconds: 16);
      clock.tick(t, interval);
      stoppedAfter++;
    }
    expect(clock.settledStill, isTrue);
    expect(stoppedAfter, greaterThan(10)); // eased, not an instant freeze
    expect(stoppedAfter, lessThan(150));
  });

  test('a restart after a long run paints straight away and speeds back up',
      () {
    final clock = FlowClock()
      ..target = 1
      ..speed = 1;
    // A long run, so the stamps are far ahead of a fresh ticker's clock.
    clock.tick(const Duration(seconds: 90), interval);
    clock.target = 0;
    var t = const Duration(seconds: 90);
    while (!clock.settledStill) {
      t += const Duration(milliseconds: 16);
      clock.tick(t, interval);
    }
    final before = clock.flowSeconds;

    // Switched back: a new ticker starts counting from zero again.
    clock.target = 1;
    clock.restart();
    final painted = <bool>[];
    for (var ms = 16; ms <= 200; ms += 16) {
      painted.add(clock.tick(Duration(milliseconds: ms), interval));
    }

    expect(painted.where((p) => p), isNotEmpty,
        reason: 'frames must be drawn within the first moments');
    expect(painted.take(4).any((p) => p), isTrue);
    expect(clock.speed, greaterThan(0.3));
    expect(clock.flowSeconds, greaterThan(before));
  });

  test('the picture carries on from where it stopped', () {
    final clock = FlowClock()
      ..target = 1
      ..speed = 1;
    clock.tick(const Duration(seconds: 3), interval);
    final phaseBefore = clock.phase;
    clock
      ..target = 0
      ..speed = 0
      ..restart();
    expect(clock.phase, phaseBefore);
  });
}
