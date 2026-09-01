{
  description = "Malinka — Raspberry Pi OS managed with Nix System Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { system-manager, ... }:
    {
      systemConfigs.malinka = system-manager.lib.makeSystemConfig {
        modules = [ ./system.nix ];
      };
    };
}
