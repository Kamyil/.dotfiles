#!/usr/bin/env bash

set -o pipefail

set_screenshot_mode() {
  qs ipc call panels setScreenshotMode "$1" >/dev/null 2>&1 || true
}

set_screenshot_mode true
trap 'set_screenshot_mode false' EXIT

omasnap "$@"
