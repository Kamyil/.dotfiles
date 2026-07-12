#!/usr/bin/env bash
set -euo pipefail

LABEL="second-brain"
DIR="$HOME/second-brain"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/herdr"
STATE_FILE="$STATE_DIR/second-brain-prev"
mkdir -p "$STATE_DIR"

# The state file contains only the workspace to return to.
STATE_PREV=""
if [[ -f "$STATE_FILE" ]]; then
    read -r STATE_PREV < "$STATE_FILE"
fi

# Read the focused workspace and the current second-brain workspace in one query.
mapfile -t WS_INFO < <(
    herdr workspace list | jq -r '
        ([.result.workspaces[] | select(.focused)][0] // {}) as $focused |
        ([.result.workspaces[] | select(.label == "second-brain").workspace_id][0] // "") as $second_brain |
        ($focused.workspace_id // ""),
        ($focused.label // ""),
        $second_brain
    '
)
CUR_ID="${WS_INFO[0]-}"
CUR_LABEL="${WS_INFO[1]-}"
SB_ID="${WS_INFO[2]-}"

# Already in second-brain → go back to the previous workspace.
if [[ "$CUR_LABEL" == "$LABEL" ]]; then
    [[ -n "$STATE_PREV" ]] && herdr workspace focus "$STATE_PREV" >/dev/null
    exit 0
fi

# Save the current workspace and focus the freshly discovered second-brain ID.
printf '%s\n' "$CUR_ID" > "$STATE_FILE"

if [[ -n "$SB_ID" ]]; then
    herdr workspace focus "$SB_ID" >/dev/null
    exit 0
fi

# Create the workspace and launch nvim on first use.
CREATED=$(herdr workspace create --cwd "$DIR" --label "$LABEL" --no-focus)
SB_ID=$(echo "$CREATED" | jq -r '.result.workspace.workspace_id')
ROOT=$(echo "$CREATED" | jq -r '.result.root_pane.pane_id')
herdr pane run "$ROOT" "nvim ." >/dev/null
herdr workspace focus "$SB_ID" >/dev/null

