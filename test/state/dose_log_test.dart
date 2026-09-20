import 'package:flutter_test/flutter_test.dart';
import 'package:wired/data/dose.dart';
import 'package:wired/state/dose_log.dart';

import '../support/in_memory_repository.dart';

Dose dose(int mg, DateTime at) =>
    Dose.create(source: DoseSource.coffee, mg: mg, at: at);

void main() {
  final t0 = DateTime(2026, 9, 20, 12);

  test('load reads the store and notifies', () async {
    final d = dose(95, t0);
    final log = DoseLog(InMemoryDoseRepository([d]), () => t0);
    var notified = 0;
    log.addListener(() => notified++);

    await log.load();
    expect(log.doses, [d]);
    expect(log.error, isNull);
    expect(notified, 1);
  });

  test('add and remove go through the store and refresh', () async {
    final repo = InMemoryDoseRepository();
    final log = DoseLog(repo, () => t0);
    final d = dose(95, t0);

    expect(await log.add(d), isTrue);
    expect(log.doses, [d]);
    expect(await log.remove(d), isTrue);
    expect(log.doses, isEmpty);
    expect(await repo.all(), isEmpty);
  });

  test('now follows the clock on load and tick', () async {
    var current = t0;
    final log = DoseLog(InMemoryDoseRepository(), () => current);
    expect(log.now, t0);

    current = t0.add(const Duration(minutes: 5));
    log.tick();
    expect(log.now, current);

    current = t0.add(const Duration(hours: 9));
    await log.load();
    expect(log.now, current);
  });

  test(
    'an unreadable store sets error and add/remove report failure',
    () async {
      final log = DoseLog(UnreadableDoseRepository(), () => t0);
      await log.load();
      expect(log.error, isA<FormatException>());
      expect(await log.add(dose(95, t0)), isFalse);
      expect(await log.remove(dose(95, t0)), isFalse);
      expect(log.doses, isEmpty);
    },
  );

  test('a later good load clears the error', () async {
    final repo = _Flaky();
    final log = DoseLog(repo, () => t0);
    await log.load();
    expect(log.error, isNotNull);
    repo.broken = false;
    await log.load();
    expect(log.error, isNull);
  });

  test('work that finishes after dispose is ignored, not thrown', () async {
    final log = DoseLog(InMemoryDoseRepository(), () => t0);
    final pending = log.add(dose(95, t0));
    log.dispose();
    await pending; // must not throw "used after being disposed"
  });
}

class _Flaky extends InMemoryDoseRepository {
  bool broken = true;

  @override
  Future<List<Dose>> all() async =>
      broken ? throw const FormatException('bad') : super.all();
}
