#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == worker ]]; then
  direction=${2:?}
  shift 2
  urls=("$@")
  index=$RANDOM
  deadline=$((SECONDS + 5))
  while (( SECONDS < deadline )); do
    url=${urls[$((index % ${#urls[@]}))]}
    if [[ $direction == down ]]; then
      curl --max-time 2 -fs -o /dev/null "$url" || true
    else
      dd if=/dev/zero bs=1M count=64 2>/dev/null | curl --max-time 2 -fs -o /dev/null -X POST --data-binary @- "$url" || true
    fi
    ((index += 1))
  done
  exit 0
fi

direction=${1:-}
[[ $direction == down || $direction == up ]] || { echo 'Usage: network-speedtest.sh down|up' >&2; exit 2; }
command -v curl >/dev/null || { echo 'curl is required' >&2; exit 1; }
command -v jq >/dev/null || { echo 'jq is required' >&2; exit 1; }

iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }')
[[ -n $iface && -r /sys/class/net/$iface/statistics/rx_bytes && -r /sys/class/net/$iface/statistics/tx_bytes ]] || { echo 'No active network interface' >&2; exit 1; }

api='https://api.fast.com/netflix/speedtest/v2?https=true&token=YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm&urlCount=3'
mapfile -t urls < <(curl -fsS "$api" | jq -r '.targets[]?.url // empty')
(( ${#urls[@]} > 0 )) || { echo 'Failed to fetch speed test endpoints' >&2; exit 1; }

pids=()
cleanup() {
  for pid in "${pids[@]}"; do kill -TERM -- "-$pid" 2>/dev/null || true; done
  sleep 0.05
  for pid in "${pids[@]}"; do
    kill -KILL -- "-$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT
trap 'cleanup; trap - EXIT; exit 143' TERM INT

for ((i = 0; i < 8; i++)); do
  setsid "$0" worker "$direction" "${urls[@]}" &
  pids+=("$!")
done

rx_before=$(<"/sys/class/net/$iface/statistics/rx_bytes")
tx_before=$(<"/sys/class/net/$iface/statistics/tx_bytes")
while kill -0 "${pids[0]}" 2>/dev/null; do
  sleep 1
  rx_after=$(<"/sys/class/net/$iface/statistics/rx_bytes")
  tx_after=$(<"/sys/class/net/$iface/statistics/tx_bytes")
  if [[ $direction == down ]]; then before=$rx_before; after=$rx_after; else before=$tx_before; after=$tx_after; fi
  awk -v before="$before" -v after="$after" 'BEGIN { value = after < before ? 0 : (after - before) * 8 / 1000000; if (value < 10) printf "%.1f\n", value; else printf "%.0f\n", value }'
  rx_before=$rx_after
  tx_before=$tx_after
done
