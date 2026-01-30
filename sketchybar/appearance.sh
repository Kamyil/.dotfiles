#!/bin/bash

# Appearance configuration matching waybar style
source "$CONFIG_DIR/colors.sh"

# Waybar uses: JetBrainsMono Nerd Font, 12px, flat design, no backgrounds
defaults=(
  updates=on
  icon.font="JetBrainsMono Nerd Font:Regular:12.0"
  icon.color=$WHITE
  icon.padding_left=0
  icon.padding_right=0
  label.font="JetBrainsMono Nerd Font:Regular:12.0"
  label.color=$WHITE
  label.padding_left=0
  label.padding_right=0
  background.border_color=$TRANSPARENT
  background.border_width=0
  background.color=$TRANSPARENT
  background.corner_radius=0
  background.height=26
  popup.background.border_width=0
  popup.background.corner_radius=0
  popup.background.color=$BAR_COLOR
  popup.blur_radius=0
  popup.y_offset=0
  padding_left=0
  padding_right=0
  scroll_texts=off
)

sketchybar --default "${defaults[@]}"
