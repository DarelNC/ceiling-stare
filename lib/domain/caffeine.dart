import 'dart:math';

import '../data/dose.dart';

/// Population-average caffeine half-life. Individuals vary widely (roughly
/// 2 to 10 hours), so anything built on this is an estimate.
const defaultHalfLife = Duration(hours: 5);

/// Estimated caffeine (mg) still active at [now]: each dose decays
/// exponentially from the moment it was taken, and the results are summed.
///
/// Deliberately simple: the whole dose counts immediately (no absorption
/// ramp), so the figure runs slightly high in the first ~hour after a drink.
/// A dose timestamped after [now] hasn't happened yet and counts as 0.
///
/// Pure: knows nothing about storage, UI, or where the doses came from.
/// See docs/features/decay-math.md.
double remainingMg(
  Iterable<Dose> doses,
  DateTime now, {
  Duration halfLife = defaultHalfLife,
}) {
  if (halfLife <= Duration.zero) {
    throw ArgumentError.value(halfLife, 'halfLife', 'must be positive');
  }
  var total = 0.0;
  for (final dose in doses) {
    final elapsed = now.difference(dose.at);
    if (elapsed.isNegative) continue;
    total +=
        dose.mg * pow(0.5, elapsed.inMicroseconds / halfLife.inMicroseconds);
  }
  return total;
}
