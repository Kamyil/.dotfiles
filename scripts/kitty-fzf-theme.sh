#!/usr/bin/env bash

# Sourced by Kitty session scripts.
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
if [[ ! -r "$state_dir/current/theme.zsh" ]]; then
  "$HOME/.dotfiles/scripts/theme" kanagawa-paper >/dev/null
fi
# shellcheck disable=SC1090
source "$state_dir/current/theme.zsh"
export FZF_POKKE_OPTS="$FZF_THEME_OPTS"
