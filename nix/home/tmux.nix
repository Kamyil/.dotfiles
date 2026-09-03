# Reproducible tmux configuration shared by NixOS and nix-darwin.
{ config, lib, pkgs, ... }:

let
  mkGithubPlugin = {
    name,
    version,
    owner,
    repo,
    rev,
    hash,
  }:
    pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = name;
      inherit version;
      src = pkgs.fetchFromGitHub {
        inherit owner repo rev hash;
      };
    };

  sessionx = mkGithubPlugin {
    name = "sessionx";
    version = "628575be60646f5712e4c8c2f76683b03b072515";
    owner = "omerxx";
    repo = "tmux-sessionx";
    rev = "628575be60646f5712e4c8c2f76683b03b072515";
    hash = "sha256-PwLydbmzS/YJqtMRpc19FpeJP3zfgzM8P14WYr2zdoA=";
  };

  nerdFontWindowName = mkGithubPlugin {
    name = "nerd-font-window-name";
    version = "f464c59e459d91d7b0db702e2f436475c4e9bf4f";
    owner = "joshmedeski";
    repo = "tmux-nerd-font-window-name";
    rev = "f464c59e459d91d7b0db702e2f436475c4e9bf4f";
    hash = "sha256-fsfhOmmAVwp/+kUcxi6ZvEfoNL1twJie8MhgNk/+UwE=";
  };

  memCpuLoad = mkGithubPlugin {
    name = "mem-cpu-load";
    version = "640eac30694c6a6f9d0303f2264de1e002db65be";
    owner = "thewtex";
    repo = "tmux-mem-cpu-load";
    rev = "640eac30694c6a6f9d0303f2264de1e002db65be";
    hash = "sha256-1yrwIOPphGn84I1tE50Dc44YixG+EoHJE4sQNjUioTE=";
  };

  gruvbox = mkGithubPlugin {
    name = "gruvbox";
    version = "c42019297da580017c0acc07a53b16de1660e3f6";
    owner = "adibhanna";
    repo = "gruvbox-tmux";
    rev = "c42019297da580017c0acc07a53b16de1660e3f6";
    hash = "sha256-VBnKRVPid8gK4xe0FzsCk6iYsfeYqp99n+guA/Ia+ms=";
  };
in
{
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    extraConfig = builtins.readFile ../../tmux/tmux.conf;

    plugins = [
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.resurrect
      sessionx
      nerdFontWindowName
      memCpuLoad
      pkgs.tmuxPlugins.continuum
      pkgs.tmuxPlugins.vim-tmux-navigator
      pkgs.tmuxPlugins.mode-indicator
      pkgs.tmuxPlugins.open
      pkgs.tmuxPlugins.tmux-floax
      gruvbox
    ];
  };

  # Replace the previous out-of-store tmux link before Home Manager creates
  # its generated configuration file.
  home.activation.migrateTmuxConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    target=${lib.escapeShellArg "${config.home.homeDirectory}/.config/tmux"}
    source=${lib.escapeShellArg "${config.home.homeDirectory}/.dotfiles/tmux"}
    if [ -L "$target" ]; then
      link_target="$(${pkgs.coreutils}/bin/readlink "$target")"
      case "$link_target" in
        "$source"|/nix/store/*-home-manager-files/.config/tmux) rm "$target" ;;
      esac
    fi

    if [ -L "$target/tmux.conf" ] && [ "$(${pkgs.coreutils}/bin/readlink "$target/tmux.conf")" = "$source/tmux.conf" ]; then
      rm "$target/tmux.conf"
    fi
  '';
}
