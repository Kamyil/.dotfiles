#!/usr/bin/env bash
set -euo pipefail

read_cpu() {
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  local idle_total=$((idle + iowait))
  local total=$((user + nice + system + idle + iowait + irq + softirq + steal))
  printf '%s %s\n' "$idle_total" "$total"
}

read_gpu_time() {
  printf '%s\n' -1
}

read -r idle_before total_before < <(read_cpu)
gpu_before=$(read_gpu_time)
start_ms=$(date +%s%3N)
sleep 0.25
end_ms=$(date +%s%3N)

read -r idle_after total_after < <(read_cpu)
total_delta=$((total_after - total_before))
idle_delta=$((idle_after - idle_before))
cpu=0
if (( total_delta > 0 )); then
  cpu=$((100 * (total_delta - idle_delta) / total_delta))
fi

memory_total_kib=0
memory_available_kib=0
while read -r key value _; do
  case "$key" in
    MemTotal:) memory_total_kib=$value ;;
    MemAvailable:) memory_available_kib=$value ;;
  esac
done < /proc/meminfo
memory_used_kib=$((memory_total_kib - memory_available_kib))
memory=0
if (( memory_total_kib > 0 )); then
  memory=$((100 * memory_used_kib / memory_total_kib))
fi

memory_used_gib=$(awk -v kib="$memory_used_kib" 'BEGIN { printf "%.1f", kib / 1048576 }')
memory_total_gib=$(awk -v kib="$memory_total_kib" 'BEGIN { printf "%.1f", kib / 1048576 }')

read -r _ ssd_total_kib ssd_used_kib _ ssd < <(df -Pk / | tail -n 1)
ssd=0
if (( ssd_total_kib > 0 )); then
  ssd=$((100 * ssd_used_kib / ssd_total_kib))
fi
ssd_used_gib=$(awk -v kib="$ssd_used_kib" 'BEGIN { printf "%.1f", kib / 1048576 }')
ssd_total_gib=$(awk -v kib="$ssd_total_kib" 'BEGIN { printf "%.1f", kib / 1048576 }')

gpu_after=$(read_gpu_time)
gpu=-1
elapsed_ms=$((end_ms - start_ms))
if (( gpu_before >= 0 && gpu_after >= gpu_before && elapsed_ms > 0 )); then
  gpu=$((100 * (gpu_after - gpu_before) / (elapsed_ms * 1000000)))
  if (( gpu > 100 )); then gpu=100; fi
fi

printf '{"cpu":%d,"memory":%d,"memoryUsedGiB":"%s","memoryTotalGiB":"%s","ssd":%d,"ssdUsedGiB":"%s","ssdTotalGiB":"%s","gpu":%d}\n' \
  "$cpu" "$memory" "$memory_used_gib" "$memory_total_gib" "$ssd" "$ssd_used_gib" "$ssd_total_gib" "$gpu"
