{
  nixpkgs,
  nixos-anywhere,
  bundle,
  origin,
  branch,
  vault,
}:

let
  system = "x86_64-linux";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    (
      { pkgs, ... }:
      {
        image.fileName = "kamil-nixos-installer-${nixpkgs.lib.substring 0 8 (builtins.hashFile "sha256" bundle)}.iso";
        isoImage.volumeID = "KAMIL_NIXOS";

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        networking.networkmanager.enable = true;

        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "prohibit-password";
            PasswordAuthentication = false;
          };
        };

        environment.systemPackages = with pkgs; [
          age
          gawk
          git
          gnutar
          networkmanager
          openssh
          python3
          util-linux
          nixos-anywhere.packages.${system}.default
        ];

        environment.etc = {
          "nixos-installer/dotfiles.bundle".source = bundle;
          "nixos-installer/origin-url".source = origin;
          "nixos-installer/branch".source = branch;
          "nixos-installer/private-vault.age" = {
            source = vault;
            mode = "0600";
          };
          "nixos-installer/install" = {
            source = ../scripts/install-nixos-usb.sh;
            mode = "0755";
          };
        };

        systemd.services.nixos-usb-installer = {
          description = "Guided NixOS USB installer";
          wantedBy = [ "multi-user.target" ];
          after = [
            "network.target"
            "sshd.service"
          ];
          conflicts = [ "getty@tty1.service" ];
          serviceConfig = {
            Type = "idle";
            ExecStart = "/etc/nixos-installer/install";
            StandardInput = "tty-force";
            StandardOutput = "tty";
            StandardError = "tty";
            TTYPath = "/dev/tty1";
            TTYReset = true;
            TTYVHangup = true;
            Restart = "no";
          };
        };
      }
    )
  ];
}
