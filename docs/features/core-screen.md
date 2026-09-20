# Core screen

Backlog item 3. Status: **built** (2026-09-20), verified on the iOS simulator.
Code in `lib/ui/`, `lib/domain/today.dart`, `lib/domain/presets.dart`.

## What it does

One screen. Top: a mug whose liquid is the caffeine still active, with the
number beside it and a caption saying it's an estimate. Then today's total and
drink count. Then six buttons: five presets and Other. Tapping a preset logs it
at the current time in one tap. Other opens a sheet for a whole-mg entry
(1 to 1000). Below, today's log, newest first, each row removable with an undo
bar. The estimate refreshes every 30 seconds and on returning to the foreground.

## Decisions

### Presets ship (decided with the user, 2026-09-20)

"Few taps to log" is the core requirement, and number-entry-only fails it. Five
presets, bundled in `lib/domain/presets.dart`, never fetched:

| Preset | mg | Serving |
|---|---|---|
| Espresso | 63 | 1 shot |
| Coffee | 95 | 240 ml |
| Black tea | 47 | 240 ml |
| Green tea | 28 | 240 ml |
| Energy drink | 80 | 250 ml can |

**These are typical published figures, recalled from commonly cited sources
(Mayo Clinic / USDA style tables), not re-verified against them in this
session.** Real values vary a lot with brand, bean, brew and cup size. The
screen says so ("Typical amounts. Other takes the real number."). Verify them
against a cited source before any public release.

A preset is a template. Logging one copies `mg` into a plain `Dose`, so editing
the list never rewrites history ([dose-model.md](dose-model.md)).

### The mug is reused, with its own reason

Full reasoning in [../design.md](../design.md). Liquid height is
`activeMg / 400`, clamped; past 400 it stays full and turns the alert colour.

### 400 mg is the mug's full scale, not advice

`referenceLimitMg = 400` is the commonly cited daily ceiling for healthy adults.
It is used only as the full-scale mark. Using an *active* amount against a
*daily intake* figure is a heuristic, not an identity: active caffeine above 400
mg implies more than 400 mg was taken in the last day or so, so the two rarely
disagree in a way that matters.

### Other: whole mg, 1 to 1000

Above 1000 is almost certainly a typo, and one wrong number skews every later
readout. Logged as `DoseSource.custom`.

### Removal is immediate with undo, not confirm-first

A confirm dialog on every removal punishes the common case. Undo (4 seconds)
re-adds the identical dose, same id and time.

### Unreadable data pauses the screen

If the stored log can't be parsed, the screen shows the error and offers no
logging. Consistent with [dose-model.md](dose-model.md): a parse failure must
never look like an empty log, or the next tap would overwrite the user's history.

### Refresh on resume, not only on a timer

Timers don't run while the app is suspended. After hours in the background,
"now" (and which day counts as "today") would be stale until the next 30-second
tick, so the screen also reloads on the resumed lifecycle event. This has a test
that fails without the fix.

## Adversarial pass

**Strongest objection:** the screen presents precise-looking numbers (`478`)
built from typical preset values and a population-average half-life, and the
orange mug past 400 can read as a verdict on the user. Precision the model
doesn't have is the failure mode, and a shaming UI would be its own problem.

**What it changes:** three things. The estimate caption sits next to the number
rather than in a footnote. The preset caption says the amounts are typical. And
the alert state is a colour change on a reference mark, with no message, warning
copy or advice attached. If that ever gets copy ("you've had too much"), that is
a product decision under [../product.md](../product.md), not a UI detail.

## Known limits (deliberate, not bugs)

- **Backdating is a separate feature**, see [backdating.md](backdating.md).
- **The log row shows the source, not the drink.** An espresso reads "Coffee"
  because `Dose` stores only the source. A name field is a model change,
  decided with the history view.
- **iOS only verified.** Android has never been run.
- **The list is below the fold** on a short phone once there are several doses;
  the mug and total update immediately, so a tap is never silent.

## Tests

`test/ui/home_screen_test.dart` (boot, one-tap logging, remove and undo, Other's
bounds, yesterday's dose decaying into the readout without appearing in today's
log, unreadable data, resume refresh across a 5-hour gap and midnight),
`test/ui/mug_test.dart` (empty, half, full, over-limit colour),
`test/domain/today_test.dart` (local-day boundaries, ordering, presets sane).
