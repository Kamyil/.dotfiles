#!/usr/bin/env bash
# Set accordion layout for workspace 2, tiles for others
# Arguments: <new-workspace> <old-workspace>

AEROSPACE="/opt/homebrew/bin/aerospace"
NEW_WORKSPACE="$1"
OLD_WORKSPACE="$2"

# Debug logging
exec >> /tmp/aerospace-layout.log 2>&1
set -x
echo "$(date): Workspace changed from '$OLD_WORKSPACE' to '$NEW_WORKSPACE'"

if [ "$NEW_WORKSPACE" = "2" ]; then
    echo "Setting accordion layout for workspace 2"
    "$AEROSPACE" layout accordion 2>&1
elif [ "$OLD_WORKSPACE" = "2" ]; then
    echo "Reverting to tiles layout"
    "$AEROSPACE" layout tiles 2>&1
fi
