#!/usr/bin/env bash

export PATH="/etc/profiles/per-user/$USER/bin:$PATH"

SESSIONS_DIR="$HOME/.local/share/kitty/sessions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/kitty-fzf-theme.sh"

if [ ! -d "$SESSIONS_DIR" ] || [ -z "$(ls -A "$SESSIONS_DIR" 2>/dev/null)" ]; then
  echo "No sessions found."
  exit 0
fi

selected=$(ls "$SESSIONS_DIR"/*.kitty-session 2>/dev/null | xargs -n1 basename | sed 's/.kitty-session$//' | fzf $FZF_POKKE_OPTS --prompt="Delete Session> " --height=40% --reverse --multi)

if [ -z "$selected" ]; then
  exit 0
fi

for session in $selected; do
  session_file="$SESSIONS_DIR/$session.kitty-session"
  
  kitten @ close-window --match "session:$session" 2>/dev/null
  rm -f "$session_file"
  echo "Deleted: $session"
done
