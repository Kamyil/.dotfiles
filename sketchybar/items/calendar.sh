#!/bin/bash

# Clock matching waybar format: "{:%A %H:%M}"
source "$CONFIG_DIR/colors.sh"

calendar=(
  icon.drawing=off
  label.align=center
  label.color=$WHITE
  label.font="JetBrainsMono Nerd Font:Regular:12.0"
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
)

sketchybar --add item calendar center \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
