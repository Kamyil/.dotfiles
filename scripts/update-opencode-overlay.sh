#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/update-opencode-overlay.sh <version|latest>

Examples:
  scripts/update-opencode-overlay.sh 1.2.20
  scripts/update-opencode-overlay.sh latest

The script:
  1) Detects the current host platform
  2) Prefetches the matching opencode release asset hash
  3) Updates nix/overlays/opencode.nix version + platform hash
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
  version="$({ curl -fsSL 'https://api.github.com/repos/anomalyco/opencode/releases/latest'; } | python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"].lstrip("v"))')"
  printf 'Resolved latest version: %s\n' "$version"
else
  version="${input_version#v}"
fi

os="$(uname -s)"
arch="$(uname -m)"

case "$os/$arch" in
  Darwin/arm64)
    platform='darwin-arm64'
    ext='zip'
    ;;
  Darwin/x86_64)
    platform='darwin-x64'
    ext='zip'
    ;;
  Linux/aarch64|Linux/arm64)
    platform='linux-arm64'
    ext='tar.gz'
    ;;
  Linux/x86_64)
    platform='linux-x64'
    ext='tar.gz'
    ;;
  *)
    printf 'Unsupported platform: %s/%s\n' "$os" "$arch" >&2
    exit 1
    ;;
esac

url="https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${platform}.${ext}"

printf 'Prefetching %s\n' "$url"

hash="$({ nix store prefetch-file --json "$url"; } | python3 -c 'import json, sys; print(json.load(sys.stdin)["hash"])')"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
overlay_path="${repo_root}/nix/overlays/opencode.nix"

python3 - "$overlay_path" "$version" "$platform" "$hash" <<'PY'
import pathlib
import re
import sys

overlay_path = pathlib.Path(sys.argv[1])
version = sys.argv[2]
platform = sys.argv[3]
hash_value = sys.argv[4]

text = overlay_path.read_text()

new_text, version_count = re.subn(
    r'version = "[^"]+";',
    f'version = "{version}";',
    text,
    count=1,
)
if version_count != 1:
    raise SystemExit('Could not update version in overlay file.')

platform_pattern = rf'("{re.escape(platform)}"\s*=\s*)"[^"]+";'
new_text, hash_count = re.subn(
    platform_pattern,
    rf'\1"{hash_value}";',
    new_text,
    count=1,
)
if hash_count != 1:
    raise SystemExit(f'Could not update hash for platform: {platform}')

overlay_path.write_text(new_text)
PY

printf 'Updated %s\n' "$overlay_path"
printf '  version: %s\n' "$version"
printf '  platform: %s\n' "$platform"
printf '  hash: %s\n' "$hash"
