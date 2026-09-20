# Log with a time (backdating)

Status: **built** (2026-09-20), verified on the iOS simulator. Code in
`lib/ui/home_screen.dart` (`_WhenRow`, `_log`, `_pickTime`) and
`lib/domain/today.dart` (`lastOccurrence`).

## What it does

A row of chips sits above the drink buttons: **NOW** (selected by default),
**−30 MIN**, **−1 H**, **−2 H**, **PICK TIME**. Choose one, then tap a drink (or
Other): the dose is logged at that time. NOW keeps logging a single tap, so the
common case costs nothing extra; a backdated log costs one more.

PICK TIME opens a time-of-day picker, restyled to the identity (hard borders,
zero radius, signal-yellow selection).

## Decisions

### One-shot, not a mode

The chosen time applies to the **next log only**, then resets to NOW. A sticky
mode would let one forgotten selection mis-time every later tap. It also resets
whenever the app returns to the foreground, for the same reason (see the
adversarial pass).

### A picked time of day means the most recent time it could have been

`lastOccurrence(hour, minute, now)`: today if that time has already happened,
otherwise yesterday. Logging "11 pm" at 12:30 am lands on the previous evening
instead of in the future. It therefore covers the last 24 hours and no more. Anything
older isn't loggable; there is no editing of past days beyond removing a dose in
the [history](history.md).

### A backdated log says when and where it went, with undo

Every log raises a bar with UNDO (see [history.md](history.md)); a backdated one
also names the time, and "yesterday" when it crossed midnight: "Logged 95 mg at
11:00 PM yesterday." The bar exists because the log isn't on the home screen. A
dose on yesterday can be found and removed later in the history view.

### Compact labels

The chips read "−30 MIN", not "30 MIN AGO", because five chips with "ago" wrap
onto two lines at phone width and push the drinks down. Screen readers get the
long form ("30 minutes ago"). Cost: the minus sign is terser and slightly less
obvious to a first-time user; the effect is visible immediately in the mug.

## Adversarial pass

**Strongest objection:** hidden state on the main screen is dangerous in a
logging app. Select "−1 H", get distracted, come back hours later, tap Coffee
expecting "now": the dose is silently logged an hour early, and the readout is
quietly wrong.

**What it changes:** three things, one of them a code change. The selected chip
is filled solid signal-yellow, which is the loudest thing on the row. Backdated
logs always announce themselves with a bar and an undo. And the selection is
cleared when the app returns to the foreground, which covers the realistic
"came back later" case; there is a test that fails without it. What remains: a
selection left untouched while the app stays open and on screen. That is an
accepted residual, because the app is visibly in that state.

## Known limits

- **24 hours back at most.** See above.
- **A dose on yesterday shows up only in the history view**, not on the home
  screen. It still counts toward the mug while it's active.

## Tests

`test/domain/today_test.dart` (`lastOccurrence`: earlier, exactly now, later,
just after midnight, month and year boundaries, never in the future, UTC input)
and the `backdating` group in `test/ui/home_screen_test.dart` (chip applies once
then resets, bar and undo, no bar for now-logs, yesterday wording, NOW cancels a
chip, picker flow, Other honours the time, reset on resume).
