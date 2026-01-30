#!/bin/bash

# Battery widget matching waybar: "{capacity}% {icon}"
source "$CONFIG_DIR/colors.sh"

battery=(
  icon.padding_left=0
  icon.padding_right=2
  label.color=$WHITE
  label.font="JetBrainsMono Nerd Font:Regular:12.0"
  update_freq=60
  script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
