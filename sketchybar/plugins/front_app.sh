#!/bin/bash

if [ "$SENDER" = "front_app_switched" ]; then
	sketchybar --set $NAME label="$INFO" icon.background.image="app.$INFO" icon.background.image.scale=0.6 icon.background.image.shadow.drawing=false
fi
