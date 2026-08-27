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
    todoist)
        app_class='chrome-app.todoist.com__-Default'
        launch_command='helium --app=https://app.todoist.com'
        ;;
    notes)
        app_class='second-brain'
        launch_command='kitty --class second-brain --directory "$HOME/second-brain" nvim'
        ;;
    *)
        printf 'usage: %s {spotify|chatgpt|messenger|todoist|notes}\n' "$0" >&2
        exit 2
        ;;
esac

client_exists() {
    hyprctl clients -j | jq -e --arg class "$app_class" 'any(.[]; .class == $class)' >/dev/null
}

if [ "$panel" = notes ]; then
    notes_clients="$(hyprctl clients -j)"
    if ! jq -e 'any(.[]; .class == "second-brain")' <<<"$notes_clients" >/dev/null; then
        hyprctl dispatch "hl.dsp.exec_cmd([[$launch_command]])" >/dev/null
        for _ in $(seq 1 20); do
            sleep 0.1
            notes_clients="$(hyprctl clients -j)"
            jq -e 'any(.[]; .class == "second-brain")' <<<"$notes_clients" >/dev/null && break
        done
    fi

    if ! jq -e 'any(.[]; .class == "second-brain" and .workspace.name == "special:notes")' <<<"$notes_clients" >/dev/null; then
        hyprctl dispatch "hl.dsp.window.move({ workspace = [[special:notes]], follow = false, window = [[class:^(second-brain)$]] })" >/dev/null
    fi

    notes_monitors="$(hyprctl monitors -j)"
    notes_monitor="$(jq -r '.[] | select(.specialWorkspace.name == "special:notes") | .name' <<<"$notes_monitors")"
    if [ -n "$notes_monitor" ]; then
        notes_monitor_focused="$(jq -r --arg monitor "$notes_monitor" '.[] | select(.name == $monitor) | .focused' <<<"$notes_monitors")"
        if [ "$notes_monitor_focused" != true ]; then
            active_address="$(hyprctl activewindow -j | jq -r '.address // empty')"
            hyprctl dispatch "focusmonitor $notes_monitor" >/dev/null
        fi

        hyprctl dispatch "hl.dsp.workspace.toggle_special([[notes]])" >/dev/null
        if [ -n "${active_address:-}" ]; then
            hyprctl dispatch "hl.dsp.focus({ window = [[address:$active_address]] })" >/dev/null
        fi
        exit 0
    fi

    hyprctl dispatch "hl.dsp.workspace.toggle_special([[notes]])" >/dev/null
    hyprctl dispatch "hl.dsp.focus({ window = [[class:^(second-brain)$]] })" >/dev/null
    exit 0
fi

if ! client_exists; then
    hyprctl dispatch "hl.dsp.exec_cmd([[$launch_command]])" >/dev/null
fi

hyprctl dispatch "hl.dsp.workspace.toggle_special([[$panel]])" >/dev/null
