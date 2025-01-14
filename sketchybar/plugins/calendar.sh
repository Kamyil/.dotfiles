#!/bin/bash

# sketchybar --set $NAME label="$(date -R +'%A %D %B %I:%M %p' )"
sketchybar --set "$NAME" label="$(LC_TIME=pl_PL.UTF-8 date +'%A, %d %B %Y, %H:%M')"
