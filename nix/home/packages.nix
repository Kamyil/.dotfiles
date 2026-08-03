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
in
{
  home.packages =
    with pkgs;
    [
      ripgrep
      diskonaut
      slk
      aerc
      neomutt
      w3m
      btop
      yazi
      tmux
      gh
      railway
      curl
      wget
      tree
      fd
      openspec
      omp
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
      podman
      podman-compose
      ffmpeg
      openai-whisper
      postgresql
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
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      qutebrowser
      sweethome3d.application
      kooha
      gpu-screen-recorder-gtk
      tldrawOffline
    ]
    ++ [
      fff.packages.${pkgs.stdenv.hostPlatform.system}.fff-mcp
      hunk.packages.${pkgs.stdenv.hostPlatform.system}.default
      lazyjira.packages.${pkgs.stdenv.hostPlatform.system}.default
      herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      himalaya-tui.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
