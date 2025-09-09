#!/bin/bash

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
    # Get current focused workspace
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null | head -1 | xargs)
    
    # Skip redundant updates - this is the biggest performance gain
    LAST_WORKSPACE_FILE="/tmp/sketchybar_last_workspace"
    if [ -f "$LAST_WORKSPACE_FILE" ] && [ "$(cat "$LAST_WORKSPACE_FILE")" = "$FOCUSED_WORKSPACE" ]; then
        exit 0  # No change needed
    fi
    echo "$FOCUSED_WORKSPACE" > "$LAST_WORKSPACE_FILE"
    
    if [ -n "$FOCUSED_WORKSPACE" ]; then
        # Build single sketchybar command for all highlights
        SKETCHYBAR_CMD="sketchybar"
        for workspace in 1 2 3 4 5 6 7 8 9 10; do
            if [ "$workspace" = "$FOCUSED_WORKSPACE" ]; then
                SKETCHYBAR_CMD="$SKETCHYBAR_CMD --set space.$workspace icon.highlight=true label.highlight=true background.border_color=$GREY"
            else
                SKETCHYBAR_CMD="$SKETCHYBAR_CMD --set space.$workspace icon.highlight=false label.highlight=false background.border_color=$BACKGROUND_2"
            fi
        done
        
        # Execute single command for all highlights
        eval "$SKETCHYBAR_CMD" 2>/dev/null
        
        # Get app list for focused workspace
        apps=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" --format "%{app-name}" 2>/dev/null)
        
        # Process icons - still using icon_map.sh but faster due to fewer calls overall
        icon_strip=" "
        if [ -n "$apps" ]; then
            while IFS= read -r app; do
                if [ -n "$app" ]; then
                    icon="$($CONFIG_DIR/plugins/icon_map.sh "$app" 2>/dev/null)"
                    icon_strip="$icon_strip$icon"
                fi
            done <<< "$apps"
        else
            icon_strip=" —"
        fi
        
        # Set the app icons label
        sketchybar --set space.$FOCUSED_WORKSPACE label="$icon_strip" 2>/dev/null
    fi

elif [ "$SENDER" = "mouse.clicked" ]; then
    # Handle workspace clicks - also update the last workspace file
    WORKSPACE_ID=${NAME#*.}
    echo "$WORKSPACE_ID" > "/tmp/sketchybar_last_workspace"
    aerospace workspace "$WORKSPACE_ID"

fi