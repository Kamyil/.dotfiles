# Shared Home Manager configuration for macOS and NixOS.
{ ... }:

{
  imports = [
    ./home/links.nix
    ./home/packages.nix
    ./home/shell.nix
  ];

  home.username = "kamil";
  home.stateVersion = "24.11";
  home.sessionVariables.PI_FFF_MODE = "override";

  programs.home-manager.enable = true;
}
