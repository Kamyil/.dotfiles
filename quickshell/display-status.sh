#!/usr/bin/env bash
set -euo pipefail

if command -v brightnessctl >/dev/null 2>&1; then
  current=$(brightnessctl get 2>/dev/null || printf '0')
  maximum=$(brightnessctl max 2>/dev/null || printf '0')
  if [[ $maximum -gt 0 ]]; then
    printf 'brightness\t%s\n' "$((current * 100 / maximum))"
  fi
fi

# Text size is optional: Quattro's omarchy-display-text-size command is only
# present on systems that provide a shell/GTK text-size override.
if command -v omarchy-display-text-size >/dev/null 2>&1; then
  printf 'text-size-available\ttrue\n'
  text_size_status=$(omarchy-display-text-size 2>/dev/null || true)
  if [[ $text_size_status =~ text[[:space:]]+size:[[:space:]]*([0-9]+) ]]; then
    printf 'text-size\t%s\n' "${BASH_REMATCH[1]}"
  fi
else
  printf 'text-size-available\tfalse\n'
fi

if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  # `monitors all` retains disabled outputs, allowing the panel to offer
  # enable/disable controls instead of only showing active monitors.
  displays=$(hyprctl monitors all -j 2>/dev/null | jq -c '[.[] | {
    name: .name,
    description: (.description // .name),
    width: (.width // 0),
    height: (.height // 0),
    refreshRate: (.refreshRate // 0),
    x: (.x // 0),
    y: (.y // 0),
    scale: (.scale // 1),
    focused: (.focused // false),
    enabled: ((.disabled // false) | not)
  }]')
  printf 'displays-json\t%s\n' "${displays:-[]}" 
fi
