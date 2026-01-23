# Emacs Configuration (Neovim Migration)

This directory contains Emacs configurations that replicate my Neovim workflow.
Based on `nvim/init.lua`.

## Quick Start

### Option A: Doom Emacs (Recommended)

Doom Emacs is faster to set up and has sensible defaults for Vim users.

```bash
# 1. Install Emacs 29+ (GUI version recommended)
brew install emacs-plus@29 --with-native-comp --with-modern-papirus-icon

# 2. Install Doom Emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# 3. Link this config
rm -rf ~/.doom.d
ln -sf ~/.dotfiles/emacs/doom ~/.doom.d

# 4. Sync Doom
~/.config/emacs/bin/doom sync

# 5. Launch
emacs
```

### Option B: Vanilla Emacs

For full control and learning "real" Emacs.

```bash
# 1. Install Emacs 29+
brew install emacs-plus@29 --with-native-comp

# 2. Backup existing config
mv ~/.emacs.d ~/.emacs.d.bak 2>/dev/null

# 3. Create config directory and link
mkdir -p ~/.emacs.d
ln -sf ~/.dotfiles/emacs/vanilla/init.el ~/.emacs.d/init.el

# 4. Launch (first run will install packages)
emacs
```

## Directory Structure

```
emacs/
├── doom/           # Doom Emacs configuration
│   ├── init.el     # Module selection (what features to enable)
│   ├── config.el   # Personal config (keybindings, settings)
│   └── packages.el # Additional packages beyond Doom defaults
│
├── vanilla/        # Standalone Emacs configuration
│   └── init.el     # Complete config in one file
│
└── lisp/           # Shared custom Elisp modules (if needed)
```

## Keybinding Mapping (Neovim → Emacs)

| Neovim | Emacs | Description |
|--------|-------|-------------|
| `<Space>` | `SPC` | Leader key |
| `<leader>w` | `SPC w` | Save file |
| `<leader>q` | `SPC q` | Quit |
| `<leader>ff` | `SPC f f` | Find file |
| `<leader>fw` | `SPC f w` | Find words (grep) |
| `<leader>e` | `SPC e` | File explorer |
| `<leader>gg` | `SPC g g` | Git status (Magit) |
| `<leader>gb` | `SPC g b` | Git blame |
| `K` | `K` | Hover documentation |
| `gd` | `g d` | Go to definition |
| `grr` | `g r r` | Find references |
| `<leader>la` | `SPC l a` | Code action |
| `<leader>lr` | `SPC l r` | Rename symbol |
| `<leader>/` | `SPC /` | Vertical split |
| `<leader>-` | `SPC -` | Horizontal split |
| `C-h/j/k/l` | `C-h/j/k/l` | Window navigation |
| `<A-1..9>` | `M-1..9` | Harpoon/bookmark jump |
| `<A-a>` | `M-a` | Add to harpoon/bookmark |
| `<leader>u` | `SPC u` | Undo tree |
| `<Tab>` | `TAB` | Toggle fold |
| `<leader>ni` | `SPC n i` | Note inbox (weekly) |
| `<leader>nc` | `SPC n c` | Capture to weekly |
| `<leader>nts` | `SPC n t s` | Start timer |
| `<leader>nte` | `SPC n t e` | Stop timer |

## Plugin Mapping (Neovim → Emacs)

| Neovim Plugin | Emacs Equivalent | Notes |
|---------------|------------------|-------|
| lazy.nvim | use-package (built-in) | Package management |
| nvim-lspconfig | eglot (built-in) | LSP client |
| blink.cmp | corfu + cape | Completion |
| fzf-lua | vertico + consult | Fuzzy finding |
| oil.nvim | dired / dirvish | File explorer |
| nvim-treesitter | treesit (built-in) | Syntax highlighting |
| lazygit | magit | Git interface (BETTER!) |
| which-key.nvim | which-key | Key hints |
| mini.surround | evil-surround | Surround editing |
| nvim-autopairs | smartparens | Auto pairs |
| lualine.nvim | doom-modeline | Status line |
| kanagawa-paper | ef-themes / doom-themes | Color themes |
| indent-blankline | highlight-indent-guides | Indent guides |
| todo-comments.nvim | hl-todo | TODO highlighting |
| harpoon | bookmarks / harpoon.el | Quick file switching |
| obsidian.nvim | org-mode / org-roam | Note-taking |
| copilot.lua | copilot.el | AI completion |
| undotree | undo-tree | Undo visualization |

## Custom Functions Ported

### From `capture.lua`:
- `kamil/note-capture` - Quick capture to weekly note's "## Capture" section
- `kamil/expand-dates` - Expands `@scheduled(today)`, `@deadline(tomorrow)`, etc.

### From `timetracking.lua`:
- `kamil/timer-start` - Start a work timer
- `kamil/timer-stop` - Stop timer and insert `@time-spent(...)` annotation

### From `agenda.lua`:
- Use `org-agenda` instead - it's significantly more powerful

## Notes on Differences

### Better in Emacs:
- **Magit** - Git interface is genuinely better than lazygit
- **Org-mode** - If you switch from markdown, vastly more powerful
- **Native GUI** - Better fonts, images inline, true transparency
- **TRAMP** - Edit remote files over SSH seamlessly

### Different in Emacs:
- **No Mason** - Install language servers via your OS package manager
- **Fuzzy finding UX** - Vertico is vertical, feels different but powerful
- **File explorer** - Dired paradigm is different from oil.nvim

### Missing (no equivalent):
- **opencode.nvim** - Use gptel or ellama for AI chat
- **supermaven** - Use copilot.el instead
- **Your exact MHFU theme** - Would need manual porting

## First Steps After Installation

1. **Run** `M-x all-the-icons-install-fonts` for icons
2. **Configure Copilot**: `M-x copilot-login`
3. **Install Language Servers**:
   ```bash
   # TypeScript
   npm install -g typescript-language-server typescript
   
   # Svelte
   npm install -g svelte-language-server
   
   # PHP
   npm install -g intelephense
   
   # Lua
   brew install lua-language-server
   ```
4. **Try Magit**: `SPC g g` - it's life-changing

## Learning Resources

- [Doom Emacs Documentation](https://github.com/doomemacs/doomemacs/blob/master/docs/index.org)
- [Evil Mode Guide](https://github.com/emacs-evil/evil)
- [Mastering Emacs (book)](https://www.masteringemacs.org/)
- [System Crafters YouTube](https://www.youtube.com/c/SystemCrafters) - Great for Vim→Emacs users
