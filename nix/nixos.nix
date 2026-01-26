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
        home-manager.extraSpecialArgs = { inherit pkgsStable neovim-nightly-overlay system; };

        # --- your user ---
        home-manager.users.kamil = { pkgs, config, pkgsStable, neovim-nightly-overlay, system, ... }:
          let
            repo = "${config.home.homeDirectory}/.dotfiles";
            link = p: config.lib.file.mkOutOfStoreSymlink "${repo}/${p}";
          in
        {
           # imports = [ ./shared.nix ];  # TEMPORARILY DISABLED FOR TESTING
           
           home.homeDirectory = lib.mkForce "/home/kamil";
           home.username = "kamil";
           home.stateVersion = "24.11";
           
            # Disable version mismatch warning between HM and nixpkgs
             home.enableNixpkgsReleaseCheck = false;

             # Simple test package
             home.packages = [ pkgs.cowsay pkgs.docker-compose ];

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
            package = pkgs.capitaine-cursors;
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
