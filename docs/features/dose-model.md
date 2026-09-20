# Dose model and storage

Backlog item 1. Status: **built** (2026-09-20), no UI yet. Code in
`lib/data/`, tests in `test/data/`.

## What it is

A `Dose` is one logged serving: `id`, `source` (coffee / tea / energy drink /
custom), `mg` (whole number, > 0), `at` (UTC instant). A `DoseRepository`
(`all`, `add`, `remove`) is the only way the rest of the app touches the log.
`PrefsDoseRepository` is the one implementation, backed by
`shared_preferences`.

## Decisions

### `mg` is stored as entered; the model doesn't know about presets

A preset is a template that produces a `Dose`, not something a dose points at.
Two reasons: a later change to a preset's value must not rewrite history, and it
keeps the model usable whether or not presets ship. **Whether presets ship in
v1 is deferred to the core-screen feature** (backlog 3), where "few taps to log"
is the actual requirement that decides it. Nothing here forces either answer.
Any presets must be bundled local data ([../architecture.md](../architecture.md)).

### Time is a UTC instant; "today" is computed, not stored

Stored as epoch milliseconds, so a dose keeps its meaning if the phone changes
time zone. "Today's total" is a query against the device's current local day,
made by the screen that needs it. Consequence: after travelling, a late-night
dose can move between "yesterday" and "today". That is the honest behaviour;
storing a local date would freeze a wrong answer.

### Whole-mg integers, source is an enum

Caffeine values in this domain are approximate anyway; fractional mg would imply
precision that isn't there. No free-text drink name yet: it's a real feature
(history readability), not a model detail, and gets decided when the history view
does. Adding an optional field later doesn't break stored data.

### Storage: `shared_preferences`, whole log as one JSON string

Chosen over SQLite (`sqflite`/`drift`) and a hand-managed JSON file. See
[../stack.md](../stack.md) for the full reasoning and the tripwire for revisiting.

### Bad data fails loudly and is never overwritten

Malformed stored data throws `FormatException` from `all()`, and `add`/`remove`
throw before writing. A parse failure must never read as "empty log", or the
next `add` would overwrite the user's history. What the UI does with that error
is a later decision; the guarantee here is that the stored bytes are left alone.

### Writes are serialized

`add`/`remove` are read-modify-write, so they run through a queue. Two quick
taps can't both read the old list and lose one write (tested, 25 concurrent
adds). A failed operation doesn't block the ones after it.

## Adversarial pass

**Strongest objection:** a time-series log doesn't belong in a key-value store.
Every `add` rewrites the whole list, there are no range queries, and the history
view (backlog 4) is exactly where that starts to hurt. SQLite is the standard
answer and this may be a decision that costs a data migration to reverse.

**Why it survives for now:** the cost is real only at sizes this app won't reach
soon. A dose is roughly 60 bytes of JSON; five a day is about 110 KB after a
year, which is trivial to read and rewrite. History over that range is a filter
in memory. Meanwhile SQLite adds a native dependency, a schema and migrations
for a v1 that needs only "load all, add, remove". The repository interface is
the mitigation: swapping the store touches one class, and the app is unreleased,
so there are no users' logs to migrate yet.

**Tripwire:** revisit before first public release, and again if the history
view needs queries that filtering in memory can't do cheaply. After release, a
store swap means migrating real users' data, which is much more expensive than
deciding now.

## Not done here

- No UI, no presets, no edit-a-dose (remove + add covers it until a screen
  needs otherwise).
- The decay math is the next feature; it will consume `List<Dose>` and never
  import the repository ([../architecture.md](../architecture.md)).
