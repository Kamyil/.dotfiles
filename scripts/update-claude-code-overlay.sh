#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/update-claude-code-overlay.sh <version|latest|stable>

Examples:
  scripts/update-claude-code-overlay.sh 2.1.283
  scripts/update-claude-code-overlay.sh latest
  scripts/update-claude-code-overlay.sh stable

The script:
  1) Resolves the version (or the latest/stable release channel)
  2) Reads all four platform SHA-256 checksums from the release manifest
  3) Updates nix/overlays/claude-code.nix version + every platform hash
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

base_url='https://downloads.claude.ai/claude-code-releases'
input_version="$1"

case "$input_version" in
  latest | stable)
    version="$(curl -fsSL "${base_url}/${input_version}")"
    printf 'Resolved %s version: %s\n' "$input_version" "$version"
    ;;
  *)
    version="${input_version#v}"
    ;;
esac

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Invalid version: %s\n' "$version" >&2
  exit 1
fi

manifest_url="${base_url}/${version}/manifest.json"
printf 'Fetching %s\n' "$manifest_url"
manifest="$(curl -fsSL "$manifest_url")"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
overlay_path="${repo_root}/nix/overlays/claude-code.nix"

python3 - "$overlay_path" "$version" "$manifest" <<'PY'
import json
import pathlib
import re
import sys

overlay_path = pathlib.Path(sys.argv[1])
version = sys.argv[2]
manifest = json.loads(sys.argv[3])

if manifest.get('version') != version:
    raise SystemExit(f'Manifest version mismatch: {manifest.get("version")} != {version}')

# All platforms, keyed exactly as in nix/overlays/claude-code.nix
platforms = ['darwin-arm64', 'darwin-x64', 'linux-arm64', 'linux-x64']
hash_values = {}
for platform in platforms:
    checksum = manifest['platforms'].get(platform, {}).get('checksum', '')
    if not re.fullmatch(r'[0-9a-f]{64}', checksum):
        raise SystemExit(f'Missing or invalid checksum for platform: {platform}')
    hash_values[platform] = checksum

text = overlay_path.read_text()

new_text, version_count = re.subn(
    r'version = "[^"]+";',
    f'version = "{version}";',
    text,
    count=1,
)
if version_count != 1:
    raise SystemExit('Could not update version in overlay file.')

for platform, hash_value in hash_values.items():
    pattern = rf'("{re.escape(platform)}"\s*=\s*)"[^"]+";'
    new_text, count = re.subn(
        pattern,
        rf'\1"{hash_value}";',
        new_text,
        count=1,
    )
    if count != 1:
        raise SystemExit(f'Could not update hash for platform: {platform}')

overlay_path.write_text(new_text)

print(f'Updated {overlay_path}')
print(f'  version: {version}')
for platform, hash_value in hash_values.items():
    print(f'  {platform}: {hash_value}')
PY
