import 'package:flutter_test/flutter_test.dart';
import 'package:ceiling_stare/data/dose.dart';

void main() {
  final at = DateTime.utc(2026, 9, 20, 8, 30);

  test('json round-trips', () {
    final d = Dose.create(source: DoseSource.coffee, mg: 95, at: at);
    expect(Dose.fromJson(d.toJson()), d);
  });

  test('stores time as UTC regardless of input zone', () {
    final local = DateTime(2026, 9, 20, 8, 30);
    final d = Dose.create(source: DoseSource.tea, mg: 47, at: local);
    expect(d.at.isUtc, isTrue);
    expect(d.at, local.toUtc());
  });

  test('create yields distinct ids for the same instant', () {
    final ids = {
      for (var i = 0; i < 200; i++)
        Dose.create(source: DoseSource.coffee, mg: 80, at: at).id,
    };
    expect(ids.length, 200);
  });

  group('fromJson rejects malformed input', () {
    final good = {'id': 'a', 'source': 'coffee', 'mg': 80, 'at': 0};
    for (final entry in {
      'not an object': 'x',
      'missing id': {...good}..remove('id'),
      'empty id': {...good, 'id': ''},
      'zero mg': {...good, 'mg': 0},
      'negative mg': {...good, 'mg': -5},
      'fractional mg': {...good, 'mg': 80.5},
      'string mg': {...good, 'mg': '80'},
      'unknown source': {...good, 'source': 'cola'},
      'missing at': {...good}..remove('at'),
    }.entries) {
      test(entry.key, () {
        expect(() => Dose.fromJson(entry.value), throwsFormatException);
      });
    }

    test('the good baseline parses', () {
      expect(Dose.fromJson(good).mg, 80);
    });
  });
}
