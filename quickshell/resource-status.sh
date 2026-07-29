#!/usr/bin/env bash
set -euo pipefail

interval="${2:-4}"
watch=false
if [[ ${1:-} == watch ]]; then
  watch=true
fi

read_cpu() {
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  cpu_idle=$((idle + iowait))
  cpu_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
}

format_gib() {
  local tenths=$(( $1 * 10 / 1048576 ))
  printf '%d.%d' "$((tenths / 10))" "$((tenths % 10))"
}

sample() {
  local previous_idle="$cpu_idle"
  local previous_total="$cpu_total"
  read_cpu

  local total_delta=$((cpu_total - previous_total))
  local idle_delta=$((cpu_idle - previous_idle))
  local cpu=0
  if (( total_delta > 0 )); then
    cpu=$((100 * (total_delta - idle_delta) / total_delta))
  fi

  local memory_total_kib=0
  local memory_available_kib=0
  local key value
  while read -r key value _; do
    case "$key" in
      MemTotal:) memory_total_kib=$value ;;
      MemAvailable:) memory_available_kib=$value ;;
    esac
  done < /proc/meminfo

  local memory_used_kib=$((memory_total_kib - memory_available_kib))
  local memory=0
  if (( memory_total_kib > 0 )); then
    memory=$((100 * memory_used_kib / memory_total_kib))
  fi

  local -a disk_lines
  mapfile -t disk_lines < <(df -Pk /)
  local ssd_total_kib ssd_used_kib
  read -r _ ssd_total_kib ssd_used_kib _ _ <<< "${disk_lines[-1]}"
  local ssd=0
  if (( ssd_total_kib > 0 )); then
    ssd=$((100 * ssd_used_kib / ssd_total_kib))
  fi

  printf '{"cpu":%d,"memory":%d,"memoryUsedGiB":"%s","memoryTotalGiB":"%s","ssd":%d,"ssdUsedGiB":"%s","ssdTotalGiB":"%s","gpu":-1}\n' \
    "$cpu" "$memory" "$(format_gib "$memory_used_kib")" "$(format_gib "$memory_total_kib")" \
    "$ssd" "$(format_gib "$ssd_used_kib")" "$(format_gib "$ssd_total_kib")"
}

read_cpu
sleep 0.25
while true; do
  sample
  $watch || break
  sleep "$interval"
done
