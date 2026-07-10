# ZenNotes themes

Each subfolder here is a theme. Drop one in and it shows up under
**Settings → Appearance → Custom themes** (edits apply live). The folder name is
the theme's id, so `my-theme/` → "my-theme".

## Layout

```
my-theme/
  manifest.json   # name, author, version, description, modes, preview
  theme.css       # the styles (required)
  my-font.woff2   # optional assets (fonts, images)
```

## manifest.json

```json
{
  "name": "My Theme",
  "author": "you",
  "version": "1.0.0",
  "description": "A short description.",
  "modes": "both",
  "preview": { "light": "#007aff", "dark": "#0a84ff" }
}
```

`modes` is `"light"`, `"dark"`, or `"both"`. `preview` colors are only used for
the swatch on the Settings card. A missing manifest is fine — the theme is then
named after its folder and assumed to support both modes.

## theme.css

Only the **active** theme's CSS is loaded, so you can use `:root` unscoped.
Put dark-mode overrides under `[data-theme-mode="dark"]`:

```css
:root {
  --z-bg: 255 255 255;     /* tokens are space-separated RGB triplets */
  --z-fg-1: 29 29 31;
  --z-accent: 0 122 255;
  /* …see Soft Paper for the full --z-* set… */
}
:root[data-theme-mode="dark"] {
  --z-bg: 28 28 30;
  --z-fg-1: 255 255 255;
  --z-accent: 10 132 255;
}
```

You can also write any other CSS (fonts, backgrounds, component tweaks).

## Fonts & images

Reference files that live beside `theme.css` with the `zen-theme://` scheme
(the host is your folder name). Remote URLs are not loaded.

```css
@font-face {
  font-family: "My Font";
  src: url(zen-theme://my-theme/my-font.woff2) format("woff2");
}
:root { --z-text-font: "My Font", ui-sans-serif, sans-serif; }
```

See `soft-paper/` in this folder for a complete example.
