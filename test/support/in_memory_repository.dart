import 'package:ceiling_stare/data/dose.dart';
import 'package:ceiling_stare/data/dose_repository.dart';
import 'package:ceiling_stare/state/theme_controller.dart';

class InMemoryDoseRepository implements DoseRepository {
  InMemoryDoseRepository([Iterable<Dose> initial = const []])
    : _doses = [...initial];

  final List<Dose> _doses;

  @override
  Future<List<Dose>> all() async =>
      [..._doses]..sort((a, b) => a.at.compareTo(b.at));

  @override
  Future<void> add(Dose dose) async => _doses.add(dose);

  @override
  Future<void> remove(String id) async => _doses.removeWhere((d) => d.id == id);
}

/// Simulates a store whose data can't be read.
class UnreadableDoseRepository implements DoseRepository {
  @override
  Future<List<Dose>> all() async => throw const FormatException('bad data');

  @override
  Future<void> add(Dose dose) async => throw const FormatException('bad data');

  @override
  Future<void> remove(String id) async =>
      throw const FormatException('bad data');
}

/// Keeps the chosen theme id in memory. Set [failWrites] to simulate a store
/// that can't be written.
class InMemoryThemeStore implements ThemeStore {
  InMemoryThemeStore([this.saved]);

  String? saved;
  bool failWrites = false;

  @override
  Future<String?> read() async => saved;

  @override
  Future<void> write(String id) async {
    if (failWrites) throw StateError('disk full');
    saved = id;
  }
}
