import 'package:ceiling_stare/data/dose.dart';
import 'package:ceiling_stare/data/dose_repository.dart';

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
