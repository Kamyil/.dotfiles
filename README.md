# .dotfiles

A single, live-editable configuration repository for my macOS and NixOS machines.

The repository keeps application configuration in the root directory (`nvim/`, `kitty/`, `wezterm/`, `hypr/`, and so on). Nix describes which programs are installed and where configuration links should exist; the links point back into this checkout instead of copying files into `$HOME`.

## Architecture

The top-level Nix flake is the composition root. It imports one system definition for each supported operating system and merges their outputs.

```mermaid
flowchart TD
    F["nix/flake.nix<br/>inputs + outputs"] --> D["nix/macos.nix<br/>nix-darwin host"]
    F --> L["nix/nixos.nix<br/>NixOS composition"]
    L --> NH["nixos/configuration.nix<br/>NixOS host"]
    D --> HM1["Home Manager"]
    L --> HM2["Home Manager"]
    HM1 --> S["nix/shared.nix<br/>shared Home Manager entry"]
    HM2 --> S
    S --> M["nix/home/<br/>shell + packages + live links"]
    M --> SYM["nix/symlinks.nix<br/>common + platform link maps"]
    HM1 --> MAC["MacBook-Pro-Kamil<br/>aarch64-darwin"]
    HM2 --> NIX["nixos<br/>x86_64-linux"]
```

### Platform branches

```mermaid
flowchart LR
    ROOT["nix/flake.nix"] --> DARWIN["nix-darwin<br/>MacBook-Pro-Kamil"]
    ROOT --> NIXOS["NixOS<br/>nixos"]
    DARWIN --> D_SYS["macOS system defaults<br/>Homebrew + shells"]
    DARWIN --> D_HOME["shared.nix + macOS packages"]
    NIXOS --> N_SYS["nixos/configuration.nix<br/>boot, networking, Hyprland, PipeWire"]
    NIXOS --> N_HOME["shared.nix + Linux packages"]
```

- **`nix/flake.nix`** pins inputs and exposes the `darwinConfigurations` and `nixosConfigurations` outputs.
- **`nix/shared.nix`** imports the common Home Manager modules in `nix/home/`.
- **`nix/home/`** contains shared shell, package, and live-link modules.
- **`nix/macos.nix`** builds the `MacBook-Pro-Kamil` nix-darwin system and adds macOS packages, defaults, Homebrew, and shell helpers.
- **`nix/nixos.nix`** composes the `nixos` host with Home Manager and Linux-specific user settings.
- **`nixos/configuration.nix`** contains machine-level NixOS settings such as boot, networking, graphics, audio, and Hyprland.
- **`nix/overlays/`** packages tools that need a local overlay (`opencode` and `omp`).

## How live configuration reload works

Nix owns the *topology* of the links. Git owns the mutable configuration contents. Home Manager uses out-of-store links, so editing a file in this repository edits the file the application is already reading.

```mermaid
sequenceDiagram
    participant R as Root checkout
    participant N as Nix/Home Manager
    participant H as $HOME config path
    participant A as Application

    N->>H: Create symlink
    H-->>R: points to .dotfiles/<tool>
    R->>A: File edit is immediately visible
    A->>H: Reload/watch configuration
    Note over N,A: Rebuilds update link topology and packages;
    Note over R,A: normal edits do not require a rebuild
```

The link policy lives in [`nix/symlinks.nix`](nix/symlinks.nix):

- `commonLinks` applies to both operating systems.
- `darwinLinks` adds macOS-only paths such as SketchyBar, Aerospace, Hammerspoon, and cmux.
- `linuxLinks` adds Hyprland, Waybar, Walker, Omarchy, and other Linux desktop paths.
- Home Manager creates every repository link with `mkOutOfStoreSymlink`.
- Activation adopts only legacy symlinks already pointing into this checkout. Missing sources, real targets, and unrelated symlinks abort without overwriting them.

Editing linked files remains immediate and requires no rebuild. Rebuild only after changing packages or link topology.

## Repository layout

