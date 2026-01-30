#!/bin/bash

# CPU widget matching waybar: "format": "󰍛 {usage}%"
source "$CONFIG_DIR/colors.sh"

cpu=(
  icon=󰍛
  icon.font="JetBrainsMono Nerd Font:Regular:12.0"
  icon.color=$WHITE
  icon.padding_right=2
  label.color=$WHITE
  label.font="JetBrainsMono Nerd Font:Regular:12.0"
  label.padding_right=7
  update_freq=5
  script="$PLUGIN_DIR/cpu.sh"
)

sketchybar --add item cpu right \
           --set cpu "${cpu[@]}"
