import 'dart:math';

enum DoseSource { coffee, tea, energyDrink, custom }

/// One logged serving of caffeine. Deliberately knows nothing about presets:
/// `mg` is stored as entered, so a later change to a preset's value never
/// rewrites history. See docs/features/dose-model.md.
class Dose {
  Dose({
    required this.id,
    required this.source,
    required this.mg,
    required DateTime at,
  }) : at = at.toUtc(),
       assert(mg > 0, 'mg must be positive');

  /// New dose with a fresh id.
  factory Dose.create({
    required DoseSource source,
    required int mg,
    required DateTime at,
  }) {
    final suffix = Random().nextInt(1 << 32).toRadixString(36);
    return Dose(
      id: '${at.microsecondsSinceEpoch.toRadixString(36)}-$suffix',
      source: source,
      mg: mg,
      at: at,
    );
  }

  /// Throws [FormatException] on anything malformed. Never guesses: a dose
  /// silently repaired into a wrong number is worse than a loud failure.
  factory Dose.fromJson(Object? json) {
    if (json is! Map) throw FormatException('dose is not an object: $json');
    final id = json['id'];
    final source = json['source'];
    final mg = json['mg'];
    final at = json['at'];
    if (id is! String || id.isEmpty) throw FormatException('bad id: $id');
    if (mg is! int || mg <= 0) throw FormatException('bad mg: $mg');
    if (at is! int) throw FormatException('bad at: $at');
    final parsed = DoseSource.values.where((s) => s.name == source);
    if (parsed.isEmpty) throw FormatException('bad source: $source');
    return Dose(
      id: id,
      source: parsed.first,
      mg: mg,
      at: DateTime.fromMillisecondsSinceEpoch(at, isUtc: true),
    );
  }

  final String id;
  final DoseSource source;
  final int mg;

  /// Always UTC. Convert with `.toLocal()` for display; "today" is computed
  /// against the device's current local day, not stored.
  final DateTime at;

  Map<String, Object> toJson() => {
    'id': id,
    'source': source.name,
    'mg': mg,
    'at': at.millisecondsSinceEpoch,
  };

  @override
  bool operator ==(Object other) =>
      other is Dose &&
      other.id == id &&
      other.source == source &&
      other.mg == mg &&
      other.at == at;

  @override
  int get hashCode => Object.hash(id, source, mg, at);

  @override
  String toString() => 'Dose($id, ${source.name}, ${mg}mg, $at)';
}
