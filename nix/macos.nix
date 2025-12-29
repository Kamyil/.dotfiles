# macOS-specific configuration using nix-darwin
{ self, nixpkgs, nixpkgs-stable, home-manager, nix-darwin, neovim-nightly-overlay, dotfiles, rust-overlay, lib, ... }:

let
  darwinSystem = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs
  darwinPkgs = import nixpkgs {
    system = darwinSystem;
    overlays = [ rust-overlay.overlays.default ];
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
      ({ config, pkgs, ... }: {
        nix.enable = false;
        # List packages installed in system profile
        environment.systemPackages = with pkgs; [
          vim
          git
          curl
          wget
        ];

        # Nix configuration (nix-daemon is enabled by default when nix.enable = true)
        nix.package = pkgs.nix;

        # Enable flakes
        nix.settings.experimental-features = "nix-command flakes";

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
          taps = [ "nikitabobko/tap" "FelixKratz/formulae" ];
          brews = [
            "sketchybar"
            "codex"
            "vercel-cli"
            "jiratui"
          ];
          casks = [
            # Keep these that aren't available in nixpkgs or ARM macOS
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
            "font-sketchybar-app-font"
            "eqmac"
            "ghostty"
            "postman"
			"opencode-desktop"
			"ovim" # macOS system-wide Vim keybindings and modal editor.
          ];
        };
      })

      # Home Manager for Darwin
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";

        home-manager.users.kamil = { pkgs, config, ... }:
          let
            repo = "${config.home.homeDirectory}/.dotfiles";
            link = p: config.lib.file.mkOutOfStoreSymlink "${repo}/${p}";
          in
        {
          imports = [ ./shared.nix ];
          
          home.homeDirectory = lib.mkForce "/Users/kamil";

          # macOS-specific packages
          home.packages = (with pkgs; [
            # Development tools
            vscode 

            # Terminal tools
            docker ripgrep btop yazi tmux wezterm kitty

            # Shell and CLI utilities
            gh curl wget tree fd
            eza difftastic just jq yq

            # Development tools
            gcc go nodejs yarn pnpm deno fnm wrangler
            lua luarocks python3 php

            # Text processing and search
            gnugrep gnused coreutils

            # System monitoring and management
            htop fastfetch pfetch neofetch

            # File and archive tools
            unzip p7zip trash-cli

            # Network and system tools
            nmap wireshark-cli socat

            # Development/Programming
            # kitty removed - using WezTerm instead

            # Container tools (CLI versions, GUI via homebrew)
            podman podman-compose

            # Media and graphics
            ffmpeg imagemagick

            # Database and data tools
            sqlite postgresql

            # Text editors and viewers
            helix

            # Version control extras
            git-extras tig

            # Virtualization and containers
            qemu lima colima

            # System utilities
            stow cowsay figlet fortune lolcat

            # Programming language tools
            zig stylua lua-language-server rustup
            
            # Libraries for fff.nvim
            openssl libssh2

            # Terminal multiplexers and sessions
            zellij

            # File synchronization and transfer
            rsync openssh sshfs-fuse

            # Other useful tools
            tldr # Simplified man pages
            watchexec # File watching

            nerd-fonts.geist-mono # Cool programming font (good alternative to BerkeleyMono and JetBrains Mono)
          ]) ++ [
            # Add neovim from the overlay
            neovim-nightly-overlay.packages.${darwinSystem}.default
          ];

          # macOS-specific zsh additions
          programs.zsh.shellAliases = lib.mkMerge [
            {
              # Override nrs alias for macOS
              nrs = "sudo darwin-rebuild switch --flake ~/.dotfiles/nixos";
            }
          ];

          # macOS-specific zsh init content
          programs.zsh.initContent = lib.mkBefore ''
            # Source nix-darwin environment first
            if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
              . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
            fi

            # macOS-specific paths
            export PATH="/opt/homebrew/bin:$PATH"
            export PNPM_HOME="/Users/kamil/Library/pnpm"
            export PATH="$PNPM_HOME:$PATH"
            
            # Initialize fnm (Fast Node Manager)
            eval "$(fnm env --use-on-cd)"
          '';

          # Direct symlinks using activation scripts (macOS)
          home.activation.directSymlinks = config.lib.dag.entryAfter ["writeBoundary"] ''
            # Remove any existing nix-managed symlinks
            rm -f ~/.config/nvim ~/.config/wezterm ~/.config/lazygit ~/.config/lazydocker ~/.config/lsd ~/.config/btop ~/.config/bat ~/.config/sketchybar ~/.config/aerospace ~/.config/yabai ~/.config/skhd ~/.config/ghostty ~/.config/tmux ~/.config/opencode ~/.config/kitty ~/.hammerspoon
            
            # Create direct symlinks
            ln -sf /Users/kamil/.dotfiles/nvim ~/.config/nvim
            ln -sf /Users/kamil/.dotfiles/wezterm ~/.config/wezterm
            ln -sf /Users/kamil/.dotfiles/config/lazygit ~/.config/lazygit
            ln -sf /Users/kamil/.dotfiles/config/lazydocker ~/.config/lazydocker
            ln -sf /Users/kamil/.dotfiles/config/lsd ~/.config/lsd
            ln -sf /Users/kamil/.dotfiles/config/btop ~/.config/btop
            ln -sf /Users/kamil/.dotfiles/bat ~/.config/bat
            ln -sf /Users/kamil/.dotfiles/sketchybar ~/.config/sketchybar
            ln -sf /Users/kamil/.dotfiles/config/aerospace ~/.config/aerospace
            ln -sf /Users/kamil/.dotfiles/yabai ~/.config/yabai
            ln -sf /Users/kamil/.dotfiles/skhd ~/.config/skhd
            ln -sf /Users/kamil/.dotfiles/config/ghostty ~/.config/ghostty
            ln -sf /Users/kamil/.dotfiles/config/tmux ~/.config/tmux
            ln -sf /Users/kamil/.dotfiles/config/opencode ~/.config/opencode
            ln -sf /Users/kamil/.dotfiles/config/kitty ~/.config/kitty
            ln -sf /Users/kamil/.dotfiles/hammerspoon ~/.hammerspoon
            
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
