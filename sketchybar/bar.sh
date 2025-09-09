#!/bin/bash

# Bar configuration - converted from Lua to shell
source "$CONFIG_DIR/colors.sh"

# Equivalent to the --bar domain from bar.lua
bar=(
  color=0x80000000
  height=45
  padding_right=10
  padding_left=10
  sticky=on
  topmost=window
  y_offset=-5
  margin=-2
  blur_radius=30
  border_color=0x00000000
)

sketchybar --bar "${bar[@]}"