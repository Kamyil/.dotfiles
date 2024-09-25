# TO FIX
- [ ] When adding new plugin and running nvim, it surely runs Lazy for installing that new plugin, but for some reason it then starts netrw instead of neo-tree (I dunno why)
- [ ] When setting colorscheme in `options.lua` (preferable place for that kind of settings), barbar doesn't apply colorscheme automatically (you have to rerun :colorscheme which is annoying and that's why colorscheme is still placed inside catppuccin.lua file)`:w
- [x] Lazy-related notifications blocks current editing, requiring you to hit Enter until it finally dissapers. Most likely we need some notification plugin to make it unblocking :/ -- EDIT: They're resolved by disabling notifications for lazy (+ installed notifier for moving other notifications to bottomr-right corner)

