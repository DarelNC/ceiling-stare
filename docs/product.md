# Product

## Why this niche

`caffeinated` is Android-only by necessity. Market research done alongside it
(in an earlier session, not re-run here) found that caffeine-intake tracking is
a low-competition category on both stores, with nobody having done for it what
Forest did for focus timers, unlike the crowded pomodoro/focus-timer space.
This project is a real attempt at that gap, not a reskin of `caffeinated`.

**Unverified numbers:** earlier notes state the competition's size two ways
("well under 1,000 reviews" for the best-reviewed app; "low thousands of
installs/reviews"). Re-check before leaning on either figure in any public
positioning.

## Naming: provisional, pass still owed

"wired" is a working codename picked to unblock the scaffold. Nothing has been
checked: no collision search, no store search, no trademark, no domain or handle
availability. Having used the name in files and commits doesn't make it settled.

- Expect the pass to be hard, not a formality: "Wired" is a well-known magazine
  name and a very common app-store word. That's a reason to run the check early,
  not a finding.
- Applied independently of `caffeinated`. A check on one sibling says nothing
  about the other.
- `applicationId` / bundle ID is still the `com.example.wired` placeholder. It
  needs a real reverse-domain, and it depends on the final name, so do both
  together before any store submission.

Must be done before anything goes public (store listing, public repo, release).

## Accounts, login and PII: decided for v1, revisit deliberately

**v1: fully local, on-device only, no accounts, no login, no PII collected.**
Same zero-friction stance as `caffeinated`.

This one is a real decision here (unlike in the sibling, where it was trivially
satisfied): a caffeine log is a plausible candidate for cross-device sync via
Health Connect, HealthKit or a cloud backup, and that is a normal feature for
the category. It stays a deliberate choice, made when it comes up and written
down here with its own adversarial pass, not a default reached for because real
apps have sync.

Consequences to weigh when that decision comes:

- The log is health-adjacent data. Local-only means the store privacy
  declarations (Play data safety, App Store privacy label) can honestly say the
  app collects nothing. That stops being true the moment sync or an account is
  added.
- Health Connect / HealthKit each add an OS permission and their own
  review/declaration requirements.

Health sync is **deferred, not rejected**. Don't build toward it by default.

## Health-claim framing (open)

The half-life math is a population average (about 5 hours); actual clearance
varies by person. A "safe to sleep" nudge (backlog item 5 in
[features/README.md](features/README.md)) turns an estimate into something that
reads like health advice. How it is worded and framed (an estimate, not a
verdict) is a product decision to make when that feature is designed, and it
applies to the copy constraint in [design.md](design.md) as well.
