#!/usr/bin/env bash

set -euo pipefail

export PATH="/etc/profiles/per-user/$USER/bin:$PATH"

SESSIONS_DIR="$HOME/.local/share/kitty/sessions"
SESSION_NAME="second-brain"
SESSION_FILE="$SESSIONS_DIR/$SESSION_NAME.kitty-session"
SECOND_BRAIN_DIR="$HOME/second-brain"

mkdir -p "$SESSIONS_DIR"

current_dir="$(pwd -P)"

if [[ "$current_dir" == "$SECOND_BRAIN_DIR" || "$current_dir" == "$SECOND_BRAIN_DIR"/* ]]; then
  kitten @ action goto_session -1
  exit 0
fi

if [ ! -f "$SESSION_FILE" ]; then
  cat > "$SESSION_FILE" << EOF
layout tall
cd $SECOND_BRAIN_DIR
launch --title "$SESSION_NAME" nvim .
EOF
fi

kitten @ action goto_session "$SESSION_FILE"
