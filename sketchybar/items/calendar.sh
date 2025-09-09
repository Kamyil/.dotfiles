#!/bin/bash

calendar=(
  icon=󰸗
  icon.font="Berkeley Mono:Black:12.0"
  icon.color=$YELLOW
  icon.padding_right=0
  label.align=right
  label.color=$WHITE
  label.font="Berkeley Mono:Regular:12.0"
  padding_left=15
  update_freq=1
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
