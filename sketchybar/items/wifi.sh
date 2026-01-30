#!/bin/bash

# WiFi widget matching waybar network module (icon only)
source "$CONFIG_DIR/colors.sh"

wifi=(
  icon=󰤨
  icon.font="JetBrainsMono Nerd Font:Regular:12.0"
  icon.color=$WHITE
  icon.padding_right=7
  label.drawing=off
  update_freq=5
  script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
           --subscribe wifi wifi_change
