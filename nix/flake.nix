{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    fff.url = "github:dmtrKovalenko/fff.nvim";
    fff.inputs.nixpkgs.follows = "nixpkgs";
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

    herdr.url = "github:ogulcancelik/herdr/v0.7.4";
    herdr.inputs.nixpkgs.follows = "nixpkgs";

    helium.url = "github:oxcl/nix-flake-helium-browser";
    helium.inputs.nixpkgs.follows = "nixpkgs";

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
      nix-homebrew,
      nix-index-database,
      sops-nix,
      disko,
      nixos-anywhere,
      rust-overlay,
      fff,
      sqlit,
      worktrunk,
      lazyjira,
      hunk,
      lumen,
      herdr,
      helium,
      ...
    }:
    let
      lib = nixpkgs.lib;
      installerEnvNames = [
        "NIXOS_INSTALLER_BUNDLE"
        "NIXOS_INSTALLER_ORIGIN"
        "NIXOS_INSTALLER_BRANCH"
        "NIXOS_INSTALLER_VAULT"
      ];
      installerEnvPresent = lib.all (name: builtins.getEnv name != "") installerEnvNames;
      requiredInstallerPath =
        name:
        builtins.path {
          path = builtins.getEnv name;
          name = lib.toLower name;
        };

      usbInstallerConfig = import ./installer-iso.nix {
        inherit nixpkgs nixos-anywhere;
        bundle = requiredInstallerPath "NIXOS_INSTALLER_BUNDLE";
        origin = requiredInstallerPath "NIXOS_INSTALLER_ORIGIN";
        branch = requiredInstallerPath "NIXOS_INSTALLER_BRANCH";
        vault = requiredInstallerPath "NIXOS_INSTALLER_VAULT";
      };


      nixosConfig = import ./nixos.nix {
        inherit
          nixpkgs
          home-manager
          rust-overlay
          lib
          disko
          fff
          nix-index-database
          sops-nix
          sqlit
          worktrunk
          lazyjira
          hunk
          lumen
          herdr
          helium
          ;
      };

      macosConfig = import ./macos.nix {
        inherit
          self
          nixpkgs
          home-manager
          nix-darwin
          rust-overlay
          fff
          lib
          nix-homebrew
          nix-index-database
          sops-nix
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
      nixosConfigurations =
        nixosConfig.nixosConfigurations
        // lib.optionalAttrs installerEnvPresent { usb-installer = usbInstallerConfig; };
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
