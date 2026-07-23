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

    shellAliases = {
      n = "nvim .";
      y = "yazi .";
      x = "exit";
      o = "omp";
      oc = "opencode";
      lg = "lazygit";
      ldk = "lazydocker";
      ls = "eza --no-filesize --long --color=always --icons=always --no-user";
      lt = "eza --git --color=always --icons --tree";
      grep = "grep --color=auto";
      reset_zsh = "source ~/.zshrc";
      clear_nvim_cache = "rm -rf ~/.local/share/nvim";
      cat = "bat";
      jira = "~/bin/jira";
      serpl = "~/bin/serpl";
      doom = "~/.config/emacs/bin/doom";
      private_gitignore = "nvim .git/info/exclude";
      git_log = "serie";
      spf = "command spf --config-file ~/.config/superfile/config.toml --hotkey-file ~/.config/superfile/hotkeys.toml";
      superfile = "command spf --config-file ~/.config/superfile/config.toml --hotkey-file ~/.config/superfile/hotkeys.toml";

      # Git aliases
      gpom = "git pull origin master";
      gpod = "git pull origin development";
      gc = "git checkout";
      gcb = "git checkout -b";
      gags = "git add . && git stash";
      gsp = "git stash pop";

      # WireGuard helpers (pass interface name, e.g. wgu myvpn)
      wgs = "sudo wg show";
    };

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

      # Cross-tool theme state. `theme toggle` updates this shell immediately;
      # other open shells can run `theme current` to reload their environment.
      _dotfiles_theme_load() {
        local state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
        if [[ ! -r "$state_dir/current/theme.zsh" ]]; then
          command "$HOME/.dotfiles/scripts/theme" kanagawa-paper >/dev/null
        fi
        source "$state_dir/current/theme.zsh"
        export FZF_DEFAULT_OPTS=" \
        --multi \
        --height=70% \
        --margin=5%,2%,2%,5% \
        --layout=reverse \
        --border=top \
        --info=inline \
        --prompt='$>' \
        --pointer='→' \
        --marker='♡' \
        --header='CTRL-c or ESC to quit' \
        --preview 'bat --style=numbers --color=always --line-range :500 {}' \
        $FZF_THEME_OPTS"
        export FZF_POKKE_OPTS="$FZF_THEME_OPTS"
      }
      theme() {
        command "$HOME/.dotfiles/scripts/theme" "''${1:-toggle}" || return
        _dotfiles_theme_load
      }
      _dotfiles_theme_load
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

      # FZF completion helper
      _fzf_comprun() {
        local command=$1
        shift
        case "$command" in
          cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
          *)            fzf "$@" ;;
        esac
      }

      # Powerline settings
      USE_POWERLINE="true"
      HAS_WIDECHARS="false"

      # Weather function
      weather() {
        curl "wttr.in/$1?lang=pl"
      }

      unalias wgu wgd wgs 2>/dev/null

      wgu() {
        local iface="$1"

        if [[ -z "$iface" ]]; then
          if command -v fzf >/dev/null 2>&1; then
            iface=$(ls /etc/wireguard/*.conf(/N:t:r) /usr/local/etc/wireguard/*.conf(/N:t:r) 2>/dev/null | sort -u | fzf --prompt='WireGuard up > ')
          else
            echo "Usage: wgu <interface>"
            echo "Example: wgu myvpn"
            return 1
          fi
        fi

        [[ -z "$iface" ]] && return 1
        sudo WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up "$iface"
      }

      wgd() {
        local iface="$1"

        if [[ -z "$iface" ]]; then
          if command -v fzf >/dev/null 2>&1; then
            iface=$(ls /etc/wireguard/*.conf(/N:t:r) /usr/local/etc/wireguard/*.conf(/N:t:r) 2>/dev/null | sort -u | fzf --prompt='WireGuard down > ')
          else
            echo "Usage: wgd <interface>"
            echo "Example: wgd myvpn"
            return 1
          fi
        fi

        [[ -z "$iface" ]] && return 1
        sudo WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick down "$iface"
      }

      # Directory search and navigation
      # Base directories to auto-discover projects from
      SD_BASE_DIRS=(
        "$HOME/Work/Projects"
        "$HOME/Personal/Projects"
      )
      # Max depth for subdirectory traversal (1 = immediate children only)
      SD_DEPTH=1

      # Config search base dirs
      C_BASE_DIRS=(
        "$HOME/.dotfiles"
      )

      unalias c 2>/dev/null

      sd() {
        local dirs=()
        
        # Auto-discover directories from base paths
        for base in "''${SD_BASE_DIRS[@]}"; do
          if [ -d "$base" ]; then
            while IFS= read -r dir; do
              dirs+=("$dir")
            done < <(find "$base" -mindepth 1 -maxdepth "$SD_DEPTH" -type d 2>/dev/null)
          fi
        done
        
        # Also include manually specified dirs if the files exist
        if [ -f "$HOME/.zsh_company_dirs" ]; then
          source "$HOME/.zsh_company_dirs"
          dirs+=("''${COMPANY_DIRS[@]}")
        fi
        if [ -f "$HOME/.zsh_personal_dirs" ]; then
          source "$HOME/.zsh_personal_dirs"
          dirs+=("''${PERSONAL_DIRS[@]}")
        fi
        
        local selected
        selected=$(printf '%s\n' "''${dirs[@]}" | fzf)
        [ -n "$selected" ] && cd "$selected"
      }

      # Search config files with a cached file list for instant startup
      C_CACHE_FILE="$HOME/.cache/dotfiles-config-files"

      c() {
        local cache="''${C_CACHE_FILE}"
        local cache_dir="''${cache:h}"
        mkdir -p "$cache_dir"

        refresh_cache() {
          local tmp="''${cache}.tmp.$$"
          : > "$tmp" || return 1
          for base in "''${C_BASE_DIRS[@]}"; do
            [ -d "$base" ] || continue
            find "$base" -type f ! -path '*/.git/*' ! -path '*/target/*' >> "$tmp" 2>/dev/null
          done
          mv "$tmp" "$cache"
        }

        if [[ ! -s "$cache" ]]; then
          refresh_cache || return 1
        else
          refresh_cache &
        fi

        local selected
        selected=$(fzf < "$cache")
        [ -n "$selected" ] || return 0
        [ -f "$selected" ] || {
          echo "Selected file no longer exists: $selected" >&2
          return 1
        }
        cd "$(dirname "$selected")" || return
        nvim "$(basename "$selected")"
      }

      # SSH fuzzy search
      sshf() {
        local ssh_hosts=$(grep "^Host " ~/.ssh/config | awk '{print $2}')
        local selected_host=$(printf '%s\n' "''${ssh_hosts[@]}" | fzf)
        if [[ -n $selected_host ]]; then
          ssh "$selected_host"
        fi
      }

      # Remote SSHFS mount
      remote_sshfs() {
        local ssh_alias
        ssh_alias=$(awk '/^Host / {print $2}' "$HOME/.ssh/config" | fzf)
        if [ -z "$ssh_alias" ]; then
          echo "No alias selected!"
          return 1
        fi

        local remote_dir
        remote_dir=$(ssh "$ssh_alias" "find / -maxdepth 1 -type d" | fzf)
        if [ -z "$remote_dir" ]; then
          echo "No directory selected!"
          return 1
        fi

        local mount_point="$HOME/remote-repos/$ssh_alias"
        mkdir -p "$mount_point"
        echo "Mounting $remote_dir..."
        sshfs -F "$HOME/.ssh/config" "$ssh_alias:$remote_dir" "$mount_point"
        echo "Attaching to Docker container..."
        ssh "$ssh_alias" "cd ''${(q)remote_dir} && docker compose exec app bash"
        nvim "$mount_point"
        echo "Unmounting $remote_dir..."
        unmount_sshfs "$mount_point"
      }

      # Search directory and open nvim
      sdn() {
        sd && nvim .
      }

      # Search directory and open opencode
      sdo() {
        sd && opencode
      }

      # Database search
      db() {
        source "$HOME/.zsh_db_configs"
        local config_keys=("''${(k)DB_CONFIGS[@]}")
        local selected_key=$(printf '%s\n' "''${config_keys[@]}" | fzf)
        if [[ -n $selected_key ]]; then
          eval "''${DB_CONFIGS[$selected_key]}"
        fi
      }

      # Work sites browser
      work_sites() {
        source "$HOME/.zsh_company_websites"
        local company_website_keys=("''${(k)COMPANY_WEBSITES[@]}")
        local selected_key=$(printf '%s\n' "''${company_website_keys[@]}" | fzf)
        if [[ -n $selected_key ]]; then
          open_url "''${COMPANY_WEBSITES[$selected_key]}"
        fi
      }

      # Git branch switcher
      switch_branch() {
        git fetch -a
        local selected_branch=$(git branch --list | fzf)
        if [[ -n $selected_branch ]]; then
          git checkout "$selected_branch"
        fi
      }

      # History fuzzy search
      hisf() {
        local commands_history_entries=$(history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq)
        local selected_command_from_history=$(printf '%s\n' "''${commands_history_entries[@]}" | fzf)
        if [[ -n $selected_command_from_history ]]; then
          eval "$selected_command_from_history"
        fi
      }

      # Process killer
      killf() {
        ps aux | fzf --preview="" --prompt="Select process to kill: " | awk '{print $2}' | xargs -r kill -9
      }

      # Color palette display
      color_palette() {
        for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}''${(l:3::0:)i}%f " ''${''${(M)$((i%6)):#3}:+$'\n'}; done
      }

      # Second brain shortcut
      sb() {
        cd ~/second-brain/ && nvim .
      }


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

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Kamil Ksen";
      user.email = "mccom_kks@mccom.pl";
      core.editor = "nvim";
      core.pager = "hunk pager";
      init.defaultBranch = "main";
    };
  };

}
