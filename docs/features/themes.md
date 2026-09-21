# Themes

Built 2026-09-21 and checked on the iOS simulator. Code: `lib/ui/app_theme.dart`,
`lib/ui/themed_background.dart`, `lib/ui/theme_screen.dart`,
`lib/state/theme_controller.dart`.

## What it does

The menu has a second entry, `02 THEME`. It opens a screen with one card per look.
Each card is drawn in its own colours with the real widgets (mug, big number,
button), so you choose by looking. Tapping a card changes the whole app at once
and the choice is saved. There are three looks: Oxblood (the default), Newsprint
and Blueprint.

## Where they came from

Five reference posters were supplied on 2026-09-21. The app already matched one
(dark red ground, hard shadows, yellow accent), so that became Oxblood, kept as
the default with its values unchanged. The other four were adapted from their
posters, borrowing elements and not copying layouts. On the same day three were
kept and two were cut: Paper (cream with one thick orange bar) and Acid (yellow
with hatching and hollow numbers). Their code was deleted along with the switches
only they used: the accent bar, the header band, outlined chart bars, the hatch
texture and the hollow number style.

| Theme | Ground | What it borrows |
|---|---|---|
| Oxblood | dark red | Nothing added. The original look. |
| Newsprint | cream with halftone dots | A yellow highlighter block behind the number, today's total on an inverted black panel, hard black shadows on boxes, a pale mug with a black liquid set in from the wall. |
| Blueprint | navy with a drawing grid | An inset frame, `DWG. CS-01` and `SCALE 1 : 1` labels under the header, thin 1 px borders, hollow screen titles, a yellow number. |

Elements from the posters that were never used: the scrolling ticker band, the
rotated sticky note and `UNFILED` stamp, the vertical side text, the tiles of
black and orange squares. Each would add a feature or invented copy.

## How it works

A theme is a `CsTheme` data object: a palette, a background pattern and a few
switches (`numberStyle`, `statPanel`, `titleBlock`, `frame`, `outlineTitle`,
`mugGap`, `liquidOverride`). Adding a look means adding one constant to
`CsThemes.all`.

Widgets read the theme with `context.cs` and never hard-code a colour. `Tokens`
holds font names only.

The roles keep their meaning in every theme. `signal` is the selected state and
usually the liquid and chart bars (`liquid` names a different colour when a theme
needs one). `alert` is the liquid past the 400 mg reference line. `ink` is text
and borders on `ground`. A theme changes the values, not what they mean.

`CsThemeScope` puts a theme in the tree. The picker nests one per card, which is
how a card renders the real widgets in another theme.

`ThemeController` holds the current theme and saves its id under `theme_v1`. It
is read before the first frame so the app never flashes the default. An unknown or
unreadable id means Oxblood, which also covers a saved `paper` or `acid` from
before the cut. A failed save means the choice lasts until the app closes. Neither
shows an error.

## Decisions

Themes are data, not a widget per theme. That keeps one implementation of every
screen, and the differences (a panel, a frame, a label row) are switches read in
one place each. The cost is that a look needing a different layout has to add a
switch first.

Oxblood is untouched. It is the original look, and the reasoning in `design.md`
(oxblood reads as espresso) is written for it.

Colours were tuned by test. `test/ui/app_theme_test.dart` computes contrast for
every theme: ink on ground at least 7, muted ink and small accent text at least
4.5, dim captions at least 3, text on a signal fill at least 4.5, and the liquid
against the inside of the mug at least 3. While five themes existed it caught a
faint orange liquid on cream, invisible yellow bars on cream, and an orange that
missed 3:1 on a pale mug.

The liquid can differ from the signal colour. Newsprint keeps yellow for the
highlighter, the chips and selected states, but draws the liquid black, because
yellow on its pale mug has a contrast of about 1.1.

The switch is live with no confirm. A wrong pick costs one tap and the result is
the preview.

Big titles get no text shadow when the shadow would be the same colour as the
text. Newsprint's hard shadow is black and its text is black, so the shadow only
smeared the letters ("THEME" and "HISTORY" looked bad). `hardTextShadow` now
returns nothing in that case, which also covers the error headline.

## Tried and dropped

- Newsprint with a black mug and yellow liquid. The black shadow, wall and
  interior fused into one slab and the handle looked thin beside it. It became a
  pale mug with a black liquid and a small gap (`mugGap`) between wall and liquid.
- Dense halftone dots. They sat at the scale of the letter strokes and made small
  captions noisy. The dots are finer and quieter, and Newsprint's secondary text
  is darker (`dim` is `#62574B`, about 5:1 on the ground).
- Five themes. Every new screen would have to work on cream, yellow, navy and dark
  red, for one screen's worth of content. Three kept.

## Known limits

- A snackbar keeps the colours of the theme it was shown in, so an undo bar shown
  just before a switch keeps the old ones for its 4 seconds.
- There is no automatic light or dark following the system. The choice is manual.
- `DWG. CS-01` and `SCALE 1 : 1` mean nothing. That is the joke.
- The picker previews are static: a mug, a number and a button, not the menu or
  history.
- Android is unverified, like everything else.

## Tests

`test/ui/app_theme_test.dart`: ids, fallback, contrast for all three, the text
shadow rule and the exact list of themes. `test/state/theme_controller_test.dart`:
load, fallback (including the removed ids), select, save failure, dispose and the
preferences store. `test/ui/theme_screen_test.dart`: the menu entry, all themes
listed, apply and persist, the in-use marker, a saved theme opening first, every
theme on home, history and the picker at 402x874 and 360x640, and each theme's
signature element. Any new screen should be added to the layout test.
