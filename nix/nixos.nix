# NixOS-specific configuration.
{
  nixpkgs,
  home-manager,
  disko,
  rust-overlay,
  fff,
  nix-index-database,
  sops-nix,
  lib,
  sqlit,
  worktrunk,
  lazyjira,
  hunk,
  lumen,
  herdr,
  himalaya-tui,
  helium,
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
      helium.nixosModules.default
      ../nixos/disk-config.nix
      ../nixos/configuration.nix
      sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
      {
        programs.helium = {
          enable = true;

          flags = [
            "--start-maximized"
            "--load-extension=${../helium-theme},/home/kamil/.dotfiles/helium-focus"
          ];

          policies = {
            DeveloperToolsAvailability = 1;
            ExtensionInstallForcelist = [
              "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
              "gfbliohnnapiefjpjlpjnehglfpaknnc" # Surfingkeys
              "oboonakemofpalcgghocfoadofidjkkk" # KeePassXC-Browser
              "epamlgdeklcjkldoaclgjdmjnchdgbho" # Time Snatch
            ];
            WebAppInstallForceList = [
              {
                url = "https://chatgpt.com/";
                default_launch_container = "window";
                create_desktop_shortcut = true;
              }
              {
                url = "https://app.todoist.com/";
                default_launch_container = "window";
                create_desktop_shortcut = true;
              }
            ];
            SpellcheckEnabled = true;
            SpellcheckLanguage = [ "en-US" ];
          };
        };
      }
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [
          nix-index-database.homeModules.default
          sops-nix.homeManagerModules.sops
        ];
        home-manager.extraSpecialArgs = {
          inherit
            system
            fff
            worktrunk
            lazyjira
            hunk
            lumen
            herdr
            himalaya-tui
            ;
        };

        home-manager.users.kamil = { lib, pkgs, ... }: {
          imports = [ ./shared.nix ];

          home.homeDirectory = lib.mkForce "/home/kamil";
          home.enableNixpkgsReleaseCheck = false;

          home.packages =
            (with pkgs; [
              gcc
              nixd
              nodejs_22
              trash-cli
              docker-buildx
              docker-compose
              satty
              chromium
              thunar
              ffmpegthumbnailer
              imv
              mpv
              thunderbird
              signal-desktop
              spotify
              obsidian
              sshfs
              easyeffects
              impala
              bluetuith
              hyprlock
              fuzzel
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
              (pkgs.callPackage ./packages/parakeet-transcribe.nix { })
              (pkgs.callPackage ./packages/omasnap.nix { })
              sqlit.packages.${system}.default
              worktrunk.packages.${system}.default
              lumen.packages.${system}.default
            ];

          programs.zsh.shellAliases = {
            finder = "thunar";
            nrs = "nh os switch ~/.dotfiles/nix";
            transcribe = "parakeet-transcribe";
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
            "$HOME/.cache/.bun/bin"
          ];

          # Preserve user-managed browser and mail associations while enforcing
          # media defaults. Declarative mimeApps would clobber the existing file.
          home.activation.mediaMimeDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            ${pkgs.xdg-utils}/bin/xdg-mime default imv.desktop image/avif
            ${pkgs.xdg-utils}/bin/xdg-mime default imv.desktop image/bmp
            ${pkgs.xdg-utils}/bin/xdg-mime default imv.desktop image/gif
            ${pkgs.xdg-utils}/bin/xdg-mime default imv.desktop image/jpeg
            ${pkgs.xdg-utils}/bin/xdg-mime default imv.desktop image/png
            ${pkgs.xdg-utils}/bin/xdg-mime default imv.desktop image/svg+xml
            ${pkgs.xdg-utils}/bin/xdg-mime default imv.desktop image/tiff
            ${pkgs.xdg-utils}/bin/xdg-mime default imv.desktop image/webp
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/mp2t
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/mp4
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/mpeg
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/ogg
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/quicktime
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/webm
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/x-flv
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/x-matroska
            ${pkgs.xdg-utils}/bin/xdg-mime default mpv.desktop video/x-msvideo
          '';

          home.file = {
            "second-brain/.keep".text = "";
            ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
            ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
            ".config/chromium/NativeMessagingHosts/dev.quickshell.focus.json".text = builtins.toJSON {
              name = "dev.quickshell.focus";
              description = "Quickshell focus mode state bridge";
              path = "/home/kamil/.config/quickshell/focus-control.py";
              type = "stdio";
              allowed_origins = [ "chrome-extension://fohieaiappjfaccidjdfjpdcbdjebmna/" ];
            };
            ".config/net.imput.helium/NativeMessagingHosts/dev.quickshell.focus.json".text = builtins.toJSON {
              name = "dev.quickshell.focus";
              description = "Quickshell focus mode state bridge";
              path = "/home/kamil/.config/quickshell/focus-control.py";
              type = "stdio";
              allowed_origins = [ "chrome-extension://fohieaiappjfaccidjdfjpdcbdjebmna/" ];
            };
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

          systemd.user.services.easyeffects = {
            Unit = {
              Description = "EasyEffects global audio processing";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
              Restart = "on-failure";
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };

          systemd.user.services.wifi-notifications = {
            Unit = {
              Description = "Wi-Fi state notifications";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "%h/.config/quickshell/wifi-notify.sh";
              Restart = "always";
              RestartSec = 2;
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };

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
