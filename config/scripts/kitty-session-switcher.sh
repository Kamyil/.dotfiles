#!/usr/bin/env bash

export PATH="/etc/profiles/per-user/$USER/bin:$PATH"

SESSIONS_DIR="$HOME/.local/share/kitty/sessions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/kitty-fzf-theme.sh"

shopt -s nullglob
session_files=("$SESSIONS_DIR"/*.kitty-session)
shopt -u nullglob

if [ ${#session_files[@]} -eq 0 ]; then
  echo "No sessions found. Use Ctrl+Shift+F to create one."
  exit 0
fi

session_names=()
for session_file in "${session_files[@]}"; do
  session_names+=("$(basename "${session_file%.kitty-session}")")
done

selected=$(printf '%s\n' "${session_names[@]}" | fzf $FZF_POKKE_OPTS --prompt="Switch Session> " --height=40% --reverse)

if [ -z "$selected" ]; then
  exit 0
fi

session_file="$SESSIONS_DIR/$selected.kitty-session"
kitten @ action goto_session "$session_file"
