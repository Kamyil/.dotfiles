#!/usr/bin/env bash
set -euo pipefail

config_dir=/etc/wireguard
command_name=${1:-list}

validate_profile() {
  local profile=${1:-}
  [[ $profile =~ ^[A-Za-z0-9_.-]+$ ]] || {
    printf 'Invalid WireGuard profile name\n' >&2
    exit 2
  }
  printf '%s' "$profile"
}

profile_active() {
  systemctl is-active --quiet "wg-quick-$1.service"
}

list_profiles() {
  local config name
  shopt -s nullglob
  for config in "$config_dir"/*.conf; do
    name=${config##*/}
    printf '%s\n' "${name%.conf}"
  done
}

case "$command_name" in
  list)
    list_profiles
    ;;
  list-status)
    while IFS= read -r name; do
      if profile_active "$name"; then
        printf '%s:active\n' "$name"
      else
        printf '%s:inactive\n' "$name"
      fi
    done < <(list_profiles)
    ;;
  active)
    while IFS= read -r name; do
      if profile_active "$name"; then
        printf '%s\n' "$name"
        exit 0
      fi
    done < <(list_profiles)
    ;;
  up|down)
    requested=$(validate_profile "${2:-}")
    sudo systemctl "$command_name" "wg-quick-$requested.service"
    ;;
  toggle)
    requested=$(validate_profile "${2:-}")
    if profile_active "$requested"; then
      sudo systemctl stop "wg-quick-$requested.service"
    else
      sudo systemctl start "wg-quick-$requested.service"
    fi
    ;;
  *)
    printf 'Usage: %s [list|list-status|active|up PROFILE|down PROFILE|toggle PROFILE]\n' "$0" >&2
    exit 2
    ;;
esac
