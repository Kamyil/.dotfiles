# WezTerm Configuration Agent Guidelines

## Build/Test Commands
- No build system - this is a Lua-based WezTerm configuration
- Test changes by reloading config: configuration auto-reloads on file changes
- Manual reload: `wezterm cli reload-config` or restart WezTerm

## Code Style Guidelines
- **Language**: Lua 5.4 (WezTerm runtime)
- **Imports**: Use `local module = require("path")` at top of file
- **Variables**: Use `local` for all variables, snake_case naming
- **Tables**: Use explicit table constructors with proper formatting
- **Functions**: Define as `local function name()` or `module.function = function()`
- **Comments**: Use `--` for single line, `--[[]]` for blocks
- **Indentation**: Use tabs (existing codebase pattern)
- **Config structure**: Extend `config` table, return at end
- **Key bindings**: Use `wezterm.action` namespace for actions
- **Error handling**: No explicit error handling - WezTerm handles config errors gracefully

## Architecture Patterns
- Main config in `wezterm.lua`, modular features in separate files
- Use `require()` to import modules like `my_own_tmux`, `nvim_split_navigator`
- Merge key bindings using table.insert() pattern
- Use `wezterm.on()` for event handlers and custom functions
- Color schemes stored in `colors/` directory as TOML files