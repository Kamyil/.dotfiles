#!/usr/bin/env bash
set -euo pipefail

theme_state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
current_theme="$theme_state/current"
current_background="$theme_state/background"

active_theme_name() {
    if [[ -r "$current_theme/theme.name" ]]; then
        cat "$current_theme/theme.name"
    else
        printf '%s\n' kanagawa-paper
    fi
}

wallpapers() {
    local theme_name theme_dir user_dir
    theme_name="$(active_theme_name)"
    theme_dir="$current_theme/backgrounds"
    user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/backgrounds/$theme_name"

    find -L "$user_dir" "$theme_dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
        -print0 2>/dev/null | sort -z | while IFS= read -r -d '' path; do
            printf '%s\n' "$path"
        done
}

current() {
    local selected
    selected="$(readlink "$current_background" 2>/dev/null || true)"
    if [[ -n "$selected" && -f "$selected" ]]; then
        printf '%s\n' "$selected"
        return
    fi
    mapfile -t items < <(wallpapers)
    ((${#items[@]} > 0)) && printf '%s\n' "${items[0]}"
}

resolve_path() {
    local requested candidate
    requested="$1"
    [[ -n "$requested" && -f "$requested" ]] || return 1
    while IFS= read -r candidate; do
        [[ "$candidate" == "$requested" ]] && { printf '%s\n' "$requested"; return; }
    done < <(wallpapers)
    return 1
}

apply() {
    local selected
    selected="$(resolve_path "$1")" || {
        printf 'Unknown wallpaper: %s\n' "$1" >&2
        exit 2
    }

    mkdir -p "$theme_state"
    ln -nsf "$selected" "$current_background"

    pkill -x swaybg 2>/dev/null || true
    systemctl --user stop dotfiles-wallpaper.service 2>/dev/null || true
    systemctl --user reset-failed dotfiles-wallpaper.service 2>/dev/null || true
    systemd-run --user --quiet --collect --service-type=exec \
        --unit=dotfiles-wallpaper \
        swaybg -i "$selected" -m fill
    printf '%s\n' "$selected"
}

cycle() {
    local direction="$1" selected index=-1
    mapfile -t items < <(wallpapers)
    ((${#items[@]} > 0)) || exit 1

    selected="$(current)"
    for i in "${!items[@]}"; do
        if [[ "${items[$i]}" == "$selected" ]]; then
            index="$i"
            break
        fi
    done

    if [[ "$direction" == next ]]; then
        index=$(( (index + 1) % ${#items[@]} ))
    else
        ((index >= 0)) || index=0
        index=$(( (index - 1 + ${#items[@]}) % ${#items[@]} ))
    fi
    apply "${items[$index]}"
}

set_theme_background() {
    local selected index=-1
    mapfile -t items < <(wallpapers)
    ((${#items[@]} > 0)) || return 0

    selected="$(readlink "$current_background" 2>/dev/null || true)"
    for i in "${!items[@]}"; do
        if [[ "${items[$i]}" == "$selected" ]]; then
            index="$i"
            break
        fi
    done
    if ((index == -1)); then
        apply "${items[0]}"
    else
        apply "${items[$(( (index + 1) % ${#items[@]} ))]}"
    fi
}

list_json() {
    local selected first=1 file filename label
    selected="$(current)"
    printf '{"current":"%s","wallpapers":[' "$selected"
    while IFS= read -r file; do
        ((first)) || printf ','
        first=0
        filename="$(basename -- "$file")"
        label="${filename%.*}"
        label="${label#[0-9]-}"
        label="${label#[0-9][0-9]-}"
        label="${label//-/ }"
        printf '{"file":"%s","name":"%s","source":"file://%s"}' \
            "$file" "$label" "$file"
    done < <(wallpapers)
    printf ']}\n'
}

case "${1:-}" in
    list) list_json ;;
    current) current ;;
    set)
        [[ $# -eq 2 ]] || { printf 'Usage: %s set <path>\n' "$0" >&2; exit 2; }
        apply "$2"
        ;;
    start) apply "$(current)" ;;
    theme) set_theme_background ;;
    next) cycle next ;;
    previous) cycle previous ;;
    random)
        mapfile -t choices < <(wallpapers)
        ((${#choices[@]} > 0)) || exit 1
        apply "${choices[RANDOM % ${#choices[@]}]}"
        ;;
    *)
        printf 'Usage: %s {list|current|set <path>|start|theme|next|previous|random}\n' "$0" >&2
        exit 2
        ;;
esac
