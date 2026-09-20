# Design

## The constraint

Bound by [`rules/design.md`](../../rules/design.md): **do not ship anything that
looks AI-generated**, in visuals or in copy. Read that file for the full banned
list and the copy tells (contrastive "X, not Y", marketing verbs, hollow
superlatives, hedge openers). The self-check before shipping UI work:

> Would this specific choice look identical on a random AI-generated SaaS
> landing page?

If yes, it isn't done.

### Flutter equivalents of the banned patterns

The library list is written for web landing pages. On a Flutter app the same
failures look like:

- A stock Material `ElevatedButton` on a plain `Scaffold` with no typographic or
  color identity.
- Default `Icons.*` from the Material set dropped in without a system around
  them.
- A static screen with no motion tied to state. The core screen shows a live
  quantity (caffeine still active) and should read as alive, not as a submitted
  form.
- A chart or list of default-styled widgets for history, with the data as
  decoration instead of the visual centerpiece.

## Current implementation: "New Cycle"

Shared with `caffeinated`. That project's `docs/rules.md`, section "Design
system: New Cycle", holds the full derivation and the adaptation calls already
made (palette choice, local fonts, how the centering rule was read). Not
repeated here.

**Rules of the system:** Oxblood ground, zero corner radius, hard zero-blur
offset shadows, signal-yellow as the single accent, flush-left layout. The one
centering exception is a single-element empty state.

**Type:**

| Face | Family key in code |
|---|---|
| Archivo Black — headlines | `Archivo Black` |
| Major Mono Display — labels / readouts | `Major Mono Display` |
| DM Serif Display italic — the human line | `DM Serif Display Italic` |
| Space Grotesk — body/UI text | `Space Grotesk` |

**Palette** (values from `caffeinated/lib/main.dart`):

| Token | Value | Declared in `lib/main.dart` |
|---|---|---|
| `ground` | `#2A0F14` | yes |
| `ink` | `#F6EFE6` | yes |
| `mutedInk` | `#D8B6AD` | yes |
| `dim` | `#8F6A62` | yes |
| `rust` | `#8C2F1B` (used as the hard shadow colour) | yes |
| `groundDeep` | `#140609` | not yet |
| `emberGlow` | `#6B1F18` | not yet |
| `signal` | `#E9FF4F` | not yet |
| `alert` | `#FF5C1C` | not yet |

Undeclared tokens get added when a real screen uses them, not before.

## Why reuse this identity: the reuse check

`rules/design.md` says a device that worked on a previous project needs its own
reason to be reused, not inertia. This project copies the whole identity, so the
check is owed.

**Reasons that hold here:**

- **Oxblood ground.** The reason it was chosen for `caffeinated` (a red-brown
  that reads as espresso, where the alternatives read purple or blue) is a
  property of the *subject*, coffee and caffeine, and carries over unchanged.
  It isn't borrowed meaning.
- **Family identity.** Two apps from one author sharing a look is a deliberate
  choice, not accidental convergence on a template.

**Strongest objection:** "Family resemblance" can justify anything, and it is
exactly the kind of reasoning that hides inertia. The type roles in particular
were assigned for a screen-awake utility.

**Where the objection lands, and what it changes:**

- Major Mono Display in `caffeinated` served a live-running-state feel (ticker,
  labels). Here it earns its place only as an *instrument readout* (mg, hours
  until clear). Where it would be used as a general "techy" signal, don't.
- The mug-fill visual from `caffeinated` is **not** carried over by default. There
  it showed a countdown of screen-awake time. Here the natural quantity is
  caffeine *still active*, which drains rather than fills, so the same picture
  would mean something different. It can still be the right answer (a mug
  emptying reads well), but it needs its own reason and should be judged running
  in the app, not from the resemblance. It is an open UX decision, listed in
  [features/README.md](features/README.md), item 3.
- Recheck this whole section if any single device from the identity ends up
  dominating the UI.

## Rejected / tried

Nothing yet. The iterate-live rule (build variations in the running app, keep
only the winner, record rejected directions here) is now possible on the iOS
simulator; Android is still unverified. See [stack.md](stack.md).
