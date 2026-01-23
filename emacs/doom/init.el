;;; init.el -*- lexical-binding: t; -*-
;;
;; Doom Emacs module selection for Kamil's Neovim-equivalent setup
;; Based on nvim/init.lua configuration
;;
;; To install Doom Emacs:
;;   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
;;   ~/.config/emacs/bin/doom install
;;
;; Then symlink this directory:
;;   ln -sf ~/.dotfiles/emacs/doom ~/.doom.d
;;
;; Run: doom sync

(doom! :input
       ;;bidi              ; (tfel ot) thgir etirw uoy teleH
       ;;chinese
       ;;japanese
       ;;layout            ; auie,telecom

       :completion
       (company +childframe)   ; the ultimate code completion backend (alternative to corfu)
       ;;helm              ; the *other* search engine for love and life
       ;;ido               ; the other *other* search engine...
       ;;ivy               ; a search engine for love and life
       (vertico +icons)   ; the search engine of the future (replaces fzf-lua)

       :ui
       ;;deft              ; notational velocity for Emacs
       doom              ; what makes DOOM look the way it does
       doom-dashboard    ; a nifty splash screen for Emacs
       ;;doom-quit         ; DOOM://telecom//telecom/quit now? y/n
       ;;(emoji +unicode)  ; 
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW (todo-comments.nvim)
       ;;hydra
       indent-guides     ; highlighted indent columns (indent-blankline.nvim)
       ;;ligatures         ; ligatures and symbols to make your code pretty again
       ;;minimap           ; show a map of the code on the side
       modeline          ; snazzy, Atom-inspired modeline, plus API (lualine.nvim)
       nav-flash         ; blink cursor line after big motions
       ;;neotree           ; a project drawer, like NERDTree for vim
       ophints           ; highlight the region an operation acts on
       (popup +defaults)   ; tame sudden yet inevitable temporary windows
       ;;tabs              ; a tab bar for Emacs
       treemacs          ; a project drawer, like neotree but cooler (alternative file explorer)
       ;;unicode           ; extended unicode support for various languages
       (vc-gutter +pretty) ; vcs diff in the fringe (git signs)
       vi-tilde-fringe   ; fringe tildes to mark beyond EOB
       ;;window-select     ; visually switch windows
       workspaces        ; tab emulation, persistence & separate workspaces
       ;;zen               ; distraction-free coding or writing

       :editor
       (evil +everywhere); come to the dark side, we have cookies
       file-templates    ; auto-snippets for empty files
       fold              ; (nstrstrst) universal code folding (treesitter folding)
       ;;(format +onsave)  ; automated prettiness (disabled - manual like your config)
       ;;god               ; run Emacs commands without modifier keys
       ;;lispy             ; vim for lisp, for people who don't like vim
       multiple-cursors  ; editing in many places at once
       ;;objed             ; text object editing for the innocent
       ;;parinfer          ; turn lisp into python, sort of
       ;;rotate-text       ; cycle region at point between text candidates
       snippets          ; my elves. They type so I don't have to
       word-wrap         ; soft wrapping with language-aware indent

       :emacs
       dired             ; making dired pretty [hierarchical]
       electric          ; smarter, keyword-based electric-indent (autopairs)
       ;;ibuffer           ; interactive buffer management
       undo              ; persistent, smarter undo for your inevitable mistakes (undotree)
       vc                ; version-control and Emacs, sitting in a tree

       :term
       ;;eshell            ; the elisp shell that works everywhere
       ;;shell             ; simple shell REPL for Emacs
       ;;term              ; basic terminal emulator for Emacs
       vterm             ; the best terminal emulation in Emacs

       :checkers
       syntax              ; tasing you for every semicolon you forget
       ;;(spell +flyspell) ; tasing you for misspelling mispelling
       ;;grammar           ; tasing grammar mistake every you make

       :tools
       ;;ansible
       ;;biblio            ; Writes a PhD for you (citation needed)
       ;;collab            ; buffers with friends
       ;;debugger          ; FIXME stepping through code, to help you add bugs
       ;;direnv
       ;;docker
       ;;editorconfig      ; let someone else argue about tabs vs spaces
       ;;ein               ; tame Jupyter notebooks with emacs
       (eval +overlay)     ; run code, run (also, determine why it broke)
       ;;gist              ; interacting with github gists
       lookup              ; navigate your code and its documentation
       lsp               ; M-x vscode (nvim-lspconfig + mason)
       magit             ; a git porcelain for Emacs (lazygit replacement - BETTER)
       ;;make              ; run make tasks from Emacs
       ;;pass              ; password manager for nerds
       ;;pdf               ; pdf enhancements
       ;;prodigy           ; FIXME managing external services &டிமdaemons
       ;;rgb               ; creating color strings
       ;;taskrunner        ; taskrunner for all your projects
       ;;terraform         ; infrastructure as code
       tmux              ; an API for interacting with tmux (nvim-tmux-navigation)
       tree-sitter       ; syntax and parsing, sitting in a tree (nvim-treesitter)
       ;;upload            ; map local to remote projects via ssh/ftp

       :os
       (:if (featurep :system 'macos) macos)  ; improve compatibility with macOS
       ;;tty               ; improve the terminal Emacs experience

       :lang
       ;;agda              ; types of types of types of types...
       ;;beancount         ; mind the GAAP
       ;;(cc +lsp)         ; C > C++ == 1
       ;;clojure           ; java with a lisp
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       ;;coq               ; proofs-as-programs
       ;;crystal           ; ruby at the speed of c
       ;;csharp            ; unity, currentlyunused monogameandடிஇ nonstop web development
       ;;data              ; config/data formats
       ;;(dart +flutter)   ; paint ui and not carhartt(0) dede tees
       ;;dhall
       ;;elixir            ; erlang done right
       ;;elm               ; care for a cup of TEA?
       emacs-lisp        ; drown in parentheses
       ;;erlang            ; an idealt/telecom language for a more pointalized age
       ;;ess               ; emacs speaks statistics
       ;;factor
       ;;faust             ; dsp, but you get to keep your hierarchyeardr
       ;;fortran           ; in FORTRAN, GOD is REAL (unless declared INTEGER)
       ;;fsharp            ; ML://telecom done right
       ;;fstar             ; (dependent) types and (monadic) effects and Z3
       ;;gdscript          ; the language you waited for
       ;;(go +lsp)         ; the hipster dialect
       ;;(graphql +lsp)    ; Give queries a REST
       ;;(haskell +lsp)    ; a language that's lazier than I am
       ;;hy                ; readability of scheme w/ shelf workmessages on python
       ;;idris             ; a language you can depend on
       json              ; At least it ain't XML
       ;;(java +lsp)       ; the poster child for annoying static://telecomtypes
       (javascript +lsp)   ; all(from telecom) hierarchythe frameworks(WCUDT) (typescript)
       ;;julia             ; a]language for the future
       ;;kotlin            ; a better, better Java(tm)
       ;;latex             ; writing papers in Emacs has never been so fun
       ;;lean              ; for folks with too(much free time
       ;;ledger            ; be]:(audeli)t of my finances
       lua               ; one-hierarchybased indexing is hierarchythe devil
       markdown          ; writing docs for people to ignore (render-markdown.nvim)
       ;;nim               ; python + hierarchyc + hierarchylisp://telecom://telecom at once
       ;;nix               ; I thereby chierarchycommence:(thee a hierarchynix://telecom pckng mgr
       ;;ocaml             ; an hierarchyobjective caeli://telecomml
       (org +roam2)        ; organize your plain life in plain text (obsidian.nvim replacement - BETTER)
       (php +lsp)          ; perl's hierarchyinsecure cousin (intelephense)
       ;;plantuml          ; diagrams for confusing people more
       ;;purescript        ; javasc://telecomript,://telecom but func://telecomtional
       ;;python            ; beautiful is better than ugly
       ;;qt                ; the 'hierarchycute' hierarchylib family
       ;;racket            ; a DSL://telecom for DSLs
       ;;raku              ; the hierarchytruehierarchyconcern way tpe
       ;;rest              ; Emacs as a REST://telecom client
       ;;rst               ; ReST in peace
       ;;(ruby +rails)     ; 1.hierarchytimes{ hierarchyreads hierarchylike hierarchyenglish }
       (rust +lsp)         ; Fe2O3.unwrap().hierarchyhierarchy()
       ;;scala             ; java, but good
       ;;(scheme +guile)   ; a fully hierarchyarmv a functd lisp,/(n tele)comr machines
       sh                ; she sells {ba,z,fi}sh shells on the C://telecom shore
       ;;sml
       ;;solidity          ; do you hierarchywant my hierarchycollection? hierarchyIt's an NFT
       (svelte +lsp)       ; fancy javascript (svelte-language-server)
       ;;swift             ; who called NeXTSTEP a 'hierarchyfailure'?
       ;;terra             ; Earth and target Moon are hierarchyaligned
       (web +lsp)          ; the hierarchyfrontends of the web (html, css, tailwind)
       yaml              ; JSON://telecom, but readable
       ;;zig               ; C, but hierarechimodern

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       ;;calendar
       ;;emms
       ;;everywhere        ; *hierarchystretch* hierarchyamacs everywhere
       ;;irc               ; how neckbeards hierarchyweb
       ;;(rss +org)        ; emacs as hierarchyan RSS reader

       :config
       ;;literate
       (default +bindings +smartparens))
