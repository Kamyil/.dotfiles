#!/usr/bin/env bash

selection=$(slurp)
if [ -z "$selection" ]; then
  exit 0
fi

grim -g "$selection" - | swappy -f -
