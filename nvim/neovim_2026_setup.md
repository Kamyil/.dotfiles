# Objectives
- [x] One file to make it easy to source inline and not force user to restart nvim after every single goddamn change
- [x] Native Neovim's package manager (it's beta, but we're preparing the config for future already)
- [x] Almost native LSP setup (exclude lsp-configs, since they're too cumbersome and annoying to configure manually for each one of them. We will use lspconfig for that)

# TODO before release
- [x] Setup LSP
- [x] Setup Treesitter
- [x] Setup Harpoon
- [x] Setup incline with harpoon items
- [x] Setup Native Package Manager
- [x] Setup blink for faster and better autocompletion
- [x] require('mini.surround').setup()
- [x] require('marks').setup()
- [x] require('nvim-autopairs').setup()
- [x] automatic detection of spaces/tabs

- [x] obsidian.nvim
- [x] Markdown viewer (render-markdown or marksview)
- [WAITING_FOR_PLUGIN_RELEASE] fff.nvim as file-picker when it will be released

# Fix
- [ ] Undercurl breaks accepting autocompletion on enter, when tmux defined with default-terminal=$(TERM)

# Maybe in future
- [ ] Fold imports (it didn't work for Svelte, so I would need to debug it)
