# Project rules

Adapted from the workspace-level `frag-ment/rules/` library, the same way
`caffeinated/docs/rules.md` was. This project is a sibling of `caffeinated`
(same visual identity, same author, same workspace conventions) but a
different product with a different shape — a caffeine intake tracker,
cross-platform (Android + iOS) from day one, no foreground service or wake
lock involved. What follows is what was kept, dropped, or reshaped, and why,
same discipline as the sibling project.

## Why this project exists

`caffeinated` (keep-screen-awake utility) is Android-only by necessity — the
feature needs a real background wake lock, which iOS doesn't grant to
third-party apps at all. Market research done in that project's session
(see its own history) showed the "keep screen awake" category isn't
portable to iOS in any form worth shipping, but also surfaced a genuinely
under-served, low-competition niche: caffeine intake tracking. Every
competing app on both Play Store and the App Store tops out in the low
thousands of installs/reviews — nobody has done for this category what
Forest did for focus timers. This project is a real attempt at that gap,
not a reskin of `caffeinated`.

## Kept, as-is (identical to caffeinated, not reinterpreted)

- **The whole "New Cycle" design system** — Oxblood ground, the same four
  bundled fonts (Archivo Black / Major Mono Display / DM Serif Display
  italic / Space Grotesk), hard zero-blur offset shadows, zero corner
  radius, signal-yellow as the one accent, flush-left layout with the
  single-element-empty-state centering exception. This is deliberately
  copied, not re-derived — see `caffeinated/docs/rules.md`'s own "Design
  system: New Cycle" section for the full reasoning and the adaptation
  calls already made there (palette choice, local font bundling instead of
  a Google Fonts runtime fetch, how the centering exception was read).
- **stack.md — License: MIT unless there's a specific reason otherwise.**
- **stack.md — Default branch for new repos is `master`.**
- **process.md — tiered documentation/review discipline**, the adversarial
  pass, and scope discipline / cut list. Same as `caffeinated`.

## Kept, adapted

- **product.md — Do a real naming pass before anything goes public.**
  "wired" is a working codename picked to unblock starting the project,
  same as "Caffeinated" originally was — not checked for collision or
  trademark yet. Do that pass before any public listing, same rule,
  independently applied (a name check on one sibling project says nothing
  about the other).
- **product.md — Weigh accounts/login/PII as a real decision.** This one
  actually needs a real decision here, unlike `caffeinated` where it was
  trivially satisfied. A caffeine log is a plausible candidate for
  cross-device sync (Health Connect on Android, HealthKit on iOS, or a
  simple cloud backup) — that's a legitimate, common feature for this
  category, but it's a decision to make explicitly when it comes up, not a
  default to reach for because "real apps have sync." v1 default: fully
  local, on-device only, no accounts — same zero-friction stance as
  `caffeinated`, revisited only with an explicit decision entry here.
- **architecture.md — mostly still N/A.** No backend, no third-party API.
  If Health Connect/HealthKit integration is added later, that's a local OS
  API call, not a third-party network dependency — the "never call a
  third-party API directly from the client" rule doesn't engage.
- **stack.md — match framework to deployment shape.** One Flutter codebase,
  two platform targets, no backend — a single deployable either way, same
  reasoning as `caffeinated`, restated because this project is genuinely
  cross-platform where the sibling deliberately isn't.

## Cut list / open decisions (nothing built yet beyond scaffolding)

- **Cross-platform support is the point this time**, not something dropped
  — the opposite call from `caffeinated`, made for a specific reason (the
  screen-awake feature has no iOS equivalent; a tracker has no such
  platform-specific dependency).
- Data model for logged drinks/doses, the caffeine half-life/remaining-level
  math, and the actual tracking screens are not designed yet — this is
  scaffolding only (project shell, git repo, shared identity/fonts wired
  up, one placeholder screen proving the theme loads). The first real
  feature is its own decision, to be made explicitly, not assumed from this
  doc.
- Health Connect / HealthKit sync — explicitly deferred, see above.
- A home-screen widget showing current caffeine level — plausible given how
  well the mug-fill metaphor from `caffeinated` could translate to "cup
  filling toward your daily limit," not decided or started.
