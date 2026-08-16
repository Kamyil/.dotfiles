{
  description = "Malinka — headless Raspberry Pi 4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      disko,
      ...
    }:
    let
      commonModules = [
        nixos-hardware.nixosModules.raspberry-pi-4
        ./hardware.nix
        ./configuration.nix
      ];
    in
    {
      nixosConfigurations.malinka = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = commonModules ++ [
          disko.nixosModules.disko
          ./disko.nix
        ];
      };

      nixosConfigurations.malinka-sd = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = commonModules ++ [
          ({ modulesPath, ... }: {
            imports = [
              "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
            ];
          })
        ];
      };
    };
}
