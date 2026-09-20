# Features

One file per feature, created when that feature is actually decided:
`features/<name>.md`, plus a line here. Scope rules are in
[../rules.md](../rules.md).

## Built

- [dose-model.md](dose-model.md) — `Dose` model and local storage behind a
  `DoseRepository`.
- [decay-math.md](decay-math.md) — `remainingMg`: estimated caffeine still
  active, a pure function over doses.
- [core-screen.md](core-screen.md) — the single screen: mug, active and today
  readouts, one-tap presets, Other, today's log with undo.

## Backlog, in order

Carried over from the untracked `next-steps.md`. Each item is a decision to make
explicitly when it's reached, not a commitment.

**First real feature**

1. ~~**Data model for a logged dose.**~~ **Done**, see
   [dose-model.md](dose-model.md). The presets question it raised was settled in
   item 3.
2. ~~**Caffeine remaining / half-life math.**~~ **Done**, see
   [decay-math.md](decay-math.md). Half-life is a parameter defaulting to 5
   hours; no user-facing setting decided.
3. ~~**The core screen.**~~ **Done**, see [core-screen.md](core-screen.md).
   Presets shipped (five, typical values, need a cited source before release)
   and the mug metaphor was reused and kept.

**Soon after**

- **Log with a time (backdating).** Every log is "now" today. Likely the first
  real usability gap. Needs a time control on the log action without costing
  the one-tap path.
- **Verify preset values** against a cited source, and decide whether the log
  should remember the drink name (model change).
4. Daily/weekly history view: trend over time, not just today.
5. Safe-to-sleep nudge from remaining level against a bedtime. Wording is a
   product decision; see health-claim framing in [../product.md](../product.md).
6. Local notifications ("near your limit", "safe to sleep now"). First real
   platform-permission decision (Android `POST_NOTIFICATIONS`, iOS permission
   prompt).

## Deferred: real decisions, not started

- **Health Connect / HealthKit sync.** Deferred, not rejected. Needs an explicit
  decision entry in [../product.md](../product.md).
- **Home-screen widget** showing current caffeine level. Mentioned once,
  undecided. If built, `caffeinated`'s widget decisions (status-only, no live
  ticking countdown for battery) are a reference, not a default.
- **Real naming pass and bundle ID** (`com.example.wired` placeholder). See
  [../product.md](../product.md).

## Cut list

- **Accounts, cloud sync, any backend — out of v1.** Reason in
  [../product.md](../product.md).
- **Nothing ported from a predecessor**, so there is no inherited-feature cut
  list yet. Add entries here when an idea is considered and deliberately
  dropped, so it isn't silently re-litigated.
