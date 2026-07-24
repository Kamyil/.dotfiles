#!/usr/bin/env bash
set -euo pipefail

if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi
hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | [.name, .active_keymap] | @tsv' | head -n 1
