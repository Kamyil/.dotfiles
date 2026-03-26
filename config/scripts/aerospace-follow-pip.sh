#!/usr/bin/env bash

LOG_FILE='/tmp/aerospace_pip.log'

AEROSPACE_BIN=''
if command -v aerospace >/dev/null 2>&1; then
    AEROSPACE_BIN='aerospace'
elif [[ -x '/opt/homebrew/bin/aerospace' ]]; then
    AEROSPACE_BIN='/opt/homebrew/bin/aerospace'
elif [[ -x '/usr/local/bin/aerospace' ]]; then
    AEROSPACE_BIN='/usr/local/bin/aerospace'
else
    printf '%s aerospace binary not found\n' "$(date)" >> "$LOG_FILE"
    exit 0
fi

focused_workspace="${AEROSPACE_FOCUSED_WORKSPACE:-}"
if [[ -z "$focused_workspace" ]]; then
    focused_workspace="$($AEROSPACE_BIN list-workspaces --focused 2>/dev/null | { IFS= read -r line; printf '%s' "$line"; })"
fi

if [[ -z "$focused_workspace" ]]; then
    printf '%s no focused workspace\n' "$(date)" >> "$LOG_FILE"
    exit 0
fi

printf '%s run focused=%s prev=%s\n' "$(date)" "$focused_workspace" "${AEROSPACE_PREV_WORKSPACE:-}" >> "$LOG_FILE"

$AEROSPACE_BIN list-windows --all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{window-title}' | while IFS=$'\t' read -r window_id app_bundle_id window_title; do
    should_follow=0

    case "$window_title" in
        *[Pp]icture*in*picture*|*[Pp]icture-in-[Pp]icture*|*[Oo]braz*w*[Oo]brazie*)
            should_follow=1
            ;;
    esac

    if [[ "$app_bundle_id" == "net.imput.helium" && "$window_title" == "Obraz w obrazie" ]]; then
        should_follow=1
    fi

    if [[ "$should_follow" -eq 1 ]]; then
        printf '%s move window=%s title=%s to=%s\n' "$(date)" "$window_id" "$window_title" "$focused_workspace" >> "$LOG_FILE"
        $AEROSPACE_BIN layout floating --window-id "$window_id" >/dev/null 2>&1 || true
        $AEROSPACE_BIN move-node-to-workspace --window-id "$window_id" "$focused_workspace" >/dev/null 2>&1 || true
    fi
done
