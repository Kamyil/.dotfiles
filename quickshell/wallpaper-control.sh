#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
wallpaper_dir="$(realpath "$script_dir/../wallpapers")"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-wallpaper"
state_file="$state_dir/current"

wallpapers() {
    local path
    shopt -s nullglob
    for path in "$wallpaper_dir"/*.png "$wallpaper_dir"/*.jpg "$wallpaper_dir"/*.jpeg; do
        basename -- "$path"
    done | sort
}

current() {
    local selected=""
    if [[ -r "$state_file" ]]; then
        IFS= read -r selected < "$state_file"
    fi
    if [[ "$selected" == *.webp && -f "$wallpaper_dir/${selected%.webp}.png" ]]; then
        selected="${selected%.webp}.png"
    fi
    if [[ -n "$selected" && -f "$wallpaper_dir/$selected" ]]; then
        printf '%s\n' "$selected"
        return
    fi
    if [[ -f "$wallpaper_dir/kanagawa-paper-monochrome.png" ]]; then
        printf '%s\n' 'kanagawa-paper-monochrome.png'
    else
        wallpapers | head -n 1
    fi
}

resolve_name() {
    local requested="$1"
    [[ "$requested" == "$(basename -- "$requested")" ]] || return 1
    [[ -f "$wallpaper_dir/$requested" ]] || return 1
    printf '%s\n' "$requested"
}

apply() {
    local selected
    selected="$(resolve_name "$1")" || {
        printf 'Unknown wallpaper: %s\n' "$1" >&2
        exit 2
    }

    mkdir -p "$state_dir"
    printf '%s\n' "$selected" > "$state_file.tmp"
    mv -f "$state_file.tmp" "$state_file"

    pkill -x swaybg 2>/dev/null || true
    systemctl --user stop dotfiles-wallpaper.service 2>/dev/null || true
    systemctl --user reset-failed dotfiles-wallpaper.service 2>/dev/null || true
    systemd-run --user --quiet --collect --service-type=exec \
        --unit=dotfiles-wallpaper \
        swaybg -i "$wallpaper_dir/$selected" -m fill
    printf '%s\n' "$selected"
}

cycle() {
    local direction="$1"
    mapfile -t items < <(wallpapers)
    ((${#items[@]} > 0)) || exit 1

    local selected index=-1
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

list_json() {
    local selected first=1 file label
    selected="$(current)"
    printf '{"current":"%s","wallpapers":[' "$selected"
    while IFS= read -r file; do
        ((first)) || printf ','
        first=0
        label="${file%.*}"
        label="${label#kanagawa-}"
        label="${label#paper-}"
        label="${label//-/ }"
        printf '{"file":"%s","name":"%s","source":"file://%s/%s"}' \
            "$file" "$label" "$wallpaper_dir" "$file"
    done < <(wallpapers)
    printf ']}\n'
}

case "${1:-}" in
    list) list_json ;;
    current) current ;;
    set)
        [[ $# -eq 2 ]] || { printf 'Usage: %s set <filename>\n' "$0" >&2; exit 2; }
        apply "$2"
        ;;
    start) apply "$(current)" ;;
    next) cycle next ;;
    previous) cycle previous ;;
    random)
        mapfile -t choices < <(wallpapers)
        ((${#choices[@]} > 0)) || exit 1
        apply "${choices[RANDOM % ${#choices[@]}]}"
        ;;
    *)
        printf 'Usage: %s {list|current|set <filename>|start|next|previous|random}\n' "$0" >&2
        exit 2
        ;;
esac
