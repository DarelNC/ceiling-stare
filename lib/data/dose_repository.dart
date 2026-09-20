import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'dose.dart';

/// Where doses live. Callers (and the decay math) never see the store behind
/// it, so it can be swapped without touching them. See docs/architecture.md.
abstract class DoseRepository {
  /// All doses, oldest first. Throws [FormatException] if stored data is
  /// unreadable rather than returning a partial or empty list.
  Future<List<Dose>> all();

  Future<void> add(Dose dose);

  /// No-op if [id] isn't present.
  Future<void> remove(String id);
}

/// Whole log as one JSON string under [key]. Adequate for a single user
/// logging a handful of doses a day; see docs/stack.md for when to revisit.
class PrefsDoseRepository implements DoseRepository {
  PrefsDoseRepository([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const key = 'doses_v1';

  final SharedPreferencesAsync _prefs;

  // add/remove are read-modify-write; chain them so two quick taps can't
  // both read the old list and drop one of the writes.
  Future<void> _tail = Future.value();

  Future<T> _serialized<T>(Future<T> Function() op) {
    final result = _tail.then((_) => op());
    _tail = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  @override
  Future<List<Dose>> all() => _serialized(_read);

  @override
  Future<void> add(Dose dose) => _serialized(() async {
    final doses = await _read();
    if (doses.any((d) => d.id == dose.id)) {
      throw ArgumentError('duplicate dose id: ${dose.id}');
    }
    await _write([...doses, dose]);
  });

  @override
  Future<void> remove(String id) => _serialized(() async {
    final doses = await _read();
    await _write(doses.where((d) => d.id != id).toList());
  });

  Future<List<Dose>> _read() async {
    final raw = await _prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('dose log is not a list');
    return decoded.map(Dose.fromJson).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
  }

  Future<void> _write(List<Dose> doses) {
    doses.sort((a, b) => a.at.compareTo(b.at));
    return _prefs.setString(
      key,
      jsonEncode(doses.map((d) => d.toJson()).toList()),
    );
  }
}
