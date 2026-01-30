# NixOS-specific configuration
{ self, nixpkgs, nixpkgs-stable, home-manager, neovim-nightly-overlay, dotfiles, rust-overlay, lib, ... }:

let
  system = builtins.currentSystem or "x86_64-linux";
  isLinux = builtins.match ".*linux.*" system != null;
  
  # Helper function to create packages for a given system
  mkPkgs = system: import nixpkgs {
    inherit system;
    overlays = [ rust-overlay.overlays.default ];
    config.allowUnfree = true;
  };

  pkgs = mkPkgs system;
  pkgsStable = import nixpkgs-stable {
    inherit system;
    overlays = [ rust-overlay.overlays.default ];
    config.allowUnfree = true;
  };
in
{
  nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      ./configuration.nix

      # enable HM as a NixOS module
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit pkgsStable neovim-nightly-overlay system; };

        # --- your user ---
        home-manager.users.kamil = { pkgs, config, pkgsStable, neovim-nightly-overlay, system, ... }:
          let
            repo = "${config.home.homeDirectory}/.dotfiles";
            link = p: config.lib.file.mkOutOfStoreSymlink "${repo}/${p}";
          in
        {
          imports = [ ./shared.nix ];
          
          home.homeDirectory = lib.mkForce "/home/kamil";
          
          # Disable version mismatch warning between HM and nixpkgs
          home.enableNixpkgsReleaseCheck = false;

          # NixOS-specific packages
          home.packages = (with pkgs; [
            # Development tools
            gcc docker
            go yarn pnpm deno fnm wrangler
            lua luarocks python3 php
            zig stylua lua-language-server
            vscode
            (pkgsStable.rust-bin.nightly.latest.default.override {
              extensions = [ "rust-src" "cargo" "rustc" ];
            })

            # Terminal tools
            yazi tmux

            # Shell and CLI utilities
            gh tree fd difftastic just jq yq
            gnugrep gnused coreutils
            nixd

            # System monitoring and management
            htop fastfetch pfetch neofetch

            # File and archive tools
            unzip p7zip trash-cli

            # Network and system tools
            nmap wireshark-cli socat

            # Container tools
            buildkit docker-compose podman podman-compose

            # Media and graphics
            ffmpeg imagemagick flameshot swappy chromium thunderbird

            # Database and data tools
            sqlite postgresql

            # Text editors and viewers
            helix

            # Version control extras
            git-extras tig

            # Virtualization and containers
            qemu

            # System utilities
            stow cowsay figlet fortune lolcat

            # Libraries
            libssh2

            # Terminal multiplexers and sessions
            zellij

            # File synchronization and transfer
            rsync openssh sshfs

            # Other useful tools
            tldr watchexec
            nerd-fonts.geist-mono

            # Network tools
            impala # TUI for managing WiFi
            bluetuith

            # Hyprland lock screen
            hyprlock

            # Cursor themes - minimal macOS-like style
            capitaine-cursors

            # Keyboard remapping
            kmonad

            # Shared packages (duplicated from shared.nix for NixOS)
            fzf bat delta lazygit lazydocker eza
            fnm just fastfetch
          ]) ++ [
            # Unstable-only packages
            pkgs.opencode
            # packages from unstable branch
            neovim-nightly-overlay.packages.${system}.default
          ];

          # NixOS-specific zsh additions
          programs.zsh.shellAliases = lib.mkMerge [
            {
              # Override nrs alias for NixOS
              nrs = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix";
            }
          ];

          # NixOS-specific zsh init content - add PNPM path for Linux
          programs.zsh.initContent = lib.mkAfter ''
            if [[ "$OSTYPE" == "darwin"* ]]; then
              export PNPM_HOME="/Users/kamil/Library/pnpm"
            else
              export PNPM_HOME="$HOME/.local/share/pnpm"
            fi
            case ":$PATH:" in
              *":$PNPM_HOME:"*) ;;
              *) export PATH="$PNPM_HOME:$PATH" ;;
            esac
          '';

          # Linux-specific configs (always applies on NixOS)
          home.file."second-brain/.keep".text = "";

           fonts.fontconfig = {
              enable = true;
            };

          # Set cursor theme environment variables for better compatibility
          home.sessionVariables = {
            XCURSOR_THEME = "capitaine-cursors";
            XCURSOR_SIZE = "24";
            HYPRCURSOR_THEME = "capitaine-cursors";
            HYPRCURSOR_SIZE = "24";
            OMARCHY_PATH = "$HOME/.local/share/omarchy";
          };

          # GTK cursor theme - minimal macOS-like style
          gtk.enable = true;
          gtk.cursorTheme = {
            package = pkgs.capitaine-cursors;
            name = "capitaine-cursors";
            size = 24;
          };

          # Nice defaults
          xdg.enable = true;

          home.sessionPath = [ "$HOME/.local/share/omarchy/bin" ];

          home.file = {
            ".config/autostart/walker.desktop".source = link "config/autostart/walker.desktop";
            ".config/elephant/calc.toml".source = link "config/elephant/calc.toml";
            ".config/elephant/desktopapplications.toml".source = link "config/elephant/desktopapplications.toml";
            ".config/omarchy/current/theme/walker.css".source = link "config/omarchy/current/theme/walker.css";
            ".config/omarchy/current/theme/waybar.css".source = link "config/omarchy/current/theme/waybar.css";
            ".config/omarchy/current/background".source = link "wallpapers/kanagawa-black-and-white-wallpaper.jpg";
            ".config/walker/config.toml".source = link "config/walker/config.toml";
            ".config/walker/themes/kanagawa.css".source = link "config/walker/themes/kanagawa.css";
            ".config/kmonad/config.kbd".source = link "config/kmonad/config.kbd";
            ".local/share/omarchy/bin".source = link "config/omarchy/bin";
            ".local/share/omarchy/default/walker/themes/omarchy-default/layout.xml".source = link "config/omarchy/default/walker/themes/omarchy-default/layout.xml";
            ".local/share/omarchy/default/walker/themes/omarchy-default/style.css".source = link "config/omarchy/default/walker/themes/omarchy-default/style.css";
            ".local/share/omarchy/default/waybar/indicators".source = link "config/omarchy/default/waybar/indicators";
          };

          systemd.user.services.kmonad = {
            Unit = {
              Description = "kmonad keyboard remapping daemon";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${pkgs.kmonad}/bin/kmonad %h/.config/kmonad/config.kbd";
              Restart = "on-failure";
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        };
      }
    ];
  };
}
