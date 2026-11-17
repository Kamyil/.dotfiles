#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/update-codex-overlay.sh <version|latest>

Examples:
  scripts/update-codex-overlay.sh 0.164.0
  scripts/update-codex-overlay.sh latest

The script:
  1) Resolves the version (or the latest GitHub release tag)
  2) Prefetches CLI and code-mode host hashes for every supported platform
  3) Updates nix/overlays/codex.nix version + all four hashes

Requires curl, nix, and python3. No system rebuild is performed.
EOF
}

if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

input_version="$1"
if [[ "$input_version" == 'latest' ]]; then
  input_version="$(curl -fsSL 'https://api.github.com/repos/openai/codex/releases/latest' | python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])')"
  printf 'Resolved latest release: %s\n' "$input_version"
fi

version="${input_version#rust-v}"
version="${version#v}"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Invalid version: %s\n' "$version" >&2
  exit 1
fi

prefetch_hash() {
  local asset="$1"
  local url="https://github.com/openai/codex/releases/download/rust-v${version}/${asset}.tar.gz"
  printf 'Prefetching %s\n' "$url" >&2
  nix store prefetch-file --json "$url" | python3 -c 'import json, sys; print(json.load(sys.stdin)["hash"])'
}

# Indexed arrays also work with the Bash 3.2 shipped on macOS.
hashes=()
for binary in codex codex-code-mode-host; do
  for platform in aarch64-apple-darwin x86_64-unknown-linux-musl; do
    hashes+=("$(prefetch_hash "${binary}-${platform}")")
  done
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
overlay_path="${repo_root}/nix/overlays/codex.nix"

python3 - "$overlay_path" "$version" "${hashes[@]}" <<'PY'
import base64
import pathlib
import re
import sys

overlay_path = pathlib.Path(sys.argv[1])
version = sys.argv[2]
hash_values = sys.argv[3:]
platforms = ['aarch64-apple-darwin', 'x86_64-unknown-linux-musl']

for value in hash_values:
    if not value.startswith('sha256-'):
        raise SystemExit(f'Invalid SHA-256 hash: {value}')
    try:
        digest = base64.b64decode(value[7:], validate=True)
    except ValueError:
        raise SystemExit(f'Invalid SHA-256 hash: {value}')
    if len(digest) != 32:
        raise SystemExit(f'Invalid SHA-256 hash: {value}')

text = overlay_path.read_text()
text, count = re.subn(r'version = "[^"]+";', f'version = "{version}";', text)
if count != 1:
    raise SystemExit('Expected exactly one version in overlay file.')

for index, block in enumerate(['hashes', 'hostHashes']):
    pattern = rf'(\b{block}\s*=\s*\{{)(.*?)(\}};)'

    def update_block(match):
        body = match[2]
        for offset, platform in enumerate(platforms):
            value = hash_values[index * len(platforms) + offset]
            body, count = re.subn(
                rf'(\b{re.escape(platform)}\s*=\s*)"[^"]+";',
                lambda m: f'{m[1]}"{value}";',
                body,
            )
            if count != 1:
                raise SystemExit(f'Expected exactly one {platform} hash in {block}.')
        return match[1] + body + match[3]

    text, count = re.subn(pattern, update_block, text, flags=re.DOTALL)
    if count != 1:
        raise SystemExit(f'Expected exactly one {block} block in overlay file.')

# Write only after every download and replacement has succeeded.
overlay_path.write_text(text)
print(f'Updated {overlay_path}')
print(f'  version: {version}')
for index, binary in enumerate(['codex', 'codex-code-mode-host']):
    for offset, platform in enumerate(platforms):
        print(f'  {binary} {platform}: {hash_values[index * len(platforms) + offset]}')
PY
