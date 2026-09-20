import 'package:flutter_test/flutter_test.dart';
import 'package:wired/data/dose.dart';
import 'package:wired/domain/presets.dart';
import 'package:wired/domain/today.dart';

Dose dose(int mg, DateTime at) =>
    Dose.create(source: DoseSource.coffee, mg: mg, at: at);

void main() {
  // Local times on purpose: "today" means the device's local day.
  final now = DateTime(2026, 9, 20, 14, 30);

  test('only doses from the local day of `now` count', () {
    final yesterdayLate = dose(100, DateTime(2026, 9, 19, 23, 59, 59));
    final midnight = dose(50, DateTime(2026, 9, 20, 0, 0));
    final morning = dose(95, DateTime(2026, 9, 20, 8));
    final tomorrow = dose(70, DateTime(2026, 9, 21, 0, 0));
    final today = dosesToday([yesterdayLate, midnight, morning, tomorrow], now);
    expect(today, [morning, midnight]);
    expect(totalMg(today), 145);
  });

  test('newest first', () {
    final a = dose(10, DateTime(2026, 9, 20, 7));
    final b = dose(20, DateTime(2026, 9, 20, 9));
    final c = dose(30, DateTime(2026, 9, 20, 8));
    expect(dosesToday([a, b, c], now), [b, c, a]);
  });

  test('a UTC `now` is read in local time', () {
    final utcNow = now.toUtc();
    expect(
      dosesToday([dose(95, DateTime(2026, 9, 20, 8))], utcNow),
      hasLength(1),
    );
  });

  test('empty in, zero out', () {
    expect(dosesToday([], now), isEmpty);
    expect(totalMg([]), 0);
  });

  group('presets', () {
    test('are sane and distinct', () {
      expect(presets.map((p) => p.name).toSet(), hasLength(presets.length));
      for (final p in presets) {
        expect(p.mg, inInclusiveRange(1, maxDoseMg), reason: p.name);
        expect(p.name, isNotEmpty);
        expect(p.serving, isNotEmpty);
      }
    });
  });

  group('lastOccurrence', () {
    test('an earlier time of day means today', () {
      expect(lastOccurrence(8, 0, now), DateTime(2026, 9, 20, 8, 0));
    });

    test('exactly now is still today, not yesterday', () {
      expect(lastOccurrence(14, 30, now), DateTime(2026, 9, 20, 14, 30));
    });

    test('a later time of day means yesterday', () {
      expect(lastOccurrence(14, 31, now), DateTime(2026, 9, 19, 14, 31));
      expect(lastOccurrence(23, 0, now), DateTime(2026, 9, 19, 23, 0));
    });

    test('just after midnight, 23:00 is the previous evening', () {
      final late = DateTime(2026, 9, 20, 0, 30);
      expect(lastOccurrence(23, 0, late), DateTime(2026, 9, 19, 23, 0));
    });

    test('crosses month and year boundaries', () {
      expect(
        lastOccurrence(23, 0, DateTime(2026, 10, 1, 0, 10)),
        DateTime(2026, 9, 30, 23, 0),
      );
      expect(
        lastOccurrence(23, 0, DateTime(2027, 1, 1, 0, 10)),
        DateTime(2026, 12, 31, 23, 0),
      );
    });

    test('is never in the future and never a day or more old', () {
      for (var h = 0; h < 24; h++) {
        for (var m = 0; m < 60; m += 7) {
          final r = lastOccurrence(h, m, now);
          expect(r.isAfter(now), isFalse, reason: '$h:$m');
          expect(now.difference(r), lessThan(const Duration(days: 1)));
        }
      }
    });

    test('a UTC `now` is read in local time', () {
      expect(lastOccurrence(8, 0, now.toUtc()), DateTime(2026, 9, 20, 8, 0));
    });
  });
}
