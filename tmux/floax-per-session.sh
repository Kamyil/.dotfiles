#!/usr/bin/env bash

current_session="$(tmux display-message -p '#{session_name}')"

if [[ "$current_session" == floax-* ]]; then
  target_session="$current_session"
else
  target_session="floax-$current_session"
fi

while IFS= read -r session_name; do
  case "$session_name" in
    floax-*)
      origin_session="${session_name#floax-}"
      if ! tmux has-session -t "$origin_session" 2>/dev/null; then
        tmux kill-session -t "$session_name" 2>/dev/null || true
      fi
      ;;
  esac
done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null)

tmux setenv -g FLOAX_SESSION_NAME "$target_session"
"$HOME/.config/tmux/plugins/tmux-floax/scripts/floax.sh"
