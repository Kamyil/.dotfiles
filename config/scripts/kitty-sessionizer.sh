#!/usr/bin/env bash

export PATH="/etc/profiles/per-user/$USER/bin:$PATH"

SD_BASE_DIRS=(
  "$HOME/Work/Projects"
  "$HOME/Personal/Projects"
)
SD_DEPTH=1
SESSIONS_DIR="$HOME/.local/share/kitty/sessions"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$SESSIONS_DIR"

dirs=()
for base in "${SD_BASE_DIRS[@]}"; do
  if [ -d "$base" ]; then
    while IFS= read -r dir; do
      dirs+=("$dir")
    done < <(find "$base" -mindepth 1 -maxdepth "$SD_DEPTH" -type d 2>/dev/null)
  fi
done

if [ -f "$HOME/.zsh_company_dirs" ]; then
  source "$HOME/.zsh_company_dirs"
  dirs+=("${COMPANY_DIRS[@]}")
fi
if [ -f "$HOME/.zsh_personal_dirs" ]; then
  source "$HOME/.zsh_personal_dirs"
  dirs+=("${PERSONAL_DIRS[@]}")
fi

for symlink in "$XDG_CONFIG_HOME"/*; do
  if [ -L "$symlink" ]; then
    target=$(readlink "$symlink")
    if [[ "$target" == */.dotfiles/* ]]; then
      dirs+=("[config] $target")
    fi
  fi
done

selected=$(printf '%s\n' "${dirs[@]}" | fzf --prompt="Session> " --height=40% --reverse)

if [ -z "$selected" ]; then
  exit 0
fi

if [[ "$selected" == "[config] "* ]]; then
  selected="${selected#\[config\] }"
  session_name=$(basename "$selected")
  session_file="$SESSIONS_DIR/$session_name.kitty-session"

  if [ ! -f "$session_file" ]; then
    cat > "$session_file" << EOF
layout tall
cd $selected
launch --title "$session_name"
launch nvim .
EOF
  fi

  kitten @ action goto_session "$session_file"
  exit 0
fi

session_name=$(basename "$selected")
session_file="$SESSIONS_DIR/$session_name.kitty-session"

if [ ! -f "$session_file" ]; then
  cat > "$session_file" << EOF
layout tall
cd $selected
launch --title "$session_name"
EOF
fi

kitten @ action goto_session "$session_file"
