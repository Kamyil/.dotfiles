#!/bin/bash

# CPU usage plugin for sketchybar
# Returns CPU percentage

usage=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
echo "$usage%"
