# Themes

Status: **built** (2026-09-21), checked on the iOS simulator in all five. Code:
`lib/ui/app_theme.dart`, `lib/ui/themed_background.dart`,
`lib/ui/theme_screen.dart`, `lib/state/theme_controller.dart`.

## What it does

The menu has a second entry, `02 THEME`. It opens a screen with one card per
look. Each card is drawn in its own colours with the real widgets (mug, big
number, button), so you choose by looking. Tapping a card changes the whole app
at once and the choice is saved. The default is Oxblood.

## Where the five came from

Five reference posters supplied on 2026-09-21. The app already matched one of
them (dark red ground, hard shadows, yellow accent), so that one is **Oxblood**,
kept as the default with its values unchanged. The other four are adaptations
that borrow elements from their poster, not copies of it.

| Theme | Ground | Elements borrowed |
|---|---|---|
| Oxblood | dark red | none added; the original look |
| Paper | cream | one thick orange bar under the mug block; black type; no shadows; black big number |
| Newsprint | cream with halftone dots | yellow highlighter block behind the number; today's total on an inverted black panel; hard black shadows; pale mug with a black liquid set in from the wall |
| Acid | yellow with diagonal hatching | black header band that runs behind the status bar; hollow outlined numbers and titles; black liquid; outlined chart bars |
| Blueprint | navy with a drawing grid | inset frame; `DWG. CS-01` and `SCALE 1 : 1` labels under the header; thin 1 px borders; hollow titles; yellow number |

Elements from the posters that were not used: the scrolling ticker band, the
rotated sticky note and `UNFILED` stamp, the vertical side text, the census
tiles of black and orange squares. They would each add a feature or invented
copy, and the brief was to adapt, not to reproduce.

## How it works

- A theme is a `CsTheme` data object: a palette, a background pattern, and a few
  switches (`numberStyle`, `accentBar`, `statPanel`, `bandHeader`, `titleBlock`,
  `frame`, `outlineTitle`, `outlinedBars`). Adding a look means adding one
  constant to `CsThemes.all`.
- Widgets read it with `context.cs` and never hard-code a colour. `Tokens` now
  holds font names only.
- The **roles stay fixed** in every theme: `signal` is the selected state and
  usually the liquid and chart bars (`liquid` says so when a theme needs a
  different colour there); `alert` is the same thing past the 400 mg reference line;
  `ink` is text and borders on `ground`. A theme changes the values, not what
  they mean.
- `CsThemeScope` puts a theme in the tree. The picker nests one per card, which
  is how a card renders the real widgets in another theme.
- `ThemeController` holds the current theme and saves the id under `theme_v1`.
  It is read before the first frame so the app never flashes the default. An
  unknown or unreadable id means Oxblood; a failed save means the choice lasts
  until the app closes. Neither shows an error.

## Decisions

### Themes are data, not per-theme widgets

The alternative was a widget per theme. Data keeps one implementation of every
screen, and the structural differences (a bar, a panel, a band) are booleans
read in one place each. The cost is that a look which needs a genuinely
different layout cannot be added without a new switch.

### The default is not touched

Oxblood is the original look and the one the docs' design reasoning is written
for. It renders the same values as before this change and was checked on the
simulator, not pixel-diffed.

### Colours were tuned by test, not by eye

`test/ui/app_theme_test.dart` computes WCAG contrast for every theme: ink on
ground at least 7, muted ink and the small accent text at least 4.5, dim
captions at least 3, text on a signal fill at least 4.5, and the liquid against
the inside of the mug at least 3. It caught three real problems before any UI
existed: Paper's orange liquid was too faint on cream (the orange was deepened),
Newsprint's yellow bars vanished on cream and Acid's orange missed 3:1 on its
pale mug (both fixed, one by outlining the bars and one by deepening the
orange).

### The liquid can differ from the signal colour

Each theme has a `liquid` (the mug fill and chart bars). It defaults to `signal`.
Paper draws over-limit as black (its normal liquid is orange). Acid's normal
liquid is black and over-limit is orange. Newsprint keeps yellow for the
highlighter, chips and selected states but draws the liquid black, because
yellow on the pale mug has a contrast of about 1.1. `alert` still means past the
limit everywhere.

### Live switch, no confirm

A wrong pick costs one tap to undo and the result is the preview.

## Rejected / tried

- **Newsprint with a black mug and yellow liquid.** First version, and it looked
  bad on the simulator. The black hard shadow, black wall and black interior fused
  into one slab, the handle was a thin outline beside it, and the yellow was
  only legible because of the black. Replaced by a pale mug, a black liquid and
  a small gap (`mugGap`) between wall and liquid so the liquid can't merge with
  the wall and shadow.
- **Dense halftone dots.** They sat at the scale of the letter strokes and made
  the small captions noisy. The dots are now finer, quieter and on a wider grid,
  and Newsprint's secondary text is darker (`dim` is `#62574B`, about 5:1 on the
  ground).

## Adversarial pass

**Strongest objection:** five looks multiply the design surface by five for a
one-person app that has one screen worth of content. Every new screen now has to
work on cream, yellow, navy and dark red, and the palette that was argued for on
the subject (oxblood reads as espresso) does not apply to four of them. It also
dilutes the identity the docs spend pages defending.

**Why it stands, and what it changes:** this was asked for as a way to see the
app in each style, so the switcher is a comparison tool as much as a feature.
The cost is contained by keeping themes as data, by the contrast test, and by a
layout test that renders home, history and the picker in every theme at two
phone sizes (it already found a real layout bug in the picker cards). What would
prove it wrong: if one look wins, delete the others and the switch with them.
Until then, **any new screen must be added to that layout test.**

## Known limits

- **A snackbar keeps the colours of the theme it was shown in.** Switch themes
  within 4 seconds of a log and the undo bar still shows the old ones.
- **No automatic light/dark following the system.** The choice is manual.
- **`DWG. CS-01` and `SCALE 1 : 1` are decoration.** They mean nothing; that is
  the joke.
- **The picker previews are static.** They show a mug, a number and a button,
  not the menu or history.
- **Android is unverified,** like everything else.

## Tests

`test/ui/app_theme_test.dart` (ids, fallback, contrast for all five),
`test/state/theme_controller_test.dart` (load, fallback, select, save failure,
dispose, the preferences store), `test/ui/theme_screen_test.dart` (menu entry,
all themes listed, apply and persist, the in-use marker, a saved theme opens
first, every theme on home, history and the picker at 402x874 and 360x640, and
each theme's signature element).
