#!/usr/bin/env bash

selection=$(slurp)
if [ -z "$selection" ]; then
  exit 0
fi

grim -g "$selection" -t ppm - | GTK_THEME=Adwaita:dark satty --filename -
