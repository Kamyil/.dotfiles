# .dotfiles

A cross-platform dotfiles repository for macOS and NixOS.

Application configs live at the repository root. Nix installs packages and links those configs into `$HOME`, so most edits take effect without a rebuild.

## Desktop showcase

NixOS running Hyprland, Quickshell, Kitty, and the widgets configured here.

![NixOS desktop with a dark Japanese landscape wallpaper](assets/desktop/desktop.png)

| Fastfetch | Calendar |
| --- | --- |
| ![Fastfetch in Kitty](assets/desktop/fastfetch.png) | ![Quickshell calendar widget](assets/desktop/calendar.png) |

![NixOS desktop with the system resources widget open](assets/desktop/system-resources.png)

## Architecture

[`nix/flake.nix`](nix/flake.nix) defines both systems. Each system combines platform settings with the same Home Manager configuration.

```mermaid
flowchart TD
    F["nix/flake.nix"]
    F --> M["macOS<br/>nix/macos.nix"]
    F --> N["NixOS<br/>nix/nixos.nix"]
    N --> H["Host settings<br/>nixos/configuration.nix"]
    M --> S["Shared Home Manager<br/>nix/shared.nix"]
    N --> S
    S --> P["Packages and shell integration<br/>nix/home/"]
    S --> L["Live config links<br/>nix/symlinks.nix"]
    S --> Z["Live Zsh code<br/>zsh/"]
```

- **macOS:** nix-darwin, Homebrew, system defaults, and macOS packages.
- **NixOS:** host settings, Hyprland, Linux packages, and sops-nix.
- **Shared:** shell tools, Home Manager packages, live Zsh code under `zsh/`, and links to root-level configs.
- **Local overlays:** packages for `opencode` and `omp` in `nix/overlays/`.

## How live configuration reload works

Home Manager creates out-of-store symlinks from `$HOME` to this checkout. Applications therefore read the repository files directly.

```mermaid
flowchart LR
    R["Repository config"] -->|symlink| H["$HOME config path"]
    H --> A["Application"]
    E["Edit file"] --> R
    B["Nix rebuild"] -->|packages + links| H
```

Link definitions live in [`nix/symlinks.nix`](nix/symlinks.nix):

- `commonLinks` applies everywhere.
- `darwinLinks` contains macOS-only apps.
- `linuxLinks` contains NixOS-only apps.
- Activation adopts matching files, backs up conflicting real files under `~/.local/state/home-manager/dotfile-backups`, and refuses unrelated symlinks.

Edit a linked config directly. Rebuild only after changing packages or links.

## Repository layout

```text
.
├── nix/                 # Flake, systems, Home Manager, overlays
├── nixos/               # NixOS host settings
├── nvim/ kitty/ ...     # Application configs
├── zsh/                 # Live aliases and shell functions
├── scripts/             # Setup and workflow helpers
├── docs/                # Setup and recovery guides
└── README.md
```

Each app config is a root-level sibling rather than part of a second `config/` tree. For example, `$HOME/.config/kitty` links to `kitty/`.

## Tool and platform matrix

The package sets are intentionally split into common, macOS, and NixOS layers. “Equivalent” means the same role is covered by another program on the other platform; it does not imply identical behavior or configuration format.

### Shared on macOS and NixOS

| Role | Tool(s) | Configuration |
| --- | --- | --- |
| Shell and prompt | zsh, Starship, Atuin | [`zsh`](nix/shared.nix), [`starship/`](starship), [`atuin/`](atuin) |
| Editor and terminal workflow | Neovim, Kitty, herdr | [`nvim/`](nvim), [`kitty/`](kitty), [`herdr/`](herdr) |
| Files and text | ripgrep, fd, eza, bat, jq, yq, yazi, tree | mostly command-line defaults; [`bat/`](bat) |
| Git and review | Git, Git Extras, tig, lazygit, difftastic, hunk, lumen | [`lazygit/`](lazygit), [`hunk/`](hunk) |
| Agentic coding | oh-my-pi (`omp`) primary; OpenCode fallback | [`pi/`](pi), [`opencode/`](opencode) |
| SQL workflow | vim-dadbod, vim-dadbod-ui, vim-dadbod-completion in Neovim | [`nvim/init.lua`](nvim/init.lua) |
| Networking and transfer | curl, wget, OpenSSH, rsync, socat, WireGuard | shell configuration |
| Terminal UI and utilities | btop, htop, fastfetch, superfile, lazydocker, tldr | [`btop/`](btop), [`superfile/`](superfile) |
| Terminal/workflow CLIs | herdr, worktrunk, lazyjira | [`herdr/`](herdr), [`worktrunk/`](worktrunk) |
| Browser tooling | qutebrowser (available fallback) | Nix package; no repository-specific configuration |
| Nix package discovery | nix-index, comma | Weekly prebuilt nix-index database |

