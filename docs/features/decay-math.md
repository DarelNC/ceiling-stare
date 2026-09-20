# Caffeine remaining (decay math)

Backlog item 2. Status: **built** (2026-09-20), no UI yet. Code in
`lib/domain/caffeine.dart`, tests in `test/domain/caffeine_test.dart`.

## What it is

```dart
double remainingMg(Iterable<Dose> doses, DateTime now,
    {Duration halfLife = defaultHalfLife});
```

Estimated mg still active at `now`. Each dose decays exponentially from the
moment it was taken (`mg * 0.5^(elapsed / halfLife)`); the results are summed.
Pure: it imports `Dose` (a plain data class) and nothing else. No storage, no
UI, no clock of its own (`now` is passed in), per
[../architecture.md](../architecture.md).

## Decisions

### Half-life: a parameter with a 5-hour default

`defaultHalfLife` is 5 hours, the commonly cited population average. It is an
argument, not a constant baked into the formula, so a per-user setting later
costs nothing structurally. **No user-facing setting is built or decided**;
whether one is worth the UI is a product call for when it's asked for.

### First-order decay, whole dose counted immediately

No absorption ramp. In reality caffeine peaks roughly 30 to 60 minutes after a
drink; this model treats it as fully active at the instant it's logged.

- **Effect:** the figure reads slightly high in the first hour after a dose and
  is indistinguishable a few hours out.
- **Why accepted:** the uses on the roadmap ("how much is still active", "safe
  to sleep by bedtime") are dominated by the multi-hour tail, where the ramp
  doesn't matter. An absorption term adds a second parameter that is as
  individual as the half-life, for accuracy nobody can verify against their own
  body.

### Future-dated doses count as 0

A dose after `now` hasn't been taken. This makes a backdated clock change or a
dose logged "for later" harmless instead of an error.

### Returns unrounded `double`

Rounding is presentation. A screen showing whole mg and a future
time-until-below-threshold calculation both want the exact value.

### Non-positive half-life throws

`ArgumentError`. A zero or negative half-life has no meaning, and a silent
default would hide a caller bug.

## Adversarial pass

**Strongest objection:** the output is a confident-looking number (say
"143 mg") built from a population average that can be off by a factor of two for
a real person (roughly 2 to 10 hours), and the roadmap builds a "safe to sleep"
nudge on top of it. Precision the model doesn't have is the failure mode.

**What it changes:** the math itself is right for what it claims, so it stays.
The honesty has to live where the number is shown. Anything user-facing that
consumes this must present it as an estimate, and the "safe to sleep" wording is
an open product decision ([../product.md](../product.md), health-claim
framing). Recorded in the docstring too, so it travels with the function.

**Reviewed:** the tests hard-code independently computed values, not just
self-consistency: `100 * 0.5^(1/5) = 87.0551` and `200 * 0.5^(2.5/5) =
141.4214`, plus exact halvings at 5, 10 and 15 hours. They also cover summing,
order independence, future doses, an adjustable and invalid half-life, strict
monotonic decrease, a 10-year-old dose (underflows to 0, not NaN or negative),
and a local-time `now` giving the same answer as UTC.

## Not done here

- No time-until-below-threshold (needed by the safe-to-sleep nudge, backlog 5).
  For doses already taken it's a closed form (`halfLife * log2(current /
  threshold)`), so it doesn't need a search.
- No daily total, and no "which day is today" logic (core screen, backlog 3).
