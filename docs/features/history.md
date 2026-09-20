# History and the menu

Status: **built** (2026-09-20), verified on the iOS simulator. Code:
`lib/ui/history_screen.dart`, `lib/ui/day_chart.dart`, `lib/ui/menu.dart`,
`lib/ui/shared.dart`, `lib/state/dose_log.dart`, `lib/domain/history.dart`.

## What it does

**Menu.** A flat `MENU` button in the home header opens a numbered panel dropped
from the top right. It has one entry, `01 HISTORY`. New screens get an entry
here rather than another control on the home screen.

**History screen.** A 14-day strip of bars (one per day, height = that day's
total, orange past the 400 mg reference line, a short stub for empty days). Tap a
bar and the caption under it shows that day's date, total and drink count.
Below the strip, every logged dose grouped by day, newest first, each day with
its total, each dose removable with an undo bar. `SEE LOG` on the home screen's
today line goes to the same place.

## Decisions

### Today's log moved off the home screen

The home screen had grown a mug, a total, a caption, a chip row, six buttons and
a log, and the log was already mostly below the fold. Home is now: read the mug,
tap a drink. The log lives here. Two costs were accepted and mitigated:

- **A wrong tap can't be seen and removed on the spot.** So *every* log now
  raises a bar ("Logged 95 mg.", UNDO), not only backdated ones. That is better
  feedback than a row appearing off-screen anyway.
- **Removing an older dose is two steps** (menu or SEE LOG, then the row). That
  is the rare path.

### A menu, with one entry, not a bar of tabs

The user's brief was to stop stacking features on the home screen and add a menu.
A two-tab bar would have fit today's two screens, but would need redesigning on
the third. The panel is numbered and additive, and I did not invent placeholder
entries for screens that don't exist. The header button is flat, not raised: the
hard shadow is reserved for the primary actions.

### One shared, in-memory log (`DoseLog`)

Both screens read the same `DoseLog` (a `ChangeNotifier` over the repository).
Writes go to the store first and the list is re-read afterwards, so what's on
screen is what's stored. It also owns "now", so today's boundary moves only on a
tick or when the app resumes. It stops offering to log while the store is
unreadable, keeping the rule from [dose-model.md](dose-model.md). Without it the
two screens would each hold a copy and drift.

### Day grouping is pure logic in `lib/domain/history.dart`

`groupByDay`, `dailyTotals`, `dayLabel`, tested without a widget. Days are local
calendar days and step by date, not by 24 hours, so a DST change can't skip or
repeat a day. A dose dated in the future gets its own day rather than vanishing.
Labels are English only, like all copy.

### The chart scales to the reference limit, and only grows past it

The 400 mg rule sits at a fixed height on an ordinary fortnight, so bars from
different visits compare. A day over 400 rescales everything so it still fits.
The scale mark is in a left gutter (the same device as the mug's ticks), after
the first version put it behind the bars where an over-limit day hid it.

### 14 days, no more

Enough to see a pattern, small enough to read on one line. The list underneath
is not limited; it is built lazily, so a long history stays cheap.

## Adversarial pass

**Strongest objection:** this moves the primary confirmation surface of the app
(the log) two taps away, and adds a whole navigation layer to hold one entry.
That is more structure than one screen justifies, and "make it easier to find
things" is exactly how a simple tracker grows menus nobody opens.

**Why it stands, and what it changes:** the log was already below the fold, so
most people weren't seeing it; the bar on every log replaces that feedback more
directly. The menu is the cheapest thing that stops the next feature (settings,
notifications, safe-to-sleep) from landing on the home screen, which is what
the brief asked for. What would prove it wrong: if in use the home screen still
feels like it needs the log, or the menu stays a single entry for a long time,
fold History back into a plain link and drop the menu.

## Known limits

- **Removal only, no editing.** A wrong dose is removed and re-logged.
- **The list rows show the source, not the drink** ("Coffee" for an espresso);
  the drink name is still a model change.
- **The trend is totals only.** No weekly average, no per-source split, no
  "time of last dose" pattern. Each is a feature to decide, not a default.
- **Selection resets to today on a new visit;** it isn't remembered.
- **English day names only.**

## Tests

`test/domain/history_test.dart` (grouping, ordering, day boundaries, DST-safe day
stepping across month and year, future doses, labels, weekday initials),
`test/state/dose_log_test.dart` (load, add and remove, clock, error and recovery,
work finishing after dispose), and `test/ui/history_screen_test.dart` (menu opens
and dismisses, grouping and order, SEE LOG, BACK, empty state, finding and
removing a dose backdated onto yesterday, undo, removals visible on home, logs
visible in history, day selection, unreadable data, chart colours and scaling).
