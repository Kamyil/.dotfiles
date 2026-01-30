#!/bin/bash

# Battery plugin matching waybar format
source "$CONFIG_DIR/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo '\d+%' | head -1 | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

# Icons matching waybar format
if [[ $CHARGING != "" ]]; then
  ICON="󰂄"
else
  case ${PERCENTAGE} in
    9[0-9]|100) ICON="󰁹";;
    8[0-9]) ICON="󰂂";;
    7[0-9]) ICON="󰂁";;
    6[0-9]) ICON="󰂀";;
    5[0-9]) ICON="󰁿";;
    4[0-9]) ICON="󰁾";;
    3[0-9]) ICON="󰁽";;
    2[0-9]) ICON="󰁼";;
    1[0-9]) ICON="󰁻";;
    *) ICON="󰁺";;
  esac
fi

sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%"
