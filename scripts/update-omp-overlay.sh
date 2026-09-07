#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/update-omp-overlay.sh <version|latest>

Examples:
  scripts/update-omp-overlay.sh 18.1.10
  scripts/update-omp-overlay.sh latest

The script:
  1) Resolves the version (or the latest GitHub release tag)
  2) Prefetches all four release binary hashes (darwin/linux x arm64/x64)
  3) Updates nix/overlays/omp.nix version + every platform hash
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

input_version="$1"

if [[ "$input_version" == 'latest' ]]; then
  version="$({ curl -fsSL 'https://api.github.com/repos/can1357/oh-my-pi/releases/latest'; } | python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"].lstrip("v"))')"
  printf 'Resolved latest version: %s\n' "$version"
else
  version="${input_version#v}"
fi

plat_hash() {
  local platform="$1"
  local url="https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-${platform}"
  printf 'Prefetching %s\n' "$url" >&2
  nix store prefetch-file --json "$url" | python3 -c 'import json, sys; print(json.load(sys.stdin)["hash"])'
}

# All platforms, keyed exactly as in nix/overlays/omp.nix
declare -A hashes
for platform in darwin-arm64 darwin-x64 linux-arm64 linux-x64; do
  hashes["$platform"]="$(plat_hash "$platform")"
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
overlay_path="${repo_root}/nix/overlays/omp.nix"

python3 - "$overlay_path" "$version" "${hashes[darwin-arm64]}" "${hashes[darwin-x64]}" "${hashes[linux-arm64]}" "${hashes[linux-x64]}" <<'PY'
import pathlib
import re
import sys

overlay_path = pathlib.Path(sys.argv[1])
version = sys.argv[2]
hash_values = {
    'darwin-arm64': sys.argv[3],
    'darwin-x64': sys.argv[4],
    'linux-arm64': sys.argv[5],
    'linux-x64': sys.argv[6],
}

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
PY

printf 'Updated %s\n' "$overlay_path"
printf '  version: %s\n' "$version"
for platform in darwin-arm64 darwin-x64 linux-arm64 linux-x64; do
  printf '  %s: %s\n' "$platform" "${hashes[$platform]}"
done
