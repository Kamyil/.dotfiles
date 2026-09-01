{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-linux";

  # Phase 0: prove that System Manager can manage Malinka without touching any
  # existing service. We intentionally start with one harmless CLI package.
  environment.systemPackages = with pkgs; [
    btop
  ];
}
