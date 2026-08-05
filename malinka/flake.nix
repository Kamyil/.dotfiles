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
    {
      nixosConfigurations.malinka = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          disko.nixosModules.disko
          ./hardware.nix
          ./disko.nix
          ./configuration.nix
        ];
      };
    };
}
