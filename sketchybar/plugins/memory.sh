#!/bin/bash

# Memory usage plugin for sketchybar
# Shows App Memory (actual app usage, excluding file cache)
# Matches waybar format: {used:0.1f}G/{total:0.1f}G

# Get page size (varies between Intel and Apple Silicon)
page_size=$(pagesize)

# Get vm_stat data
vm_stats=$(vm_stat)

# Calculate App Memory (Anonymous pages - purgeable)
# This excludes file cache which macOS uses aggressively
anonymous_pages=$(echo "$vm_stats" | grep "Anonymous pages" | awk '{gsub(/\./, "", $3); print $3}')
purgeable=$(echo "$vm_stats" | grep "Pages purgeable" | awk '{gsub(/\./, "", $3); print $3}')
wired=$(echo "$vm_stats" | grep "Pages wired down" | awk '{gsub(/\./, "", $4); print $4}')
compressor=$(echo "$vm_stats" | grep "Pages occupied by compressor" | awk '{gsub(/\./, "", $5); print $5}')

# App memory calculation (what apps are actually using)
app_memory_pages=$(( anonymous_pages + wired + compressor ))
app_memory_bytes=$(( app_memory_pages * page_size ))
app_memory_gb=$(echo "scale=1; $app_memory_bytes / 1024 / 1024 / 1024" | bc)

# Get total memory in GB
total_bytes=$(sysctl -n hw.memsize)
total_gb=$(echo "scale=1; $total_bytes / 1024 / 1024 / 1024" | bc)

sketchybar --set $NAME label="${app_memory_gb}G/${total_gb}G"
