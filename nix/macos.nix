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
  ...
}:

let
  darwinSystem = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs

  # Local overlays
  opencode-overlay = import ./overlays/opencode.nix;
  omp-overlay = import ./overlays/omp.nix;

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
        {
          nix.enable = false;
          nixpkgs.pkgs = darwinPkgs;

          # List packages installed in system profile
          environment.systemPackages = with pkgs; [
            vim
            git
            curl
            wget
          ];

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
            '';
            brews = [
              "sketchybar"
              "vercel-cli"
              "jiratui"
              "bd"
              "stripe-cli"
              # opencode - installed via nix overlay (see overlays/opencode.nix)
            ];
            casks = [
              # Keep these that aren't available in nixpkgs or ARM macOS
              "chromium"
              "firefox"
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
