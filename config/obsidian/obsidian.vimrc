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

" Paste clipboard into selected text/word, useful for Markdown links.
map <A-p> :pasteinto
