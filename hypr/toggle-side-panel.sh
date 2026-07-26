#!/usr/bin/env bash
set -euo pipefail

panel="${1:-}"

case "$panel" in
    spotify)
        app_class='Spotify'
        launch_command='spotify'
        ;;
    chatgpt)
        app_class='chrome-chatgpt.com__-Default'
        launch_command='helium --app=https://chatgpt.com'
        ;;
    messenger)
        app_class='chrome-www.messenger.com__-Default'
        launch_command='helium --app=https://www.messenger.com'
        ;;
    *)
        printf 'usage: %s {spotify|chatgpt|messenger}\n' "$0" >&2
        exit 2
        ;;
esac

if ! hyprctl clients -j | jq -e --arg class "$app_class" 'any(.[]; .class == $class)' >/dev/null; then
    hyprctl dispatch "hl.dsp.exec_cmd([[$launch_command]])" >/dev/null
fi

hyprctl dispatch "hl.dsp.workspace.toggle_special([[$panel]])" >/dev/null
