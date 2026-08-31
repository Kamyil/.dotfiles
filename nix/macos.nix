# macOS-specific configuration using nix-darwin
{
  self,
  nixpkgs,
  home-manager,
  nix-darwin,
  fff,
  nix-homebrew,
  nix-index-database,
  sops-nix,
  rust-overlay,
  lib,
  sqlit,
  worktrunk,
  lazyjira,
  hunk,
  lumen,
  herdr,
  himalaya-tui,
  ...
}:

let
  darwinSystem = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs

  # Local overlays
  opencode-overlay = import ./overlays/opencode.nix;
  omp-overlay = import ./overlays/omp.nix;
  tldrawOffline = darwinPkgs.callPackage ./packages/tldraw-offline.nix { };

  darwinPkgs = import nixpkgs {
    system = darwinSystem;
    overlays = [
      rust-overlay.overlays.default
      opencode-overlay
      omp-overlay
    ];
    config.allowUnfree = true;
  };
in
{
  darwinConfigurations."MacBook-Pro-Kamil" = nix-darwin.lib.darwinSystem {
    system = darwinSystem;
    specialArgs = {
      inherit lib;
      pkgs = darwinPkgs;
    };
    modules = [
      # nix-darwin system configuration
      (
        {
          config,
          pkgs,
          lib,
          ...
        }:
        let
          malinkaDesiredActive = "/var/run/wireguard/malinka.desired-active";

          triggerMalinkaWakeRefresh = pkgs.writeShellScript "trigger-malinka-wake-refresh" ''
            set -eu

            if [[ -f ${malinkaDesiredActive} ]]; then
              /usr/bin/touch /var/run/malinka-wireguard-wake
            fi
          '';

          runMalinka = pkgs.writeShellScript "run-malinka-wireguard" ''
            set -u

            [[ -f ${malinkaDesiredActive} ]] || exit 0

            export PATH="${pkgs.wireguard-tools}/bin:${pkgs.wireguard-go}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
            export WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go

            echo "$(/bin/date '+%Y-%m-%dT%H:%M:%S%z') starting malinka"

            # Preserve the launchd-owned PID so wg-quick detects launchd, keeps
            # its route monitor attached, and waits for that monitor.
            exec ${pkgs.wireguard-tools}/bin/wg-quick up malinka
          '';

          refreshMalinka = pkgs.writeShellScript "refresh-malinka-wireguard" ''
            set -u

            timestamp() {
              /bin/date '+%Y-%m-%dT%H:%M:%S%z'
            }

            if [[ ! -f ${malinkaDesiredActive} ]]; then
              echo "$(timestamp) malinka is intentionally inactive; nothing to refresh"
              exit 0
            fi

            echo "$(timestamp) refresh requested"

            # A wake/network notification can arrive before the new network is usable.
            /bin/sleep 5

            export PATH="${pkgs.wireguard-tools}/bin:${pkgs.wireguard-go}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
            export WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go

            runtime_interface=
            [[ ! -f /var/run/wireguard/malinka.name ]] || runtime_interface=$(/bin/cat /var/run/wireguard/malinka.name)

            if [[ -n "$runtime_interface" ]]; then
              if ${pkgs.wireguard-tools}/bin/wg show "$runtime_interface" >/dev/null 2>&1; then
                echo "$(timestamp) stopping malinka ($runtime_interface)"
              else
                echo "$(timestamp) cleaning stale malinka mapping ($runtime_interface)"
              fi

              if ! ${pkgs.wireguard-tools}/bin/wg-quick down malinka; then
                echo "$(timestamp) wg-quick down failed; removing stale userspace state"
                /bin/rm -f "/var/run/wireguard/$runtime_interface.sock" /var/run/wireguard/malinka.name
              fi
            fi

            echo "$(timestamp) starting launchd tunnel service"
            /bin/launchctl kickstart -k system/org.nixos.malinka-wireguard
            echo "$(timestamp) refresh dispatched"
          '';
        in
        {
          nix.enable = false;
          nixpkgs.pkgs = darwinPkgs;

          # List packages installed in system profile
          environment.systemPackages = with pkgs; [
            vim
            git
            curl
            wget
            tldrawOffline
          ];

          # Route only .lan queries through the DNS server reachable over WireGuard.
          # This resolver may remain installed while the tunnel is down; macOS keeps
          # DHCP/Wi-Fi resolvers for every other domain.
          environment.etc."resolver/lan".text = ''
            nameserver 10.10.0.1
          '';

          # sleepwatcher converts the native macOS wake notification into a file
          # event. The refresh job also watches resolv.conf, which macOS rewrites
          # when the active network/DNS configuration changes.
          # wg-quick deliberately stays alive under launchd so its route monitor
          # remains a child of the service. The event job only restarts this job.
          launchd.daemons.malinka-wireguard = {
            command = "${runMalinka}";
            serviceConfig = {
              ProcessType = "Background";
              ThrottleInterval = 10;
              StandardOutPath = "/var/log/malinka-wireguard.log";
              StandardErrorPath = "/var/log/malinka-wireguard.log";
            };
          };

          launchd.daemons.malinka-wireguard-wake = {
            command = "${pkgs.sleepwatcher}/bin/sleepwatcher -w '${triggerMalinkaWakeRefresh}'";
            serviceConfig = {
              KeepAlive = true;
              ProcessType = "Background";
              StandardOutPath = "/var/log/malinka-wireguard-wake.log";
              StandardErrorPath = "/var/log/malinka-wireguard-wake.log";
            };
          };

          launchd.daemons.malinka-wireguard-refresh = {
            command = "${refreshMalinka}";
            serviceConfig = {
              ProcessType = "Background";
              ThrottleInterval = 10;
              WatchPaths = [
                "/etc/resolv.conf"
                "/var/run/malinka-wireguard-wake"
              ];
              StandardOutPath = "/var/log/malinka-wireguard-refresh.log";
              StandardErrorPath = "/var/log/malinka-wireguard-refresh.log";
            };
          };

          # Work around nix-darwin applications buildEnv pathsToLink type
          system.build.applications = lib.mkForce (
            pkgs.buildEnv {
              name = "system-applications";
              paths = config.environment.systemPackages;
              pathsToLink = [ "/Applications" ];
            }
          );

          # Determinate Nix manages the daemon and nix.conf on this machine.
          # Keep nix-darwin from managing Nix itself; otherwise activation aborts.

          # Disable darwin-uninstaller to avoid broken buildEnv pathsToLink
          system.tools.darwin-uninstaller.enable = false;

          # Create /etc/zshrc that loads the nix-darwin environment
          programs.zsh = {
            enable = true;
            enableCompletion = true;
            enableBashCompletion = true;
          };

          # Set Git commit hash for darwin-version
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility
          system.stateVersion = 5;

          # The platform the configuration will be used on
          nixpkgs.hostPlatform = "aarch64-darwin";

          # Set primary user (required for system defaults and homebrew)
          system.primaryUser = "kamil";

          # Configure users and set shell
          users.users.kamil = {
            name = "kamil";
            home = "/Users/kamil";
            shell = pkgs.zsh;
          };

          # Ensure nix-darwin manages shells
          environment.shells = with pkgs; [ zsh ];

          # Add nix paths to zsh
          environment.variables = {
            EDITOR = "nvim";
            SHELL = "${pkgs.zsh}/bin/zsh";
          };

          # Ensure nix environment is loaded in all shells
          environment.interactiveShellInit = ''
            # Nix
            if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
              . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
            fi
            # End Nix
          '';

          # macOS system defaults
          system.defaults = {
            dock = {
              autohide = true;
              show-recents = false;
              tilesize = 48;
            };
            finder = {
              AppleShowAllExtensions = true;
              ShowPathbar = true;
              ShowStatusBar = true;
            };
            NSGlobalDomain = {
              AppleShowAllExtensions = true;
              KeyRepeat = 2;
              InitialKeyRepeat = 15;
              ApplePressAndHoldEnabled = false;
            };
          };

          # Homebrew integration
          homebrew = {
            enable = true;
            onActivation.cleanup = "uninstall";
            # Homebrew requires explicit trust for third-party Ruby code. Keep every
            # declared tap here so `brew bundle cleanup` also preserves its trust.
            extraConfig = ''
              tap "nikitabobko/tap", trusted: true
              tap "FelixKratz/formulae", trusted: true
              tap "steveyegge/beads", trusted: true
              tap "steipete/tap", trusted: true
              tap "cloudmanic/spice-edit", trusted: true
              # Force prevents Brew Bundle's default adoption path from recursively
              # chmodding an existing signed app bundle.
              cask "helium-browser", args: { force: true }
            '';
            brews = [
              "sketchybar"
              "vercel-cli"
              "jiratui"
              "bd"
              "stripe-cli"
              "spice-edit"
              # opencode - installed via nix overlay (see overlays/opencode.nix)
            ];
            casks = [
              # Keep these that aren't available in nixpkgs or ARM macOS
              "firefox"
              "spotify"
              "vivaldi"
              "libreoffice"
              "love"
              "stats"
              "macs-fan-control"
              "utm"
              "podman-desktop"
              "qmk-toolbox"
              "ytmdesktop-youtube-music"
              "aerospace"
              "raycast"
              "signal"
              "obsidian"
              "font-sketchybar-app-font"
              "eqmac"
              "ghostty"
              "postman"
              "beekeeper-studio"
              "opencode-desktop"
              "emacs-app"
              "sweet-home3d"
            ];
          };
        }
      )
      sops-nix.darwinModules.sops
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          user = "kamil";
          autoMigrate = true;
        };
      }

      # Home Manager for Darwin
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [
          nix-index-database.homeModules.default
          sops-nix.homeManagerModules.sops
        ];
        home-manager.extraSpecialArgs = {
          inherit
            worktrunk
            fff
            darwinSystem
            lazyjira
            hunk
            lumen
            herdr
            himalaya-tui
            ;
        };

        home-manager.users.kamil =
          {
            pkgs,
            lib,
            worktrunk,
            darwinSystem,
            lumen,
            ...
          }:
          let
            heliumLauncher = pkgs.writeShellScript "helium-themed" ''
              if [[ ! -f "$HOME/.local/state/dotfiles-theme/current/helium/manifest.json" ]]; then
                "$HOME/.dotfiles/scripts/theme" kanagawa-paper >/dev/null
              fi
              exec "/Applications/Helium.app/Contents/MacOS/Helium" \
                --start-maximized \
                --load-extension="$HOME/.local/state/dotfiles-theme/current/helium" \
                "$@"
            '';
            heliumLauncherInfo = pkgs.writeText "helium-themed-Info.plist" ''
              <?xml version="1.0" encoding="UTF-8"?>
              <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
              <plist version="1.0">
              <dict>
                <key>CFBundleDisplayName</key>
                <string>Helium Themed</string>
                <key>CFBundleExecutable</key>
                <string>helium-themed</string>
                <key>CFBundleIdentifier</key>
                <string>net.imput.helium-themed-launcher</string>
                <key>CFBundleName</key>
                <string>Helium Themed</string>
                <key>CFBundlePackageType</key>
                <string>APPL</string>
                <key>CFBundleShortVersionString</key>
                <string>1.0.0</string>
                <key>LSMinimumSystemVersion</key>
                <string>12.0</string>
              </dict>
              </plist>
            '';
            heliumLauncherApp = pkgs.runCommand "helium-themed-app" { } ''
              mkdir -p "$out/Contents/MacOS"
              cp ${heliumLauncherInfo} "$out/Contents/Info.plist"
              cp ${heliumLauncher} "$out/Contents/MacOS/helium-themed"
            '';
          in
          {
            imports = [ ./shared.nix ];

            home.homeDirectory = lib.mkForce "/Users/kamil";
            home.enableNixpkgsReleaseCheck = false;

            # macOS-specific packages; cross-platform packages live in home/packages.nix.
            home.packages =
              (with pkgs; [
                docker
                gcc
                opencode
                lima
                colima
                trash-cli
                cowsay
                figlet
                fortune
                lolcat
                rustup
                openssl
                uv
                zellij
                sshfs-fuse
                nerd-fonts.geist-mono
                nerd-fonts.jetbrains-mono
              ])
              ++ [
                sqlit.packages.${darwinSystem}.default
                worktrunk.packages.${darwinSystem}.default
                lumen.packages.${darwinSystem}.default
              ];

            programs.zsh.shellAliases = {
              finder = "open";
              nrs = "nh darwin switch ~/.dotfiles/nix";
              transcribe = "uvx parakeet-mlx --model mlx-community/parakeet-tdt-0.6b-v3 --output-format txt";
            };

            programs.zsh.initContent = lib.mkMerge [
              (lib.mkBefore ''
                # Source the nix-darwin environment before Home Manager builds fpath.
                if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
                fi

                if [[ -d "/etc/profiles/per-user/$USER" ]]; then
                  case " $NIX_PROFILES " in
                    *" /etc/profiles/per-user/$USER "*) ;;
                    *) export NIX_PROFILES="/etc/profiles/per-user/$USER $NIX_PROFILES" ;;
                  esac
                fi

                export PATH="/opt/homebrew/bin:$PATH"
              '')
              (lib.mkAfter ''
                open_url() {
                  open "$@"
                }

                unmount_sshfs() {
                  umount "$1"
                }

                macos_copy_to_clipboard() {
                  pbcopy < "$1"
                }

                macos_set_proper_key_repeat() {
                  defaults write -g KeyRepeat -int 1
                  defaults write -g InitialKeyRepeat -int 10
                }
              '')
            ];

            home.sessionVariables = {
              PNPM_HOME = "/Users/kamil/Library/pnpm";
              HOMEBREW_NO_AUTO_UPDATE = "1";
            };
            home.sessionPath = [ "/Users/kamil/Library/pnpm" ];

            home.file."Applications/Helium Themed.app".source = heliumLauncherApp;

            # Enable XDG for proper config management

            xdg.enable = true;
          };
      }
    ];
  };

  # Compatibility outputs for the supported Apple Silicon host.
  packages.aarch64-darwin.default = self.darwinConfigurations."MacBook-Pro-Kamil".system;

  apps.aarch64-darwin.default = {
    type = "app";
    program = "${self.darwinConfigurations."MacBook-Pro-Kamil".system}/sw/bin/darwin-rebuild";
    meta.description = "Activate the MacBook-Pro-Kamil nix-darwin configuration";
  };
}
