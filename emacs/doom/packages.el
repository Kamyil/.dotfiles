;; -*- no-byte-compile: t; -*-
;;; packages.el
;;
;; Additional packages for Kamil's Doom Emacs setup
;; Based on nvim/init.lua plugins
;;
;; To install these packages, run: doom sync

;;; ============================================================================
;;; AI / COPILOT (copilot.lua, supermaven-nvim equivalent)
;;; ============================================================================

;; GitHub Copilot
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))

;; GPTel for general AI chat (alternative to opencode.nvim)
(package! gptel)

;;; ============================================================================
;;; THEME (kanagawa-paper, catppuccin equivalent)
;;; ============================================================================

;; Catppuccin theme (you have this in Neovim)
(package! catppuccin-theme)

;; Kanagawa theme - provides kanagawa-wave, kanagawa-dragon, kanagawa-lotus
(package! kanagawa-themes
  :recipe (:host github :repo "Fabiokleis/kanagawa-emacs" :files ("*.el")))

;;; ============================================================================
;;; GIT ENHANCEMENTS (git-conflict.nvim, blame.nvim additions)
;;; ============================================================================

;; Git timemachine - step through git history
(package! git-timemachine)

;; Diff-hl for git gutter (already in doom, but ensure it's there)
(package! diff-hl)

;;; ============================================================================
;;; FILE NAVIGATION (oil.nvim, harpoon equivalents)
;;; ============================================================================

;; Harpoon.el - direct port of ThePrimeagen's harpoon
(package! harpoon
  :recipe (:host github :repo "kofm/harpoon.el" :files ("*.el")))

;; Dirvish - polished dired experience (closer to oil.nvim)
(package! dirvish)

;;; ============================================================================
;;; COMPLETION ENHANCEMENTS (blink.cmp additions)
;;; ============================================================================

;; Corfu as alternative to company (more like blink.cmp)
(package! corfu)

;; Cape - completion at point extensions
(package! cape)

;;; ============================================================================
;;; VISUAL ENHANCEMENTS
;;; ============================================================================

;; Rainbow mode for color highlighting (nvim-highlight-colors equivalent)
(package! rainbow-mode)

;; Indent bars (indent-blankline.nvim alternative with tree-sitter)
(package! indent-bars
  :recipe (:host github :repo "jdtsmith/indent-bars"))

;; Pulsar - pulse current line after commands (nav-flash alternative)
(package! pulsar)

;;; ============================================================================
;;; MARKDOWN / NOTES (obsidian.nvim, render-markdown.nvim)
;;; ============================================================================

;; Grip mode - live preview markdown
(package! grip-mode)

;; Markdown TOC generator
(package! markdown-toc)

;;; ============================================================================
;;; PRODUCTIVITY
;;; ============================================================================

;; Focus mode (like zen mode plugins)
(package! olivetti)

;; Pomodoro timer
(package! org-pomodoro)

;;; ============================================================================
;;; TREESITTER ENHANCEMENTS
;;; ============================================================================

;; Treesit-auto for automatic grammar installation
(package! treesit-auto)

;;; ============================================================================
;;; NAVIGATION / EDITING
;;; ============================================================================

;; Avy - jump to visible text (like hop.nvim/leap.nvim)
(package! avy)

;; Multiple cursors enhancement
(package! iedit)

;; Expand region incrementally
(package! expand-region)

;;; ============================================================================
;;; MISC
;;; ============================================================================

;; Restart emacs from within emacs
(package! restart-emacs)

;; Which-key posframe (floating which-key like your popup borders)
(package! which-key-posframe)
