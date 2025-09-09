#!/bin/bash

# Appearance configuration - converted from Lua to shell
source "$CONFIG_DIR/colors.sh"

# Bar defaults based on appearance.lua
defaults=(
  updates=when_shown
  icon.font="Berkeley Mono:Bold:13.0"
  icon.color=$BLUE
  icon.padding_left=0
  icon.padding_right=0
  label.font="Berkeley Mono:Semibold:13.0"
  label.color=$BLUE
  label.padding_left=3
  label.padding_right=3
  background.border_color=$GREY
  background.border_width=0
  background.color=0x33000000
  background.corner_radius=0
  background.height=32
  popup.background.border_width=0
  popup.background.corner_radius=6
  popup.background.color=$WHITE
  popup.blur_radius=50
  popup.y_offset=5
  padding_left=3
  padding_right=3
  scroll_texts=on
)

sketchybar --default "${defaults[@]}"