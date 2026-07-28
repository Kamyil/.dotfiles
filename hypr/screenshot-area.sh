#!/usr/bin/env bash

set -o pipefail

set_panel_screenshot_mode() {
  qs ipc call panels setScreenshotMode "$1" >/dev/null 2>&1 || true
}

set_panel_screenshot_mode true
trap 'set_panel_screenshot_mode false' EXIT
selection=$(slurp)
if [ -z "$selection" ]; then
  exit 0
fi

grim -g "$selection" -t ppm - | GTK_THEME=Adwaita:dark satty --filename -
