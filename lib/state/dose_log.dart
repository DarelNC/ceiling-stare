import 'package:flutter/foundation.dart';

import '../data/dose.dart';
import '../data/dose_repository.dart';

/// The one in-memory copy of the dose log that every screen reads. Screens
/// listen to it; nothing else holds doses. Writes go to the repository first
/// and the list is re-read afterwards, so what's on screen is always what's
/// stored.
class DoseLog extends ChangeNotifier {
  DoseLog(this._repository, this._clock) : _now = _clock();

  final DoseRepository _repository;
  final DateTime Function() _clock;

  List<Dose> _doses = const [];
  Object? _error;
  DateTime _now;
  bool _disposed = false;

  List<Dose> get doses => _doses;

  /// Non-null when the stored data couldn't be read or written. While set the
  /// screens stop offering to log, so bad data is never overwritten.
  Object? get error => _error;

  /// The clock as of the last load or tick. Screens use this rather than
  /// calling the clock in `build`, so "today" changes only when we say so.
  DateTime get now => _now;

  DateTime clock() => _clock();

  Future<void> load() async {
    try {
      _doses = await _repository.all();
      _error = null;
    } catch (e) {
      _error = e;
    }
    _now = _clock();
    notifyListeners();
  }

  void tick() {
    _now = _clock();
    notifyListeners();
  }

  /// True if it was stored.
  Future<bool> add(Dose dose) => _write(() => _repository.add(dose));

  Future<bool> remove(Dose dose) => _write(() => _repository.remove(dose.id));

  Future<bool> _write(Future<void> Function() op) async {
    try {
      await op();
    } catch (e) {
      _error = e;
      notifyListeners();
      return false;
    }
    await load();
    return _error == null;
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
