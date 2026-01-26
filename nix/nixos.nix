# NixOS-specific configuration
{ self, nixpkgs, nixpkgs-stable, home-manager, neovim-nightly-overlay, dotfiles, rust-overlay, lib, ... }:

let
  system = builtins.currentSystem or "x86_64-linux";
  
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

        # --- your user ---
        home-manager.users.kamil = { pkgs, config, ... }:
          let
            repo = "${config.home.homeDirectory}/.dotfiles";
            link = p: config.lib.file.mkOutOfStoreSymlink "${repo}/${p}";
          in
        {
           imports = [ ./shared.nix ];
           
           home.homeDirectory = lib.mkForce "/home/kamil";
           
           # Disable version mismatch warning between HM and nixpkgs
           home.enableNixpkgsReleaseCheck = false;

             # NixOS-specific packages (merged with shared packages)
             home.packages = lib.mkMerge [
               (with pkgsStable; [
                 # Development tools
                 gcc docker
                 go yarn pnpm deno fnm wrangler
                 lua luarocks python3 php
                 zig stylua lua-language-server
                 rustup
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
                 docker-compose podman podman-compose

                 # Media and graphics
                 ffmpeg imagemagick

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

                 # Cursor themes - minimal macOS-like style
                 capitaine-cursors
               ] ++ [
                 # Unstable-only packages
                 pkgs.opencode
                 # packages from unstable branch
                 neovim-nightly-overlay.packages.${system}.default
               ])
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

            # Linux-specific configs
          } // lib.optionalAttrs (builtins.match ".*linux.*" system != null) {

          home.file."second-brain/.keep".text = "";

          # Commented out font configuration as noted in original
          # home.file.".local/share/fonts/BerkeleyMono-Regular.otf".source = berkeley-font + "/BerkeleyMono-Regular.otf";
          # home.file.".local/share/fonts/BerkeleyMono-Bold.otf".source = berkeley-font + "/BerkeleyMono-Bold.otf";
          # home.file.".local/share/fonts/BerkeleyMono-Oblique.otf".source = berkeley-font + "/BerkeleyMono-Oblique.otf";
          # home.file.".local/share/fonts/BerkeleyMono-Bold-Oblique.otf".source = berkeley-font + "/BerkeleyMono-Bold-Oblique.otf";

          fonts.fontconfig.enable = true;
          # fonts.fontconfig.defaultFonts.monospace = [ "Berkeley Mono" ];

          # Set cursor theme environment variables for better compatibility
          home.sessionVariables = {
            XCURSOR_THEME = "capitaine-cursors";
            XCURSOR_SIZE = "24";
            HYPRCURSOR_THEME = "capitaine-cursors";
            HYPRCURSOR_SIZE = "24";
          };

          # GTK cursor theme - minimal macOS-like style
          gtk.enable = true;
          gtk.cursorTheme = {
            package = pkgsStable.capitaine-cursors;
            name = "capitaine-cursors";
            size = 24;
          };

          # Nice defaults
          xdg.enable = true;
          };

         # Per-OS gating for files you only want on macOS / Linux
         # Example: only install yabai/skhd configs on macOS
         # (for later if you reuse the same flake on your Mac)
         # home-manager.sharedModules = [
         #   ({ pkgs, ... }: lib.mkIf pkgs.stdenv.isDarwin {
         #     xdg.configFile."yabai".source = dotfiles + "/yabai";
         #     xdg.configFile."skhd".source  = dotfiles + "/skhd";
         #   })
         # ];
      }
    ];
  };
}
