{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Comment out problematic inputs temporarily
    # dotfiles.url = "path:/home/kamil/.dotfiles";
    # dotfiles.flake = false;

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay"; 
    rust-overlay.url = "github:oxalica/rust-overlay";

    # Comment out font input temporarily
    # berkeley-font = {
    #   url = "path:///home/kamil/.local/share/fonts";
    #   flake = false;
    # };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, neovim-nightly-overlay, rust-overlay, ... }:
    let
      system = "aarch64-linux";  # Explicitly set for ARM VM
      
      pkgs = import nixpkgs {
        inherit system;
        overlays = [rust-overlay.overlays.default];
        config.allowUnfree = true;
      };
      
      lib = nixpkgs.lib;
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs; };
        modules = [
          ./configuration.nix

          # Simplified home-manager config
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            home-manager.users.kamil = { pkgs, config, ... }: {
              home.username = "kamil";
              home.homeDirectory = "/home/kamil";
              home.stateVersion = "24.11";

              # Minimal package set that should work
              home.packages = with pkgs; [
                firefox
                fzf
                bat
                ripgrep
                git
                neovim-nightly-overlay.packages.${system}.default
                # Remove opencode for now
              ];

              programs.zsh = {
                enable = true;
                autosuggestion.enable = true;
                syntaxHighlighting.enable = true;
                
                # Basic aliases only
                shellAliases = {
                  ls = "ls --color=auto";
                  ll = "ls -la";
                  nrs = "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos";
                };
              };

              programs.git = {
                enable = true;
                userName = "Kamil Ksen";
                userEmail = "mccom_kks@mccom.pl";
              };

              # Comment out file mappings that depend on dotfiles
              # xdg.configFile."nvim".source = dotfiles + "/nvim";

              xdg.enable = true;
              programs.home-manager.enable = true;
            };
          }
        ];	
      };
    };
}
