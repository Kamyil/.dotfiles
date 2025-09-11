{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # OS-aware dotfiles path
    # Relative path - goes up one directory from nixos/ to .dotfiles/ and works on both systems (Mac and Linux)
    dotfiles.url = "path:..";

    dotfiles.flake = false;

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    rust-overlay.url = "github:oxalica/rust-overlay";

    # Add private fonts
    # berkeley-font = {
    #   url = "path:///home/kamil/.local/share/fonts";
    #   flake = false;
    # };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nix-darwin, neovim-nightly-overlay, dotfiles, rust-overlay, ... }:
    let
      # Define supported systems
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      lib = nixpkgs.lib;

      # Import platform-specific configurations
      nixosConfig = import ./nixos.nix {
        inherit self nixpkgs nixpkgs-stable home-manager neovim-nightly-overlay dotfiles rust-overlay lib;
      };

      macosConfig = import ./macos.nix {
        inherit self nixpkgs nixpkgs-stable home-manager nix-darwin neovim-nightly-overlay dotfiles rust-overlay lib;
      };

    in 
    # Merge the configurations from both platforms
    lib.recursiveUpdate nixosConfig macosConfig;
}
