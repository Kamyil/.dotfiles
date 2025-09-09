#!/bin/bash

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
    echo "$(date): Processing workspace change event" >> /tmp/aerospace_debug.log
    
    # Get current focused workspace
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null | head -1 | xargs)
    echo "$(date): Current focused workspace: '$FOCUSED_WORKSPACE'" >> /tmp/aerospace_debug.log
    
    if [ -n "$FOCUSED_WORKSPACE" ]; then
        # PRIORITY 1: Update highlights immediately (this is what user sees first)
        for workspace in 1 2 3 4 5 6 7 8 9 10; do
            if [ "$workspace" = "$FOCUSED_WORKSPACE" ]; then
                sketchybar --set space.$workspace \
                    icon.highlight=true \
                    label.highlight=true \
                    background.border_color=$GREY 2>/dev/null
            else
                sketchybar --set space.$workspace \
                    icon.highlight=false \
                    label.highlight=false \
                    background.border_color=$BACKGROUND_2 2>/dev/null
            fi
        done
        
        # PRIORITY 2: Update app icons (slower, can lag behind)
        apps=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" --format "%{app-name}" 2>/dev/null)
        
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
        
        sketchybar --set space.$FOCUSED_WORKSPACE label="$icon_strip" 2>/dev/null
        echo "$(date): Workspace update completed" >> /tmp/aerospace_debug.log
    else
        echo "$(date): ERROR - Could not determine focused workspace" >> /tmp/aerospace_debug.log
    fi

elif [ "$SENDER" = "mouse.clicked" ]; then
    # Handle workspace clicks
    WORKSPACE_ID=${NAME#*.}  # Extract number from space.X
    echo "$(date): Switching to workspace $WORKSPACE_ID via mouse click" >> /tmp/aerospace_debug.log
    aerospace workspace "$WORKSPACE_ID"

fi