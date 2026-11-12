# Periodically commit and sync ~/second-brain with its Git upstream (Malinka).
# The script stays live-editable in scripts/; only the timers live here.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  script = "${config.home.homeDirectory}/.dotfiles/scripts/second-brain-sync.sh";
  intervalSeconds = 600;
in
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isDarwin {
    launchd.agents.second-brain-sync = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          script
        ];
        # Nix git, then the system ssh (/usr/bin) with its Keychain integration.
        EnvironmentVariables.PATH = "${
          lib.makeBinPath [
            pkgs.git
            pkgs.coreutils
          ]
        }:/usr/bin:/bin";
        RunAtLoad = true;
        StartInterval = intervalSeconds;
        ProcessType = "Background";
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/second-brain-sync.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/second-brain-sync.log";
      };
    };
  })

  (lib.mkIf pkgs.stdenv.isLinux {
    systemd.user.services.second-brain-sync = {
      Unit.Description = "Commit and sync ~/second-brain with its Git upstream";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash ${script}";
        Environment = [
          "PATH=${
            lib.makeBinPath [
              pkgs.git
              pkgs.openssh
              pkgs.coreutils
              pkgs.libnotify
            ]
          }"
        ];
      };
    };

    systemd.user.timers.second-brain-sync = {
      Unit.Description = "Sync ~/second-brain every ${toString (intervalSeconds / 60)} minutes";
      Timer = {
        OnStartupSec = "2min";
        OnUnitActiveSec = "${toString intervalSeconds}s";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  })
]
