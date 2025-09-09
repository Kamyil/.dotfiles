#!/bin/bash

# Aerospace workspace change trigger script
echo "$(date): Aerospace trigger called" >> /tmp/aerospace_debug.log

# Find sketchybar binary path
SKETCHYBAR_BIN=""
if command -v sketchybar >/dev/null 2>&1; then
    SKETCHYBAR_BIN="sketchybar"
elif [ -x "/opt/homebrew/bin/sketchybar" ]; then
    SKETCHYBAR_BIN="/opt/homebrew/bin/sketchybar"
elif [ -x "/usr/local/bin/sketchybar" ]; then
    SKETCHYBAR_BIN="/usr/local/bin/sketchybar"
else
    echo "$(date): ERROR - sketchybar binary not found" >> /tmp/aerospace_debug.log
    exit 1
fi

echo "$(date): Triggering sketchybar workspace update" >> /tmp/aerospace_debug.log
$SKETCHYBAR_BIN --trigger aerospace_workspace_change