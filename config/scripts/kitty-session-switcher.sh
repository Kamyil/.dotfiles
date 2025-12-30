#!/usr/bin/env bash

export PATH="/etc/profiles/per-user/$USER/bin:$PATH"

SESSIONS_DIR="$HOME/.local/share/kitty/sessions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/kitty-fzf-theme.sh"

if [ ! -d "$SESSIONS_DIR" ] || [ -z "$(ls -A "$SESSIONS_DIR" 2>/dev/null)" ]; then
  echo "No sessions found. Use Ctrl+f to create one."
  exit 0
fi

selected=$(ls "$SESSIONS_DIR"/*.kitty-session 2>/dev/null | xargs -n1 basename | sed 's/.kitty-session$//' | fzf $FZF_POKKE_OPTS --prompt="Switch Session> " --height=40% --reverse)

if [ -z "$selected" ]; then
  exit 0
fi

session_file="$SESSIONS_DIR/$selected.kitty-session"
kitten @ action goto_session "$session_file"
