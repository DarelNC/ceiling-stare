import '../data/dose.dart';

/// Doses that fall on the same local calendar day as [now], newest first.
/// "Today" is the device's current local day, not a stored value, so a dose
/// keeps its meaning if the phone changes time zone (docs/features/dose-model.md).
List<Dose> dosesToday(Iterable<Dose> doses, DateTime now) {
  final day = now.toLocal();
  return doses.where((d) {
    final at = d.at.toLocal();
    return at.year == day.year && at.month == day.month && at.day == day.day;
  }).toList()..sort((a, b) => b.at.compareTo(a.at));
}

int totalMg(Iterable<Dose> doses) => doses.fold(0, (sum, d) => sum + d.mg);

/// The most recent local moment whose clock reads [hour]:[minute] at or before
/// [now]: today if that time has already happened, otherwise yesterday. Used to
/// turn a picked time of day into a dose time, so logging "11 pm" at 12:30 am
/// lands on the previous evening instead of in the future.
DateTime lastOccurrence(int hour, int minute, DateTime now) {
  final local = now.toLocal();
  final today = DateTime(local.year, local.month, local.day, hour, minute);
  return today.isAfter(local)
      ? DateTime(local.year, local.month, local.day - 1, hour, minute)
      : today;
}
