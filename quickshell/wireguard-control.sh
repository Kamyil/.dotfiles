#!/usr/bin/env bash
set -euo pipefail

config_dir=/etc/wireguard
command_name=${1:-list}

case "$command_name" in
  list)
    shopt -s nullglob
    for config in "$config_dir"/*.conf; do
      name=${config##*/}
      printf '%s\n' "${name%.conf}"
    done
    ;;
  import)
    requested=${2:-}
    [[ -n "$requested" && "$requested" != */* ]] || {
      printf 'Invalid WireGuard profile name\n' >&2
      exit 2
    }
    config="$config_dir/$requested.conf"
    [[ -f "$config" ]] || {
      printf 'WireGuard config not found: %s\n' "$requested" >&2
      exit 2
    }
    sudo nmcli connection import type wireguard file "$config"
    sudo nmcli connection up id "$requested"
    ;;
  *)
    printf 'Usage: %s [list|import PROFILE]\n' "$0" >&2
    exit 2
    ;;
esac
