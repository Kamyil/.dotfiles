# Weak Points

Known problems in this repository. Tick an item when it is fixed.

- [ ] `nrs` hides the real Homebrew Bundle error. nh prints only stderr, while
      `brew bundle` reports failures on stdout. A failed cleanup shows only
      "Skipping … not installed" warnings. Reproduce with
      `brew bundle cleanup --file=<generated Brewfile>`.
- [ ] Cleanup cannot remove hand-installed apps that carry macOS app protection
      attributes (`com.apple.macl`, `com.apple.provenance`) unless the terminal has
      App Management permission. Activation then fails. Seen when Handy was
      replaced with Hex.
- [ ] Homebrew tap trust is split across two files. Interactive shells set
      `XDG_CONFIG_HOME` and read `~/.config/homebrew/trust.json`. Activation runs
      through sudo without it and reads `~/.homebrew/trust.json`. Trust declared
      in `nix/macos.nix` reaches only the activation file, so interactive `brew`
      can refuse casks from a declared tap (for example `anomalyco/tap`).
- [ ] `nix flake check --no-build ./nix` fails on this Mac with
      `path '/nix/store/rajfap2y…-source.drv' is not valid` while evaluating the
      NixOS configuration. This is local store corruption, not a config error;
      `nix-store --verify --check-contents --repair` should clear it.
- [ ] NixOS generation 107 shipped Vicinae 0.29.2 from a flake input that was
      never committed; the next rebuild from `main` would have dropped it. Build
      only from committed (or at least tracked) state so generations stay
      reproducible.
- [ ] Vicinae settings (`~/.config/vicinae/settings.json`) live outside the
      repo because Vicinae rewrites the file from its GUI. Theme, font, and
      keybinding choices are not versioned.
- [ ] Codex overlay bumps can leave a stale per-platform hash (0.164.0 shipped
      with an outdated `x86_64-unknown-linux-musl` hash, breaking `nrs` on
      NixOS). Overlay updates should prefetch every platform's assets.
- [ ] The official Herdr app and herdr-core (`nix/packages/herdr-app.nix`,
      `nix/packages/herdr-core.nix`) are prebuilt release binaries pinned by
      hand from `releases.herdr.dev/{app,core}/latest.json`; there is no
      upstream flake or update script. The app's built-in self-updater cannot
      write into the Nix store, so updates must be bumped here. macOS has no
      declarative Herdr app install (no Homebrew cask exists yet).
- [ ] Herdr app keybindings and settings (`~/.config/herdr-app/keys.json`,
      `settings.json`) live outside the repo: the app rewrites its home
      folder in place, so a repository symlink would be replaced. Only the
      theme is reproducible, via `scripts/herdr-theme`.
- [ ] `nvim/lua/config/keymaps.lua` is tab-indented and fails
      `stylua --check --config-path nvim/.stylua.toml` (spaces, width 2).
- [ ] `nvim/lua/config/plugins.lua` declares `lmilojevicc/herdr-splits.nvim`
      twice with identical settings.
- [ ] Herdr app Ctrl+h/j/k/l navigation depends on files outside the repo:
      the `nav` mod (`~/.config/herdr-app/mods/nav`), its key bindings, and the
      personal `main-nav` layout (a clone of `main` holding the mod in an empty
      floating block). The clone no longer receives Herdr's updates to `main`.
