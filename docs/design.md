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
| Major Mono Display — readouts and the wordmark | `Major Mono Display` |
| DM Serif Display italic — the human line | `DM Serif Display Italic` |
| Space Grotesk — labels, captions, body | `Space Grotesk` |

**Palette** (values from `caffeinated/lib/main.dart`, declared in
`lib/ui/tokens.dart`):

| Token | Value | Used for |
|---|---|---|
| `ground` | `#2A0F14` | page background |
| `groundDeep` | `#140609` | inside of the mug |
| `ink` | `#F6EFE6` | primary text, borders |
| `mutedInk` | `#D8B6AD` | labels, secondary text |
| `dim` | `#8F6A62` | captions, scale ticks, disabled |
| `rust` | `#8C2F1B` | every hard shadow |
| `signal` | `#E9FF4F` | the liquid, press flash, focus underline |
| `alert` | `#FF5C1C` | liquid past the reference limit |
| `emberGlow` | `#6B1F18` | not declared yet; add when a screen uses it |

Type roles as built: Archivo Black for the big number, the today total, button
titles and the error headline. Space Grotesk for section labels, captions and
body. Major Mono Display for readouts only: mug scale marks, the `MG` unit,
log-row times and amounts, plus the `WIRED` wordmark. DM Serif italic for the
one human line (the empty state).

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
  until clear). Where it would be used as a general "techy" signal, don't. This
  was enforced in practice: see the first entry under Rejected / tried.
- **The mug-fill visual is reused, with its own reason, and kept.** In
  `caffeinated` the mug showed a countdown of screen-awake time. Here the liquid
  is caffeine *still active*: it rises when a drink is logged and drains as the
  estimate decays, full at the 400 mg reference limit, orange past it. That is a
  different quantity with a different direction of motion, and it reads
  correctly at a glance in the running app (checked on the iOS simulator at
  empty, 158 mg, and 478 mg). The reason is fit to the quantity, not familiarity.
- Recheck this whole section if any single device from the identity ends up
  dominating the UI.

## Rejected / tried

- **Major Mono Display for section labels** (`STILL ACTIVE`, `TAP TO LOG`,
  `TODAY`). Built first, screenshotted, rejected: at 11 px its letterforms are
  hard to read, and it was exactly the general "techy signal" use the reuse
  check rules out. Replaced by Space Grotesk bold caps with letter-spacing, which
  is also what `caffeinated` uses for labels.
- **Material's default snackbar shadow.** Soft blur shadow broke the hard-shadow
  rule; elevation set to 0 (flat ink bar, zero radius).
- **No alternative to the mug was built.** The brief was to try the mug first,
  and it worked, so nothing was compared. This is not a result that the mug beats
  other metaphors, only that it isn't broken. Revisit if it stops carrying the
  screen (for example once history charts share the page).

Iterate-live is possible on the iOS simulator; Android is still unverified. See
[stack.md](stack.md).
