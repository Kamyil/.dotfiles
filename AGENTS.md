# Dotfiles Agent Guidelines

## Repository Contract

- Root-level tool directories contain live configuration: `nvim/`, `kitty/`, `hypr/`, etc. Never add a second `config/` tree.
- Nix owns packages and symlink topology. Git owns mutable config contents.
- Repository configs must remain live-editable without a rebuild.
- Never replace out-of-store links with store-copied Home Manager files.
- Never run `sudo`, rebuild a system, modify files outside this repository, or remove installed applications.

## Nix Architecture

- `nix/flake.nix`: composition root and pinned inputs.
- `nix/macos.nix`: `MacBook-Pro-Kamil`, nix-darwin, Homebrew, Darwin packages/helpers.
- `nix/nixos.nix`: NixOS composition and Linux Home Manager settings.
- `nixos/configuration.nix`: active NixOS host configuration.
- `nixos/hardware-configuration.nix`: generated hardware configuration.
- `nix/shared.nix`: shared Home Manager entrypoint.
- `nix/home/links.nix`: out-of-store Home Manager links and collision checks.
- `nix/home/packages.nix`: shared user packages.
- `nix/home/shell.nix`: shared Zsh, prompt, history, and Git configuration.
- `nix/symlinks.nix`: authoritative common/Darwin/Linux repository link maps.
- `nix/overlays/`: active local overlays only. `omp` and OpenCode are the supported coding harnesses; do not restore the separate `pi` or Codex packages.

## Live Symlink Rules

- Add repository-backed links only in `nix/symlinks.nix`.
- Use `commonLinks` only when the app/config is valid on both systems.
- Darwin-only examples: Aerospace, SketchyBar, Hammerspoon, cmux.
- Linux-only examples: Hyprland, Waybar, Walker, Omarchy.
- `nix/home/links.nix` must use `mkOutOfStoreSymlink`; never use `force = true`.
- Missing sources, real targets, and unrelated symlinks must abort activation without modifying the target.
- Existing links already pointing into `~/.dotfiles` may be adopted.
- Rebuild only after changing packages or link topology. Normal config edits require no rebuild.

## Package and Shell Ownership

- Put cross-platform user tools in `nix/home/packages.nix`.
- Put platform user tools in `nix/macos.nix` or `nix/nixos.nix`.
- Keep NixOS system packages for recovery, services, and desktop/session integration.
- Before moving a package, confirm it remains installed in exactly one intended layer. Never silently drop capabilities while deduplicating.
- `fnm` owns interactive Node versions. Do not restore NVM initialization or a competing global `nodejs`.
- Bun is Nix-managed; do not add mutable `$HOME/.bun` PATH setup.
- Keep `programs.zsh.dotDir = config.home.homeDirectory`.
- Put `open`, `pbcopy`, and `defaults` helpers on Darwin; put `xdg-open` and `fusermount` helpers on Linux.
- Quote shell paths, hosts, and user-selected values.

## Nix Editing Checks

- Flakes ignore untracked imported files. Add new Nix files to the Git index, or use `git add -N <path>`, before evaluation.
- Format changed Nix files with `nixfmt`.
- Required final check:

```sh
nix flake check --no-build ./nix
```

- Validate generated Zsh content when shell configuration changes:

```sh
nix eval --raw ./nix#darwinConfigurations.MacBook-Pro-Kamil.config.home-manager.users.kamil.programs.zsh.initContent | zsh -n
nix eval --raw ./nix#nixosConfigurations.nixos.config.home-manager.users.kamil.programs.zsh.initContent | zsh -n
```

- Let the user apply changes with `nrs`; never run it for them.

## NixOS Desktop Invariants

- NixOS uses Hyprland, Waybar, Walker, Elephant, and `swaybg`; do not restore retired window-manager configs.
- `Super+Space` launches Walker; `Super+Escape` selects emoji; `Super+Ctrl+E` selects symbols.
- Omarchy scripts live in `omarchy/bin` and must remain executable.
- `OMARCHY_PATH` and Omarchy links are declared in `nix/nixos.nix` and `nix/symlinks.nix`.
- Keep required desktop packages: `waybar`, `walker`, `uwsm`, `swaybg`, `pulsemixer`, `pamixer`, `rfkill_udev`, `impala`, `bluetuith`, `wtype`, and `wl-clipboard`.
- Check Hyprland changes with `hyprctl configerrors`; let the user perform disruptive restarts.

## Documentation and Hygiene

- Update `README.md` when changing entrypoints, package roles, link maps, platforms, overlays, or rebuild behavior.
- Verify every local README link and Mermaid path exists.
- Keep generated state ignored: `.DS_Store`, logs, Python bytecode, caches, backups, MRU files, and application state.
- Never commit secrets, API keys, or `.env` contents.

## Style and Commits

- Shell: `#!/usr/bin/env bash`, quoted expansions, ShellCheck-compatible.
- Lua: local variables, `snake_case`; use repository Stylua settings.
- Preserve the surrounding config style; use `nixfmt` for Nix.
- Commit format: `(topic) - (feature/change)`, e.g. `(nix) - update omp overlay`.
