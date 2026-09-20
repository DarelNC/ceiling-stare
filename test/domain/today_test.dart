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
}
