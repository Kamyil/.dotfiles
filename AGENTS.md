# Dotfiles Agent Guidelines

## Build/Test Commands
- **No build system** - This is a configuration repository
- **Test configs**: Restart applications or source files (e.g., `source ~/.zshrc`)
- **NixOS**: Suggest changes but let user run `sudo nixos-rebuild switch` manually
- **Manual testing**: Check individual configs by loading them in respective applications

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

## Important Notes
- Never commit secrets or API keys to .env files
- Test changes on non-production systems first
- Maintain backward compatibility for existing tool configurations
- **Focus on NixOS configs**: Rely entirely on nixos/ folder and files referenced there - ignore legacy configs like i3/
- **NEVER run sudo commands** - Always let the user run them and provide output when requested