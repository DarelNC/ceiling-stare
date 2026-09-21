import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:ceiling_stare/data/dose.dart';
import 'package:ceiling_stare/data/dose_repository.dart';

Dose dose(int mg, DateTime at, [DoseSource s = DoseSource.coffee]) =>
    Dose.create(source: s, mg: mg, at: at);

void main() {
  late PrefsDoseRepository repo;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    repo = PrefsDoseRepository();
  });

  test('empty store gives an empty list', () async {
    expect(await repo.all(), isEmpty);
  });

  test('add then all returns the dose, oldest first', () async {
    final late = dose(80, DateTime.utc(2026, 9, 20, 15));
    final early = dose(95, DateTime.utc(2026, 9, 20, 8));
    await repo.add(late);
    await repo.add(early);
    expect(await repo.all(), [early, late]);
  });

  test('a second repository instance sees persisted doses', () async {
    final d = dose(95, DateTime.utc(2026, 9, 20, 8));
    await repo.add(d);
    expect(await PrefsDoseRepository().all(), [d]);
  });

  test('remove deletes by id and ignores unknown ids', () async {
    final a = dose(95, DateTime.utc(2026, 9, 20, 8));
    final b = dose(47, DateTime.utc(2026, 9, 20, 10), DoseSource.tea);
    await repo.add(a);
    await repo.add(b);
    await repo.remove(a.id);
    await repo.remove('nope');
    expect(await repo.all(), [b]);
  });

  test('duplicate id is rejected and leaves the log intact', () async {
    final a = dose(95, DateTime.utc(2026, 9, 20, 8));
    await repo.add(a);
    await expectLater(repo.add(a), throwsArgumentError);
    expect(await repo.all(), [a]);
  });

  test('concurrent adds are all kept', () async {
    final doses = [
      for (var i = 0; i < 25; i++)
        dose(50 + i, DateTime.utc(2026, 9, 20, 8, i)),
    ];
    await Future.wait(doses.map(repo.add));
    expect(await repo.all(), doses);
  });

  test('corrupt data throws instead of reading as empty', () async {
    await SharedPreferencesAsync().setString(
      PrefsDoseRepository.key,
      '{not json',
    );
    await expectLater(repo.all(), throwsFormatException);
  });

  test('corrupt data is not overwritten by a later add', () async {
    const junk = '[{"id":"a","source":"coffee","mg":-1,"at":0}]';
    await SharedPreferencesAsync().setString(PrefsDoseRepository.key, junk);
    await expectLater(
      repo.add(dose(80, DateTime.utc(2026, 9, 20))),
      throwsFormatException,
    );
    expect(
      await SharedPreferencesAsync().getString(PrefsDoseRepository.key),
      junk,
    );
  });

  test('a failed operation does not block the ones after it', () async {
    final a = dose(95, DateTime.utc(2026, 9, 20, 8));
    await repo.add(a);
    await expectLater(repo.add(a), throwsArgumentError);
    final b = dose(47, DateTime.utc(2026, 9, 20, 9), DoseSource.tea);
    await repo.add(b);
    expect(await repo.all(), [a, b]);
  });
}
