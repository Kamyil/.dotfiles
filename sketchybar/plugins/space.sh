#!/bin/bash

source "$CONFIG_DIR/colors.sh"

update() {
  # Get the currently focused workspace
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
  
  # Reset all workspaces to inactive state first
  for workspace in $(aerospace list-workspaces --all); do
    sketchybar --set space.$workspace \
      icon.highlight=false \
      label.highlight=false \
      background.border_color=$ITEM_BG_COLOR
  done
  
  # Highlight the focused workspace
  if [ -n "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set space.$FOCUSED_WORKSPACE \
      icon.highlight=true \
      label.highlight=true \
      background.border_color=$ACCENT_COLOR
  fi
  
  # Update app icons for all workspaces
  for workspace in $(aerospace list-workspaces --all); do
    apps=$(aerospace list-windows --workspace $workspace | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
    
    icon_strip=" "
    if [ "${apps}" != "" ]; then
      while read -r app; do
        if [ -n "$app" ]; then
          icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
        fi
      done <<< "${apps}"
    else
      icon_strip=" —"
    fi
    
    sketchybar --set space.$workspace label="$icon_strip"
  done
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    # Right click - could add workspace management here
    echo ""
  else
    if [ "$MODIFIER" = "shift" ]; then
      # Shift+click - rename workspace
      WORKSPACE_ID=${NAME#*.}
      SPACE_LABEL="$(osascript -e "return (text returned of (display dialog \"Give a name to workspace $WORKSPACE_ID:\" default answer \"\" with icon note buttons {\"Cancel\", \"Continue\"} default button \"Continue\"))")"
      if [ $? -eq 0 ]; then
        if [ "$SPACE_LABEL" = "" ]; then
          sketchybar --set $NAME icon="$WORKSPACE_ID"
        else
          sketchybar --set $NAME icon="$WORKSPACE_ID ($SPACE_LABEL)"
        fi
      fi
    else
      # Regular click - switch to workspace
      WORKSPACE_ID=${NAME#*.}
      aerospace workspace $WORKSPACE_ID
    fi
  fi
}

case "$SENDER" in
  "mouse.clicked") 
    mouse_clicked
    ;;
  *) 
    update
    ;;
esac
