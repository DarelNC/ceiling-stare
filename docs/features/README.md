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
  readouts, one-tap presets, Other, undo on every log.
- [history.md](history.md) — the menu, and a history screen: 14-day trend strip
  plus every dose grouped by day, with removal. Today's log moved here from home.
- [themes.md](themes.md): five looks (Oxblood, Paper, Newsprint, Acid,
  Blueprint) chosen from menu entry 02, each previewed with the real widgets.
- [backdating.md](backdating.md) — log a dose at an earlier time: −30 MIN, −1 H,
  −2 H chips or a picked time of day.

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

- **Verify preset values** against a cited source, and decide whether the log
  should remember the drink name (model change).
4. ~~History view~~ **Done**, see [history.md](history.md).
- **Personal caffeine cap from an onboarding profile** (height, weight, gender,
  age) in place of the fixed 400 mg reference. Not started. Needs a decision
  entry in [../product.md](../product.md) first: which inputs a cited source
  says matter, under-18 handling, how it changes the mug scale and the
  over-limit colour, and wording that reads as a reference, not medical advice.
  The data would stay on the device.
- **Show the caffeine drop over time.** The decay already exists (5 hour
  half-life, about 9 mg per 20 minutes at 200 mg active). Undecided whether to
  show the rate and a "clear by" time, tick the number more often, or change the
  formula.
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
- **Final bundle ID** (`com.example.ceilingstare` placeholder, needs a real
  reverse-domain) and the remaining name checks. See
  [../product.md](../product.md).

## Cut list

- **Accounts, cloud sync, any backend — out of v1.** Reason in
  [../product.md](../product.md).
- **Nothing ported from a predecessor**, so there is no inherited-feature cut
  list yet. Add entries here when an idea is considered and deliberately
  dropped, so it isn't silently re-litigated.
