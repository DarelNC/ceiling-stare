import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/app_theme.dart';

/// Where the chosen theme id is kept.
abstract class ThemeStore {
  Future<String?> read();
  Future<void> write(String id);
}

class PrefsThemeStore implements ThemeStore {
  PrefsThemeStore([this._injected]);

  static const key = 'theme_v1';

  final SharedPreferencesAsync? _injected;

  // Created on first use, so building the store needs no platform plugin.
  late final SharedPreferencesAsync _prefs =
      _injected ?? SharedPreferencesAsync();

  @override
  Future<String?> read() => _prefs.getString(key);

  @override
  Future<void> write(String id) => _prefs.setString(key, id);
}

/// The current look. Cosmetic only: a store that can't be read means the
/// default theme, and one that can't be written means the choice lasts until
/// the app closes. Neither is an error worth showing.
class ThemeController extends ChangeNotifier {
  ThemeController(this._store, [this._theme = CsThemes.oxblood]);

  /// Reads the saved choice before the first frame, so the app never flashes
  /// the default on the way to a saved theme.
  static Future<ThemeController> load(ThemeStore store) async {
    String? id;
    try {
      id = await store.read();
    } catch (_) {}
    return ThemeController(store, CsThemes.byId(id));
  }

  final ThemeStore _store;
  CsTheme _theme;
  bool _disposed = false;

  CsTheme get theme => _theme;

  Future<void> select(CsTheme theme) async {
    if (theme == _theme) return;
    _theme = theme;
    notifyListeners();
    try {
      await _store.write(theme.id);
    } catch (_) {}
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
