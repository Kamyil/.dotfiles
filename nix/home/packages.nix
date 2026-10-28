# Packages used by the interactive user on both macOS and NixOS.
{
  pkgs,
  lib,
  fff,
  lazyjira,
  hunk,
  herdr,
  himalaya-tui,
  ...
}:

let
  tldrawOffline = pkgs.callPackage ../packages/tldraw-offline.nix { };
  diskonaut = pkgs.callPackage ../packages/diskonaut.nix { };
  slk = pkgs.callPackage ../packages/slk.nix { };
  # Godot 4 .NET projects. On macOS the godot-mono cask pulls in Homebrew's
  # dotnet-sdk, so Nix provides the SDK only on Linux to keep a single one.
  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0;
  cliampFixed =
    if pkgs.stdenv.isDarwin then
      pkgs.cliamp.overrideAttrs (oldAttrs: {
        preCheck = (oldAttrs.preCheck or "") + ''
          export TMPDIR=/tmp
        '';
      })
    else
      pkgs.cliamp;
in
{
  home.packages =
    with pkgs;
    [
      zennotes-desktop
      ripgrep
      codex
      diskonaut
      slk
      aerc
      neomutt
      w3m
      btop
      yazi
      gh
      railway
      curl
      wget
      tree
      fd
      openspec
      omp
      claude-code
      zsh-completions
      eza
      difftastic
      just
      nh
      nix-output-monitor
      jq
      yq
      lazygit
      lazydocker
      (oxker.overrideAttrs (_: {
        doCheck = false;
      }))
      gnugrep
      gnused
      coreutils
      bat
      delta
      fzf
      htop
      fastfetch
      pfetch
      unzip
      p7zip
      nmap
      socat
      wireguard-tools
      wireguard-go
      git-extras
      tig
      stow
      neovim
      zig
      stylua
      tree-sitter
      go
      yarn
      pnpm
      fnm
      wrangler
      lua
      luarocks
      lua-language-server
      python3
      php
      bun
      wireshark-cli
      ffmpeg
      yt-dlp
      postgresql
      cliampFixed
      helix
      superfile
      qemu
      libssh2
      alacritty
      wezterm
      kitty
      rsync
      openssh
      imagemagick
      tldr
      watchexec
      firefox
      dig
      roslyn-ls
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      qutebrowser
      beekeeper-studio
      sweethome3d.application
      obs-studio
      tldrawOffline
      # macOS gets the godot-mono Homebrew cask (not in the Darwin binary cache)
      godot-mono
      dotnetSdk
    ]
    ++ [
      fff.packages.${pkgs.stdenv.hostPlatform.system}.fff-mcp
      hunk.packages.${pkgs.stdenv.hostPlatform.system}.default
      lazyjira.packages.${pkgs.stdenv.hostPlatform.system}.default
      herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      himalaya-tui.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  home.sessionVariables =
    if pkgs.stdenv.isDarwin then
      {
        DOTNET_ROOT = "/usr/local/share/dotnet";
        # Godot MCP only auto-detects the non-.NET Godot.app
        GODOT_PATH = "/Applications/Godot_mono.app/Contents/MacOS/Godot";
      }
    else
      {
        DOTNET_ROOT = "${dotnetSdk}/share/dotnet";
        GODOT_PATH = lib.getExe pkgs.godot-mono;
      };
}
