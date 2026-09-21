import 'package:flutter/material.dart';

/// Background texture behind every screen.
enum BgPattern { none, dots, hatch, blueprint }

/// How the big "still active" number is drawn.
enum NumberStyle {
  /// Filled ink with a hard offset shadow.
  shadowed,

  /// Ink on a solid signal block with a hard shadow.
  highlight,

  /// Hollow letters, stroke only.
  outline,

  /// Filled in the signal colour, no shadow.
  plain,
}

/// One complete look for the app. Widgets read colours and switches from here
/// (`context.cs`) and never hard-code either, so a new look is a new instance.
///
/// The roles keep their meaning in every theme: [signal] is the liquid, the
/// chart bars and the selected state; [alert] is the same thing past the
/// reference limit; [ink] is text and borders on [ground].
class CsTheme {
  const CsTheme({
    required this.id,
    required this.name,
    required this.blurb,
    required this.brightness,
    required this.ground,
    required this.mugInner,
    required this.ink,
    required this.mutedInk,
    required this.dim,
    required this.signal,
    required this.onSignal,
    required this.alert,
    required this.accentText,
    required this.shadow,
    required this.rule,
    this.liquidOverride,
    this.mugGap = 0,
    this.shadowOffset = 0,
    this.border = 2,
    this.pattern = BgPattern.none,
    this.patternColor = const Color(0x00000000),
    this.numberStyle = NumberStyle.shadowed,
    this.outlineTitle = false,
    this.accentBar = false,
    this.statPanel = false,
    this.bandHeader = false,
    this.titleBlock = false,
    this.frame = false,
    this.outlinedBars = false,
  });

  final String id;
  final String name;

  /// One dry line shown on the theme picker.
  final String blurb;
  final Brightness brightness;

  final Color ground;

  /// Inside of the mug.
  final Color mugInner;
  final Color ink;
  final Color mutedInk;
  final Color dim;
  final Color signal;

  /// Text on a [signal] fill.
  final Color onSignal;
  final Color alert;

  /// Accent that is safe to use as small text on [ground].
  final Color accentText;
  final Color shadow;

  /// Thin separators and grid lines.
  final Color rule;

  /// 0 turns hard shadows off.
  final double shadowOffset;

  /// Stroke width of borders on boxes, buttons and chips.
  final double border;

  final BgPattern pattern;
  final Color patternColor;
  final NumberStyle numberStyle;

  /// Big screen titles drawn hollow.
  final bool outlineTitle;

  /// A thick signal bar under the mug block.
  final bool accentBar;

  /// Today's total in an inverted panel.
  final bool statPanel;

  /// Header as a solid ink band across the top.
  final bool bandHeader;

  /// Drawing-office labels under the header.
  final bool titleBlock;

  /// Thin frame drawn inside the screen edge.
  final bool frame;

  /// Ink outline on chart bars (for grounds where the fills are close).
  final bool outlinedBars;

  /// Set only when the signal colour would be lost against the mug.
  final Color? liquidOverride;

  /// Empty space between the mug wall and the liquid (sides and bottom), so a
  /// dark liquid doesn't fuse with a dark wall and shadow.
  final double mugGap;

  /// The mug's liquid and the chart bars. Usually the [signal] colour; a theme
  /// can set its own when the signal colour is too close to the mug's inside.
  Color get liquid => liquidOverride ?? signal;

  bool get isLight => brightness == Brightness.light;

  /// Scrim behind modal panels.
  Color get barrier =>
      isLight ? ink.withValues(alpha: 0.5) : mugInner.withValues(alpha: 0.78);
}

abstract final class CsThemes {
  /// The original look: dark red, hard rust shadows, yellow signal.
  static const oxblood = CsTheme(
    id: 'oxblood',
    name: 'Oxblood',
    blurb: 'The default. Dark red, hard shadows, yellow liquid.',
    brightness: Brightness.dark,
    ground: Color(0xFF2A0F14),
    mugInner: Color(0xFF140609),
    ink: Color(0xFFF6EFE6),
    mutedInk: Color(0xFFD8B6AD),
    dim: Color(0xFF8F6A62),
    signal: Color(0xFFE9FF4F),
    onSignal: Color(0xFF2A0F14),
    alert: Color(0xFFFF5C1C),
    accentText: Color(0xFFE9FF4F),
    shadow: Color(0xFF8C2F1B),
    rule: Color(0xFF8C2F1B),
    shadowOffset: 4,
  );

