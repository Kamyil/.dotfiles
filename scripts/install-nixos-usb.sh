#!/usr/bin/env bash

set -euo pipefail

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: install-nixos-usb.sh [--disk /dev/DEVICE]

Runs inside the custom installer ISO. If --disk is omitted, presents the fixed
whole-disk devices reported by lsblk. The selected disk is erased only after the
existing exact-path confirmation. The private vault is decrypted into /run.
EOF
}

disk=
while (( $# > 0 )); do
  case "$1" in
    --disk)
      (( $# >= 2 )) || fail "--disk requires a value"
      disk=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ $(id -u) -eq 0 ]] || fail "run this installer as root"
command -v lsblk >/dev/null 2>&1 || fail "lsblk is required"
command -v ssh-keygen >/dev/null 2>&1 || fail "ssh-keygen is required"

installer_root=/etc/nixos-installer
bundle=$installer_root/dotfiles.bundle
origin_file=$installer_root/origin-url
branch_file=$installer_root/branch
vault=$installer_root/private-vault.age
[[ -f $bundle ]] || fail "installer repository bundle is missing"
[[ -s $branch_file ]] || fail "installer repository branch is missing"
[[ -f $vault ]] || fail "encrypted installer vault is missing"

if [[ -z $disk ]]; then
  mapfile -t disks < <(lsblk -dnpo NAME,TYPE,RM,SIZE,MODEL \
    | awk '$2 == "disk" && $3 == "0" { $2=""; $3=""; sub(/^ +/, ""); print }')
  (( ${#disks[@]} > 0 )) || fail "no fixed whole-disk device found"

  printf '\nAvailable installation disks:\n' >&2
  for index in "${!disks[@]}"; do
    printf '  %d) %s\n' "$((index + 1))" "${disks[$index]}" >&2
  done
  printf 'Select the disk to erase [1-%d]: ' "${#disks[@]}" >&2
  IFS= read -r selection
  [[ $selection =~ ^[0-9]+$ ]] || fail "selection must be a number"
  (( selection >= 1 && selection <= ${#disks[@]} )) || fail "selection is out of range"
  disk=${disks[$((selection - 1))]%% *}
fi

work=/run/nixos-usb-installer
rm -rf "$work"
mkdir -p "$work/ssh" /root/.ssh
chmod 700 "$work/ssh" /root/.ssh
branch=$(cat "$branch_file")
git clone --quiet --branch "$branch" "$bundle" "$work/dotfiles"
[[ $(git -C "$work/dotfiles" branch --show-current) == "$branch" ]] \
  || fail "installer repository branch checkout failed"
if [[ -s $origin_file ]]; then
  origin_url=$(cat "$origin_file")
  git -C "$work/dotfiles" remote set-url origin "$origin_url"
fi

printf 'Checking network access and prefetching pinned flake inputs...\n' >&2
until nix flake metadata "$work/dotfiles/nix" >/dev/null; do
  printf '\nNetwork access is required for this installer. Open nmtui now? [Y/n]: ' >&2
  IFS= read -r configure_network
  case $configure_network in
    n|N) fail "network access is required to install the target system" ;;
    *) nmtui ;;
  esac
done

ssh-keygen -q -t ed25519 -N '' -f "$work/ssh/installer" \
  -C nixos-usb-installer
cat "$work/ssh/installer.pub" >/root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys "$work/ssh/installer"

systemctl start sshd
export NIXOS_INSTALLER_TMPDIR=/run
exec "$work/dotfiles/scripts/install-nixos-anywhere.sh" \
  --target root@127.0.0.1 \
  --identity "$work/ssh/installer" \
  --vault "$vault" \
  --disk "$disk"
