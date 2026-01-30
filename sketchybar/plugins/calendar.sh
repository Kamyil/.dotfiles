#!/bin/bash

# Calendar plugin matching waybar format: Full weekday + 24h time
# e.g., "Friday 14:30"

weekday=$(date '+%A')
time=$(date '+%H:%M')
sketchybar --set $NAME label="$weekday $time"
