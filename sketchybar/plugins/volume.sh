#!/bin/bash

# Volume plugin for sketchybar
# Shows volume icon based on level

volume=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
muted=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)

if [ "$muted" = "true" ]; then
  echo ""
elif [ "$volume" -gt 66 ]; then
  echo ""
elif [ "$volume" -gt 33 ]; then
  echo ""
elif [ "$volume" -gt 0 ]; then
  echo ""
else
  echo ""
fi
