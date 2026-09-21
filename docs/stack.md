# Stack

## Framework: Flutter, one codebase, Android + iOS

The library rule is to fit the framework to the deployment shape. Here that is
one on-device app with no backend, so a single cross-platform codebase is
right-sized. Cross-platform is the point of this project, unlike `caffeinated`,
which is Android-only because a background wake lock has no iOS equivalent. A
tracker has no such dependency.

Created with `flutter create --platforms=android,ios`, so there are no
desktop/web targets to prune. SDK constraint in `pubspec.yaml`: `^3.12.0`.

## Language: Dart

Typed, so the library's mitigation for untyped languages doesn't apply. The one
place an untyped assumption could creep in later is parsing data from
HealthKit/Health Connect. If that lands, keep that parsing small, isolated and
tested.

## Storage: `shared_preferences`, whole log as one JSON string

Decided 2026-09-20 with the dose model; full reasoning and the adversarial pass
are in [features/dose-model.md](features/dose-model.md). The rule is to start as
simple as current load requires. A single user's dose log is a few hundred KB at
most over years, and v1 needs only load-all, add, remove. Uses
`SharedPreferencesAsync` (first-party, `flutter.dev`) behind `DoseRepository`,
so the decay math and UI never see it. `shared_preferences_platform_interface`
is a dev dependency, only for the in-memory test helper.

**Not chosen:** SQLite (`sqflite`/`drift`), a native dependency plus schema and
migrations for queries v1 doesn't make.

**Tripwire:** revisit before the first public release (a swap after that means
migrating real users' logs), and if the history view needs queries that
in-memory filtering can't do cheaply.

## Testing

Highest-value target: the caffeine-remaining math, since it is pure and
source-agnostic ([architecture.md](architecture.md)). Written test first, with
independently hand-computed expected values. Also covered: the model and
repository (including corrupt data and concurrent writes), the today/preset
and history logic, the shared `DoseLog`, and the screens through widget
tests with an in-memory repository (`test/support/`). Widget tests use a fixed
clock injected into `CeilingStareApp`.

**Verification:** `flutter analyze` and `flutter test` are clean, and the
app was built (`flutter build ios --simulator --debug`) and exercised on the
iPhone 17 Pro simulator on 2026-09-20: logging, Other, remove and undo,
persistence across relaunch, and the over-limit state all behaved.
**Gap:** never run on Android (no emulator or SDK used yet), and never on a
physical device.

## Fonts: bundled locally

Archivo Black, Major Mono Display, DM Serif Display Italic and Space Grotesk
(variable) are committed under `assets/fonts/` with their OFL texts and declared
in `pubspec.yaml`. No runtime fetch from Google Fonts. v1 is offline by design,
so a font that can fail to load over the network would be a new failure mode for
no benefit. Same call as `caffeinated`.

## License and branch

- **MIT** unless there's a specific reason otherwise. No reason has come up.
  **Gap:** the project has no `LICENSE` file. `caffeinated/LICENSE` is the
  template (MIT, 2026, DarelNC).
- **Default branch is `master`.** Current branch is `master`. Remote:
  `git@github.com:DarelNC/ceiling-stare.git`, first pushed 2026-09-21.
