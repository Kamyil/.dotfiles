#!/bin/bash

# Apple icon matching waybar's custom/omarchy module
# Using Nerd Font apple icon (not SF Symbols)
source "$CONFIG_DIR/colors.sh"

apple_logo=(
  icon=
  icon.font="JetBrainsMono Nerd Font:Regular:12.0"
  icon.color=$WHITE
  icon.padding_right=7
  label.drawing=off
  click_script="open -a 'System Preferences'"
)

sketchybar --add item apple.logo left \
           --set apple.logo "${apple_logo[@]}"
