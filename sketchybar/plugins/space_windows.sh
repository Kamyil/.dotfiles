#!/bin/bash

# Simple script for handling space creation and window changes
# This is called by the space_creator item

source "$CONFIG_DIR/colors.sh"

# Update the space creator icon based on current state
sketchybar --set space_creator icon.color=$WHITE

# Refresh all workspace displays when aerospace changes occur
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