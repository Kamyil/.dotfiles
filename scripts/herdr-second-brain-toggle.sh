#!/usr/bin/env bash
set -euo pipefail

LABEL="second-brain"
DIR="$HOME/second-brain"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/herdr"
STATE_FILE="$STATE_DIR/second-brain-prev"
mkdir -p "${STATE_FILE%/*}"

# Read state: line 1 = prev WS ID, line 2 = cached sb WS ID
STATE_PREV=""
STATE_SB=""
if [[ -f "$STATE_FILE" ]]; then
    { read -r STATE_PREV; read -r STATE_SB; } < "$STATE_FILE"
fi

# One workspace list call: find focused WS and (if cache stale) sb WS
eval "$(
  herdr workspace list | jq -r '
    [.result.workspaces[] | select(.focused)] as $focused |
    $focused[0].workspace_id as $cur_id |
    $focused[0].label as $cur_label |
    (
      if $ARGS.positional[0] == "" then
        ([.result.workspaces[] | select(.label == $ARGS.positional[1]).workspace_id][0] // "")
      else
        $ARGS.positional[0]
      end
    ) as $sb_id |
    "CUR_ID=\($cur_id)\nCUR_LABEL=\($cur_label)\nSB_ID=\($sb_id)"
  ' --args "$STATE_SB" "$LABEL"
)"

# Already in second-brain → go back to previous workspace
if [[ "$CUR_LABEL" == "$LABEL" ]]; then
    [[ -n "$STATE_PREV" ]] && herdr workspace focus "$STATE_PREV" >/dev/null
    exit 0
fi

# Save current and cached sb_id, then focus second-brain
printf '%s\n%s\n' "$CUR_ID" "$SB_ID" > "$STATE_FILE"

if [[ -n "$SB_ID" ]]; then
    herdr workspace focus "$SB_ID" >/dev/null
    exit 0
fi

# One-time create
CREATED=$(herdr workspace create --cwd "$DIR" --label "$LABEL" --no-focus)
SB_ID=$(echo "$CREATED" | jq -r '.result.workspace.workspace_id')
ROOT=$(echo "$CREATED" | jq -r '.result.root_pane.pane_id')
printf '%s\n%s\n' "$CUR_ID" "$SB_ID" > "$STATE_FILE"
herdr pane run "$ROOT" "nvim ." >/dev/null
herdr workspace focus "$SB_ID" >/dev/null
