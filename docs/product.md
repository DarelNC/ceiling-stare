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

## Naming: Ceiling Stare, chosen 2026-09-21; final clearance still owed

The project began as the codename "wired", picked to unblock the scaffold. On
2026-09-21 it was renamed **Ceiling Stare** (what 3 a.m. looks like after cup
number five), chosen from a shortlist after the check below. "Wired" was a
well-known magazine name and a very common app-store word, and it was never
checked; the rename made that moot.

**Done in code:** Dart package `ceiling_stare`, app title and home-screen name
"Ceiling Stare", header wordmark, Android and iOS identifiers. The identifier is
a placeholder: **`com.example.ceilingstare`** on both platforms. It is not
publishable (Google Play rejects `com.example` IDs) and needs a real
reverse-domain the owner controls. No domain has been bought, by choice, until
there is a reason to; the ID can be changed later with a find-and-replace across
`android/app/build.gradle.kts`, the Kotlin package path and
`ios/Runner.xcodeproj/project.pbxproj`. Changing the ID after a release ships a
different app to the stores, so settle it before the first submission.

**Not renamed:** the project folder is still `wired/` in the workspace, since
moving it affects the workspace and every open session. Local data from the old
bundle ID was not migrated (there were no users), so the renamed app starts empty.

Applied independently of `caffeinated`. A check on one sibling says nothing
about the other. Everything below must be finished before anything goes public
(store listing, public repo, release).

### Shortlist check, 2026-09-21

Two candidates, chosen for a dry, sarcastic voice (constraints: no common names,
no 3 to 4 letter names): **Ceiling Stare** and **Definitely Decaf**. Checked
with the USPTO trademark search (US only), the iTunes search API for the App
Store, Google Play search pages, DNS/whois/RDAP for domains, and public handle
lookups.

| | Ceiling Stare | Definitely Decaf |
|---|---|---|
| USPTO | no `CEILING STARE` record; only unrelated `STARE`-family marks (Death Stare, Blank Stare) | one dead mark (cancelled caffeine test device, serial 78071063); **one live, pending: `DEF. DECAF COFFEE / DEFINITELY DECAF FOR THE POWERFUL YET GROUNDED / ESTD 2026`, Definitely Something, Inc., class 30 coffee (serial 99900771)** |
| App Store | no match; nearest concept is "Wall Stare: Staring at a wall" (Health & Fitness, 2 ratings) | no exact match, but a cluster of same-category apps named "Decaf": Decaf AI: Caffeine Tracker, Decaf - Stop Caffeine & Coffee, Quit Coffee - My Decaf Life, Coffee Dose (2,066 ratings) |
| Google Play | no match | same cluster: Decaf - Quit Caffeine Fast, Decaf - Caffeine Tracker, Decaf |
| Domains | `.com`, `.app`, `.co`, `.io` all unregistered | `.com` registered since 2017 (GoDaddy, parked); `.app`, `.co`, `.io` unregistered |
| Handles | GitHub and npm free; Bluesky `ceilingstare.bsky.social` held by an empty account from 2024 | GitHub, Bluesky and npm free |

**Reading:** Ceiling Stare is clear on everything checked. Definitely Decaf has a
live coffee trademark application containing the exact phrase, filed by a party
with priority, in an adjacent consumer market, and it would sit in store search
next to four "Decaf" caffeine apps that mean the opposite (quitting) of what a
tracker does.

**Not checked, still owed before launch:** Instagram, X, TikTok (bot-walled), Reddit,
non-US trademark registries (EUIPO/TMview, WIPO), a real clearance search, and a
lawyer's read if the name matters commercially. A no-hit search is evidence, not
clearance. The USPTO search is fuzzy: exact matches rank first, and none of the
top 50 was `CEILING STARE`, but only the first page of each search was read.

**Outcome:** Ceiling Stare was chosen. Definitely Decaf was dropped on the
trademark finding.

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
