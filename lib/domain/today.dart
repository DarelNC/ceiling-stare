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
