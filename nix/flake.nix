{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # OS-aware dotfiles path
    # Relative path - goes up one directory from nix/ to .dotfiles/ and works on both systems (Mac and Linux)
    dotfiles.url = "path:..";

    dotfiles.flake = false;

    rust-overlay.url = "github:oxalica/rust-overlay";
    sqlit.url = "github:Maxteabag/sqlit";
    sqlit.inputs.nixpkgs.follows = "nixpkgs";

    worktrunk.url = "github:max-sixty/worktrunk";
    worktrunk.inputs.nixpkgs.follows = "nixpkgs";

    lazyjira.url = "github:textfuel/lazyjira";

    hunk.url = "github:modem-dev/hunk/v0.14.0";
    hunk.inputs.nixpkgs.follows = "nixpkgs";

    lumen.url = "github:jnsahaj/lumen";
    lumen.inputs.nixpkgs.follows = "nixpkgs";

    herdr.url = "github:ogulcancelik/herdr/v0.7.1";
    herdr.inputs.nixpkgs.follows = "nixpkgs";

    # Add private fonts
    # berkeley-font = {
    #   url = "path:///home/kamil/.local/share/fonts";
    #   flake = false;
    # };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nix-darwin, dotfiles, rust-overlay, sqlit, worktrunk, lazyjira, hunk, lumen, herdr, ... }:
    let
      # Define supported systems
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      lib = nixpkgs.lib;

      # Import platform-specific configurations
      nixosConfig = import ./nixos.nix {
        inherit self nixpkgs nixpkgs-stable home-manager dotfiles rust-overlay lib sqlit worktrunk lazyjira hunk lumen herdr;
      };

      macosConfig = import ./macos.nix {
        inherit self nixpkgs nixpkgs-stable home-manager nix-darwin dotfiles rust-overlay lib sqlit worktrunk lazyjira hunk lumen herdr;
      };

    in
    # Merge the configurations from both platforms
    lib.recursiveUpdate nixosConfig macosConfig;
}
