#!/usr/bin/env bash
set -euo pipefail

dir="${1:?usage: herdr-navigate.sh <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"
pane="${HERDR_PANE_ID:-}"
if [[ -z "$pane" ]] && command -v jq >/dev/null 2>&1; then
  pane="$("$herdr" pane current 2>/dev/null | jq -r '.result.pane.pane_id // empty')"
fi

case "$dir" in
  left) key="ctrl+h" ;;
  down) key="ctrl+j" ;;
  up) key="ctrl+k" ;;
  right) key="ctrl+l" ;;
  *) echo "herdr-navigate.sh: unknown direction: $dir" >&2; exit 2 ;;
esac

vim_re='^g?(view|l?n?vim?x?)(diff)?$'
forward=0
if [[ -n "$pane" ]] && command -v jq >/dev/null 2>&1; then
  if "$herdr" pane process-info --pane "$pane" 2>/dev/null \
    | jq -e --arg vim "$vim_re" \
      '.result.process_info.foreground_processes[]?.name
       | ascii_downcase
       | select(test($vim))' >/dev/null 2>&1; then
    forward=1
  fi
fi

if [[ "$forward" -eq 1 ]]; then
  exec "$herdr" pane send-keys "$pane" "$key"
elif [[ -n "$pane" ]]; then
  exec "$herdr" pane focus --direction "$dir" --pane "$pane"
else
  exec "$herdr" pane focus --direction "$dir" --current
fi
