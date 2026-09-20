import 'package:flutter_test/flutter_test.dart';
import 'package:wired/data/dose.dart';
import 'package:wired/domain/history.dart';

Dose dose(int mg, DateTime at) =>
    Dose.create(source: DoseSource.coffee, mg: mg, at: at);

void main() {
  // 2026-09-20 is a Sunday. Local times on purpose: days are local days.
  final now = DateTime(2026, 9, 20, 14, 30);

  group('groupByDay', () {
    test('empty in, empty out', () {
      expect(groupByDay([]), isEmpty);
    });

    test('groups by local day, newest day first, newest dose first', () {
      final a = dose(10, DateTime(2026, 9, 19, 8));
      final b = dose(20, DateTime(2026, 9, 20, 9));
      final c = dose(30, DateTime(2026, 9, 20, 13));
      final d = dose(40, DateTime(2026, 9, 18, 22));
      final groups = groupByDay([a, b, c, d]);
      expect(groups.map((g) => g.day), [
        DateTime(2026, 9, 20),
        DateTime(2026, 9, 19),
        DateTime(2026, 9, 18),
      ]);
      expect(groups[0].doses, [c, b]);
      expect(groups[0].totalMg, 50);
      expect(groups[1].doses, [a]);
    });

    test('day boundary is local midnight', () {
      final late = dose(10, DateTime(2026, 9, 19, 23, 59, 59));
      final early = dose(20, DateTime(2026, 9, 20, 0, 0, 0));
      final groups = groupByDay([late, early]);
      expect(groups, hasLength(2));
      expect(groups[0].doses, [early]);
      expect(groups[1].doses, [late]);
    });

    test('a dose in the future gets its own day rather than vanishing', () {
      final future = dose(50, DateTime(2026, 9, 21, 9));
      expect(groupByDay([future]).single.day, DateTime(2026, 9, 21));
    });

    test('UTC-stored doses are read in local time', () {
      final d = dose(10, DateTime(2026, 9, 20, 8).toUtc());
      expect(groupByDay([d]).single.day, DateTime(2026, 9, 20));
    });
  });

  group('dailyTotals', () {
    test('covers exactly `days` days ending today, oldest first', () {
      final totals = dailyTotals([], now, days: 14);
      expect(totals, hasLength(14));
      expect(totals.last.day, DateTime(2026, 9, 20));
      expect(totals.first.day, DateTime(2026, 9, 7));
      expect(totals.every((t) => t.mg == 0 && t.count == 0), isTrue);
    });

    test('sums doses into their day, zero days included', () {
      final totals = dailyTotals([
        dose(95, DateTime(2026, 9, 20, 8)),
        dose(63, DateTime(2026, 9, 20, 12)),
        dose(80, DateTime(2026, 9, 18, 15)),
      ], now);
      expect(totals.last.mg, 158);
      expect(totals.last.count, 2);
      expect(totals[totals.length - 2].mg, 0);
      expect(totals[totals.length - 3].mg, 80);
      expect(totals[totals.length - 3].count, 1);
    });

    test('ignores doses outside the window and in the future', () {
      final totals = dailyTotals(
        [
          dose(100, DateTime(2026, 9, 6, 12)), // day 15 back
          dose(100, DateTime(2026, 9, 21, 12)), // tomorrow
        ],
        now,
        days: 14,
      );
      expect(totals.fold(0, (s, t) => s + t.mg), 0);
    });

    test('crosses month and year boundaries by calendar, not by 24 h', () {
      final totals = dailyTotals([], DateTime(2027, 1, 2, 10), days: 4);
      expect(totals.map((t) => t.day), [
        DateTime(2026, 12, 30),
        DateTime(2026, 12, 31),
        DateTime(2027, 1, 1),
        DateTime(2027, 1, 2),
      ]);
    });

    test('a UTC `now` is read in local time', () {
      expect(dailyTotals([], now.toUtc()).last.day, DateTime(2026, 9, 20));
    });
  });

  group('dayLabel', () {
    test('today and yesterday are named', () {
      expect(dayLabel(DateTime(2026, 9, 20), now), 'TODAY');
      expect(dayLabel(DateTime(2026, 9, 19), now), 'YESTERDAY');
    });

    test('yesterday works across a month boundary', () {
      expect(
        dayLabel(DateTime(2026, 9, 30), DateTime(2026, 10, 1, 8)),
        'YESTERDAY',
      );
    });

    test('older days read as weekday, date, month', () {
      expect(dayLabel(DateTime(2026, 9, 14), now), 'MON 14 SEP');
      expect(dayLabel(DateTime(2026, 9, 13), now), 'SUN 13 SEP');
    });

    test('a day from another year includes the year', () {
      expect(
        dayLabel(DateTime(2026, 12, 31), DateTime(2027, 1, 5)),
        'THU 31 DEC 2026',
      );
    });

    test('a future day is not called today', () {
      expect(dayLabel(DateTime(2026, 9, 21), now), 'MON 21 SEP');
    });
  });

  test('weekday initials', () {
    final initials = [
      for (var d = 14; d <= 20; d++) weekdayInitial(DateTime(2026, 9, d)),
    ];
    expect(initials, ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
  });
}
