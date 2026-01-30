#!/bin/bash

# Memory widget matching waybar: "format": "󰘚 {used:0.1f}G/{total:0.1f}G"
source "$CONFIG_DIR/colors.sh"

memory=(
  icon=󰘚
  icon.font="JetBrainsMono Nerd Font:Regular:12.0"
  icon.color=$WHITE
  icon.padding_right=2
  label.color=$WHITE
  label.font="JetBrainsMono Nerd Font:Regular:12.0"
  label.padding_right=7
  update_freq=5
  script="$PLUGIN_DIR/memory.sh"
)

sketchybar --add item memory right \
           --set memory "${memory[@]}"
