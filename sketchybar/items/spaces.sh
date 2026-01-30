#!/bin/bash

# Aerospace workspaces matching waybar's hyprland/workspaces
# Shows all workspaces 1-9, 0 (for workspace 10)
source "$CONFIG_DIR/colors.sh"

sketchybar --add event aerospace_workspace_change

# All workspace IDs we want to show
WORKSPACE_IDS=(1 2 3 4 5 6 7 8 9 0)

for sid in "${WORKSPACE_IDS[@]}"; do
  # Map 0 to workspace 10 for aerospace
  aerospace_id=$sid
  if [ "$sid" = "0" ]; then
    aerospace_id="10"
  fi
  
  space=(
    icon="$sid"
    icon.color=$WHITE
    icon.highlight_color=$YELLOW
    icon.font="JetBrainsMono Nerd Font:Regular:12.0"
    icon.padding_left=6
    icon.padding_right=6
    label.drawing=off
    click_script="aerospace workspace $aerospace_id"
  )

  sketchybar --add item space.$sid left \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid aerospace_workspace_change
done

# Update workspace highlighting when workspace changes
sketchybar --add item workspace_watcher left \
           --set workspace_watcher drawing=off \
           --subscribe workspace_watcher aerospace_workspace_change \
           --set workspace_watcher script="$CONFIG_DIR/items/update_workspaces.sh"