```text
.
├── nix/                 # Flake, system definitions, shared HM, overlays
├── nixos/               # NixOS machine configuration
├── nvim/ kitty/ ...     # Application configs at repository root
├── scripts/             # Helper scripts used by configs and workflows
├── docs/                # Setup and recovery notes
└── README.md
```

The important convention is: **a tool's configuration directory is a root-level sibling, not hidden below a second `config/` tree**. For example, edit `kitty/kitty.conf`, `herdr/config.toml`, or `nvim/init.lua`; the corresponding `$HOME/.config/...` path is linked to that directory.

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

SQL work is intentionally handled inside Neovim with the Dadbod plugins. Harlequin and Rainfrog were tried and removed from the package sets.

For agentic work, **oh-my-pi (`omp`) is the primary harness** and **OpenCode is the fallback**. No other agentic harness is installed by this flake.

### macOS-specific

| Role | Tool(s) | Linux/NixOS counterpart |
| --- | --- | --- |
| System integration | nix-darwin | NixOS modules (`nix/nixos.nix`, `nixos/configuration.nix`) |
| Window manager / compositor | Aerospace | Hyprland |
| Status bar | SketchyBar | Waybar |
| Terminal apps | Kitty, WezTerm, Ghostty, Alacritty | Alacritty, Kitty, WezTerm (shared where enabled) |
| Virtualization | Lima, Colima, QEMU, UTM | QEMU, Podman, Docker |
| GUI application delivery | Homebrew brews and casks | Nix packages and NixOS modules |
| macOS automation | Hammerspoon | Hyprland scripts / systemd user services |
| Desktop applications | Chromium, Firefox, Vivaldi, Signal, Obsidian, Postman, Raycast | Chromium, Firefox, Signal, Obsidian, qutebrowser (package availability differs) |

The primary macOS browser is **Helium**, installed outside this flake. Chromium, Firefox, Vivaldi, and qutebrowser remain declaratively installed fallbacks.

macOS Homebrew is used for GUI applications and tools that are unavailable or inconvenient in the current Nix package set. The authoritative list is in [`nix/macos.nix`](nix/macos.nix).

### NixOS-specific

| Role | Tool(s) | macOS counterpart |
| --- | --- | --- |
| Desktop compositor | Hyprland | Aerospace |
| Status bar and launcher | Waybar, Walker, Elephant | SketchyBar, Raycast |
| Lock screen and idle desktop | Hyprlock, Hypridle | macOS screen lock / system behavior |
| Audio and graphics | PipeWire, Pulse compatibility, XWayland | CoreAudio and native macOS display stack |
| Wi-Fi/Bluetooth TUIs | impala, bluetuith | macOS system UI or third-party GUI tools |
| Container stack | Docker, Podman, Compose, buildx | Docker/Podman plus Colima/Lima |
| Linux development | gcc, nixd, nightly Rust, Zig, PHP, Go | clang/Xcode toolchain, rustup, same language tools |
| Screenshot and clipboard | flameshot, swappy, wl-clipboard | macOS screenshot and clipboard tools |
| Keyboard remapping | kmonad | macOS keyboard shortcuts / QMK Toolbox |
| Linux fonts/cursors | JetBrains Mono, Lexend, Capitaine cursors | Nerd fonts and macOS font management |

## Applying the configurations

From the repository root:

```sh
# macOS
sudo darwin-rebuild switch --flake ./nix # or `nrs` alias

# NixOS
sudo nixos-rebuild switch --flake ./nix # or `nrs` alias
```

Each platform defines `nrs` with the correct rebuild command. A rebuild installs or updates packages and recreates the declared symlink topology. Editing a linked root-level configuration afterward is immediately visible without another rebuild.

## Adding a new configuration

1. Create a root-level directory or file named after the application.
2. Add the desired `$HOME` target to the appropriate set in [`nix/symlinks.nix`](nix/symlinks.nix). Reserve direct `home.file` declarations for Nix-store-owned files rather than repository dotfiles.
3. Use `commonLinks` for both platforms; use `darwinLinks` or `linuxLinks` when the application is platform-specific.
4. Rebuild once to create the link, then edit the root-level source directly.

Keep generated state, caches, and machine-specific secrets out of the repository unless the relevant application deliberately requires them.
