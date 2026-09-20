import '../data/dose.dart';

/// All the doses of one local calendar day, newest first.
class DayGroup {
  DayGroup(this.day, this.doses);

  /// Local midnight of the day.
  final DateTime day;
  final List<Dose> doses;

  int get totalMg => doses.fold(0, (sum, d) => sum + d.mg);
}

/// One day's total, for the trend strip.
class DayTotal {
  const DayTotal(this.day, this.mg, this.count);

  final DateTime day;
  final int mg;
  final int count;
}

DateTime _localDay(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

int _key(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

/// Days that have at least one dose, newest day first, doses newest first.
/// A dose dated in the future still gets its own day rather than vanishing.
List<DayGroup> groupByDay(Iterable<Dose> doses) {
  final byDay = <int, DayGroup>{};
  for (final d in doses) {
    final day = _localDay(d.at);
    byDay.putIfAbsent(_key(day), () => DayGroup(day, [])).doses.add(d);
  }
  final groups = byDay.values.toList()..sort((a, b) => b.day.compareTo(a.day));
  for (final g in groups) {
    g.doses.sort((a, b) => b.at.compareTo(a.at));
  }
  return groups;
}

/// Exactly [days] local days ending today, oldest first, zero days included.
/// Doses outside that window (older, or dated in the future) are ignored.
/// Days step by calendar date, not by 24 hours, so DST can't skip or repeat one.
List<DayTotal> dailyTotals(
  Iterable<Dose> doses,
  DateTime now, {
  int days = 14,
}) {
  final today = _localDay(now);
  final window = [
    for (var i = days - 1; i >= 0; i--)
      DateTime(today.year, today.month, today.day - i),
  ];
  final mg = <int, int>{};
  final count = <int, int>{};
  for (final d in doses) {
    final k = _key(_localDay(d.at));
    mg[k] = (mg[k] ?? 0) + d.mg;
    count[k] = (count[k] ?? 0) + 1;
  }
  return [
    for (final day in window)
      DayTotal(day, mg[_key(day)] ?? 0, count[_key(day)] ?? 0),
  ];
}

const _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const _months = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

/// TODAY, YESTERDAY, otherwise "MON 14 SEP" (with the year if it isn't this
/// one). English only, like the rest of the app's copy.
String dayLabel(DateTime day, DateTime now) {
  final d = _localDay(day);
  final today = _localDay(now);
  if (_key(d) == _key(today)) return 'TODAY';
  if (_key(d) == _key(DateTime(today.year, today.month, today.day - 1))) {
    return 'YESTERDAY';
  }
  final base = '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
  return d.year == today.year ? base : '$base ${d.year}';
}

/// M T W T F S S, for the trend strip.
String weekdayInitial(DateTime day) => _weekdays[day.weekday - 1][0];
