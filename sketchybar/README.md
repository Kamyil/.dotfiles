# SketchyBar Configuration

This configuration provides both **shell-based** (current) and **Lua-based** (future) versions.

## Current Setup (Shell-based)
- Uses `sketchybarrc` as main entry point
- Modular structure inspired by the Lua version
- Compatible with current nix-installed sketchybar

## Future Lua Setup
The Lua files are ready for when Lua API support becomes available:
- `init.lua` - Main Lua bootstrap
- `appearance.lua` - Colors and themes (Catppuccin)
- `bar.lua` - Bar configuration
- `items/*.lua` - Individual item configurations
- `helpers/` - Lua helper modules and app icons

## Enabling Lua Support

### Option 1: Wait for Official Support
The SketchyBar Lua API is still in development. Check the [SketchyBar repository](https://github.com/FelixKratz/SketchyBar) for updates.

### Option 2: Manual Build (Advanced)
If Lua support becomes available, you can build it manually:
```bash
# Run the provided script
~/.dotfiles/scripts/install-sketchybar-lua.sh

# Then switch to Lua configuration
mv ~/.dotfiles/sketchybar/sketchybarrc ~/.dotfiles/sketchybar/sketchybarrc.shell
mv ~/.dotfiles/sketchybar/sketchybarrc.lua ~/.dotfiles/sketchybar/sketchybarrc
```

### Option 3: Custom Nix Package
Create a custom nix package with Lua support enabled.

## Features
- **Catppuccin theming** (Macchiato variant)
- **Aerospace integration** with workspace app icons
- **Modular structure** for easy customization
- **Font flexibility** with multiple options
- **Icon system** with SF Symbols + Nerd Font fallbacks