#!/bin/bash

# Volume widget matching waybar pulseaudio module (icon only)
source "$CONFIG_DIR/colors.sh"

volume=(
  icon=
  icon.font="JetBrainsMono Nerd Font:Regular:12.0"
  icon.color=$WHITE
  icon.padding_right=7
  label.drawing=off
  script="$PLUGIN_DIR/volume.sh"
)

sketchybar --add item volume right \
           --set volume "${volume[@]}" \
           --subscribe volume volume_change
