#!/usr/bin/env bash

export PATH="/etc/profiles/per-user/$USER/bin:$PATH"

SESSIONS_DIR="$HOME/.local/share/kitty/sessions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/kitty-fzf-theme.sh"

shopt -s nullglob
session_files=("$SESSIONS_DIR"/*.kitty-session)
shopt -u nullglob

if [ ${#session_files[@]} -eq 0 ]; then
  echo "No sessions found."
  exit 0
fi

session_names=()
for session_file in "${session_files[@]}"; do
  session_names+=("$(basename "${session_file%.kitty-session}")")
done

selected=$(printf '%s\n' "${session_names[@]}" | fzf $FZF_POKKE_OPTS --prompt="Delete Session> " --height=40% --reverse --multi)

if [ -z "$selected" ]; then
  exit 0
fi

for session in $selected; do
  session_file="$SESSIONS_DIR/$session.kitty-session"
  
  kitten @ close-window --match "session:$session" 2>/dev/null
  rm -f "$session_file"
  echo "Deleted: $session"
done
