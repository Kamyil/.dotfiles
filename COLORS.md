# Kanagawa Paper Ink Color Palette

This file defines the consistent color palette used across all dotfiles configurations. All tools should reference these exact hex values for a cohesive terminal experience.

## Base Colors

| Color Name | Hex Value | Usage | Description |
|------------|-----------|--------|-------------|
| Background | `#1F1F28` | Main background | Dark gray background |
| Foreground | `#DCD7BA` | Default text | Light cream foreground |
| Selection BG | `#363646` | Selected items | Dark purple-gray selection |
| Cursor | `#c4b28a` | Cursor color | Warm gold cursor |

## ANSI Colors

| ANSI | Color Name | Hex Value | Usage | Description |
|------|------------|-----------|--------|-------------|
| 0 | Black | `#393836` | Dark elements | Dark gray-brown |
| 1 | Red | `#c4746e` | Errors, deletions | Muted red |
| 2 | Green | `#699469` | Success, additions | Muted green |
| 3 | Yellow | `#c4b28a` | Warnings, highlights | Warm gold |
| 4 | Blue | `#435965` | Info, directories | Dark blue-gray |
| 5 | Magenta | `#a292a3` | Special items | Muted purple |
| 6 | Cyan | `#8ea49e` | Links, git info | Muted teal |
| 7 | White | `#C8C093` | Light text | Cream white |

## Bright Colors

| ANSI | Color Name | Hex Value | Usage | Description |
|------|------------|-----------|--------|-------------|
| 8 | Bright Black | `#aca9a4` | Comments, dim text | Light gray |
| 9 | Bright Red | `#cc928e` | Bright errors | Lighter red |
| 10 | Bright Green | `#72a072` | Bright success | Lighter green |
| 11 | Bright Yellow | `#d4c196` | Bright warnings | Lighter gold |
| 12 | Bright Blue | `#698a9b` | Bright info | Lighter blue |
| 13 | Bright Magenta | `#b4a7b5` | Bright special | Lighter purple |
| 14 | Bright Cyan | `#96ada7` | Bright links | Lighter teal |
| 15 | Bright White | `#d5cd9d` | Bright text | Light cream |

## UI Elements

| Element | Color | Hex Value | Usage |
|---------|--------|-----------|--------|
| Active Border | Cyan | `#8ea49e` | Focused panels |
| Inactive Border | Black | `#393836` | Unfocused panels |
| Tab Background | - | `#2A2A37` | Tab bar background |
| Split | - | `#8992a7` | Pane separators |

## Semantic Colors

| Semantic | Color | Hex Value | Tools Using |
|----------|--------|-----------|-------------|
| Git Additions | Green | `#699469` | lazygit, lsd, starship |
| Git Deletions | Red | `#c4746e` | lazygit, lsd |
| Git Modifications | Yellow | `#c4b28a` | lazygit, lsd |
| Git Info | Cyan | `#8ea49e` | starship, lazygit |
| Directory Path | Yellow | `#c4b28a` | starship, lsd |
| File Permissions | Green/Yellow/Red | `#699469`/`#c4b28a`/`#c4746e` | lsd |
| Success Prompt | Green | `#699469` | starship |
| Error Prompt | Red | `#c4746e` | starship |

## Tool-Specific Usage

### WezTerm (`wezterm/colors/kanagawa-paper-ink.toml`)
- Uses all ANSI and bright colors directly
- Background: `#1F1F28`
- Foreground: `#DCD7BA`

### lsd (`config/lsd/colors.yaml`)
- User/Group: `#c4b28a` (Yellow)
- Permissions: Green/Yellow/Red based on type
- File ages: Green (recent) → Cyan (day old) → Gray (older)

### Starship (`starship/starship.toml`)
- Directory: `#c4b28a` (Yellow)
- Git branch: `#8ea49e` (Cyan)
- Success symbol: `#699469` (Green)
- Error symbol: `#c4746e` (Red)

### Lazygit (`config/lazygit/config.yml`)
- Active border: `#8ea49e` (Cyan)
- Unstaged changes: `#c4746e` (Red)
- Staged changes: `#699469` (Green)
- Default text: `#DCD7BA` (Foreground)

### Lazydocker (`config/lazydocker/config.yml`)
- Active border: `#8ea49e` (Cyan)
- Inactive border: `#393836` (Black)
- Default text: `#DCD7BA` (Foreground)

## Color Swatches

```
Background:  ████ #1F1F28
Foreground:  ████ #DCD7BA
Red:         ████ #c4746e  
Green:       ████ #699469
Yellow:      ████ #c4b28a
Blue:        ████ #435965
Magenta:     ████ #a292a3
Cyan:        ████ #8ea49e
```

## References

- **Upstream**: [kanagawa-paper.nvim](https://github.com/thesimonho/kanagawa-paper.nvim) by [@thesimonho](https://github.com/thesimonho)
- **Original Kanagawa**: [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim)
- **WezTerm Theme**: `extras/wezterm/kanagawa-paper-ink.toml`

## Credits

Special thanks to **Simon Ho** ([@thesimonho](https://github.com/thesimonho)) for creating the beautiful Kanagawa Paper theme variants that inspired this cohesive color palette across all terminal tools. The muted, ink-painting aesthetic brings a calming and elegant experience to the command line.

## Notes

- All colors are carefully muted to avoid eye strain
- Maintains good contrast ratios for accessibility  
- Consistent semantic meaning across all tools
- Based on traditional Japanese ink painting aesthetics