# Set up a new NixOS laptop

## Before starting

You need:

- another macOS or Linux machine with Nix installed;
- this repository cloned on that machine;
- a USB drive flashed with the [NixOS graphical ISO](https://nixos.org/download/);
- a backup of anything on the new laptop—the selected disk will be erased.

Commit the configuration you want to install:

```sh
cd ~/.dotfiles
git status --short
git add -A
git diff --cached
git commit -m "prepare NixOS laptop setup"
git push
```

Ensure the controller has an SSH public key:

```sh
test -f ~/.ssh/id_ed25519.pub || ssh-keygen -t ed25519
```

## 1. Boot the NixOS installer

1. Boot the new laptop from the USB drive in UEFI mode.
2. Disable Secure Boot; this configuration does not enable it.
3. Open a terminal.

## 2. Connect the laptop to the network

For Wi-Fi:

```sh
nmtui
```

Verify connectivity:

```sh
ping -c 3 nixos.org
```

## 3. Enable installer SSH access

On the new laptop:

```sh
sudo passwd nixos
sudo systemctl start sshd
ip -brief address
```

Record its LAN address, for example `192.168.1.50`.

## 4. Identify the internal disk

On the new laptop:

```sh
lsblk -o NAME,SIZE,MODEL,TYPE,TRAN
ls -l /dev/disk/by-id/
```

Choose the stable path for the **whole internal disk**, for example:

```text
/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_SERIAL
```

Do not select `/dev/nvme0n1p1`, `/dev/sda1`, or a path ending in `-part1`.

## 5. Preview the installation

On the controller:

```sh
cd ~/.dotfiles

./scripts/install-nixos-anywhere.sh \
  --target nixos@192.168.1.50 \
  --disk /dev/disk/by-id/nvme-YOUR_DISK \
  --dry-run
```

Replace the IP address and disk path with the values from the new laptop.

## 6. Install NixOS

Run the same command without `--dry-run`:

```sh
./scripts/install-nixos-anywhere.sh \
  --target nixos@192.168.1.50 \
  --disk /dev/disk/by-id/nvme-YOUR_DISK
```

Follow the prompts:

1. type the exact disk path to confirm erasure;
2. enter and repeat the LUKS boot passphrase;
3. enter and repeat the `kamil` login password;
4. enter the temporary `nixos` SSH password when SSH requests it.

The script partitions the disk, installs NixOS, copies the repository to
`/home/kamil/.dotfiles`, and reboots the laptop.

## 7. Boot the installed system

1. Remove the USB drive when the laptop reboots.
2. Enter the LUKS passphrase.
3. Log in as `kamil` with the login password.

## 8. Verify reproducibility

On the new laptop:

```sh
cd ~/.dotfiles
readlink ~/.config/nvim
sudo nixos-rebuild switch --flake ./nix#nixos
git status --short
```

The Neovim link should point into `/home/kamil/.dotfiles/nvim`, and the rebuild
should succeed.

Inspect the generated machine-specific changes:

```sh
git diff -- nixos/
```

If this laptop is the canonical NixOS host, commit them:

```sh
git add nixos/hardware-configuration.nix nixos/install-disk nixos/bootstrap.nix
git commit -m "record new NixOS laptop"
git push
```
