#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  install-nixos-anywhere.sh --target USER@HOST --disk /dev/DEVICE [options]

Required:
  --target USER@HOST       NixOS installer reachable over SSH, usually nixos@IP
  --disk /dev/DEVICE       Entire target disk; prefer a /dev/disk/by-id path

Options:
  --identity PATH          SSH private key used to reach the installer
  --public-key PATH        Public key installed for kamil (default: id_ed25519.pub)
  --yes                    Skip the destructive disk-name confirmation
  --dry-run                Stage the committed checkout and print the command only
  -h, --help               Show this help

The target disk is erased. The script intentionally still prompts for the LUKS
and login passwords; neither plaintext password is stored in the repository.
EOF
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

prompt_secret_twice() {
  local label=$1
  local first second

  while true; do
    printf '%s: ' "$label" >&2
    IFS= read -r -s first
    printf '\nRepeat %s: ' "$label" >&2
    IFS= read -r -s second
    printf '\n' >&2

    if [[ -z $first ]]; then
      printf 'The value must not be empty.\n' >&2
    elif [[ $first != "$second" ]]; then
      printf 'Values did not match; try again.\n' >&2
    else
      printf '%s' "$first"
      return
    fi
  done
}

target=
disk=
identity=
public_key=
yes=false
dry_run=false

