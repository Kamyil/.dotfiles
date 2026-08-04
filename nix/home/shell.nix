# Shared shell, prompt, history, and Git configuration.
{
  pkgs,
  config,
  lib,
  herdr,
  ...
}:

let
  mkGeneratedZshCompletionPlugin =
    {
      name,
      package,
      bin ? lib.getExe package,
      args ? [
        "completion"
        "zsh"
      ],
    }:
    {
      name = "${name}-completions";
      src = pkgs.runCommand "${name}-zsh-completions" { } ''
        mkdir -p "$out"
        ${lib.escapeShellArgs ([ bin ] ++ args)} > "$out/_${name}"
      '';
      file = "_${name}";
    };

  mkZshInitScript =
    {
      name,
      package,
      args,
    }:
    pkgs.runCommand "${name}-zsh-init" { } ''
      export HOME="$TMPDIR"
      export XDG_CONFIG_HOME="$TMPDIR/.config"
      ${lib.escapeShellArgs ([ (lib.getExe package) ] ++ args)} > "$out"
    '';

  fzfZshInit = mkZshInitScript {
    name = "fzf";
    package = pkgs.fzf;
    args = [ "--zsh" ];
  };

  starshipZshInit = mkZshInitScript {
    name = "starship";
    package = pkgs.starship;
    args = [
      "init"
      "zsh"
    ];
  };

  atuinZshInit = mkZshInitScript {
    name = "atuin";
    package = pkgs.atuin;
    args = [
      "init"
      "zsh"
    ];
  };

  herdrPackage = herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;

in
{

  # Common shell aliases across both systems
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    completionInit = ''
      autoload -U compinit
      _zcompdump="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
      if [[ -s "$_zcompdump" && "$_zcompdump" -nt "$HOME/.zshrc" ]]; then
        compinit -C -d "$_zcompdump"
      else
        [[ -d "''${_zcompdump:h}" ]] || mkdir -p "''${_zcompdump:h}"
        compinit -d "$_zcompdump"
        zcompile "$_zcompdump"
      fi
      unset _zcompdump
    '';
    dotDir = config.home.homeDirectory;

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      (mkGeneratedZshCompletionPlugin {
        name = "herdr";
        package = herdrPackage;
      })
    ];


    # History configuration
    history = {
      size = 999;
      save = 1000;
      path = "$HOME/.zhistory";
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    initContent = ''
      # Disable auto update and title
      DISABLE_AUTO_UPDATE=true
      export DISABLE_AUTO_TITLE=true
      export MANPAGER="nvim -c 'Man!' -"

      # Editor configuration
      if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='vim'
      else
        export EDITOR='nvim'
      fi

      # XDG config directory
      export XDG_CONFIG_HOME="$HOME/.config"

      # Live-editable shell code. These files are sourced from the checkout,
      # so aliases and functions change without a Home Manager rebuild.
      source "$HOME/.dotfiles/zsh/aliases.zsh"
      source "$HOME/.dotfiles/zsh/functions.zsh"
      export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

      # fnm owns interactive Node.js versions on both platforms.
      if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd)"
      fi

       # Docker BuildKit
       export DOCKER_BUILDKIT=1

      # ANSI output follows the active terminal palette.
      export BAT_THEME="ansi"

      # Vi mode and key bindings
      export KEYTIMEOUT=1
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      bindkey -M viins '^P' up-line-or-beginning-search
      bindkey -M viins '^N' down-line-or-beginning-search

      # Edit command line in $EDITOR
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd 'v' edit-command-line
      bindkey -M viins '^x^e' edit-command-line

      # ZVM configuration
      ZVM_VI_HIGHLIGHT_BACKGROUND=#A33FC4
      ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
      ZVM_CURSOR_STYLE_ENABLED=true
      # Too-small timeout breaks multi-key motions like ci"/di".
      ZVM_KEYTIMEOUT=0.4


      # Powerline settings
      USE_POWERLINE="true"
      HAS_WIDECHARS="false"


      # Source external files if they exist
      [ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"
      [ -f "$HOME/.dotfiles/scripts/fzf-git.sh" ] && source "$HOME/.dotfiles/scripts/fzf-git.sh"

      # Enable colors and prompt substitution
      autoload -U colors && colors
      setopt PROMPT_SUBST


      # Set up fzf key bindings and fuzzy completion
      source ${fzfZshInit}

      # Completion UX
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' squeeze-slashes true
      if [[ -n "''${LS_COLORS:-}" ]]; then
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      fi

      # Static init output is generated once by Nix instead of forking on every shell.
      if [[ $TERM != dumb ]]; then
        source ${starshipZshInit}
      fi

      if [[ -o zle ]]; then
        source ${atuinZshInit}
      fi

      # Optional machine-local overrides (not tracked in git)
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
    '';
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = false;
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
  };

  home.activation.buildBatThemeCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.bat}/bin/bat cache --build
  '';

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Kamil Ksen";
      user.email = "mccom_kks@mccom.pl";
      core.editor = "nvim";
      core.pager = "hunk pager";
      include.path = "~/.local/state/dotfiles-theme/current/delta.gitconfig";
      delta.line-numbers = true;
      init.defaultBranch = "main";
    };
  };

}
