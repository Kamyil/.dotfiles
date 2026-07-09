# macOS-specific configuration using nix-darwin
{ self, nixpkgs, nixpkgs-stable, home-manager, nix-darwin, dotfiles, rust-overlay, lib, sqlit, worktrunk, lazyjira, hunk, lumen, herdr, ... }:

let
  darwinSystem = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs
  
  # Local overlays
  opencode-overlay = import ./overlays/opencode.nix;
  codex-overlay = import ./overlays/codex.nix;
  pi-overlay = import ./overlays/pi.nix;
  dotfileSymlinks = import ./symlinks.nix { inherit lib; };

  darwinPkgs = import nixpkgs {
    system = darwinSystem;
    overlays = [
      rust-overlay.overlays.default
      opencode-overlay
      codex-overlay
      pi-overlay
    ];
    config.allowUnfree = true;
  };
  darwinPkgsStable = import nixpkgs-stable {
    system = darwinSystem;
    config.allowUnfree = true;
  };
in
{
  darwinConfigurations."MacBook-Pro-Kamil" = nix-darwin.lib.darwinSystem {
    system = darwinSystem;
    specialArgs = {
      inherit lib;
      pkgs = darwinPkgs;
      pkgsStable = darwinPkgsStable;
    };
    modules = [
      # nix-darwin system configuration
      ({ config, pkgs, lib, ... }: {
        nix.enable = false;
        nixpkgs.pkgs = darwinPkgs;

        # List packages installed in system profile
        environment.systemPackages = with pkgs; [
          vim
          git
          curl
          wget
          codex
          harlequin
          rainfrog
        ];

        # Work around nix-darwin applications buildEnv pathsToLink type
        system.build.applications = lib.mkForce (pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = [ "/Applications" ];
        });

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
          taps = [ "nikitabobko/tap" "FelixKratz/formulae" "steveyegge/beads" "steipete/tap" ];
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
            "cmux"
            "eqmac"
            "ghostty"
            "postman"
			"opencode-desktop"
			"emacs-app"
			"sweet-home3d"
	          ];
        };
      })

      # Home Manager for Darwin
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit worktrunk darwinSystem lazyjira hunk lumen herdr; };

        home-manager.users.kamil = { pkgs, config, lib, worktrunk, darwinSystem, lumen, ... }:
          let
            repo = "${config.home.homeDirectory}/.dotfiles";
            link = p: config.lib.file.mkOutOfStoreSymlink "${repo}/${p}";
          in
        {
          imports = [ ./shared.nix ];
          
          home.homeDirectory = lib.mkForce "/Users/kamil";
          home.enableNixpkgsReleaseCheck = false;

          # macOS-specific packages (shared packages are in shared.nix)
          home.packages = (with pkgs; [
            # Terminal tools
            docker wezterm kitty alacritty

            # Development tools
            gcc go nodejs yarn pnpm fnm wrangler
            lua luarocks python3 php

            # Network and system tools
            wireshark-cli

            # Container tools (CLI versions, GUI via homebrew)
            podman podman-compose

            # Media and graphics
            ffmpeg imagemagick

            # Database and data tools
            postgresql

            # AI coding tools
            opencode
            pi

            # Text editors and viewers
            helix
            superfile

            # Virtualization and containers
            qemu lima colima

            # System utilities
            trash-cli cowsay figlet fortune lolcat

            # Programming language tools
            lua-language-server rustup
            
            # Libraries for fff.nvim
            openssl libssh2

             # Terminal multiplexers and sessions
             zellij

             # File synchronization and transfer
             sshfs-fuse

             # Browsers
             qutebrowser

            nerd-fonts.geist-mono # Cool programming font (good alternative to BerkeleyMono and JetBrains Mono)
            nerd-fonts.jetbrains-mono # Used for sketchybar to match waybar styling
          ]) ++ [
            # SQL TUI from flake
            sqlit.packages.${darwinSystem}.default
            # Git worktree CLI from flake
            worktrunk.packages.${darwinSystem}.default
            # Git diff/review TUI from flake
            lumen.packages.${darwinSystem}.default
          ];

          # macOS-specific zsh additions
          programs.zsh.shellAliases = lib.mkMerge [
            {
              # Override nrs alias for macOS
              nrs = "sudo darwin-rebuild switch --flake ~/.dotfiles/nix";
            }
          ];

          # macOS-specific zsh init content
          programs.zsh.initContent = lib.mkBefore ''
            # Source nix-darwin environment first
            if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
              . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
            fi

            # nix-darwin installs Home Manager user packages in /etc/profiles/per-user.
            # Include that profile before Home Manager builds fpath from NIX_PROFILES.
            if [[ -d "/etc/profiles/per-user/$USER" ]]; then
              case " $NIX_PROFILES " in
                *" /etc/profiles/per-user/$USER "*) ;;
                *) export NIX_PROFILES="/etc/profiles/per-user/$USER $NIX_PROFILES" ;;
              esac
            fi

            # macOS-specific paths
            export PATH="/opt/homebrew/bin:$PATH"
            export PNPM_HOME="/Users/kamil/Library/pnpm"
            export PATH="$PNPM_HOME:$PATH"
            
            # Initialize fnm (Fast Node Manager)
            eval "$(fnm env --use-on-cd)"
          '';

          # Live-editable dotfile symlinks: Nix owns link topology, Git owns contents.
          home.activation.directSymlinks = config.lib.dag.entryAfter ["writeBoundary"] ''
            ${dotfileSymlinks.mkDarwinActivation { }}

            echo "Created direct symlinks to dotfiles"
          '';

          # Enable XDG for proper config management
          xdg.enable = true;
        };
      }
    ];
  };

  # Add required outputs for nix-darwin compatibility
  packages.aarch64-darwin.default = self.darwinConfigurations."MacBook-Pro-Kamil".system;
  packages.x86_64-darwin.default = self.darwinConfigurations."MacBook-Pro-Kamil".system;

  apps.aarch64-darwin.default = {
    type = "app";
    program = "${self.darwinConfigurations."MacBook-Pro-Kamil".system}/sw/bin/darwin-rebuild";
  };

  apps.x86_64-darwin.default = {
    type = "app";
    program = "${self.darwinConfigurations."MacBook-Pro-Kamil".system}/sw/bin/darwin-rebuild";
  };
}
