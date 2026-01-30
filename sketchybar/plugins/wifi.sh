#!/bin/bash

# WiFi status plugin for sketchybar
# Shows connected/disconnected icon

wifi_status=$(ifconfig en0 2>/dev/null | grep 'status:' | awk '{print $2}')

if [ "$wifi_status" = "active" ]; then
  echo "󰤨"
else
  echo "󰤮"
fi
