# ZenNotes overrides

Drop a `.css` file here and toggle it on under
**Settings → Appearance → Overrides**. Enabled overrides are injected on top of
whichever theme is active (built-in or custom), in filename order, so they win
the cascade.

## Override a theme color

Target `:root[data-theme]` so your rule beats both a built-in theme's
`:root[data-theme="…"]` block and a custom theme's `:root {}`:

```css
:root[data-theme] {
  --z-accent: 255 59 48;   /* space-separated RGB */
}
```

You can also write any other CSS to tweak the UI. Remote URLs are not loaded.

See `example.css` here for the full list of `--z-*` tokens and a few
ready-to-use recipes.
