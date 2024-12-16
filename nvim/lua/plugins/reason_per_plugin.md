# Plugins
- barbar - for best tabs integration. They have also built-in shortcuts for navigating between them using <leader>+1/2/3/...
- bigfile - for disabling some features when opening huge files, making it possible to edit such file without lags
- comment - for smart commenting the file (with auto detection how to comment in given file). // TODO: Replace it with newest built-in Neovim commenting module
- conform - for auto-formatting in files where `format_on_save` is enabled
- gitsigns - for displaying which line was added/modified/removed next to line number
- guess-indent - for auto inferring spacing/tabs per project if they're not defined inside `.editorconfig`
- indent-blankline - for having indentation guides (lines indicating where given function/class etc. end)
- lazygit - for Lazygit integration (best GIT TUI so far)
- blame - for handy git blame functionality
- lsp-lines - for best error messages so far. They're not only displaying it under the line with error, but they also stack and also display EXACT place in the line where error occurs. Best plugin so far
- lsp (Mason) - for installing LSPs and formatters
- mini - some collections of little enhancements from whole mini.nvim ecosystem. In this case, it gives convinient text-manipulation motions  like better Around/Inside and Surroundings and also adds better Statusline and autocloses brackets
- modes - for inline displaying color of your current mode on cursor, instead having to look down to check which mode you're in. It's convenient and visually practical and functional
- neo-tree - for having convinient and easy-to-use file-tree
- neogen - for better markdown annotations
- nvim-cmp - for autocompletion, powered by both LSP and Snippets 
- nvim-treesitter - for syntax highlighting and understanding the syntax allowing to do some text-object manipulations
- nvim_tmux_navigation - for easy movement between neovim and tmux panes using simple Ctrl + hjkl. So basically you can now consistently move between neo-tree <-> neovim splits <-> tmux using same intuitive shortcuts
- obsidian - for Obsidian integration, making possible to ditch Electron-based GUI app in favor of note-taking in Neovim completely
- markview - for inline rendering Markdown like in Obsidian, so thanks to it you don't have to rely on external Markdown preview rendereds 
- smartsplits - for having ability so split and conviniently move between those splits by using Ctrl + hjkl
- telescope - **CORE** plugin. Adds searcher for searching through files, contents and others
- todo-comments - for inline highlighting TODO/FIXME/WARNING/BUG etc. comments which gives little nice and pleasing visual indicator marking there is such thing. Without it it would be easy to miss such comment
- transparent - for enabling transparency which gives way different vibes while editing
- undotree - for having the tree and history of all Undo's, so you don't have to completely rely on Git when you want to revert the changes to state from given time
- webdevicons - for having nice collection of file icons
- which-key - for displaying the shortcuts and their descriptions after heading <leader> 
- vim-dadbod-ui - for having Database viewer and SQL runner
- legendary - for nice command-palette that comes quite handy when you don't remember how some command was named
- yankbank - for having persistent yank (copy) history across sessions (kinda like clipboard history but for yanks (copies)) 
- git-conflict - for visualizing and resolving git conflicts in inline fashion (kinda like in VSCode)

# Themes
My colleciton of themes that I found most practical and useful and pretty:

- catppuccin (currently using)
- tokyonight
- rosepine 


# Maybe will add, maybe not. Still thinking...
- [ ] [persisted.nvim](https://github.com/olimorris/persisted.nvim) for Session Managment
