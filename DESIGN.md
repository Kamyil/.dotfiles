# Dotfiles interface design

Scope: Herdr's native GPUI `threads` tab bar. Other layouts and applications
retain their existing identities. The user's concept pairs simple established
program marks with rich, dark PC-game inventory scenery. The final requested
height is half the portrait concept: 42 logical pixels.

## Runtime ownership

- `herdr-app/tab-art.js`: `TAB_WIDTH = 180`, `TAB_HEIGHT = 42`, a 24px SVG mark,
  and center-cropped cover scenery. Marks render at 22px inside a fixed 24px slot;
  their viewBoxes normalize intrinsic whitespace without changing logo paths. The source painting renders at 180 × 84 and
  clips 21px from top and bottom. Never squeeze or distort it.
- `herdr-app/threads-tab-bar.js`: live label and close button, gold selected
  identical 1px slate frames (`#333d4c`) in every state. No active gold border or
  state-dependent border width. Foreground content shares one vertically centered
  flex row with a 16px label line height; there are no guessed text top offsets.
  Numeric tabs retain their number with the detected program name beside it;
  named tabs retain their name. Full name and cwd remain in the tooltip.
- `scripts/herdr-tab-art-setup`: source adapters, content-addressed asset install,
  52px layout block (42px tab + tray/outer space), rollback and native scroll
  handle. It preserves the shared upstream drag implementation except its height.
- `herdr-app/artwork/catalog.json`: all 121 program-to-glyph/scene/color mappings;
  generic `program` and `agent` fallback keys remain with upstream `tile()`.
- `herdr-app/artwork/effects`: graphite alpha overlays for label contrast and
  overflow edge fades. GPUI `.bg()` takes a color string, not a Background object.
- `scripts/herdr-tab-art-build`: build-time derivatives/contact sheets. Source
  paintings come from imagegen, original marks from Herdr's licensed SVG catalog.

Use native horizontal scrolling without a visible scrollbar, with edge fades
only when total tab width exceeds the viewport. Both fades indicate overflow;
there is no exposed native scroll-offset getter. Selection changes and viewport
resizing reveal the active tab. Close presses stop propagation before tab dragging.
The bar's native measured height can be smaller because of saved layout clicks;
tabs adapt to that height (up to 42px), vertically centering marks and labels.
Never clip a 42px tile into a shorter saved viewport or lose its border sides.
Keep native program detection, context menus, keyboard shortcuts, status dots and
terminal behavior. No extra animation loops, web/CSS runtime, or package dependency.

The active artwork stays at full brightness. Inactive scenery gets a 72% graphite
shade and its logo is 45% opaque; labels stay readable in `#979eac`. Active labels
use `#f2f4f8`. Status dots keep their full brightness.

## Validation

Parse every glyph, decode every PNG, check catalog coverage, exercise install /
repeat / restore / upstream-change failure, and run populated native mod checks.
Inspect the real bar after the file watcher reloads; an immediate screenshot can
still show a previous frame. Review contact sheets at real UI size and high DPI.
