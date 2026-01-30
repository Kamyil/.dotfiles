#!/bin/bash

# Bar configuration matching waybar
# Position: bottom, height: 26px, no blur, minimal styling
source "$CONFIG_DIR/colors.sh"

# Convert waybar colors to sketchybar format
# waybar: foreground #dcd7ba, background rgba(31, 31, 40, 0.95)
BAR_HEIGHT=26
BAR_POSITION="bottom"
FONT="JetBrainsMono Nerd Font"

bar=(
  color=$BAR_COLOR
  height=$BAR_HEIGHT
  padding_right=8
  padding_left=8
  position=$BAR_POSITION
  sticky=on
  topmost=off
  y_offset=0
  margin=0
  blur_radius=0
  border_color=$TRANSPARENT
  border_width=0
)

sketchybar --bar "${bar[@]}"
