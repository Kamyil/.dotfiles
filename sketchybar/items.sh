#!/bin/bash

# Items configuration matching waybar layout
# Left: Apple icon, Workspaces
# Center: Clock
# Right: CPU, Memory, WiFi, Volume, Battery

ITEM_DIR="$CONFIG_DIR/items"

# Source icons
source "$CONFIG_DIR/icons.sh"

# Left side items
source "$ITEM_DIR/apple.sh"
source "$ITEM_DIR/spaces.sh"

# Center item
source "$ITEM_DIR/calendar.sh"

# Right side items (matching waybar order: cpu, memory, wifi, volume, battery)
source "$ITEM_DIR/cpu.sh"
source "$ITEM_DIR/memory.sh"
source "$ITEM_DIR/wifi.sh"
source "$ITEM_DIR/volume.sh"
source "$ITEM_DIR/battery.sh"

sketchybar --hotload on
sketchybar --update
