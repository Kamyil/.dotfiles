# Dotfiles Agent Guidelines

- When doing commits, pls write them in following pattern: 
(topic) - (feature/change) ex. `(nix) (opencode) updated opencode overlay to use opencode v2`

## Build/Test Commands
- **No build system** - This is a configuration repository
- **Test configs**: Restart applications or source files (e.g., `source ~/.zshrc`)
- **NixOS**: Suggest changes but let user run `sudo nixos-rebuild switch` manually
- **Manual testing**: Check individual configs by loading them in respective applications
- **Hyprland config errors**: Use `hyprctl configerrors` to check config issues
- **Waybar restart**: `pkill -x waybar; waybar`
- **Walker restart**: `pkill -x walker` then trigger launcher (Super+Space)
- **Wallpaper restart**: `pkill -x swaybg; swaybg -i ~/.config/omarchy/current/background -m fill`

## Code Style Guidelines
- **Lua (WezTerm/Hammerspoon)**: Use `local` variables, snake_case, tabs for indentation
- **Shell scripts**: Use `#!/usr/bin/env bash`, proper quoting, shellcheck compliance
- **Config files**: Follow existing indentation patterns (2 spaces for YAML/TOML, 4 for others)
- **Git**: Use delta pager configured in .gitconfig
- **Stylua**: 2 spaces, 160 column width, single quotes preferred (see nvim/.stylua.toml)

## Architecture Patterns
- **Modular approach**: Separate configs per tool in respective directories
- **NixOS integration**: Flake-based with home-manager for packages and user activation, but not for store-owned dotfile contents
- **Live-editable dotfile links**: Config directories are intentionally out-of-store symlinks; Nix declares link topology, Git checkout provides mutable contents for app hot reloads without rebuilds
- **New config symlinks**: Add the source configuration under a root-level tool directory (never under `config/`), then declare its live symlink in `nix/symlinks.nix` to the actual destination, preferably under `$XDG_CONFIG_HOME` (`~/.config`) when the application supports it.
- **Symlink implementation**: Keep symlink targets in `nix/symlinks.nix`; do not add one-off `ln -s` blocks or unconditional `rm -rf` cleanup
- **Cross-platform**: macOS uses Aerospace for tiling and SketchyBar for the status bar; NixOS uses Hyprland and Waybar
- **Environment files**: Use .env files for sensitive data (see scripts/.env)
 
## README Architecture Documentation
- **Keep `README.md` current**: When changing Nix entrypoints, platform branches, package roles, symlink topology, root-level config layout, or rebuild workflow, update the corresponding README prose, tool matrix, and Mermaid diagrams in the same change.
- **Make it useful**: Diagrams and descriptions must reflect the actual repository, distinguish shared/macOS/NixOS behavior, and explain live-reload symlink flow for both humans and agents. Do not leave generic or aspirational architecture documentation.
- **Verify documentation**: Check every README path link and ensure diagrams name real files, outputs, hosts, and relationships. Remove stale claims when configuration moves or behavior changes.
- **Document new tools by role**: When adding or removing a platform package, Homebrew item, overlay, or major configured application, update the relevant platform matrix and equivalent tool entry if one exists.

## Omarchy-Based NixOS Setup (Hyprland/Walker/Waybar)
- **Walker (Nixpkgs)**: Uses v0.13 config at `walker/config.toml` with theme `walker/themes/kanagawa.css` (`theme = "kanagawa"`).
- **Launcher keybinds**: `Super+Space` runs `/home/kamil/.local/share/omarchy/bin/omarchy-launch-walker`, `Super+Escape` runs emoji picker (`-m emojis`), `Super+Ctrl+E` runs symbols (`-m symbols`).
- **Emoji auto-paste**: `omarchy/bin/omarchy-emoji-insert` (wl-copy + wtype). Requires `wtype` + `wl-clipboard`.
- **Omarchy scripts**: Stored in `omarchy/bin`, linked to `~/.local/share/omarchy/bin`. Keep scripts executable; Waybar uses absolute paths for reliability.
- **Waybar**: Config in `waybar/config`, style in `waybar/style.css` (JetBrainsMono Nerd Font, NixOS logo glyph). Indicator script at `omarchy/default/waybar/indicators/screen-recording.sh`.
- **Env + links**: `OMARCHY_PATH` set in `nix/nixos.nix`, assets linked via home-manager (e.g., `~/.config/omarchy/current/theme/waybar.css`, `~/.config/omarchy/current/background`, `~/.local/share/omarchy/bin`).
- **Wallpaper**: Hyprpaper is unreliable here; use `swaybg` autostart in `hypr/hyprland.conf` with `~/.config/omarchy/current/background`.
- **Required packages**: `waybar`, `walker`, `uwsm`, `swaybg`, `pulsemixer`, `pamixer`, `rfkill_udev` (not `rfkill`), `impala`, `bluetui*`, `wtype`.

## Important Notes
- Never commit secrets or API keys to .env files
- Test changes on non-production systems first
- Maintain backward compatibility for existing tool configurations
- **Focus on NixOS configs**: Rely entirely on nixos/ folder and files referenced there; do not reintroduce retired window-manager configurations

## System Operation Guidelines
- **NEVER run sudo commands** - Always let the user run them and provide output when requested
- **NEVER modify system files** outside of the dotfiles directory (e.g., /Applications, /System, /Library)
- **NEVER remove applications** - Let user handle manual app removals
- **Focus on configuration**: Edit config files and provide guidance, not execute system changes
- **User autonomy**: Respect user's desire to maintain full control over their system
