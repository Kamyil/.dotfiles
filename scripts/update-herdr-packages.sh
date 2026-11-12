#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/update-herdr-packages.sh <app|core> <version|latest>
       scripts/update-herdr-packages.sh all

Examples:
  scripts/update-herdr-packages.sh app 0.1.15
  scripts/update-herdr-packages.sh core latest
  scripts/update-herdr-packages.sh all            # app and core at latest

The script:
  1) Resolves the version (or the latest release from latest.json)
  2) Reads every platform SHA-256 checksum from the release manifest
  3) Updates nix/packages/herdr-<app|core>.nix version + every platform hash
  4) Warns when the app needs a newer core than the one pinned
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

base_url='https://releases.herdr.dev'
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

update_package() {
  local package="$1"
  local input_version="$2"
  local manifest_url version manifest

  if [[ "$input_version" == 'latest' ]]; then
    manifest_url="${base_url}/${package}/latest.json"
  else
    version="${input_version#v}"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      printf 'Invalid version: %s\n' "$version" >&2
      exit 1
    fi
    manifest_url="${base_url}/${package}/${version}/manifest.json"
  fi

  printf 'Fetching %s\n' "$manifest_url"
  manifest="$(curl -fsSL "$manifest_url")"

  python3 - "${repo_root}/nix/packages/herdr-${package}.nix" "$input_version" "$manifest" <<'PY'
import base64
import json
import pathlib
import re
import sys

package_path = pathlib.Path(sys.argv[1])
requested = sys.argv[2].removeprefix('v')
manifest = json.loads(sys.argv[3])

version = manifest.get('version', '')
if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+', version):
    raise SystemExit(f'Invalid version in manifest: {version!r}')
if requested != 'latest' and version != requested:
    raise SystemExit(f'Manifest version mismatch: {version} != {requested}')

text = package_path.read_text()

new_text, version_count = re.subn(
    r'version = "[^"]+";',
    f'version = "{version}";',
    text,
    count=1,
)
if version_count != 1:
    raise SystemExit(f'Could not update version in {package_path}.')

# Every release target pinned in the package file (macos-aarch64, linux-*).
targets = re.findall(r'target = "([^"]+)";', new_text)
if not targets:
    raise SystemExit(f'No targets found in {package_path}.')

hash_values = {}
for target in targets:
    checksum = manifest.get('targets', {}).get(target, {}).get('sha256', '')
    if not re.fullmatch(r'[0-9a-f]{64}', checksum):
        raise SystemExit(f'Missing or invalid checksum for target: {target}')
    sri = 'sha256-' + base64.b64encode(bytes.fromhex(checksum)).decode()
    pattern = rf'(target = "{re.escape(target)}";\s*hash = )"[^"]+";'
    new_text, count = re.subn(pattern, rf'\1"{sri}";', new_text, count=1)
    if count != 1:
        raise SystemExit(f'Could not update hash for target: {target}')
    hash_values[target] = sri

package_path.write_text(new_text)

print(f'Updated {package_path}')
print(f'  version: {version}')
for target, hash_value in hash_values.items():
    print(f'  {target}: {hash_value}')

core_min = manifest.get('core_min')
if core_min:
    print(f'  core_min: {core_min}')
PY
}

check_core_min() {
  local app_file="${repo_root}/nix/packages/herdr-app.nix"
  local core_file="${repo_root}/nix/packages/herdr-core.nix"
  local app_version core_version core_min

  app_version="$(sed -n 's/^  version = "\([^"]*\)";/\1/p' "$app_file")"
  core_version="$(sed -n 's/^  version = "\([^"]*\)";/\1/p' "$core_file")"
  core_min="$(curl -fsSL "${base_url}/app/${app_version}/manifest.json" |
    python3 -c 'import json, sys; print(json.load(sys.stdin).get("core_min", ""))')"

  if [[ -n "$core_min" && "$(printf '%s\n%s\n' "$core_min" "$core_version" | sort -V | head -n 1)" != "$core_min" ]]; then
    printf 'Warning: herdr-app %s needs herdr-core >= %s, but %s is pinned.\n' \
      "$app_version" "$core_min" "$core_version" >&2
  fi
}

case "${1:-}" in
  app | core)
    if [[ $# -ne 2 ]]; then
      usage
      exit 1
    fi
    update_package "$1" "$2"
    ;;
  all)
    if [[ $# -ne 1 ]]; then
      usage
      exit 1
    fi
    update_package core latest
    update_package app latest
    ;;
  *)
    usage
    exit 1
    ;;
esac

check_core_min
