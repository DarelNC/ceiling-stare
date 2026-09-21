import 'package:ceiling_stare/state/theme_controller.dart';
import 'package:ceiling_stare/ui/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../support/in_memory_repository.dart';

void main() {
  test('starts on the default when nothing is saved', () async {
    final c = await ThemeController.load(InMemoryThemeStore());
    expect(c.theme, CsThemes.oxblood);
  });

  test('starts on the saved theme', () async {
    final c = await ThemeController.load(InMemoryThemeStore('newsprint'));
    expect(c.theme, CsThemes.newsprint);
  });

  test('ids of removed themes fall back to the default', () async {
    for (final id in ['paper', 'acid']) {
      final c = await ThemeController.load(InMemoryThemeStore(id));
      expect(c.theme, CsThemes.oxblood, reason: id);
    }
  });

  test('an unknown saved id falls back to the default', () async {
    final c = await ThemeController.load(InMemoryThemeStore('hologram'));
    expect(c.theme, CsThemes.oxblood);
  });

  test('select changes the theme, notifies, and saves', () async {
    final store = InMemoryThemeStore();
    final c = await ThemeController.load(store);
    var notified = 0;
    c.addListener(() => notified++);

    await c.select(CsThemes.blueprint);
    expect(c.theme, CsThemes.blueprint);
    expect(notified, 1);
    expect(store.saved, 'blueprint');
  });

  test('selecting the current theme does nothing', () async {
    final store = InMemoryThemeStore('newsprint');
    final c = await ThemeController.load(store);
    var notified = 0;
    c.addListener(() => notified++);
    await c.select(CsThemes.newsprint);
    expect(notified, 0);
  });

  test('a failed save keeps the choice for this session', () async {
    final store = InMemoryThemeStore()..failWrites = true;
    final c = await ThemeController.load(store);
    await c.select(CsThemes.newsprint);
    expect(c.theme, CsThemes.newsprint);
  });

  test('a save that finishes after dispose is ignored', () async {
    final c = await ThemeController.load(InMemoryThemeStore());
    final pending = c.select(CsThemes.blueprint);
    c.dispose();
    await pending;
  });

  group('PrefsThemeStore', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('round-trips through shared preferences', () async {
      final store = PrefsThemeStore();
      expect(await store.read(), isNull);
      await store.write('newsprint');
      expect(await PrefsThemeStore().read(), 'newsprint');
    });

    test('stores under its own key', () async {
      await PrefsThemeStore().write('blueprint');
      expect(
        await SharedPreferencesAsync().getString(PrefsThemeStore.key),
        'blueprint',
      );
    });
  });
}