SQL work is intentionally handled inside Neovim with the Dadbod plugins. Harlequin and Rainfrog were tried and removed from the package sets.

For agentic work, **oh-my-pi (`omp`) is the primary harness** and **OpenCode is the fallback**. No other agentic harness is installed by this flake.

### macOS-specific

| Role | Tool(s) | Linux/NixOS counterpart |
| --- | --- | --- |
| System integration | nix-darwin | NixOS modules (`nix/nixos.nix`, `nixos/configuration.nix`) |
| Window manager / compositor | Aerospace | Hyprland |
| Desktop shell / status bar | SketchyBar | Quickshell |
| Terminal apps | Kitty, WezTerm, Ghostty, Alacritty | Alacritty, Kitty, WezTerm (shared where enabled) |
| Virtualization | Lima, Colima, QEMU, UTM | QEMU, Podman, Docker |
| GUI application delivery | Homebrew brews and casks | Nix packages and NixOS modules |
| macOS automation | Hammerspoon | Hyprland scripts / systemd user services |
| Audio transcription | Parakeet MLX (`transcribe <audio-file>`, TDT 0.6B v3) | NixOS uses the INT8 Parakeet v3 model through sherpa-onnx |
| Desktop applications | Chromium, Firefox, Vivaldi, Signal, Obsidian, Postman, Raycast | Chromium, Firefox, Signal, Obsidian, qutebrowser (package availability differs) |

The primary macOS browser is **Helium**, installed outside this flake. Chromium, Firefox, Vivaldi, and qutebrowser remain declaratively installed fallbacks.

macOS Homebrew is used for GUI applications and tools that are unavailable or inconvenient in the current Nix package set. The authoritative list is in [`nix/macos.nix`](nix/macos.nix).

### NixOS-specific

| Role | Tool(s) | macOS counterpart |
| --- | --- | --- |
| Desktop compositor | Hyprland | Aerospace |
| Desktop shell and launcher | Quickshell, Walker, Elephant | SketchyBar, Raycast |
| Desktop notifications | Dunst | macOS Notification Center |
| Lock screen and idle desktop | Hyprlock, Hypridle | macOS screen lock / system behavior |
| Audio and graphics | PipeWire, Pulse compatibility, EasyEffects global processing, XWayland | CoreAudio and native macOS display stack |
| Network and Bluetooth controls | Quickshell panels; impala and bluetuith as fallbacks | macOS system UI or third-party GUI tools |
| Container stack | Docker, Podman, Compose, buildx | Docker/Podman plus Colima/Lima |
| Linux development | gcc, nixd, nightly Rust, Zig, PHP, Go | clang/Xcode toolchain, rustup, same language tools |
| Screenshot and clipboard | Omasnap, Satty fallback, grim, slurp, wl-clipboard | macOS screenshot and clipboard tools |
| GUI files and media | Thunar with GVfs, Tumbler, and video thumbnails; imv for images; mpv for video/WebM (`Super+E` or `finder`) | Finder, Preview, QuickTime Player |
| Keyboard remapping | kmonad | macOS keyboard shortcuts / QMK Toolbox |
| Linux fonts/cursors | JetBrains Mono, Lexend, Capitaine cursors | Nerd fonts and macOS font management |
| Laptop firmware and power | fwupd, thermald, power-profiles-daemon | Vendor firmware tools and macOS power management |

## Installing NixOS from scratch

The NixOS host supports a mostly one-command bare-metal installation through
[Disko](https://github.com/nix-community/disko) and
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere). The only
manual choices left are the target over SSH, the disk to erase, and the two
passwords that must not be committed.

The declared layout in [`nixos/disk-config.nix`](nixos/disk-config.nix) creates:

- a 1 GiB UEFI system partition mounted at `/boot`;
- a LUKS2-encrypted partition using the remaining space;
- an ext4 root filesystem inside LUKS.

### 1. Boot the target laptop

Boot the official NixOS installer, connect it to the network, and run:

```sh
sudo passwd nixos
ip -brief address
ls -l /dev/disk/by-id/
```

The temporary `nixos` password only grants the installer SSH access. Prefer the
stable whole-disk path under `/dev/disk/by-id/`; do not select a partition path.

### 2. Run the installer from this checkout

Commit the configuration you want to install, then run from macOS or Linux:

```sh
./scripts/install-nixos-anywhere.sh \
  --target nixos@192.168.1.50 \
  --disk /dev/disk/by-id/nvme-YOUR_DRIVE
```

