import 'package:ceiling_stare/ui/tokens.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('readouts use Space Grotesk with tabular figures', () {
    final style = Tokens.readout();
    expect(style.fontFamily, Tokens.spaceGrotesk);
    expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  test('readout size, weight, colour and spacing pass through', () {
    final style = Tokens.readout(
      size: 11,
      weight: FontWeight.w700,
      color: const Color(0xFF123456),
      letterSpacing: 2,
      height: 1.2,
    );
    expect(style.fontSize, 11);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.color, const Color(0xFF123456));
    expect(style.letterSpacing, 2);
    expect(style.height, 1.2);
  });
}
