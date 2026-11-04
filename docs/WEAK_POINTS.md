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
