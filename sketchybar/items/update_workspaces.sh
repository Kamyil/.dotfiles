#!/bin/bash

# Update workspace highlighting when aerospace workspace changes
# This makes the active workspace stand out like waybar's hyprland/workspaces

source "$CONFIG_DIR/colors.sh"

focused=$(aerospace list-workspaces --focused)

# Map aerospace workspace 10 to sketchybar id 0
sketchybar_id=$focused
if [ "$focused" = "10" ]; then
  sketchybar_id="0"
fi

# Reset all workspaces to normal
for sid in 1 2 3 4 5 6 7 8 9 0; do
  if [ "$sid" = "$sketchybar_id" ]; then
    # Active workspace: yellow color + bold font
    sketchybar --set space.$sid icon.color=$YELLOW icon.font="JetBrainsMono Nerd Font:Bold:12.0"
  else
    # Inactive workspace: white color + regular font
    sketchybar --set space.$sid icon.color=$WHITE icon.font="JetBrainsMono Nerd Font:Regular:12.0"
  fi
done