The script shows the exact disk and requires typing it back before anything is
destroyed. It then prompts locally for:

1. the LUKS passphrase used at boot;
2. the `kamil` login password.

Plaintext passwords are held only in temporary mode-0600 files and removed when
the command exits. The login password is stored on the target as a yescrypt
hash. The first available local public key (`id_ed25519.pub`, `id_ecdsa.pub`, or
`id_rsa.pub`) is authorized for `kamil`; override it with `--public-key PATH`.

The installation:

1. stages committed `HEAD`, excluding ignored files and untracked secrets;
2. persists that checkout as `/home/kamil/.dotfiles` with UID/GID 1000;
3. replaces [`nixos/install-disk`](nixos/install-disk) in the staged checkout;
4. generates target hardware settings with `--no-filesystems`, leaving Disko
   as the single owner of partitions and mounts;
5. partitions, formats, installs, and reboots through nixos-anywhere.

Preview argument validation and the generated command without connecting to or
changing a target:

```sh
./scripts/install-nixos-anywhere.sh \
  --target nixos@192.168.1.50 \
  --disk /dev/nvme0n1 \
  --dry-run
```

`--yes` skips only the disk-name confirmation; password prompts remain. Use
`--identity PATH` when the installer requires a specific SSH private key.

After the first login, inspect and commit the generated
`nixos/hardware-configuration.nix`, `nixos/install-disk`, and
`nixos/bootstrap.nix` changes if this machine should become the repository's
canonical NixOS host.

### Bootable USB workflow

The custom USB image embeds committed `HEAD` and a passphrase-encrypted private
home-directory payload. Create a staging directory whose contents should become
`/home/kamil`; symlinks and special files are rejected:

```sh
mkdir -p ~/installer-private/.ssh ~/installer-private/.local/share/fonts
cp ~/.ssh/id_ed25519{,.pub} ~/installer-private/.ssh/
cp -R ~/.local/share/fonts/PAID-FONT ~/installer-private/.local/share/fonts/
./scripts/create-installer-vault.sh \
  --source ~/installer-private \
  --output ~/nixos-installer-vault.age
```

Build the ISO from a clean, committed checkout:

```sh
./scripts/build-nixos-installer.sh \
  --vault ~/nixos-installer-vault.age \
  --out-link result-installer
```

The image is under `result-installer/iso/`. Building an x86_64 NixOS ISO
requires an x86_64-linux builder; an aarch64-darwin machine needs a configured
Linux remote/VM builder.

After boot, the installer starts on tty1, checks network access, offers `nmtui`
when necessary, asks which fixed disk to erase, and retains the exact disk-name
confirmation. It then prompts for the vault, LUKS, and login passphrases before
installing and rebooting. The current image is **online**: the repository and
encrypted vault are embedded, but target package closures are downloaded from
the configured Nix caches.

The decrypted vault archive exists only below `/run` in the live installer.
Archive paths and member types are validated before extraction; SSH directories
are installed as mode 0700, private files as 0600, and public keys as 0644.

> **Destructive boundary:** Disko erases the entire value passed to `--disk`.
> Target/disk selection cannot safely be inferred when more than one drive is
> present, so the installer deliberately requires both.

## Applying the configurations
On macOS, nix-homebrew installs or adopts the Apple Silicon Homebrew prefix before nix-darwin applies the declared formulae, casks, and taps.

From the repository root:

```sh
# macOS
nh darwin switch ./nix # or `nrs` alias

# NixOS
nh os switch ./nix # or `nrs` alias
```

For the first rebuild on a machine where `nh` is not installed yet, bootstrap with the native command:

```sh
# macOS
sudo darwin-rebuild switch --flake ./nix

# NixOS
sudo nixos-rebuild switch --flake ./nix
```

Each platform uses the matching `nh` rebuild command: `nh darwin switch` on macOS and `nh os switch` on NixOS. A rebuild installs or updates packages and recreates the declared symlink topology. Editing a linked root-level configuration afterward is immediately visible without another rebuild.

## Adding a new configuration

1. Create a root-level directory or file named after the application.
2. Add the desired `$HOME` target to the appropriate set in [`nix/symlinks.nix`](nix/symlinks.nix). Reserve direct `home.file` declarations for Nix-store-owned files rather than repository dotfiles.
3. Use `commonLinks` for both platforms; use `darwinLinks` or `linuxLinks` when the application is platform-specific.
4. Rebuild once to create the link, then edit the root-level source directly.

Keep generated state, caches, and machine-specific secrets out of the repository unless the relevant application deliberately requires them.
