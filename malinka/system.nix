{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-linux";

  # Bootstrap phase: System Manager must not touch any existing Malinka
  # service yet. Start with one harmless package to validate the workflow.
  environment.systemPackages = with pkgs; [
    btop
  ];
}