while (( $# > 0 )); do
  case "$1" in
    --target)
      (( $# >= 2 )) || fail "--target requires a value"
      target=$2
      shift 2
      ;;
    --disk)
      (( $# >= 2 )) || fail "--disk requires a value"
      disk=$2
      shift 2
      ;;
    --identity)
      (( $# >= 2 )) || fail "--identity requires a value"
      identity=$2
      shift 2
      ;;
    --public-key)
      (( $# >= 2 )) || fail "--public-key requires a value"
      public_key=$2
      shift 2
      ;;
    --yes)
      yes=true
      shift
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown argument: $1"
      ;;
  esac
done

[[ -n $target ]] || fail "--target is required"
[[ $target != *[[:space:]]* ]] || fail "--target must not contain whitespace"
[[ $target == *@* ]] || fail "--target must include the SSH user, for example nixos@192.168.1.50"
[[ -n $disk ]] || fail "--disk is required"
[[ $disk == /dev/* ]] || fail "--disk must be an absolute /dev path"
[[ $disk != *[[:space:]]* ]] || fail "--disk must not contain whitespace"
case "$disk" in
  /dev/disk/by-id/*-part[0-9]* | \
    /dev/nvme[0-9]*n[0-9]*p[0-9]* | \
    /dev/mmcblk[0-9]*p[0-9]* | \
    /dev/sd[a-z][0-9]* | \
    /dev/vd[a-z][0-9]* | \
    /dev/xvd[a-z][0-9]*)
    fail "--disk points to a partition; pass the parent whole-disk device"
    ;;
esac

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH='' cd -- "$script_dir/.." && pwd)
command -v git >/dev/null 2>&1 || fail "git is required"
command -v nix >/dev/null 2>&1 || fail "Nix with flakes enabled is required"
git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || fail "$repo_root is not a Git checkout"

branch=$(git -C "$repo_root" branch --show-current)
[[ -n $branch ]] || fail "check out a branch before installing; detached HEAD is unsupported"
source_head=$(git -C "$repo_root" rev-parse HEAD)
origin_url=$(git -C "$repo_root" remote get-url origin 2>/dev/null || true)

if ! git -C "$repo_root" diff --quiet || ! git -C "$repo_root" diff --cached --quiet; then
  printf 'note: the installer uses committed HEAD %s; uncommitted tracked changes are omitted.\n' "$source_head" >&2
fi

if [[ -z $public_key ]]; then
  for candidate in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_ecdsa.pub" "$HOME/.ssh/id_rsa.pub"; do
    if [[ -f $candidate ]]; then
      public_key=$candidate
      break
    fi
  done
fi

if [[ $dry_run == false ]]; then
  [[ -n $public_key ]] || fail "no SSH public key found; pass --public-key PATH"
  [[ -f $public_key ]] || fail "public key does not exist: $public_key"
  if [[ -n $identity ]]; then
    [[ -f $identity ]] || fail "SSH identity does not exist: $identity"
  fi
fi

if [[ $yes == false && $dry_run == false ]]; then
  printf '\nTARGET: %s\nDISK:   %s\n\n' "$target" "$disk" >&2
  printf 'This permanently erases %s. Type the exact disk path to continue: ' "$disk" >&2
  IFS= read -r confirmation
  [[ $confirmation == "$disk" ]] || fail "confirmation did not match; nothing was changed"
fi

staging_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install.XXXXXX")
luks_key=$(mktemp "${TMPDIR:-/tmp}/dotfiles-luks.XXXXXX")
cleanup() {
  rm -rf "$staging_root"
  rm -f "$luks_key"
}
trap cleanup EXIT INT TERM
chmod 600 "$luks_key"

checkout="$staging_root/home/kamil/.dotfiles"
mkdir -p "$(dirname "$checkout")" "$staging_root/etc/nixos"
git clone --quiet --no-local --branch "$branch" "$repo_root" "$checkout"
[[ $(git -C "$checkout" rev-parse HEAD) == "$source_head" ]] \
  || fail "source branch changed while staging; rerun the installer"
if [[ -n $origin_url ]]; then
  git -C "$checkout" remote set-url origin "$origin_url"
fi
printf '%s\n' "$disk" >"$checkout/nixos/install-disk"

if [[ $dry_run == true ]]; then
  key_type=ssh-ed25519
  key_data=DRY_RUN_PUBLIC_KEY
  user_hash='!'
  printf 'dry-run' >"$luks_key"
else
  read -r key_type key_data _ <"$public_key"
  [[ $key_type == ssh-* || $key_type == ecdsa-* || $key_type == sk-* ]] \
    || fail "unsupported SSH public key type: $key_type"
  [[ -n $key_data ]] || fail "invalid SSH public key: $public_key"

  luks_password=$(prompt_secret_twice "LUKS passphrase")
  printf '%s' "$luks_password" >"$luks_key"
  unset luks_password

  login_password=$(prompt_secret_twice "kamil login password")
  user_hash=$(printf '%s\n' "$login_password" \
    | nix shell nixpkgs#mkpasswd --command mkpasswd --method=yescrypt --stdin)
  unset login_password
fi

cat >"$checkout/nixos/bootstrap.nix" <<EOF
# Generated locally by scripts/install-nixos-anywhere.sh.
# The password hash lives outside the Nix store in /etc/nixos.
{
  users.users.kamil = {
    hashedPasswordFile = "/etc/nixos/kamil-password-hash";
    openssh.authorizedKeys.keys = [ "$key_type $key_data" ];
  };
}
EOF
printf '%s\n' "$user_hash" >"$staging_root/etc/nixos/kamil-password-hash"
chmod 600 "$staging_root/etc/nixos/kamil-password-hash"

anywhere_args=(
  --flake "$checkout/nix#nixos"
  --generate-hardware-config nixos-generate-config "$checkout/nixos/hardware-configuration.nix"
  --extra-files "$staging_root"
  --chown /home/kamil 1000:1000
  --disk-encryption-keys /tmp/disko-password "$luks_key"
  --build-on auto
)
if [[ -n $identity ]]; then
  anywhere_args+=(-i "$identity")
fi
anywhere_args+=(--target-host "$target")

if [[ $dry_run == true ]]; then
  printf 'Staged committed checkout: %s\n' "$source_head"
  printf 'Command:'
  printf ' %q' nix run "$repo_root/nix#nixos-anywhere" -- "${anywhere_args[@]}"
  printf '\n'
  exit 0
fi

nix run "$repo_root/nix#nixos-anywhere" -- "${anywhere_args[@]}"

printf '\nInstallation finished. The target checkout is /home/kamil/.dotfiles.\n'
printf 'Generated machine files are intentionally left modified there; inspect and commit them after first login.\n'
