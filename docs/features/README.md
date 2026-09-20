# Features

One file per feature, created when that feature is actually decided:
`features/<name>.md`, plus a line here. Scope rules are in
[../rules.md](../rules.md).

## Built

- [dose-model.md](dose-model.md) — `Dose` model and local storage behind a
  `DoseRepository`. No UI yet.

`lib/main.dart` is still a placeholder screen that proves the palette and fonts
load; it is not a feature.

## Backlog, in order

Carried over from the untracked `next-steps.md`. Each item is a decision to make
explicitly when it's reached, not a commitment.

**First real feature**

1. ~~**Data model for a logged dose.**~~ **Done**, see
   [dose-model.md](dose-model.md). Still open, and moved to item 3: do curated
   drink presets (known mg values) ship in v1? That decides how much is content
   work versus a pure number-entry app. Presets must be bundled local data, not
   fetched (see [../architecture.md](../architecture.md)).
2. **Caffeine remaining / half-life math.** The one real piece of domain logic.
   Standard half-life is about 5 hours; open whether it is hardcoded or
   adjustable. Written as a pure function and tested first, per
   [../architecture.md](../architecture.md) and [../stack.md](../stack.md).
3. **The core screen.** Fast log entry (few taps), today's total, and a live
   "how much is still active" readout. Two open calls live here: whether drink
   presets ship (carried from item 1; "few taps" is the deciding requirement),
   and whether the `caffeinated` mug metaphor is reused, which needs its own
   reason; see the reuse check in [../design.md](../design.md).

**Soon after**

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
