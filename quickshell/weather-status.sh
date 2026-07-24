#!/usr/bin/env bash
set -euo pipefail

command -v curl >/dev/null 2>&1 || { echo 'error\tcurl is unavailable'; exit 1; }
command -v jq >/dev/null 2>&1 || { echo 'error\tjq is unavailable'; exit 1; }

payload=$(curl -fsS --max-time 8 'https://wttr.in/?format=j1')
printf '%s' "$payload" | jq -r '
  .nearest_area[0] as $a |
  .current_condition[0] as $c |
  (["current", ($a.areaName[0].value // "Current location"), $c.temp_C, $c.FeelsLikeC, $c.weatherDesc[0].value, $c.humidity, $c.windspeedKmph, $c.winddir16Point] | @tsv),
  (.weather[0:4][] | ["day", .date, .mintempC, .maxtempC, (.hourly[4].weatherDesc[0].value // .hourly[0].weatherDesc[0].value), (.hourly[4].chanceofrain // "0")] | @tsv)
'
