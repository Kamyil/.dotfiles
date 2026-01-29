#!/usr/bin/env bash
set -euo pipefail

cache_file="${XDG_CACHE_HOME:=$HOME/.cache}/tui-launcher-apps.cache"
cache_time=3600

rebuild_cache=false
if [ ! -f "$cache_file" ] || [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -gt "$cache_time" ]; then
  rebuild_cache=true
fi

if [ "$rebuild_cache" = true ]; then
  app_dirs=(
    "$HOME/.local/share/applications"
    "$HOME/.nix-profile/share/applications"
    "/etc/profiles/per-user/$USER/share/applications"
    "/run/current-system/sw/share/applications"
    "/usr/share/applications"
  )

  if [ -n "${XDG_DATA_DIRS:-}" ]; then
    IFS=':' read -r -a xdg_dirs <<< "$XDG_DATA_DIRS"
    for dir in "${xdg_dirs[@]}"; do
      [ -n "$dir" ] || continue
      app_dirs+=("$dir/applications")
    done
  fi

  entries=()
  for dir in "${app_dirs[@]}"; do
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' file; do
      name_line=$(sed -n 's/^Name=//p' "$file" | head -1)
      name=${name_line:-$(basename "$file" .desktop)}
      exec_line=$(sed -n 's/^Exec=//p' "$file" | head -1)
      [ -n "$exec_line" ] || continue
      entries+=("$name|$file")
    done < <(find -L "$dir" -type f -name "*.desktop" -print0 2>/dev/null)
  done

  printf '%s\n' "${entries[@]}" | sort -u > "$cache_file"
fi

# Read from cache
entries=()
while IFS= read -r line; do
  [ -n "$line" ] && entries+=("$line")
done < "$cache_file"

if [ "${#entries[@]}" -eq 0 ]; then
  echo "No applications found"
  exit 1
fi

fzf_bin="/run/current-system/sw/bin/fzf"
if [ ! -x "$fzf_bin" ]; then
  fzf_bin=$(command -v fzf || true)
fi

if [ -z "$fzf_bin" ]; then
  echo "fzf not found in PATH"
  exit 1
fi

choice=$(printf '%s\n' "${entries[@]}" | "$fzf_bin" --prompt='Launch> ' --with-nth=1 --delimiter='|')
[ -n "$choice" ] || exit 0

desktop_file=${choice#*|}
desktop_id=$(basename "$desktop_file" .desktop)

# Try gtk-launch first
if command -v gtk-launch >/dev/null 2>&1; then
  gtk-launch "$desktop_id" 2>/dev/null &
  sleep 0.1
  exit 0
fi

# Fall back to manual Exec parsing
exec_line=$(grep -m1 '^Exec=' "$desktop_file" | cut -d= -f2- || true)
if [ -z "$exec_line" ]; then
  echo "Error: No Exec= found in $desktop_file"
  exit 1
fi

# Remove %f, %F, %u, %U, %i, %c, %k placeholders
exec_line=$(printf '%s' "$exec_line" | sed 's/%[fFuUick]//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Launch with setsid to fully detach from terminal
setsid -f bash -lc "$exec_line" >/dev/null 2>&1
sleep 0.05
exit 0
