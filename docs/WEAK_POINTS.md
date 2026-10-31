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
