#!/usr/bin/env bash
# Regenerates the hud mod's chiptune sounds (square waves, a short fade each)
# with FFmpeg: bash herdr-app/mods/hud/sounds/make.sh
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"

# tone <hz> <seconds>: one square-wave note as an aevalsrc expression part.
notes() {
  local expr="" start=0 hz len
  while (($#)); do
    hz=$1 len=$2
    shift 2
    expr+="+between(t,${start},${start}+${len})*0.18*sgn(sin(2*PI*${hz}*t))*(1-(t-${start})/${len})"
    start=$(awk "BEGIN{print ${start}+${len}}")
  done
  printf '%s|%s' "0${expr}" "${start}"
}

make() {
  local name=$1 spec
  shift
  spec=$(notes "$@")
  ffmpeg -loglevel error -y -f lavfi -i "aevalsrc='${spec%|*}':s=44100:d=${spec#*|}" -ac 1 -b:a 64k "${name}.mp3"
}

make play 523 0.07 784 0.12
make stop 784 0.07 392 0.14
make levelup 523 0.09 659 0.09 784 0.09 1047 0.3
make rest 392 0.18 330 0.18 262 0.36
