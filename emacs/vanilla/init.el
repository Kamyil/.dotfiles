;;; init.el --- Kamil's Vanilla Emacs Config (Neovim equivalent) -*- lexical-binding: t; -*-
;;
;; A minimal but complete Emacs configuration that replicates Neovim workflow.
;; Requires Emacs 29+ for native tree-sitter and use-package.
;;
;; To use: ln -sf ~/.dotfiles/emacs/vanilla/init.el ~/.emacs.d/init.el
;;
;; First run will take a while to install packages.

;;; ============================================================================
;;; PACKAGE MANAGEMENT (lazy.nvim equivalent)
;;; ============================================================================

;; Initialize package sources
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

;; Refresh package list on first run
(unless package-archive-contents
  (package-refresh-contents))

;; use-package is built into Emacs 29+
(require 'use-package)
(setq use-package-always-ensure t)  ; Auto-install packages

;;; ============================================================================
;;; BASIC SETTINGS (matching your vim.o.* options)
;;; ============================================================================

;; Line numbers (relative, like your config)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Disable line numbers for some modes
(dolist (mode '(term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Theme/Colors (vim.o.termguicolors = true)
(setq custom-safe-themes t)

;; No line wrap (vim.o.wrap = false)
(setq-default truncate-lines t)

;; Tabs (tabstop = 4, expandtab = false)
(setq-default tab-width 4
              indent-tabs-mode t)

;; No swap/backup files (vim.o.swapfile = false)
(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil)

;; Don't show mode in echo area (vim.o.showmode = false)
(setq-default mode-line-modes nil)

;; Leader key (Space)
(defvar kamil/leader-key "SPC")

;; Clipboard (vim.o.clipboard = 'unnamedplus')
(setq select-enable-clipboard t
      select-enable-primary t)

;; UTF-8 encoding
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; No cursor line highlight (vim.o.cursorline = false)
(global-hl-line-mode -1)

;; Undo settings (vim.opt.undofile = true)
(setq undo-limit 80000000
      evil-want-fine-undo t)

;; Update time (vim.opt.updatetime = 100)
(setq idle-update-delay 0.1)

;; Scroll margin (vim.opt.scrolloff = 8)
(setq scroll-margin 8
      hscroll-margin 8)

;; Mouse support (vim.opt.mouse = 'a')
(setq mouse-wheel-scroll-amount '(3 ((shift) . 1))
      mouse-wheel-progressive-speed nil)

;; Search (ignorecase + smartcase)
(setq case-fold-search t)

;; Whitespace display (vim.opt.list = true)
(setq-default show-trailing-whitespace t)
(setq whitespace-style '(face tabs tab-mark trailing))
(global-whitespace-mode 1)

;; Folding settings
(setq-default foldmethod 'syntax)

;; Disable startup screen
(setq inhibit-startup-message t
      initial-scratch-message nil)

;; Clean UI
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

;; Bell
(setq visible-bell t
      ring-bell-function 'ignore)

;; Yes/No -> y/n
(fset 'yes-or-no-p 'y-or-n-p)

;; Revert buffers when files change on disk
(global-auto-revert-mode 1)

;;; ============================================================================
;;; FONTS
;;; ============================================================================

(set-face-attribute 'default nil
                    :family "Berkeley Mono"
                    :height 140
                    :weight 'regular)

(set-face-attribute 'fixed-pitch nil
                    :family "Berkeley Mono"
                    :height 140)

(set-face-attribute 'variable-pitch nil
                    :family "Berkeley Mono"
                    :height 140)

;;; ============================================================================
;;; EVIL MODE (Vim keybindings - ESSENTIAL)
;;; ============================================================================

(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-respect-visual-line-mode t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  
  ;; Set initial state for some modes
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

;; Evil collection - vim bindings for many modes
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Evil surround (mini.surround equivalent)
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;; Evil commentary (commenting)
(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

;;; ============================================================================
;;; GENERAL (Leader key bindings)
;;; ============================================================================

(use-package general
  :after evil
  :config
  (general-create-definer kamil/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Top level bindings
  (kamil/leader-keys
    "w" '(save-buffer :which-key "Save")
    "q" '(save-buffers-kill-terminal :which-key "Quit")
    "e" '(dired-jump :which-key "Explorer")
    "u" '(undo-tree-visualize :which-key "Undo tree")
    "/" '(evil-window-vsplit :which-key "Split vertical")
    "-" '(evil-window-split :which-key "Split horizontal")
    "D" '(flycheck-explain-error-at-point :which-key "Diagnostics"))

  ;; Find prefix
  (kamil/leader-keys
    "f" '(:ignore t :which-key "Find")
    "ff" '(project-find-file :which-key "Find file")
    "fw" '(consult-ripgrep :which-key "Find words")
    "fk" '(describe-bindings :which-key "Find keymaps")
    "fr" '(consult-recent-file :which-key "Recent files"))

  ;; LSP prefix
  (kamil/leader-keys
    "l" '(:ignore t :which-key "LSP")
    "la" '(eglot-code-actions :which-key "Code action")
    "lf" '(eglot-format-buffer :which-key "Format")
    "lr" '(eglot-rename :which-key "Rename")
    "ld" '(xref-find-definitions :which-key "Definition")
    "lD" '(xref-find-references :which-key "References"))

  ;; Git prefix
  (kamil/leader-keys
    "g" '(:ignore t :which-key "Git")
    "gg" '(magit-status :which-key "Magit status")
    "gb" '(magit-blame-addition :which-key "Git blame")
    "gc" '(:ignore t :which-key "Conflict")
    "gcc" '(smerge-keep-upper :which-key "Keep current")
    "gci" '(smerge-keep-lower :which-key "Keep incoming")
    "gcb" '(smerge-keep-all :which-key "Keep both"))

  ;; Notes prefix  
  (kamil/leader-keys
    "n" '(:ignore t :which-key "Notes")
    "ni" '(kamil/note-inbox :which-key "Inbox")
    "nw" '(kamil/note-weekly-browse :which-key "Weekly")
    "np" '(kamil/note-previous-week :which-key "Prev week")
    "nf" '(kamil/note-find :which-key "Find note")
    "ns" '(kamil/note-search :which-key "Search notes")
    "nc" '(kamil/note-capture :which-key "Capture")
    "na" '(org-agenda :which-key "Agenda")
    "nt" '(:ignore t :which-key "Todo/Time")
    "nts" '(kamil/timer-start :which-key "Start timer")
    "nte" '(kamil/timer-stop :which-key "Stop timer")
    "ntx" '(kamil/toggle-checkbox :which-key "Toggle todo"))

  ;; Refactor prefix
  (kamil/leader-keys
    "r" '(:ignore t :which-key "Refactor")
    "rr" '(eglot-rename :which-key "Rename"))

  ;; AI prefix
  (kamil/leader-keys
    "a" '(:ignore t :which-key "AI")
    "ac" '(copilot-complete :which-key "Complete")
    "aa" '(copilot-accept-completion :which-key "Accept")))

;;; ============================================================================
;;; WHICH-KEY (which-key.nvim equivalent)
;;; ============================================================================

(use-package which-key
  :init
  (which-key-mode)
  :config
  (setq which-key-idle-delay 0.2
        which-key-idle-secondary-delay 0.05))

;;; ============================================================================
;;; THEME (kanagawa-paper equivalent)
;;; ============================================================================

;; Kanagawa theme (matching your Neovim kanagawa-paper)
(use-package kanagawa-themes
  :straight (:host github :repo "Fabiokleis/kanagawa-emacs" :files ("*.el"))
  :config
  (load-theme 'kanagawa t))

;; Alternative: ef-themes (similar warm tones)
(use-package ef-themes)
  ;; Uncomment to use: (load-theme 'ef-autumn t)

;; Alternative: doom-themes
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
  ;; Uncomment to use: (load-theme 'doom-gruvbox t)

;; Catppuccin (you have this in neovim)
(use-package catppuccin-theme)
  ;; Uncomment to use: (load-theme 'catppuccin t)

;;; ============================================================================
;;; MODELINE (lualine.nvim equivalent)
;;; ============================================================================

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 28
        doom-modeline-bar-width 3
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-file-name-style 'relative-to-project))

;; Icons for modeline
(use-package nerd-icons)

;;; ============================================================================
;;; COMPLETION (vertico stack - fzf-lua equivalent)
;;; ============================================================================

;; Vertico - vertical completion UI
(use-package vertico
  :init
  (vertico-mode)
  :config
  (setq vertico-cycle t
        vertico-count 15))

;; Orderless - flexible completion matching
(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

;; Marginalia - rich annotations
(use-package marginalia
  :init
  (marginalia-mode))

;; Consult - enhanced commands
(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer))
  :config
  (setq consult-narrow-key "<"))

;; Embark - contextual actions
(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)))

(use-package embark-consult
  :after (embark consult))

;;; ============================================================================
;;; CODE COMPLETION (blink.cmp equivalent)
;;; ============================================================================

;; Corfu - fast, minimal completion
(use-package corfu
  :init
  (global-corfu-mode)
  :config
  (setq corfu-cycle t
        corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 1
        corfu-quit-no-match 'separator))

;; Cape - completion extensions
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;;; ============================================================================
;;; LSP (nvim-lspconfig equivalent)
;;; ============================================================================

;; Eglot - built-in LSP client (simpler than lsp-mode)
(use-package eglot
  :ensure nil  ; built-in
  :hook ((typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure)
         (js-ts-mode . eglot-ensure)
         (svelte-mode . eglot-ensure)
         (php-mode . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (lua-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t
        eglot-events-buffer-size 0))

;; Flycheck for diagnostics
(use-package flycheck
  :init
  (global-flycheck-mode)
  :config
  (setq flycheck-display-errors-delay 0.1))

;;; ============================================================================
;;; TREESITTER (nvim-treesitter equivalent)
;;; ============================================================================

;; Tree-sitter is built into Emacs 29+
(use-package treesit-auto
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

;;; ============================================================================
;;; FILE EXPLORER (oil.nvim equivalent)
;;; ============================================================================

;; Dired enhancements
(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :config
  (setq dired-listing-switches "-agho --group-directories-first"
        dired-dwim-target t
        delete-by-moving-to-trash t))

;; Dired icons
(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; Dirvish - polished dired (closer to oil.nvim)
(use-package dirvish
  :init
  (dirvish-override-dired-mode)
  :config
  (setq dirvish-quick-access-entries
        '(("h" "~/" "Home")
          ("d" "~/Downloads/" "Downloads")
          ("s" "~/second-brain/" "Second Brain")
          ("c" "~/.dotfiles/" "Dotfiles"))))

;;; ============================================================================
;;; GIT (magit - better than lazygit!)
;;; ============================================================================

(use-package magit
  :commands magit-status
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Git gutter (git signs in fringe)
(use-package diff-hl
  :init
  (global-diff-hl-mode)
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

;;; ============================================================================
;;; AUTOPAIRS (nvim-autopairs equivalent)
;;; ============================================================================

(use-package smartparens
  :init
  (smartparens-global-mode)
  :config
  (require 'smartparens-config))

;;; ============================================================================
;;; INDENT GUIDES (indent-blankline.nvim equivalent)
;;; ============================================================================

(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character
        highlight-indent-guides-character ?│
        highlight-indent-guides-responsive 'top))

;;; ============================================================================
;;; TODO COMMENTS (todo-comments.nvim equivalent)
;;; ============================================================================

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-keyword-faces
        '(("TODO" . "#FFB86C")
          ("FIXME" . "#FF5555")
          ("BUG" . "#FF5555")
          ("HACK" . "#8BE9FD")
          ("NOTE" . "#50FA7B")
          ("DEPRECATED" . "#6272A4"))))

;;; ============================================================================
;;; COLOR HIGHLIGHTING (nvim-highlight-colors equivalent)
;;; ============================================================================

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode))

;;; ============================================================================
;;; UNDO TREE (undotree equivalent)
;;; ============================================================================

(use-package undo-tree
  :init
  (global-undo-tree-mode)
  :config
  (setq undo-tree-auto-save-history t
        undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))))

;;; ============================================================================
;;; PROJECT MANAGEMENT (projectile)
;;; ============================================================================

(use-package projectile
  :init
  (projectile-mode +1)
  :config
  (setq projectile-project-search-path '("~/projects" "~/work")))

;;; ============================================================================
;;; MARKDOWN (render-markdown.nvim equivalent)
;;; ============================================================================

(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :config
  (setq markdown-fontify-code-blocks-natively t
        markdown-enable-wiki-links t))

;;; ============================================================================
;;; ORG MODE (obsidian.nvim equivalent - but BETTER)
;;; ============================================================================

(use-package org
  :config
  (setq org-directory "~/second-brain/"
        org-agenda-files '("~/second-brain/")
        org-default-notes-file (concat org-directory "inbox.org")
        org-log-done 'time
        org-hide-emphasis-markers t))

;; Org-roam (Obsidian-like zettelkasten)
(use-package org-roam
  :config
  (setq org-roam-directory "~/second-brain/")
  (org-roam-db-autosync-mode))

;;; ============================================================================
;;; COPILOT (copilot.lua equivalent)
;;; ============================================================================

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("M-j" . copilot-accept-completion)
              ("M-n" . copilot-next-completion)
              ("M-p" . copilot-previous-completion)))

;;; ============================================================================
;;; CUSTOM FUNCTIONS (ported from your Lua modules)
;;; ============================================================================

;; --- Notes/Second-brain functions ---

(defvar kamil/weekly-dir (expand-file-name "weekly" "~/second-brain/"))

(defun kamil/get-weekly-file ()
  "Return the path to current week's note file."
  (let ((year (format-time-string "%G"))
        (week (format-time-string "%V")))
    (expand-file-name (format "%s-W%s.md" year week) kamil/weekly-dir)))

(defun kamil/note-inbox ()
  "Open current week's note and go to end."
  (interactive)
  (find-file (kamil/get-weekly-file))
  (goto-char (point-max)))

(defun kamil/note-weekly-browse ()
  "Browse weekly notes."
  (interactive)
  (let ((default-directory kamil/weekly-dir))
    (call-interactively #'find-file)))

(defun kamil/note-previous-week ()
  "Open previous week's note."
  (interactive)
  (let* ((prev-time (time-subtract (current-time) (days-to-time 7)))
         (year (format-time-string "%G" prev-time))
         (week (format-time-string "%V" prev-time)))
    (find-file (expand-file-name (format "%s-W%s.md" year week) kamil/weekly-dir))))

(defun kamil/note-find ()
  "Find notes by filename."
  (interactive)
  (let ((default-directory "~/second-brain/"))
    (call-interactively #'project-find-file)))

(defun kamil/note-search ()
  "Search notes content."
  (interactive)
  (let ((default-directory "~/second-brain/"))
    (call-interactively #'consult-ripgrep)))

(defun kamil/expand-dates (text)
  "Expand relative dates in TEXT."
  (let ((today (format-time-string "%Y-%m-%d"))
        (tomorrow (format-time-string "%Y-%m-%d" (time-add (current-time) (days-to-time 1)))))
    (thread-last text
      (replace-regexp-in-string "@scheduled(today)" (format "@scheduled(%s)" today))
      (replace-regexp-in-string "@scheduled(tomorrow)" (format "@scheduled(%s)" tomorrow))
      (replace-regexp-in-string "@deadline(today)" (format "@deadline(%s)" today))
      (replace-regexp-in-string "@deadline(tomorrow)" (format "@deadline(%s)" tomorrow)))))

(defun kamil/note-capture ()
  "Capture a task to weekly note's Capture section."
  (interactive)
  (let* ((task (read-string "Capture: "))
         (file (kamil/get-weekly-file))
         (expanded (kamil/expand-dates task)))
    (with-current-buffer (find-file-noselect file)
      (goto-char (point-min))
      (if (search-forward "## Capture" nil t)
          (progn
            (forward-line 1)
            (while (looking-at "^\\s-*$") (forward-line 1))
            (insert (format "- [ ] %s\n" expanded))
            (save-buffer)
            (message "Captured to weekly note"))
        (message "No '## Capture' section found")))))

(defun kamil/toggle-checkbox ()
  "Toggle markdown checkbox on current line."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (cond
     ((looking-at ".*- \\[ \\]")
      (replace-match (replace-regexp-in-string "- \\[ \\]" "- [x]" (match-string 0))))
     ((looking-at ".*- \\[x\\]")
      (replace-match (replace-regexp-in-string "- \\[x\\]" "- [ ]" (match-string 0))))
     ((looking-at ".*- \\[-\\]")
      (replace-match (replace-regexp-in-string "- \\[-\\]" "- [x]" (match-string 0)))))))

;; --- Time tracking functions ---

(defvar kamil/timer-start nil)
(defvar kamil/timer-display nil)

(defun kamil/timer-format-duration (seconds)
  "Format SECONDS as duration string."
  (let* ((hours (/ seconds 3600))
         (minutes (/ (% seconds 3600) 60))
         (secs (% seconds 60)))
    (cond
     ((> hours 0) (format "%dh %02dm" hours minutes))
     ((> minutes 0) (format "%dm %02ds" minutes secs))
     (t (format "%ds" secs)))))

(defun kamil/timer-start ()
  "Start the timer."
  (interactive)
  (if kamil/timer-start
      (message "Timer already running!")
    (setq kamil/timer-start (current-time)
          kamil/timer-display (format-time-string "%H:%M"))
    (message "Timer started at %s" kamil/timer-display)))

(defun kamil/timer-stop ()
  "Stop timer and insert time annotation."
  (interactive)
  (if (not kamil/timer-start)
      (message "No timer running!")
    (let* ((end-time (current-time))
           (end-display (format-time-string "%H:%M"))
           (duration (floor (float-time (time-subtract end-time kamil/timer-start))))
           (formatted (kamil/timer-format-duration duration))
           (output (format "@time-spent(%s - %s, %s)" kamil/timer-display end-display formatted)))
      (insert output)
      (message "Timer stopped: %s" formatted)
      (setq kamil/timer-start nil kamil/timer-display nil))))

;;; ============================================================================
;;; ADDITIONAL KEYBINDINGS
;;; ============================================================================

;; Window navigation with C-h/j/k/l
(global-set-key (kbd "C-h") 'evil-window-left)
(global-set-key (kbd "C-j") 'evil-window-down)
(global-set-key (kbd "C-k") 'evil-window-up)
(global-set-key (kbd "C-l") 'evil-window-right)

;; K for hover
(evil-define-key 'normal 'global (kbd "K") 'eldoc-doc-buffer)

;; gd for definition
(evil-define-key 'normal 'global (kbd "g d") 'xref-find-definitions)

;; Quickfix navigation
(evil-define-key 'normal 'global (kbd "] q") 'next-error)
(evil-define-key 'normal 'global (kbd "[ q") 'previous-error)

;; Tab for fold toggle
(evil-define-key 'normal 'global (kbd "TAB") 'evil-toggle-fold)

;; Ctrl+A select all
(evil-define-key 'normal 'global (kbd "C-a") 'mark-whole-buffer)

;; Polish characters (insert mode)
(evil-define-key 'insert 'global (kbd "M-a") (lambda () (interactive) (insert "ą")))
(evil-define-key 'insert 'global (kbd "M-c") (lambda () (interactive) (insert "ć")))
(evil-define-key 'insert 'global (kbd "M-e") (lambda () (interactive) (insert "ę")))
(evil-define-key 'insert 'global (kbd "M-l") (lambda () (interactive) (insert "ł")))
(evil-define-key 'insert 'global (kbd "M-n") (lambda () (interactive) (insert "ń")))
(evil-define-key 'insert 'global (kbd "M-o") (lambda () (interactive) (insert "ó")))
(evil-define-key 'insert 'global (kbd "M-s") (lambda () (interactive) (insert "ś")))
(evil-define-key 'insert 'global (kbd "M-x") (lambda () (interactive) (insert "ź")))
(evil-define-key 'insert 'global (kbd "M-z") (lambda () (interactive) (insert "ż")))

;; Harpoon-like bookmarks with Alt+number
(evil-define-key 'normal 'global (kbd "M-a") 'bookmark-set)
(evil-define-key 'normal 'global (kbd "M-e") 'bookmark-bmenu-list)

;;; ============================================================================
;;; HIGHLIGHT ON YANK
;;; ============================================================================

(use-package evil-goggles
  :after evil
  :config
  (evil-goggles-mode)
  (setq evil-goggles-duration 0.2))

;;; ============================================================================
;;; FINAL SETUP
;;; ============================================================================

;; Create undo directory if needed
(unless (file-exists-p "~/.emacs.d/undo")
  (make-directory "~/.emacs.d/undo" t))

;; Server for faster startup on subsequent opens
(require 'server)
(unless (server-running-p)
  (server-start))

(provide 'init)
;;; init.el ends here
