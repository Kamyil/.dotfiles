#!/bin/bash

# Items configuration - loads all items like items/init.lua
ITEM_DIR="$CONFIG_DIR/items"

# Left side items
source "$ITEM_DIR/apple.sh"
source "$ITEM_DIR/spaces.sh"
source "$ITEM_DIR/front_app.sh"

# Right side items
source "$ITEM_DIR/calendar.sh"

# Only source files that exist as .sh
# Note: Other items (battery, wifi, volume, svim, cpu, weather) are .lua files
# and should be converted to .sh if needed, or loaded via the Lua configuration

sketchybar --hotload on
sketchybar --update