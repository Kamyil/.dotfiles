#!/bin/bash

#Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/items/front_app.sh

front_app=(
  label.padding_left=4
  label.padding_right=4
  # Using "JetBrainsMono Nerd Font"
  label.font="JetBrainsMonoNL Nerd Font Propo:Bold:10.0"
  # Using default "SF Pro"
  # label.font="$FONT:Black:13.0"
  script="$PLUGIN_DIR/front_app.sh"
  click_script="open -a 'Mission Control'"
)

sketchybar --add item front_app left \
  --set front_app "${front_app[@]}" \
  --subscribe front_app front_app_switched
