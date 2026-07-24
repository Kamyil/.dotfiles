#!/usr/bin/env bash
set -euo pipefail

if command -v brightnessctl >/dev/null 2>&1; then
  current=$(brightnessctl get 2>/dev/null || printf '0')
  maximum=$(brightnessctl max 2>/dev/null || printf '0')
  if [[ $maximum -gt 0 ]]; then
    printf 'brightness\t%s\n' "$((current * 100 / maximum))"
  fi
fi

if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  hyprctl monitors -j | jq -r '.[] | ["monitor", .name, (.description // .name), (.width|tostring), (.height|tostring), (.refreshRate|tostring), (.x|tostring), (.y|tostring), (.scale|tostring), (.focused|tostring)] | @tsv'
fi
