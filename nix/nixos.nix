# NixOS-specific configuration.
{
  nixpkgs,
  home-manager,
  disko,
  rust-overlay,
  lib,
  sqlit,
  worktrunk,
  lazyjira,
  hunk,
  lumen,
  herdr,
  ...
}:

let
  system = "x86_64-linux";
in
{
  nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      {
        nixpkgs.overlays = [ rust-overlay.overlays.default ];
      }
      disko.nixosModules.disko
      ../nixos/disk-config.nix
      ../nixos/configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit
            system
            worktrunk
            lazyjira
            hunk
            lumen
            herdr
            ;
        };

        home-manager.users.kamil = { pkgs, ... }: {
          imports = [ ./shared.nix ];

          home.homeDirectory = lib.mkForce "/home/kamil";
          home.enableNixpkgsReleaseCheck = false;

          home.packages =
            (with pkgs; [
              gcc
              nixd
              trash-cli
              docker-buildx
              docker-compose
              flameshot
              swappy
              chromium
              thunderbird
              signal-desktop
              obsidian
              sshfs
              impala
              bluetuith
              hyprlock
              capitaine-cursors
              nerd-fonts.jetbrains-mono
              lexend
              kmonad
              opencode
              (rust-bin.nightly.latest.default.override {
                extensions = [
                  "rust-src"
                  "cargo"
                  "rustc"
                ];
              })
            ])
            ++ [
              sqlit.packages.${system}.default
              worktrunk.packages.${system}.default
              lumen.packages.${system}.default
            ];

          programs.zsh.shellAliases = {
            finder = "xdg-open";
            nrs = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix";
          };

          programs.zsh.initContent = lib.mkAfter ''
            open_url() {
              xdg-open "$@"
            }

            unmount_sshfs() {
              fusermount -u "$1"
            }
          '';

          home.sessionVariables = {
            PNPM_HOME = "$HOME/.local/share/pnpm";
            XCURSOR_THEME = "capitaine-cursors";
            XCURSOR_SIZE = "24";
            HYPRCURSOR_THEME = "capitaine-cursors";
            HYPRCURSOR_SIZE = "24";
            OMARCHY_PATH = "$HOME/.local/share/omarchy";
          };

          home.sessionPath = [
            "$HOME/.local/share/pnpm"
            "$HOME/.local/share/omarchy/bin"
          ];

          home.file = {
            "second-brain/.keep".text = "";
            ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
            ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
          };

          fonts.fontconfig.enable = true;

          gtk = {
            enable = true;
            cursorTheme = {
              package = pkgs.capitaine-cursors;
              name = "capitaine-cursors";
              size = 24;
            };
          };

          xdg.enable = true;

          systemd.user.services.kmonad = {
            Unit = {
              Description = "kmonad keyboard remapping daemon";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${pkgs.kmonad}/bin/kmonad %h/.config/kmonad/config.kbd";
              Restart = "on-failure";
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };
        };
      }
    ];
  };
}
