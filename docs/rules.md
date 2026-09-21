# Project rules

Durable project memory for **Ceiling Stare** (formerly the codename "wired"; see
[product.md](product.md)): a caffeine intake tracker, Flutter, Android + iOS from day one, fully on-device. Adapted from the
workspace library in `frag-ment/rules/`, following the layout in
[`process.md`](../../rules/process.md) — one file per concern, never a single
doc. This file started life as that single doc; on 2026-09-20 its contents were
redistributed into the files below and the workspace rules were re-checked
against the project (ledger at the bottom).

Sibling project: `caffeinated/` (keep-screen-awake, Android-only). Same author,
same visual identity, different product. A decision made there is not
automatically made here — see [design.md](design.md) for the one place that
matters.

## Where things live

| File | Holds |
|---|---|
| [architecture.md](architecture.md) | how the pieces fit; the pure-logic seam; when the third-party-API rules would engage |
| [stack.md](stack.md) | Flutter/Dart, storage, testing, fonts, license, branch |
| [design.md](design.md) | the no-AI-look constraint, the "New Cycle" identity as implemented, why reusing it is justified |
| [product.md](product.md) | why this niche, naming pass, accounts/PII, health-claim framing |
| [features/README.md](features/README.md) | feature index, backlog in order, cut/deferred list |

`CLAUDE.md` at the project root `@`-imports this file and `design.md`; the rest
are read on demand.

## Current state

v1 core loop is built: log a dose in one tap (five bundled presets, or a
hand-entered amount), optionally backdated up to 24 hours; see today's total and
an estimate of caffeine still active as a draining mug; undo any log. A menu
leads to a history screen (14-day trend strip, every dose grouped by day, removal).
All local, no accounts. Details in [features/](features/README.md). `flutter
analyze` is clean and 103 tests pass. Run and seen on the iOS simulator (iPhone
17 Pro, 2026-09-20); **never run on Android**. Not yet built: notifications,
safe-to-sleep, verified preset values, drink names in the log.

## Hard rules

- **v1 is local and account-free.** No cloud, no login, no PII collection. Any
  change to that is a decision-lane entry in [product.md](product.md), not a
  quiet addition.
- **Any UI work follows [design.md](design.md).** No exceptions, no "just this
  once."
- **Scope is decided, not inherited.** A new feature gets its own
  `features/<name>.md`, a line in [features/README.md](features/README.md), and
  an explicit decision. The deferred list there exists so ideas aren't silently
  built (or silently re-litigated).
- **No Claude attribution anywhere in commits or PRs** — no author, co-author,
  or "generated with" line. Commits are a single subject line, no body.
  Reasoning goes in these docs. (Enforced globally by the workspace
  `CLAUDE.md`; restated because this file is the durable memory and the repo
  has its own git history.)
- **Real naming pass before anything public.** See [product.md](product.md).

## Process

Tiered, per [`process.md`](../../rules/process.md):

- **Fast lane:** typos, formatting, copy tweaks, small fixes, routine
  implementation of something already decided. No doc update, no review.
- **Decision lane:** a new dependency, a storage choice, a scope call, a UX
  direction, anything annoying to reverse. Write it in the file for its concern
  as part of the same unit of work, and do one honest adversarial pass — the
  strongest reason it's wrong or premature. If nothing survives, say so; don't
  invent an objection.
- **Publish gate:** doc-sync before anything goes public (push, PR, release).
  First push: 2026-09-21, to `git@github.com:DarelNC/ceiling-stare.git`, after a
  doc-sync pass. Every later push or PR is subject to the same gate.

  **Known gaps at first publish** (recorded rather than fixed, by choice): no
  `LICENSE` file although MIT is the stated default; preset caffeine values are
  recalled figures, not checked against a cited source; the name has US-only
  trademark clearance and an incomplete handle check; the app ID is the
  unpublishable placeholder `com.example.ceilingstare`; never run on Android.

## Adaptation ledger (workspace rules → this project)

What each library file contributed, what was dropped, and why.

| Library file | Outcome |
|---|---|
| `process.md` | **Kept in full**, including the required `docs/` split (adopted 2026-09-20), tiered lanes, adversarial pass, one-line commits, scope discipline. |
| `architecture.md` | **Mostly N/A, one rule engages.** No backend or third-party API, so client-call/failover/hosting-shape/hard-cap/fallback rules are dormant. "Keep reusable logic separate from where the data comes from" applies to the decay math — see [architecture.md](architecture.md). |
| `stack.md` | **Kept/adapted:** framework-fits-deployment (one Flutter codebase, no backend), test the pure logic first, MIT, `master`. **Dropped:** the typed/untyped-language tradeoff (Dart is typed; no untyped external parsing yet) and the caching rule (no request path); local storage was decided as its own item. See [stack.md](stack.md). |
| `design.md` | **Kept in full**, with Flutter equivalents of the banned patterns and the new "reusing a device needs its own reason" check applied to the shared identity. See [design.md](design.md). |
| `product.md` | **Kept.** Naming pass still owed; accounts/PII resolved as local-only for v1. See [product.md](product.md). |

Known gap against the ledger: **no `LICENSE` file exists** although MIT is the
stated default — see [stack.md](stack.md).
