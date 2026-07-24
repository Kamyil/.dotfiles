#!/usr/bin/env bash
set -euo pipefail

repo=${DOTFILES_DIR:-"$HOME/.dotfiles"}
flake="$repo/nix"
current="$flake/flake.lock"
[[ -f $current ]] || { printf 'error\tMissing flake.lock\n'; exit 1; }

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
if ! nix flake update --flake "$flake" --output-lock-file "$tmp" --refresh >/dev/null 2>&1; then
  printf 'error\tUpdate check failed\n'
  exit 1
fi

changed=$(jq -n --slurpfile old "$current" --slurpfile new "$tmp" '
  [$new[0].nodes | to_entries[] |
    select((.value.locked.rev // .value.locked.narHash // "") !=
           ($old[0].nodes[.key].locked.rev // $old[0].nodes[.key].locked.narHash // ""))] |
  length
')
printf 'updates\t%s\n' "$changed"
