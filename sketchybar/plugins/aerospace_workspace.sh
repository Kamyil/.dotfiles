#!/bin/bash

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
    echo "$(date): Processing workspace change event - FOCUSED: '$AEROSPACE_FOCUSED_WORKSPACE', PREV: '$AEROSPACE_PREV_WORKSPACE'" >> /tmp/aerospace_debug.log
    
    # Get current focused workspace if not provided
    if [ -z "$AEROSPACE_FOCUSED_WORKSPACE" ]; then
        FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null | head -1 | xargs)
        echo "$(date): Got current focused workspace: '$FOCUSED_WORKSPACE'" >> /tmp/aerospace_debug.log
    else
        FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE"
    fi
    
    if [ -n "$FOCUSED_WORKSPACE" ]; then
        echo "$(date): Updating workspace highlights for focused workspace: $FOCUSED_WORKSPACE" >> /tmp/aerospace_debug.log
        
        # Reset all workspace highlights first
        for workspace in 1 2 3 4 5 6 7 8 9 10; do
            sketchybar --set space.$workspace \
                icon.highlight=false \
                label.highlight=false \
                background.border_color=$BACKGROUND_2 2>/dev/null
        done
        
        # Set current workspace highlight
        echo "$(date): Setting highlight for workspace: $FOCUSED_WORKSPACE" >> /tmp/aerospace_debug.log
        sketchybar --set space.$FOCUSED_WORKSPACE \
            icon.highlight=true \
            label.highlight=true \
            background.border_color=$GREY 2>/dev/null
        
        # Update app icons for all workspaces or just the changed ones
        workspaces_to_update=()
        if [ -n "$AEROSPACE_PREV_WORKSPACE" ] && [ "$AEROSPACE_PREV_WORKSPACE" != "$FOCUSED_WORKSPACE" ]; then
            workspaces_to_update=("$AEROSPACE_PREV_WORKSPACE" "$FOCUSED_WORKSPACE")
        else
            # If we don't have prev info, update just the focused workspace
            workspaces_to_update=("$FOCUSED_WORKSPACE")
        fi
        
        for workspace in "${workspaces_to_update[@]}"; do
            echo "$(date): Updating app icons for workspace: $workspace" >> /tmp/aerospace_debug.log
            
            # Get app list for this workspace
            apps=$(aerospace list-windows --workspace "$workspace" --format "%{app-name}" 2>/dev/null)
            
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
            
            echo "$(date): Setting workspace $workspace label to: '$icon_strip'" >> /tmp/aerospace_debug.log
            sketchybar --set space.$workspace label="$icon_strip" 2>/dev/null
        done
    else
        echo "$(date): ERROR - Could not determine focused workspace" >> /tmp/aerospace_debug.log
    fi

elif [ "$SENDER" = "mouse.clicked" ]; then
    # Handle workspace clicks
    WORKSPACE_ID=${NAME#*.}  # Extract number from space.X
    echo "$(date): Switching to workspace $WORKSPACE_ID via mouse click" >> /tmp/aerospace_debug.log
    aerospace workspace "$WORKSPACE_ID"

fi