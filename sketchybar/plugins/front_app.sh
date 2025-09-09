#!/bin/bash

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "front_app_switched" ]; then
    sketchybar --set $NAME label="$INFO" icon="$($CONFIG_DIR/plugins/icon_map.sh "$INFO")"
fi