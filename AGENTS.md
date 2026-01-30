# Dotfiles Agent Guidelines

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
- **NixOS integration**: Flake-based with home-manager for user configs
- **Symlink structure**: Config files linked via NixOS home-manager or manual setup
- **Cross-platform**: Some configs are macOS-specific (yabai, skhd, sketchybar)
- **Environment files**: Use .env files for sensitive data (see config/scripts/.env)
- **Home Manager preference**: NEVER create symlinks manually - always use NixOS home-manager configuration

## Omarchy-Based NixOS Setup (Hyprland/Walker/Waybar)
- **Walker (Nixpkgs)**: Uses v0.13 config at `config/walker/config.toml` with theme `config/walker/themes/kanagawa.css` (`theme = "kanagawa"`).
- **Launcher keybinds**: `Super+Space` runs `/home/kamil/.local/share/omarchy/bin/omarchy-launch-walker`, `Super+Escape` runs emoji picker (`-m emojis`), `Super+Ctrl+E` runs symbols (`-m symbols`).
- **Emoji auto-paste**: `config/omarchy/bin/omarchy-emoji-insert` (wl-copy + wtype). Requires `wtype` + `wl-clipboard`.
- **Omarchy scripts**: Stored in `config/omarchy/bin`, linked to `~/.local/share/omarchy/bin`. Keep scripts executable; Waybar uses absolute paths for reliability.
- **Waybar**: Config in `config/waybar/config`, style in `config/waybar/style.css` (JetBrainsMono Nerd Font, NixOS logo glyph). Indicator script at `config/omarchy/default/waybar/indicators/screen-recording.sh`.
- **Env + links**: `OMARCHY_PATH` set in `nix/nixos.nix`, assets linked via home-manager (e.g., `~/.config/omarchy/current/theme/waybar.css`, `~/.config/omarchy/current/background`, `~/.local/share/omarchy/bin`).
- **Wallpaper**: Hyprpaper is unreliable here; use `swaybg` autostart in `config/hypr/hyprland.conf` with `~/.config/omarchy/current/background`.
- **Required packages**: `waybar`, `walker`, `uwsm`, `swaybg`, `pulsemixer`, `pamixer`, `rfkill_udev` (not `rfkill`), `impala`, `bluetui*`, `wtype`.

## Important Notes
- Never commit secrets or API keys to .env files
- Test changes on non-production systems first
- Maintain backward compatibility for existing tool configurations
- **Focus on NixOS configs**: Rely entirely on nixos/ folder and files referenced there - ignore legacy configs like i3/

## System Operation Guidelines
- **NEVER run sudo commands** - Always let the user run them and provide output when requested
- **NEVER modify system files** outside of the dotfiles directory (e.g., /Applications, /System, /Library)
- **NEVER remove applications** - Let user handle manual app removals
- **Focus on configuration**: Edit config files and provide guidance, not execute system changes
- **User autonomy**: Respect user's desire to maintain full control over their system
