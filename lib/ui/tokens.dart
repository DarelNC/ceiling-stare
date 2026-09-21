import 'package:flutter/painting.dart';

/// Font family names, as declared in pubspec.yaml. Colours live in the theme
/// (`context.cs`, see app_theme.dart).
class Tokens {
  static const archivoBlack = 'Archivo Black';
  static const dmSerifItalic = 'DM Serif Display Italic';
  static const spaceGrotesk = 'Space Grotesk';

  /// Small numbers that have to line up: times, amounts, scale marks. Space
  /// Grotesk digits are proportional by default (a 1 is much narrower than a 0),
  /// so this turns on tabular figures.
  static TextStyle readout({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0,
    double? height,
  }) => TextStyle(
    fontFamily: spaceGrotesk,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
