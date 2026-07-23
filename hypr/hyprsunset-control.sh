#!/usr/bin/env bash

set -euo pipefail

socket="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.hyprsunset.sock"
state_file="${socket%.sock}.state"

# A new Hyprsunset process starts enabled regardless of the previous IPC state.
if [[ -f "$state_file" ]] && [[ -S "$socket" ]] && [[ "$socket" -nt "$state_file" ]]; then
  rm -f "$state_file"
fi

if [[ ! -S "$socket" ]]; then
  if [[ ${1:-status} == status ]]; then
    printf '{"text":"󰖨 ?","tooltip":"Hyprsunset is not running","class":"unavailable"}\n'
  else
    printf 'Hyprsunset is not running\n' >&2
    exit 1
  fi
  exit 0
fi

ipc() {
  # OpenBSD netcat otherwise waits indefinitely after stdin reaches EOF,
  # causing Waybar polling processes to accumulate.
  printf '%s\n' "$1" | nc -N -U "$socket"
}

refresh_waybar() {
  pkill -RTMIN+9 waybar 2>/dev/null || true
}

status() {
  local temperature state class
  temperature="$(ipc 'temperature')"

  if [[ -f "$state_file" ]] && [[ "$(cat "$state_file")" == disabled ]]; then
    state="off"
    class="disabled"
  else
    state="on"
    class="enabled"
  fi

  printf '{"text":"󰖨 %sK","tooltip":"Night light: %s\\nTemperature: %sK\\n\\nLeft click: toggle\\nScroll: adjust by 250K\\nMiddle click: reset to 4500K","class":"%s"}\n' \
    "$temperature" "$state" "$temperature" "$class"
}

set_temperature() {
  local temperature="$1"
  (( temperature < 1000 )) && temperature=1000
  (( temperature > 6500 )) && temperature=6500
  ipc "temperature $temperature" >/dev/null
  printf 'enabled\n' >"$state_file"
  refresh_waybar
}

case "${1:-status}" in
  status)
    status
    ;;
  toggle)
    if [[ -f "$state_file" ]] && [[ "$(cat "$state_file")" == disabled ]]; then
      # v0.3.3 has no `identity false`; setting the current temperature
      # disables identity mode and reapplies the filter.
      ipc "temperature $(ipc 'temperature')" >/dev/null
      printf 'enabled\n' >"$state_file"
    else
      ipc 'identity' >/dev/null
      printf 'disabled\n' >"$state_file"
    fi
    refresh_waybar
    ;;
  warmer)
    set_temperature "$(( $(ipc 'temperature') - 250 ))"
    ;;
  cooler)
    set_temperature "$(( $(ipc 'temperature') + 250 ))"
    ;;
  reset)
    set_temperature 4500
    ;;
  *)
    printf 'Usage: %s {status|toggle|warmer|cooler|reset}\n' "$0" >&2
    exit 2
    ;;
esac
