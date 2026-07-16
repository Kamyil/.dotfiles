#!/usr/bin/env bash

set -euo pipefail

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: create-installer-vault.sh --source DIR --output FILE

Encrypts the contents of DIR as a passphrase-protected installer vault. DIR is
the future /home/kamil, so typical entries are .ssh/ and .local/share/fonts/.
Only regular files and directories are accepted; symlinks and special files are
rejected. The output is written atomically with mode 0600.
EOF
}

original_args=("$@")
source_dir=
output=
while (( $# > 0 )); do
  case "$1" in
    --source)
      (( $# >= 2 )) || fail "--source requires a value"
      source_dir=$2
      shift 2
      ;;
    --output)
      (( $# >= 2 )) || fail "--output requires a value"
      output=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n $source_dir ]] || fail "--source is required"
[[ -d $source_dir ]] || fail "source directory does not exist: $source_dir"
[[ -n $output ]] || fail "--output is required"

if ! command -v age >/dev/null 2>&1 \
  || ! command -v tar >/dev/null 2>&1 \
  || ! tar --version 2>/dev/null | grep -q 'GNU tar'; then
  command -v nix >/dev/null 2>&1 \
    || fail "age and GNU tar are required; install them or make Nix available"
  exec nix shell nixpkgs#age nixpkgs#gnutar --command "$0" "${original_args[@]}"
fi
command -v find >/dev/null 2>&1 || fail "find is required"

source_dir=$(CDPATH='' cd -- "$source_dir" && pwd)
output_dir=$(dirname -- "$output")
mkdir -p "$output_dir"
output_dir=$(CDPATH='' cd -- "$output_dir" && pwd)
output=$output_dir/$(basename -- "$output")
case "$output" in
  "$source_dir"/*) fail "--output must be outside --source" ;;
esac

invalid=$(find "$source_dir" -mindepth 1 ! -type f ! -type d -print -quit)
[[ -z $invalid ]] || fail "vault source contains a symlink or special file: $invalid"

output_dir=$(dirname -- "$output")
tmp=$(mktemp "$output_dir/.installer-vault.XXXXXX")
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT INT TERM
umask 077

tar --sort=name --mtime='@0' --owner=0 --group=0 --numeric-owner \
  -C "$source_dir" -czf - . \
  | age --passphrase --output "$tmp"
chmod 600 "$tmp"
mv -f "$tmp" "$output"
trap - EXIT INT TERM
printf 'Created encrypted installer vault: %s\n' "$output"
