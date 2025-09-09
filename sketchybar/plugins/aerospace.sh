#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

source "$CONFIG_DIR/colors.sh"

# Get the workspace ID from the script argument
WORKSPACE_ID="$1"

# Check if this workspace is currently focused
if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
    # Active workspace styling
    sketchybar --set space.$WORKSPACE_ID \
        background.drawing=on \
        background.color=$ACCENT_COLOR \
        label.color=$BAR_COLOR
else
    # Inactive workspace styling
    sketchybar --set space.$WORKSPACE_ID \
        background.drawing=off \
        label.color=$WHITE
fi
