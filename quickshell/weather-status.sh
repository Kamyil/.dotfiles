#!/usr/bin/env bash
set -euo pipefail

command -v curl >/dev/null 2>&1 || { echo 'error\tcurl is unavailable'; exit 1; }
command -v jq >/dev/null 2>&1 || { echo 'error\tjq is unavailable'; exit 1; }

location_file="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/weather-location"
locations="${WEATHER_LOCATION:-}"
if [[ -z "$locations" && -r "$location_file" ]]; then
  locations=$(<"$location_file")
fi

fetch_weather() {
  local location="$1"
  local include_forecast="$2"
  local weather_url='https://wttr.in/?format=j1'

  if [[ -n "$location" ]]; then
    local encoded_location
    encoded_location=$(printf '%s' "$location" | jq -sRr @uri)
    weather_url="https://wttr.in/${encoded_location}?format=j1"
  fi

  curl -fsS --max-time 8 "$weather_url" | jq -r --argjson include_forecast "$include_forecast" '
    .nearest_area[0] as $a |
    .current_condition[0] as $c |
    (["current", ($a.areaName[0].value // "Current location"), $c.temp_C, $c.FeelsLikeC, $c.weatherDesc[0].value, $c.humidity, $c.windspeedKmph, $c.winddir16Point] | @tsv),
    (if $include_forecast then
      (.weather[0:4][] | ["day", .date, .mintempC, .maxtempC, (.hourly[4].weatherDesc[0].value // .hourly[0].weatherDesc[0].value), (.hourly[4].chanceofrain // "0")] | @tsv)
    else empty end)
  '
}

if [[ -z "$locations" ]]; then
  fetch_weather "" true
else
  first=true
  while IFS= read -r location; do
    [[ -z "$location" ]] && continue
    fetch_weather "$location" "$first"
    first=false
  done <<< "$locations"
fi
