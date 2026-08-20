#!/usr/bin/env bash
set -euo pipefail

iface="${1:-}"
if [[ -z "$iface" ]]; then
  iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }')
fi

band_from_freq() {
  local freq="$1"
  if (( freq >= 2400 && freq < 2500 )); then echo 2.4
  elif (( freq >= 4900 && freq < 5925 )); then echo 5
  elif (( freq >= 5925 && freq < 7125 )); then echo 6
  else echo ""; fi
}

current=""
if [[ -n "$iface" ]] && command -v iw >/dev/null 2>&1; then
  freq=$(iw dev "$iface" link 2>/dev/null | awk '/freq:/ { print $2; exit }')
  [[ "$freq" =~ ^[0-9]+$ ]] && current=$(band_from_freq "$freq")
fi

selected="auto"
if [[ -n "$iface" ]] && command -v nmcli >/dev/null 2>&1; then
  uuid=$(nmcli -t -g GENERAL.CONNECTION device show "$iface" 2>/dev/null || true)
  if [[ -n "$uuid" && "$uuid" != "--" ]]; then
    pinned=$(nmcli -g 802-11-wireless.band connection show "$uuid" 2>/dev/null || true)
    case "$pinned" in
      bg) selected=2.4;; a) selected=5;; ax) selected=6;; esac
  fi
fi

if [[ $# -ge 1 && "$1" == "--set" ]]; then
  target="${2:-auto}"
  [[ -n "$iface" ]] || { echo "No Wi-Fi interface" >&2; exit 1; }
  uuid=$(nmcli -t -g GENERAL.CONNECTION device show "$iface" 2>/dev/null || true)
  [[ -n "$uuid" && "$uuid" != "--" ]] || { echo "No active Wi-Fi connection" >&2; exit 1; }
  case "$target" in
    auto) nmcli connection modify "$uuid" 802-11-wireless.band "" ;;
    2.4) nmcli connection modify "$uuid" 802-11-wireless.band bg ;;
    5) nmcli connection modify "$uuid" 802-11-wireless.band a ;;
    6) nmcli connection modify "$uuid" 802-11-wireless.band ax ;;
    *) echo "Unsupported Wi-Fi band: $target" >&2; exit 2;;
  esac
  nmcli device reapply "$iface" >/dev/null 2>&1 || nmcli connection up "$uuid" >/dev/null
  exit 0
fi

available=""
if [[ -n "$iface" ]] && command -v nmcli >/dev/null 2>&1; then
  frequencies=$(nmcli -t -e no -f FREQ device wifi list ifname "$iface" --rescan no 2>/dev/null || true)
  has24=0; has5=0; has6=0
  while IFS= read -r freq; do
    [[ "$freq" =~ ^[0-9]+$ ]] || continue
    b=$(band_from_freq "$freq")
    case "$b" in 2.4) has24=1;; 5) has5=1;; 6) has6=1;; esac
  done <<< "$frequencies"
  (( has24 )) && available+="2.4 "
  (( has5 )) && available+="5 "
  (( has6 )) && available+="6 "
fi
[[ -n "$available" ]] || available="$current"
printf 'band\t%s\nselected\t%s\navailable\t%s\n' "$current" "$selected" "${available% }"
