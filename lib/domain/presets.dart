import '../data/dose.dart';

/// A one-tap drink. Only a template: logging one produces a plain [Dose]
/// with the mg copied in, so editing this list never rewrites history.
class Preset {
  const Preset(this.name, this.source, this.mg, this.serving);

  final String name;
  final DoseSource source;
  final int mg;
  final String serving;
}

/// Typical published figures for one serving, not measurements. Brands,
/// beans, brew time and cup size all move these. Bundled, never fetched.
/// See docs/features/core-screen.md.
const presets = [
  Preset('Espresso', DoseSource.coffee, 63, '1 shot'),
  Preset('Coffee', DoseSource.coffee, 95, '240 ml'),
  Preset('Black tea', DoseSource.tea, 47, '240 ml'),
  Preset('Green tea', DoseSource.tea, 28, '240 ml'),
  Preset('Energy drink', DoseSource.energyDrink, 80, '250 ml can'),
];

/// Ceiling for a hand-entered dose. Anything above is almost certainly a
/// typo (an extra zero), and a wrong number here skews everything after it.
const maxDoseMg = 1000;
