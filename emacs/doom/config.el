;;; config.el -*- lexical-binding: t; -*-
;;
;; Kamil's Doom Emacs config - Neovim equivalent
;; Based on nvim/init.lua
;;
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;;; ============================================================================
;;; IDENTITY
;;; ============================================================================
(setq user-full-name "Kamil"
      user-mail-address "")

;;; ============================================================================
;;; APPEARANCE (matching your Neovim aesthetics)
;;; ============================================================================

;; Theme - Kanagawa (matching your Neovim kanagawa-paper)
;; kanagawa-themes provides: kanagawa-wave (dark), kanagawa-dragon (darker), kanagawa-lotus (light)
(setq doom-theme 'kanagawa-wave)

;; Font configuration - Berkeley Mono
(setq doom-font (font-spec :family "Berkeley Mono" :size 14 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Berkeley Mono" :size 14)
      doom-big-font (font-spec :family "Berkeley Mono" :size 20))

;; Line numbers (relative like your Neovim config)
(setq display-line-numbers-type 'relative)

;; Disable line highlighting (cursorline = false in your config)
(remove-hook 'doom-first-buffer-hook #'global-hl-line-mode)

;; Scrolloff equivalent (vim.opt.scrolloff = 8)
(setq scroll-margin 8
      hscroll-margin 8)

;; Don't wrap lines (vim.o.wrap = false)
(setq-default truncate-lines t)

;; Transparent background (matching your kanagawa-paper transparent = true)
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; MHFU-style border colors (matching your FloatBorder highlight)
(custom-set-faces!
  '(vertical-border :foreground "#b89060")
  '(fringe :background nil))

;;; ============================================================================
;;; GENERAL SETTINGS (matching your vim.o.* settings)
;;; ============================================================================

;; Tabs vs Spaces (your config uses tabs with tabstop=4)
(setq-default tab-width 4
              indent-tabs-mode t)  ; Use tabs, not spaces

;; No swap files (vim.o.swapfile = false)
(setq auto-save-default nil
      make-backup-files nil)

;; Persistent undo (vim.opt.undofile = true)
(setq undo-tree-auto-save-history t)

;; Fast updates (vim.opt.updatetime = 100)
(setq idle-update-delay 0.1)

;; Timeout for key sequences (vim.opt.timeoutlen = 200)
(setq which-key-idle-delay 0.2)

;; Mouse support (vim.opt.mouse = 'a')
(setq mouse-wheel-scroll-amount '(3 ((shift) . 1))
      mouse-wheel-progressive-speed nil)

;; Case insensitive search (vim.opt.ignorecase + smartcase)
(setq case-fold-search t)

;; Encoding (vim.o.encoding = 'utf-8')
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

;; Show trailing whitespace (vim.opt.list = true with listchars)
(setq-default show-trailing-whitespace t)

;;; ============================================================================
;;; LEADER KEY MAPPINGS (Space as leader, like your config)
;;; ============================================================================

;; Doom uses SPC as leader by default - matches your vim.g.mapleader = ' '

;; Quick save (your <leader>w)
(map! :leader
      :desc "Save file" "w" #'save-buffer)

;; Quick quit (your <leader>q)
(map! :leader
      :desc "Quit Emacs" "q" #'save-buffers-kill-terminal)

;;; ============================================================================
;;; FILE FINDING (fzf-lua / fff.nvim equivalent)
;;; ============================================================================

;; <leader>ff - Find files (vertico + consult)
(map! :leader
      :desc "Find file" "f f" #'projectile-find-file)

;; <leader>fw - Find words / live grep
(map! :leader
      :desc "Search in project" "f w" #'+default/search-project)

;; <leader>fk - Find keymaps
(map! :leader
      :desc "Find keymaps" "f k" #'describe-bindings)

;; <leader>e - File explorer (oil.nvim equivalent - using dired)
(map! :leader
      :desc "File explorer" "e" #'dired-jump)

;;; ============================================================================
;;; LSP MAPPINGS (matching your nvim-lspconfig keymaps)
;;; ============================================================================

(map! :leader
      (:prefix ("l" . "LSP")
       :desc "Code action" "a" #'lsp-execute-code-action
       :desc "Format buffer" "f" #'+format/buffer
       :desc "Rename" "r" #'lsp-rename
       :desc "Definitions" "d" #'lsp-find-definition
       :desc "References" "D" #'lsp-find-references))

;; K for hover (same as your config)
(map! :n "K" #'lsp-describe-thing-at-point)

;; gd for go to definition
(map! :n "g d" #'lsp-find-definition)

;; grr for references
(map! :n "g r r" #'lsp-find-references)

;; <leader>D for diagnostics hover
(map! :leader
      :desc "Show diagnostics" "D" #'flycheck-explain-error-at-point)

;;; ============================================================================
;;; GIT (lazygit / git-conflict.nvim / blame.nvim equivalent)
;;; ============================================================================

;; <leader>gg - Open Magit (better than lazygit!)
(map! :leader
      :desc "Magit status" "g g" #'magit-status)

;; <leader>gb - Git blame
(map! :leader
      :desc "Git blame" "g b" #'magit-blame-addition)

;; Git conflict resolution (smerge-mode)
(map! :leader
      (:prefix ("g c" . "Git conflict")
       :desc "Keep current" "c" #'smerge-keep-upper
       :desc "Keep incoming" "i" #'smerge-keep-lower
       :desc "Keep both" "b" #'smerge-keep-all
       :desc "Keep none" "n" #'smerge-kill-current
       :desc "Prev conflict" "[" #'smerge-prev
       :desc "Next conflict" "]" #'smerge-next))

;;; ============================================================================
;;; HARPOON EQUIVALENT (quick file switching)
;;; ============================================================================

;; Using bookmarks as harpoon equivalent
;; Alt+a to add bookmark (like your <A-a>)
(map! :n "M-a" #'bookmark-set)

;; Alt+e to list bookmarks (like your <A-e>)
(map! :n "M-e" #'bookmark-bmenu-list)

;; Alt+1-9 for quick bookmark jumps
(map! :n "M-1" (cmd! (bookmark-jump "1")))
(map! :n "M-2" (cmd! (bookmark-jump "2")))
(map! :n "M-3" (cmd! (bookmark-jump "3")))
(map! :n "M-4" (cmd! (bookmark-jump "4")))
(map! :n "M-5" (cmd! (bookmark-jump "5")))
(map! :n "M-6" (cmd! (bookmark-jump "6")))
(map! :n "M-7" (cmd! (bookmark-jump "7")))
(map! :n "M-8" (cmd! (bookmark-jump "8")))
(map! :n "M-9" (cmd! (bookmark-jump "9")))

;;; ============================================================================
;;; SPLITS (matching your <leader>/ and <leader>-)
;;; ============================================================================

(map! :leader
      :desc "Split vertical" "/" #'evil-window-vsplit
      :desc "Split horizontal" "-" #'evil-window-split)

;;; ============================================================================
;;; TMUX NAVIGATION (nvim-tmux-navigation equivalent)
;;; ============================================================================

;; C-h/j/k/l for window navigation (works with tmux.el)
(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right)

;;; ============================================================================
;;; VISUAL MODE IMPROVEMENTS (matching your keymaps)
;;; ============================================================================

;; Better indenting (stay in visual mode after indent)
(map! :v "<" #'+evil/shift-left
      :v ">" #'+evil/shift-right)

;; Move lines up and down (J/K in visual mode)
(map! :v "J" (cmd! (evil-move-region-down 1))
      :v "K" (cmd! (evil-move-region-up 1)))

;; Paste without replacing register (<leader>p)
(map! :leader
      :v "p" #'evil-paste-from-register-0)

;;; ============================================================================
;;; QUICKFIX (matching your ]q and [q)
;;; ============================================================================

(map! :n "] q" #'next-error
      :n "[ q" #'previous-error)

;;; ============================================================================
;;; FOLDING (Tab to toggle fold, like your config)
;;; ============================================================================

(map! :n "TAB" #'+fold/toggle)

;;; ============================================================================
;;; UNDOTREE (matching your <leader>u)
;;; ============================================================================

(map! :leader
      :desc "Undo tree" "u" #'undo-tree-visualize)

;;; ============================================================================
;;; REFACTORING (matching your <leader>rr)
;;; ============================================================================

(map! :leader
      (:prefix ("r" . "Refactor")
       :desc "Refactor menu" "r" #'lsp-rename))

;;; ============================================================================
;;; NOTES / SECOND-BRAIN (obsidian.nvim equivalent using org-mode)
;;; ============================================================================

(setq org-directory "~/second-brain/"
      org-roam-directory "~/second-brain/")

;; Weekly notes directory
(defvar kamil/weekly-dir (expand-file-name "weekly" org-directory))

;; Get current ISO week file path
(defun kamil/get-weekly-file ()
  "Return the path to current week's note file."
  (let ((year (format-time-string "%G"))
        (week (format-time-string "%V")))
    (expand-file-name (format "%s-W%s.md" year week) kamil/weekly-dir)))

;; <leader>ni - Open current week's inbox
(defun kamil/note-inbox ()
  "Open current week's note and go to end."
  (interactive)
  (find-file (kamil/get-weekly-file))
  (goto-char (point-max)))

;; <leader>nw - Browse weekly notes
(defun kamil/note-weekly-browse ()
  "Browse weekly notes with completion."
  (interactive)
  (let ((default-directory kamil/weekly-dir))
    (call-interactively #'find-file)))

;; <leader>np - Previous week's note
(defun kamil/note-previous-week ()
  "Open previous week's note."
  (interactive)
  (let* ((prev-time (time-subtract (current-time) (days-to-time 7)))
         (year (format-time-string "%G" prev-time))
         (week (format-time-string "%V" prev-time)))
    (find-file (expand-file-name (format "%s-W%s.md" year week) kamil/weekly-dir))))

;; <leader>nf - Find notes by filename
(defun kamil/note-find ()
  "Find notes in second-brain directory."
  (interactive)
  (let ((default-directory org-directory))
    (call-interactively #'projectile-find-file)))

;; <leader>ns - Search notes content
(defun kamil/note-search ()
  "Search notes content."
  (interactive)
  (let ((default-directory org-directory))
    (call-interactively #'+default/search-project)))

;; <leader>nc - Capture to weekly (equivalent to your capture.lua)
(defun kamil/note-capture ()
  "Quick capture a task to the weekly note's Capture section."
  (interactive)
  (let* ((task (read-string "Capture: "))
         (file (kamil/get-weekly-file))
         (expanded-task (kamil/expand-dates task)))
    (with-current-buffer (find-file-noselect file)
      (goto-char (point-min))
      (if (search-forward "## Capture" nil t)
          (progn
            (forward-line 1)
            (while (looking-at "^\\s-*$")
              (forward-line 1))
            (insert (format "- [ ] %s\n" expanded-task))
            (save-buffer)
            (message "Captured to weekly note"))
        (message "No '## Capture' section found")))))

;; Date expansion (like your expand_dates function)
(defun kamil/expand-dates (text)
  "Expand relative dates in TEXT like @scheduled(tomorrow)."
  (let ((result text))
    ;; @scheduled(today) -> @scheduled(2025-01-20)
    (setq result (replace-regexp-in-string
                  "@scheduled(today)"
                  (format "@scheduled(%s)" (format-time-string "%Y-%m-%d"))
                  result))
    ;; @scheduled(tomorrow)
    (setq result (replace-regexp-in-string
                  "@scheduled(tomorrow)"
                  (format "@scheduled(%s)" (format-time-string "%Y-%m-%d" (time-add (current-time) (days-to-time 1))))
                  result))
    ;; @deadline patterns
    (setq result (replace-regexp-in-string
                  "@deadline(today)"
                  (format "@deadline(%s)" (format-time-string "%Y-%m-%d"))
                  result))
    (setq result (replace-regexp-in-string
                  "@deadline(tomorrow)"
                  (format "@deadline(%s)" (format-time-string "%Y-%m-%d" (time-add (current-time) (days-to-time 1))))
                  result))
    result))

;; Note keymaps
(map! :leader
      (:prefix ("n" . "Notes")
       :desc "Inbox (current week)" "i" #'kamil/note-inbox
       :desc "Weekly browse" "w" #'kamil/note-weekly-browse
       :desc "Previous week" "p" #'kamil/note-previous-week
       :desc "Find by filename" "f" #'kamil/note-find
       :desc "Search contents" "s" #'kamil/note-search
       :desc "Capture" "c" #'kamil/note-capture
       :desc "Agenda" "a" #'org-agenda))

;; Todo toggle in markdown (like your <leader>ntx)
(defun kamil/toggle-checkbox ()
  "Toggle markdown checkbox on current line."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (cond
     ((looking-at ".*\\- \\[ \\]")
      (replace-match (replace-regexp-in-string "- \\[ \\]" "- [x]" (match-string 0))))
     ((looking-at ".*\\- \\[x\\]")
      (replace-match (replace-regexp-in-string "- \\[x\\]" "- [ ]" (match-string 0))))
     ((looking-at ".*\\- \\[-\\]")
      (replace-match (replace-regexp-in-string "- \\[-\\]" "- [x]" (match-string 0)))))))

(map! :leader
      (:prefix ("n t" . "Todo/Time")
       :desc "Toggle checkbox" "x" #'kamil/toggle-checkbox))

;;; ============================================================================
;;; TIME TRACKING (equivalent to your timetracking.lua)
;;; ============================================================================

(defvar kamil/timer-start nil "Start time of the timer.")
(defvar kamil/timer-display nil "Display string of start time.")
(defvar kamil/timer-object nil "Timer object for updates.")

(defun kamil/timer-format-duration (seconds)
  "Format SECONDS as human readable duration."
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
      (message "Timer already running! Use <leader>nte to stop it first.")
    (setq kamil/timer-start (current-time)
          kamil/timer-display (format-time-string "%H:%M"))
    (message "Timer started at %s" kamil/timer-display)))

(defun kamil/timer-stop ()
  "Stop the timer and insert time-spent annotation."
  (interactive)
  (if (not kamil/timer-start)
      (message "No timer running! Use <leader>nts to start one.")
    (let* ((end-time (current-time))
           (end-display (format-time-string "%H:%M"))
           (duration-seconds (floor (float-time (time-subtract end-time kamil/timer-start))))
           (duration-formatted (kamil/timer-format-duration duration-seconds))
           (output (format "@time-spent(%s - %s, %s)" kamil/timer-display end-display duration-formatted)))
      (insert output)
      (message "Timer stopped: %s" duration-formatted)
      (setq kamil/timer-start nil
            kamil/timer-display nil))))

(map! :leader
      (:prefix ("n t" . "Todo/Time")
       :desc "Start timer" "s" #'kamil/timer-start
       :desc "Stop timer" "e" #'kamil/timer-stop))

;;; ============================================================================
;;; AI INTEGRATION (copilot.lua equivalent)
;;; ============================================================================

;; Copilot keybindings (configured in packages.el)
(map! :leader
      (:prefix ("a" . "AI")
       :desc "Copilot complete" "c" #'copilot-complete
       :desc "Copilot accept" "a" #'copilot-accept-completion
       :desc "Copilot next" "n" #'copilot-next-completion
       :desc "Copilot prev" "p" #'copilot-previous-completion))

;; Accept copilot with M-j (like your <M-j> mapping)
(map! :i "M-j" #'copilot-accept-completion)

;;; ============================================================================
;;; POLISH CHARACTER MAPPINGS (like your 🇵🇱 mappings)
;;; ============================================================================

(map! :i "M-a" (cmd! (insert "ą"))
      :i "M-c" (cmd! (insert "ć"))
      :i "M-e" (cmd! (insert "ę"))
      :i "M-l" (cmd! (insert "ł"))
      :i "M-n" (cmd! (insert "ń"))
      :i "M-o" (cmd! (insert "ó"))
      :i "M-s" (cmd! (insert "ś"))
      :i "M-x" (cmd! (insert "ź"))
      :i "M-z" (cmd! (insert "ż"))
      :i "M-A" (cmd! (insert "Ą"))
      :i "M-C" (cmd! (insert "Ć"))
      :i "M-E" (cmd! (insert "Ę"))
      :i "M-L" (cmd! (insert "Ł"))
      :i "M-N" (cmd! (insert "Ń"))
      :i "M-O" (cmd! (insert "Ó"))
      :i "M-S" (cmd! (insert "Ś"))
      :i "M-X" (cmd! (insert "Ź"))
      :i "M-Z" (cmd! (insert "Ż")))

;;; ============================================================================
;;; SELECT ALL (Ctrl+A like your config)
;;; ============================================================================

(map! :n "C-a" #'mark-whole-buffer)

;;; ============================================================================
;;; DIAGNOSTICS (matching your vim.diagnostic.config)
;;; ============================================================================

;; Show diagnostics inline (like virtual_text in your config)
(after! flycheck
  (setq flycheck-indication-mode 'right-fringe
        flycheck-display-errors-delay 0.1))

;; Diagnostic signs (matching your custom signs)
(after! flycheck
  (define-fringe-bitmap 'flycheck-fringe-bitmap-ball
    (vector #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00111000
            #b01111100
            #b01111100
            #b01111100
            #b00111000
            #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00000000)))

;;; ============================================================================
;;; HIGHLIGHT ON YANK (like your TextYankPost autocmd)
;;; ============================================================================

(after! evil
  (setq evil-goggles-enable-yank t
        evil-goggles-duration 0.2))

;;; ============================================================================
;;; WHICH-KEY CUSTOMIZATION (matching your wk.add icons)
;;; ============================================================================

(after! which-key
  (setq which-key-idle-delay 0.2
        which-key-idle-secondary-delay 0.05))

;;; ============================================================================
;;; COMPANY/COMPLETION SETTINGS (matching blink.cmp behavior)
;;; ============================================================================

(after! company
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 1
        company-selection-wrap-around t))

;;; ============================================================================
;;; TREEMACS (alternative to oil.nvim popup explorer)
;;; ============================================================================

(after! treemacs
  (setq treemacs-width 35
        treemacs-show-hidden-files t))

;;; ============================================================================
;;; ORG-ROAM (if you want to migrate from Obsidian)
;;; ============================================================================

(after! org-roam
  (setq org-roam-directory "~/second-brain/"))

;;; ============================================================================
;;; MARKDOWN SETTINGS (render-markdown.nvim equivalent)
;;; ============================================================================

(after! markdown-mode
  (setq markdown-fontify-code-blocks-natively t
        markdown-enable-wiki-links t
        markdown-enable-math t
        ;; Hide markup characters (**, __, `, etc.) - renders inline
        markdown-hide-markup t)

  ;; Reveal markup when cursor is on the line (like render-markdown.nvim)
  (defun kamil/markdown-reveal-at-point ()
    "Reveal markdown markup on current line, hide on others."
    (when (eq major-mode 'markdown-mode)
      (save-excursion
        ;; Re-hide all markup first
        (font-lock-fontify-buffer))))

  ;; Use cursor sensor to reveal/hide markup
  (add-hook 'markdown-mode-hook
            (lambda ()
              ;; Enable cursor sensor mode for reveal-on-cursor behavior
              (cursor-sensor-mode 1)
              ;; Refresh display when idle to update concealment
              (add-hook 'post-command-hook
                        (lambda ()
                          (when (bound-and-true-p markdown-hide-markup)
                            (font-lock-flush (line-beginning-position) (line-end-position))))
                        nil t))))

;;; ============================================================================
;;; LSP SETTINGS (matching your nvim-lspconfig)
;;; ============================================================================

(after! lsp-mode
  (setq lsp-idle-delay 0.1
        lsp-log-io nil
        lsp-completion-provider :capf
        lsp-headerline-breadcrumb-enable t  ; Like barbecue.nvim
        lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols)))

;;; ============================================================================
;;; MODELINE (lualine.nvim equivalent)
;;; ============================================================================

;; Doom modeline is already configured, but customize it
(after! doom-modeline
  (setq doom-modeline-height 28
        doom-modeline-bar-width 3
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-file-name-style 'relative-to-project
        doom-modeline-vcs-max-length 20))
