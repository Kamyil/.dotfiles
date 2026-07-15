{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.disko.follows = "disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    sqlit.url = "github:Maxteabag/sqlit";
    sqlit.inputs.nixpkgs.follows = "nixpkgs";

    worktrunk.url = "github:max-sixty/worktrunk";
    worktrunk.inputs.nixpkgs.follows = "nixpkgs";

    lazyjira.url = "github:textfuel/lazyjira";
    lazyjira.inputs.nixpkgs.follows = "nixpkgs";

    hunk.url = "github:modem-dev/hunk/main";
    hunk.inputs.nixpkgs.follows = "nixpkgs";

    lumen.url = "github:jnsahaj/lumen";
    lumen.inputs.nixpkgs.follows = "nixpkgs";

    herdr.url = "github:ogulcancelik/herdr/master";
    herdr.inputs.nixpkgs.follows = "nixpkgs";

    # Add private fonts
    # berkeley-font = {
    #   url = "path:///home/kamil/.local/share/fonts";
    #   flake = false;
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      disko,
      nixos-anywhere,
      rust-overlay,
      sqlit,
      worktrunk,
      lazyjira,
      hunk,
      lumen,
      herdr,
      ...
    }:
    let
      lib = nixpkgs.lib;

      nixosConfig = import ./nixos.nix {
        inherit
          nixpkgs
          home-manager
          rust-overlay
          lib
          disko
          sqlit
          worktrunk
          lazyjira
          hunk
          lumen
          herdr
          ;
      };

      macosConfig = import ./macos.nix {
        inherit
          self
          nixpkgs
          home-manager
          nix-darwin
          rust-overlay
          lib
          sqlit
          worktrunk
          lazyjira
          hunk
          lumen
          herdr
          ;
      };
    in
    nixosConfig
    // macosConfig
    // {
      packages =
        lib.genAttrs
          [
            "aarch64-darwin"
            "x86_64-darwin"
            "x86_64-linux"
          ]
          (system: {
            nixos-anywhere = nixos-anywhere.packages.${system}.default;
          });
    };
}
