#!/bin/bash

# Items configuration - loads all items like items/init.lua
ITEM_DIR="$CONFIG_DIR/items"

# Load icons first
source "$CONFIG_DIR/icons.sh"

# Left side items
# source "$ITEM_DIR/apple.sh"  # Removed Apple logo
source "$ITEM_DIR/spaces.sh"
# source "$ITEM_DIR/front_app.sh"  # Removed - redundant with workspace apps

# Right side items
source "$ITEM_DIR/calendar.sh"

# Only source files that exist as .sh
# Note: Other items (battery, wifi, volume, svim, cpu, weather) are .lua files
# and should be converted to .sh if needed, or loaded via the Lua configuration

sketchybar --hotload on
sketchybar --update