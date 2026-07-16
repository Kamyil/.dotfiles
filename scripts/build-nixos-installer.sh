#!/usr/bin/env bash

set -euo pipefail

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: build-nixos-installer.sh --vault FILE [--out-link PATH]

Builds the x86_64 NixOS installer ISO with the encrypted vault and committed
repository HEAD embedded in it. The vault remains encrypted in the Nix store
and ISO. Uncommitted repository changes are intentionally excluded.
EOF
}

vault=
out_link=result
while (( $# > 0 )); do
  case "$1" in
    --vault)
      (( $# >= 2 )) || fail "--vault requires a value"
      vault=$2
      shift 2
      ;;
    --out-link)
      (( $# >= 2 )) || fail "--out-link requires a value"
      out_link=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n $vault ]] || fail "--vault is required"
[[ -f $vault ]] || fail "vault does not exist: $vault"
command -v git >/dev/null 2>&1 || fail "git is required"
command -v nix >/dev/null 2>&1 || fail "Nix is required"

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH='' cd -- "$script_dir/.." && pwd)
git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || fail "$repo_root is not a Git checkout"
branch=$(git -C "$repo_root" branch --show-current)
[[ -n $branch ]] || fail "check out a branch before building the installer"

if ! git -C "$repo_root" diff --quiet || ! git -C "$repo_root" diff --cached --quiet; then
  fail "commit installer changes before building; the ISO embeds committed HEAD"
fi

build_dir=$(mktemp -d "${TMPDIR:-/tmp}/nixos-installer-build.XXXXXX")
cleanup() {
  rm -rf "$build_dir"
}
trap cleanup EXIT INT TERM

git -C "$repo_root" bundle create "$build_dir/dotfiles.bundle" "$branch"
origin_url=$(git -C "$repo_root" remote get-url origin 2>/dev/null || true)
printf '%s\n' "$origin_url" >"$build_dir/origin-url"
printf '%s\n' "$branch" >"$build_dir/branch"

export NIXOS_INSTALLER_BUNDLE="$build_dir/dotfiles.bundle"
export NIXOS_INSTALLER_ORIGIN="$build_dir/origin-url"
export NIXOS_INSTALLER_BRANCH="$build_dir/branch"
vault_dir=$(CDPATH='' cd -- "$(dirname -- "$vault")" && pwd)
NIXOS_INSTALLER_VAULT=$vault_dir/$(basename -- "$vault")
export NIXOS_INSTALLER_VAULT

nix build --impure \
  --out-link "$out_link" \
  "$repo_root/nix#nixosConfigurations.usb-installer.config.system.build.isoImage"

printf 'Installer ISO: %s/iso/\n' "$out_link"
