# Architecture

## Shape

One Flutter app, on-device only. No backend, no network calls, no third-party
API. State is the user's own dose log, held locally. One deployable per
platform, built from one codebase.

## Rules from the workspace library that are dormant

`rules/architecture.md` is about upstream dependencies. None exist here, so
these don't engage today:

- Never call a third-party API from the client.
- Prefer documented APIs over undocumented ones.
- Design for upstream failover.
- Match hosting to the upstream's shape / hard connection caps.
- Be honest when a fallback isn't equivalent.

**What would wake them up:** any network data source. The obvious candidate is a
drink database API for caffeine-per-serving values. v1 avoids it by shipping
any presets as bundled local data (see [features/README.md](features/README.md),
item 1). Adding a network source would mean a backend in front of it, which
also contradicts the local-only stance in [product.md](product.md). That's a
decision-lane change, not an implementation detail.

Health Connect (Android) and HealthKit (iOS) are local OS APIs, not third-party
network dependencies, so the client-call rule doesn't apply to them either. They
are deferred for product reasons, not architectural ones.

## The one rule that engages: keep the logic separate from the data source

The caffeine-remaining calculation is the only real domain logic in the app. It
should be a pure function: doses and a point in time in, remaining caffeine out.
No storage, UI, or platform imports, and no knowledge of where a dose came from.

- **Why it matters here:** testable without a device or mocks (see
  [stack.md](stack.md); this is the first thing worth a real test suite), and
  a later HealthKit/Health Connect import or a different local store feeds the
  same function instead of forcing a rewrite.
- **Built:** `remainingMg` in `lib/domain/caffeine.dart` follows this seam. It
  takes `Iterable<Dose>` and a `now`, imports only the `Dose` data class, and
  never touches the repository. Half-life is a parameter with a 5-hour default;
  see [features/decay-math.md](features/decay-math.md).
- **Screens read one shared `DoseLog`** (`lib/state/dose_log.dart`), a
  `ChangeNotifier` over the repository. Screens never hold their own copy of
  the log or talk to the repository directly, and the pure functions in
  `lib/domain/` (decay, today, history) take plain `Dose` lists from it. See
  [features/history.md](features/history.md).
- **Colours and switches come from a theme, not from widgets.** `CsTheme`
  (`lib/ui/app_theme.dart`) is read with `context.cs`; the chosen id is kept by
  `ThemeController`, separate from the dose log. See
  [features/themes.md](features/themes.md).
