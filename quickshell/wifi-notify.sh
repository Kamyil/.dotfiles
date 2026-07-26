#!/usr/bin/env bash
set -u

export LC_ALL=C

notify() {
  notify-send --app-name="Network" --icon="$1" "$2" "$3"
}

previous_wifi=""
previous_connection=""

while sleep 2; do
  wifi_radio=$(nmcli -t -f WIFI general 2>/dev/null || true)
  wifi_device=""
  connected_device=""

  while IFS=: read -r device type state; do
    [[ $type == "wifi" ]] || continue
    [[ -n $wifi_device ]] || wifi_device=$device
    if [[ $state == "connected" ]]; then
      connected_device=$device
      break
    fi
  done < <(nmcli -t -e no -f DEVICE,TYPE,STATE device status 2>/dev/null || true)

  if [[ $wifi_radio == "enabled" && -n $wifi_device ]]; then
    wifi_state="on"
  else
    wifi_state="off"
  fi

  connection=""
  if [[ -n $connected_device ]]; then
    connection=$(nmcli -g GENERAL.CONNECTION device show "$connected_device" 2>/dev/null || true)
  fi

  if [[ -n $previous_wifi && $wifi_state != "$previous_wifi" ]]; then
    if [[ $wifi_state == "on" ]]; then
      notify "network-wireless" "Wi-Fi on" "USB Wi-Fi adapter is available."
    elif [[ $wifi_radio == "disabled" ]]; then
      notify "network-wireless-offline" "Wi-Fi off" "Wi-Fi radio is disabled."
    else
      notify "network-wireless-offline" "Wi-Fi off" "USB Wi-Fi adapter is unavailable."
    fi
  fi

  if [[ -n $previous_connection && $connection != "$previous_connection" ]]; then
    notify "network-wireless-offline" "Wi-Fi disconnected" "$previous_connection"
  fi
  if [[ -n $connection && $connection != "$previous_connection" ]]; then
    notify "network-wireless" "Wi-Fi connected" "$connection"
  fi

  previous_wifi=$wifi_state
  previous_connection=$connection
done
