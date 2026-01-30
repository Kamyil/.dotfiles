#!/bin/bash

# Memory usage plugin for sketchybar
# Matches waybar format: {used:0.1f}G/{total:0.1f}G

# Get used memory pages
pages_used=$(vm_stat | grep 'Pages used' | awk '{print $3}' | sed 's/\.//')

# Get total memory in bytes
total_bytes=$(sysctl -n hw.memsize)

page_size=4096

# Calculate in GB
used_mb=$(( (pages_used * page_size) / 1024 / 1024 ))
total_mb=$(( total_bytes / 1024 / 1024 ))

used_gb=$(echo "scale=1; $used_mb / 1024" | bc)
total_gb=$(echo "scale=1; $total_mb / 1024" | bc)

echo "${used_gb}G/${total_gb}G"
