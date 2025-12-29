# NixOS-specific configuration
{ self, nixpkgs, nixpkgs-stable, home-manager, neovim-nightly-overlay, dotfiles, rust-overlay, lib, ... }:

let
  system = builtins.currentSystem or "aarch64-linux";
  
  # Helper function to create packages for a given system
  mkPkgs = system: import nixpkgs {
    inherit system;
    overlays = [ rust-overlay.overlays.default ];
    config.allowUnfree = true;
  };

  pkgs = mkPkgs system;
  pkgsStable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs; };
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

          # NixOS-specific packages
          home.packages = (with pkgs; [
            # Development tools
            gcc docker
            (pkgs.rust-bin.nightly.latest.default.override {
              extensions = [ "rust-src" "cargo" "rustc" ];
            })
            
            # Network tools
            impala # TUI for managing WiFi
          ]) ++ [
            # packages from unstable branch
            neovim-nightly-overlay.packages.${system}.default
          ];

          # NixOS-specific zsh additions
          programs.zsh.shellAliases = lib.mkMerge [
            {
              # Override nrs alias for NixOS
              nrs = "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos";
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

          # Direct symlinks using activation scripts (Linux)
          home.activation.directSymlinks = config.lib.dag.entryAfter ["writeBoundary"] ''
            # Remove any existing nix-managed symlinks
            rm -f ~/.config/nvim ~/.config/wezterm ~/.config/lazygit ~/.config/lazydocker ~/.config/lsd ~/.config/btop ~/.config/bat ~/.config/hypr ~/.config/waybar ~/.config/wofi
            
            # Create direct symlinks
            ln -sf /home/kamil/.dotfiles/nvim ~/.config/nvim
            ln -sf /home/kamil/.dotfiles/wezterm ~/.config/wezterm
            ln -sf /home/kamil/.dotfiles/config/lazygit ~/.config/lazygit
            ln -sf /home/kamil/.dotfiles/config/lazydocker ~/.config/lazydocker
            ln -sf /home/kamil/.dotfiles/config/lsd ~/.config/lsd
            ln -sf /home/kamil/.dotfiles/config/btop ~/.config/btop
            ln -sf /home/kamil/.dotfiles/bat ~/.config/bat
            ln -sf /home/kamil/.dotfiles/config/hypr ~/.config/hypr
            ln -sf /home/kamil/.dotfiles/config/waybar ~/.config/waybar
            ln -sf /home/kamil/.dotfiles/config/wofi ~/.config/wofi
            
            echo "Created direct symlinks to dotfiles"
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

        # Nice defaults
        xdg.enable = false;
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
