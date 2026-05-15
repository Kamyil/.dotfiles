" Obsidian Vim mode configuration.
" Loaded by the Vimrc Support plugin from the vault root as .obsidian.vimrc.

" Keep movement on the same physical keys as my Neovim setup.
" Vimrc Support reserves gl/gL for link navigation, so horizontal movement uses arrows.
noremap h <Left>
noremap j gj
noremap k gk
noremap l <Right>

" Move by rendered lines in Markdown paragraphs.
nmap <Down> gj
nmap <Up> gk

" Use system clipboard for yanks/pastes.
set clipboard=unnamed

" Space leader, matching Neovim muscle memory where Obsidian supports it.
" This plugin build does not support let mapleader, so use literal <Space> chords.
unmap <Space>

" Common editor actions via Obsidian commands.
exmap save obcommand editor:save-file
nmap <Space>w :save<CR>

exmap commandPalette obcommand command-palette:open
nmap <Space><Space> :commandPalette<CR>

exmap quickSwitcher obcommand switcher:open
nmap <Space>ff :quickSwitcher<CR>

exmap globalSearch obcommand global-search:open
nmap <Space>fw :globalSearch<CR>

exmap toggleChecklist obcommand editor:toggle-checklist-status
nmap <Space>ntx :toggleChecklist<CR>

exmap splitVertical obcommand workspace:split-vertical
nmap <Space>/ :splitVertical<CR>

exmap splitHorizontal obcommand workspace:split-horizontal
nmap <Space>- :splitHorizontal<CR>

" Neovim-style go to definition: open link/file under cursor.
nmap gd gf

" Neovim-style references: show backlinks for the active note.
exmap backlinks obcommand backlink:open
nmap grr :backlinks<CR>

exmap togglefold obcommand editor:toggle-fold
nmap <Tab> :togglefold<CR>
nmap za :togglefold<CR>

exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall<CR>

exmap foldall obcommand editor:fold-all
nmap zM :foldall<CR>

" Obsidian navigation that maps cleanly to Vim habits.
exmap back obcommand app:go-back
nmap <C-o> :back<CR>
nmap <C-t> :back<CR>

exmap forward obcommand app:go-forward
nmap <C-i> :forward<CR>

exmap tabnext obcommand workspace:next-tab
nmap gt :tabnext<CR>

exmap tabprev obcommand workspace:previous-tab
nmap gT :tabprev<CR>

" Lightweight surround/link helpers from Vimrc Support.
exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }

nunmap s
vunmap s
map s[ :surround_wiki<CR>
map s" :surround_double_quotes<CR>
map s' :surround_single_quotes<CR>
map s` :surround_backticks<CR>
map sb :surround_brackets<CR>
map s( :surround_brackets<CR>
map s) :surround_brackets<CR>
map s] :surround_square_brackets<CR>
map s{ :surround_curly_brackets<CR>
map s} :surround_curly_brackets<CR>

" Move selected lines up/down with J/K (matching Neovim muscle memory).
exmap moveSelectionDown jscommand { const from = editor.getCursor('from'); const to = editor.getCursor('to'); const start = from.line; let end = to.line; if (to.ch === 0 && to.line > start) end = to.line - 1; if (end >= editor.lineCount() - 1) return; const block = editor.getRange({ line: start, ch: 0 }, { line: end, ch: editor.getLine(end).length }); const next = editor.getLine(end + 1); editor.replaceRange(next + '\n' + block, { line: start, ch: 0 }, { line: end + 1, ch: next.length }); const new_start = start + 1; editor.setSelection({ line: new_start, ch: 0 }, { line: end + 1, ch: editor.getLine(end + 1).length }); }
exmap moveSelectionUp jscommand { const from = editor.getCursor('from'); const to = editor.getCursor('to'); const start = from.line; let end = to.line; if (to.ch === 0 && to.line > start) end = to.line - 1; if (start === 0) return; const block = editor.getRange({ line: start, ch: 0 }, { line: end, ch: editor.getLine(end).length }); const prev = editor.getLine(start - 1); editor.replaceRange(block + '\n' + prev, { line: start - 1, ch: 0 }, { line: end, ch: editor.getLine(end).length }); const new_start = start - 1; editor.setSelection({ line: new_start, ch: 0 }, { line: end - 1, ch: editor.getLine(end - 1).length }); }
vmap J :moveSelectionDown<CR>
vmap K :moveSelectionUp<CR>

" Paste clipboard into selected text/word, useful for Markdown links.
map <A-p> :pasteinto
