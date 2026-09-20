import 'package:flutter_test/flutter_test.dart';
import 'package:wired/data/dose.dart';
import 'package:wired/domain/caffeine.dart';

Dose dose(int mg, DateTime at) =>
    Dose.create(source: DoseSource.coffee, mg: mg, at: at);

void main() {
  final now = DateTime.utc(2026, 9, 20, 12);
  DateTime before(Duration d) => now.subtract(d);

  test('no doses means nothing active', () {
    expect(remainingMg([], now), 0);
  });

  test('a dose taken this instant is fully active', () {
    expect(remainingMg([dose(100, now)], now), 100);
  });

  test('default half-life is 5 hours', () {
    expect(defaultHalfLife, const Duration(hours: 5));
    expect(
      remainingMg([dose(100, before(const Duration(hours: 5)))], now),
      closeTo(50, 1e-9),
    );
  });

  test('halves every half-life', () {
    for (final (hours, expected) in [(5, 50.0), (10, 25.0), (15, 12.5)]) {
      final d = dose(100, before(Duration(hours: hours)));
      expect(
        remainingMg([d], now),
        closeTo(expected, 1e-9),
        reason: '$hours h',
      );
    }
  });

  test('matches hand-computed fractional values', () {
    // 100 * 0.5^(1/5) and 200 * 0.5^(2.5/5)
    expect(
      remainingMg([dose(100, before(const Duration(hours: 1)))], now),
      closeTo(87.0551, 1e-4),
    );
    expect(
      remainingMg([
        dose(200, before(const Duration(hours: 2, minutes: 30))),
      ], now),
      closeTo(141.4214, 1e-4),
    );
  });

  test('doses add up', () {
    final doses = [
      dose(100, before(const Duration(hours: 5))), // 50 left
      dose(80, now), // 80 left
      dose(60, before(const Duration(hours: 10))), // 15 left
    ];
    expect(remainingMg(doses, now), closeTo(145, 1e-9));
  });

  test('order of the list does not matter', () {
    final doses = [
      dose(100, before(const Duration(hours: 3))),
      dose(50, before(const Duration(hours: 1))),
      dose(75, before(const Duration(hours: 7))),
    ];
    expect(remainingMg(doses.reversed, now), remainingMg(doses, now));
  });

  test('a dose in the future has not been taken yet', () {
    final future = dose(100, now.add(const Duration(minutes: 1)));
    expect(remainingMg([future], now), 0);
  });

  test('half-life is adjustable', () {
    final d = dose(100, before(const Duration(hours: 3)));
    expect(
      remainingMg([d], now, halfLife: const Duration(hours: 3)),
      closeTo(50, 1e-9),
    );
    expect(
      remainingMg([d], now, halfLife: const Duration(hours: 6)),
      closeTo(100 * 0.7071067811865476, 1e-9),
    );
  });

  test('rejects a half-life that is zero or negative', () {
    for (final h in [Duration.zero, const Duration(hours: -5)]) {
      expect(
        () => remainingMg([dose(100, now)], now, halfLife: h),
        throwsArgumentError,
      );
    }
  });

  test('only ever decreases as time passes', () {
    final d = dose(100, before(const Duration(hours: 1)));
    var last = double.infinity;
    for (var m = 0; m <= 24 * 60; m += 15) {
      final r = remainingMg([d], now.add(Duration(minutes: m)));
      expect(r, lessThan(last));
      last = r;
    }
  });

  test('very old doses are effectively zero, never negative or NaN', () {
    final r = remainingMg([dose(500, before(const Duration(days: 3650)))], now);
    expect(r, greaterThanOrEqualTo(0));
    expect(r, lessThan(1e-100));
    expect(r.isNaN, isFalse);
  });

  test('time zone of `now` does not change the answer', () {
    final d = dose(100, before(const Duration(hours: 2)));
    expect(remainingMg([d], now.toLocal()), remainingMg([d], now));
  });
}