  /// Cream and black type with one orange bar.
  static const paper = CsTheme(
    id: 'paper',
    name: 'Paper',
    blurb: 'Cream, black type, one thick orange bar.',
    brightness: Brightness.light,
    ground: Color(0xFFF5EFE6),
    mugInner: Color(0xFFF1EADC),
    ink: Color(0xFF14110F),
    mutedInk: Color(0xFF5A4E46),
    dim: Color(0xFF857468),
    signal: Color(0xFFE8460A),
    onSignal: Color(0xFF14110F),
    alert: Color(0xFF14110F),
    accentText: Color(0xFFB53F0A),
    shadow: Color(0xFF14110F),
    rule: Color(0xFF14110F),
    accentBar: true,
  );

  /// Halftone dots, a yellow highlighter, black stat panels.
  static const newsprint = CsTheme(
    id: 'newsprint',
    name: 'Newsprint',
    blurb: 'Halftone dots, a yellow highlighter, black panels.',
    brightness: Brightness.light,
    ground: Color(0xFFEFE8DA),
    mugInner: Color(0xFFFBF7EC),
    ink: Color(0xFF14110F),
    mutedInk: Color(0xFF3F372F),
    dim: Color(0xFF62574B),
    signal: Color(0xFFE9FF4F),
    onSignal: Color(0xFF14110F),
    alert: Color(0xFFE8460A),
    accentText: Color(0xFFB53F0A),
    shadow: Color(0xFF14110F),
    rule: Color(0xFF14110F),
    // Yellow on the pale mug would vanish, so the liquid is ink; the yellow
    // stays on the highlighter, the chips and the selected states.
    liquidOverride: Color(0xFF14110F),
    mugGap: 4,
    shadowOffset: 4,
    pattern: BgPattern.dots,
    patternColor: Color(0x1A14110F),
    numberStyle: NumberStyle.highlight,
    statPanel: true,
  );

  /// Yellow ground, black marks, hollow numbers.
  static const acid = CsTheme(
    id: 'acid',
    name: 'Acid',
    blurb: 'Yellow everywhere. Black marks, hollow numbers.',
    brightness: Brightness.light,
    ground: Color(0xFFE9FF4F),
    mugInner: Color(0xFFFCFFD9),
    ink: Color(0xFF14110F),
    mutedInk: Color(0xFF363A0C),
    dim: Color(0xFF565E10),
    signal: Color(0xFF14110F),
    onSignal: Color(0xFFE9FF4F),
    alert: Color(0xFFE8460A),
    accentText: Color(0xFF14110F),
    shadow: Color(0xFF14110F),
    rule: Color(0xFF14110F),
    pattern: BgPattern.hatch,
    patternColor: Color(0x1214110F),
    numberStyle: NumberStyle.outline,
    outlineTitle: true,
    bandHeader: true,
    outlinedBars: true,
  );

  /// Navy grid, thin lines, drawing-office labels.
  static const blueprint = CsTheme(
    id: 'blueprint',
    name: 'Blueprint',
    blurb: 'Navy grid, thin lines, drawing-office labels.',
    brightness: Brightness.dark,
    ground: Color(0xFF0E2236),
    mugInner: Color(0xFF09192A),
    ink: Color(0xFFEDEFE6),
    mutedInk: Color(0xFF9CC3BB),
    dim: Color(0xFF6A9A98),
    signal: Color(0xFFE9FF4F),
    onSignal: Color(0xFF0E2236),
    alert: Color(0xFFFF5C1C),
    accentText: Color(0xFFE9FF4F),
    shadow: Color(0xFF0E2236),
    rule: Color(0xFF2F6B69),
    border: 1,
    pattern: BgPattern.blueprint,
    patternColor: Color(0xFF3F8F84),
    numberStyle: NumberStyle.plain,
    outlineTitle: true,
    titleBlock: true,
    frame: true,
  );

  static const all = [oxblood, paper, newsprint, acid, blueprint];

  /// Unknown or missing ids fall back to the default rather than failing.
  static CsTheme byId(String? id) =>
      all.firstWhere((t) => t.id == id, orElse: () => oxblood);
}

/// Puts a theme in the tree. Nest one to render a preview in another theme.
class CsThemeScope extends InheritedWidget {
  const CsThemeScope({super.key, required this.theme, required super.child});

  final CsTheme theme;

  static CsTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CsThemeScope>()?.theme ??
      CsThemes.oxblood;

  @override
  bool updateShouldNotify(CsThemeScope old) => old.theme != theme;
}

extension CsThemeContext on BuildContext {
  CsTheme get cs => CsThemeScope.of(this);
}

extension CsThemeShadows on CsTheme {
  /// Hard, zero-blur text shadow; empty when the theme has no shadows.
  List<Shadow> hardTextShadow({double extra = 0}) => shadowOffset > 0
      ? [
          Shadow(
            color: shadow,
            offset: Offset(shadowOffset + extra, shadowOffset + extra),
          ),
        ]
      : const [];
}
