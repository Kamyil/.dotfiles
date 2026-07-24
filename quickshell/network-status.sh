#!/usr/bin/env bash
set -u

probe=1.1.1.1
route=$(ip route get "$probe" 2>/dev/null) || exit 0
iface=$(awk '{ for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }' <<<"$route")
gateway=$(awk '{ for (i = 1; i <= NF; i++) if ($i == "via") { print $(i + 1); exit } }' <<<"$route")
ip_address=$(awk '{ for (i = 1; i <= NF; i++) if ($i == "src") { print $(i + 1); exit } }' <<<"$route")
[[ -n $iface ]] || exit 0

printf 'iface\t%s\n' "$iface"
printf 'ip\t%s\n' "$ip_address"
printf 'gateway\t%s\n' "$gateway"
[[ -r /sys/class/net/$iface/statistics/rx_bytes ]] && printf 'rx_bytes\t%s\n' "$(<"/sys/class/net/$iface/statistics/rx_bytes")"
[[ -r /sys/class/net/$iface/statistics/tx_bytes ]] && printf 'tx_bytes\t%s\n' "$(<"/sys/class/net/$iface/statistics/tx_bytes")"

if [[ -d /sys/class/net/$iface/wireless ]]; then
  printf 'type\twifi\n'
  ssid=""
  if command -v iw >/dev/null; then
    link=$(iw dev "$iface" link 2>/dev/null)
    ssid=$(awk '/SSID:/ { sub(/.*SSID: /, ""); print; exit }' <<<"$link")
    printf 'signal_dbm\t%s\n' "$(awk '/signal:/ { print $2; exit }' <<<"$link")"
    printf 'freq\t%s\n' "$(awk '/freq:/ { print $2; exit }' <<<"$link")"
    printf 'bitrate\t%s\n' "$(awk '/tx bitrate:/ { print $3 " " $4; exit }' <<<"$link")"
  fi
  if [[ -z $ssid ]] && command -v nmcli >/dev/null; then
    ssid=$(nmcli -t -e no -f IN-USE,SSID device wifi list ifname "$iface" --rescan no 2>/dev/null |
      awk -F: '$1 == "*" { sub(/^[^:]*:/, ""); print; exit }')
  fi
  printf 'ssid\t%s\n' "$ssid"
else
  printf 'type\tethernet\n'
  [[ -r /sys/class/net/$iface/speed ]] && printf 'speed\t%s\n' "$(<"/sys/class/net/$iface/speed")"
  [[ -r /sys/class/net/$iface/duplex ]] && printf 'duplex\t%s\n' "$(<"/sys/class/net/$iface/duplex")"
fi

ping_once() {
  LC_ALL=C ping -n -c 1 -W 1 "$1" 2>/dev/null | awk -F'time[=<]' '/time[=<]/ { split($2, p, " "); print p[1]; exit }'
}

command -v ping >/dev/null || exit 0
[[ -n $gateway ]] && printf 'router_ping_ms\t%s\n' "$(ping_once "$gateway")"
printf 'internet_ping_ms\t%s\n' "$(ping_once "$probe")"
