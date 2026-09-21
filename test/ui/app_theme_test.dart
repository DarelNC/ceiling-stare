import 'dart:math' as math;

import 'package:ceiling_stare/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final l1 = _lum(a), l2 = _lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void main() {
  test('ids are unique and byId falls back to the default', () {
    final ids = CsThemes.all.map((t) => t.id).toSet();
    expect(ids, hasLength(CsThemes.all.length));
    expect(CsThemes.all.first, CsThemes.oxblood);
    expect(CsThemes.byId('blueprint'), CsThemes.blueprint);
    expect(CsThemes.byId('nope'), CsThemes.oxblood);
    expect(CsThemes.byId(null), CsThemes.oxblood);
  });

  for (final t in CsThemes.all) {
    group('${t.name} contrast', () {
      test('text on the ground is readable', () {
        expect(
          contrast(t.ink, t.ground),
          greaterThanOrEqualTo(7),
          reason: 'ink',
        );
        expect(
          contrast(t.mutedInk, t.ground),
          greaterThanOrEqualTo(4.5),
          reason: 'mutedInk',
        );
        expect(
          contrast(t.accentText, t.ground),
          greaterThanOrEqualTo(4.5),
          reason: 'accentText',
        );
        expect(
          contrast(t.dim, t.ground),
          greaterThanOrEqualTo(3),
          reason: 'dim',
        );
      });

      test('text on a signal fill is readable', () {
        expect(contrast(t.onSignal, t.signal), greaterThanOrEqualTo(4.5));
      });

      test('the liquid shows against the inside of the mug', () {
        expect(
          contrast(t.signal, t.mugInner),
          greaterThanOrEqualTo(3),
          reason: 'signal',
        );
        expect(
          contrast(t.alert, t.mugInner),
          greaterThanOrEqualTo(3),
          reason: 'alert',
        );
      });

      test('normal and over-limit liquid can be told apart', () {
        expect(t.signal == t.alert, isFalse);
        expect(contrast(t.signal, t.alert), greaterThanOrEqualTo(1.5));
      });

      test('chart bars show against the ground (or are outlined)', () {
        if (!t.outlinedBars) {
          expect(
            contrast(t.signal, t.ground),
            greaterThanOrEqualTo(3),
            reason: 'signal',
          );
          expect(
            contrast(t.alert, t.ground),
            greaterThanOrEqualTo(3),
            reason: 'alert',
          );
        }
      });

      test('inverted stat panel text is readable', () {
        // Used when statPanel is on: ink panel, ground text, signal label.
        expect(contrast(t.ground, t.ink), greaterThanOrEqualTo(7));
        if (t.statPanel) {
          expect(contrast(t.signal, t.ink), greaterThanOrEqualTo(4.5));
        }
      });
    });
  }
}
