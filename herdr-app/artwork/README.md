# Illustrated Threads tabs

The `threads` layout uses fixed **180 × 42 logical pixel** tabs: simple, size-normalized
program marks in 24px slots, full-width painted scenery, live labels, and close buttons.
The artwork is cropped like a cover image from the same taller sources; it is
never stretched. Horizontal scrolling has no visible scrollbar. Soft edge fades
appear when the row overflows; native keyboard selection reveals the selected tab.
Every tab has the same frame and spacing. Active artwork is fully bright; inactive
scenery and marks are strongly dimmed while labels and status dots remain readable.
Icons, labels and close controls share a vertically centered row. Tabs adapt to
shorter saved bar heights.

## Complete catalog

[The catalog](catalog.json) covers all **121 program identities**: the installed
Herdr program SVG library plus the repository's omp mark. Nix, PHP, Node, Docker,
Git, Neovim and every shipped agent/editor/runtime/tool are included. Generic
`program` and `agent` fallbacks are deliberately preserved. No process detection,
launch commands, program aliases, or program-table overrides are changed.

The [glyph library](glyphs) retains upstream licenses and exact logo geometry.
The [runtime marks](marks) normalize intrinsic whitespace with viewBox changes
only, so a padded Codex mark and an edge-to-edge Nix mark have comparable size.
Codex omits its outer white tile so the terminal mark is visible as a native SVG
mask. omp uses the original repository card's pixel geometry without its frame.
Other Herdr layouts retain the original [SVG cards](../cards).

The collection uses **12 image-generated scene families**, assigned explicitly in
`catalog.json`: emerald forest, copper forge, amethyst, graphite vault, obsidian,
violet mist, snowy mountains, autumn leaves, underwater cargo, green machinery,
rose woodland and amber parchment. Related programs share scenery intentionally;
this is 121 program treatments, not 121 independently generated paintings.

Runtime assets are 720 × 336 PNG scenery, resolution-independent SVG marks, and
three tiny alpha overlays for label contrast and edge fades. All source paintings
are saved at full generated resolution in [sources](sources). The installed PNGs
and SVGs have content-hashed paths, and shared scenery is installed only once.
There are no new runtime dependencies, polling loops or background processes.

## Review artifacts

- [Every program at its actual UI size, with 24/32/64px marks](review/contact-sheet.png).
- [Enlarged review pages and full-resolution scene sheets](review).
- [Initial generation record](generation.json) and [additional scene prompts](scenery-generation.json).

The enlarged contact sheets are named `contact-sheet-large-01.png` through
`contact-sheet-large-11.png`. The `scene-full-*.png` sheets retain each generated
scene's full source resolution. These labeled composites inspect assets; actual
native-window screenshots are kept locally as ignored `live-*.png` files.

Images were made with the built-in `image_gen` tool. Production foregrounds use
simple original program marks, following the user's revised concept direction.
Pillow only downsamples/crops assets and creates review sheets/UI alpha masks.

## Apply and restore

For an already configured Herdr app:

```sh
scripts/herdr-tab-art-setup --check
scripts/herdr-tab-art-setup
herdr-app check ~/.config/herdr-app/mods/terminals-bar-square-threads
```

This updates only the generated threads bar, its assets, and the threads layout's
bar height (52px including its tray). The original bar and original height are
saved alongside the mod. Other settings, layouts, terminals, and program detection
remain untouched. To restore the original bar and height:

```sh
scripts/herdr-tab-art-setup --restore
```

The [full setup](../../scripts/herdr-app-setup) reapplies this treatment when it
regenerates the threads layout. No rebuild or `nrs` is needed. The repository
contract requires approval before applying changes outside the repository.

Build-time only: Python with Pillow and ImageMagick, then:

```sh
scripts/herdr-tab-art-build
python3 scripts/test-herdr-tab-art.py
```

## Validation

- All catalog SVGs parse; all scene PNGs decode at the expected dimensions.
- Installer dry-run, repeat installation, original bar/height restoration,
  preservation of other mods and mappings, and fail-before-write checks pass.
- A populated native-check fixture exercises all 121 program identities.
- The installed renderer passes `herdr-app check`; live screenshots confirm
  compact tabs, readable labels, simple logos including Codex, and no scrollbar.
- The required `nix flake check --no-build ./nix` passed on this Mac.
- Full pointer-drag/trackpad/zoom matrices and a GPU benchmark were not run.

The edge fades currently indicate overflow on both edges; Herdr's public scroll
handle does not expose the live offset for per-edge end detection. Its native
scrolling and selected-tab reveal remain authoritative.
