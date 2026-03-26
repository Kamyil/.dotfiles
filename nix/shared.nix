# Shared configuration between macOS and NixOS systems
{ pkgs, config, lib, ... }:

let
  repo = "${config.home.homeDirectory}/.dotfiles";
  link = p: config.lib.file.mkOutOfStoreSymlink "${repo}/${p}";
in
{
  home.username = "kamil";
  home.stateVersion = "24.11";

  # Common shell aliases across both systems
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    shellAliases = {
      n = "nvim .";
      y = "yazi .";
      b = "browser";
      hf = "his";
      x = "exit";
      q = "exit";
      lg = "lazygit";
      ldk = "lazydocker";
      ls = "eza --no-filesize --long --color=always --icons=always --no-user";
      lt = "eza --git --color=always --icons --tree";
      finder = "open";
      grep = "grep --color=auto";
      reset_zsh = "source ~/.zshrc";
      clear_nvim_cache = "rm -rf ~/.local/share/nvim";
      cat = "bat";
      jira = "~/bin/jira";
      serpl = "~/bin/serpl";
      json = "fx";
      doom = "~/.config/emacs/bin/doom";
      chsh = "~/.local/scripts/tmux-cht/tmux-cht.sh";
      setup = "~/.dotfiles/config/scripts/tmux-setup-session";
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

      # FZF configuration
      export FZF_DEFAULT_OPTS=" \
      --multi \
      --height=50% \
      --margin=5%,2%,2%,5% \
      --layout=reverse-list \
      --border=double \
      --info=inline \
      --prompt='$>' \
      --pointer='→' \
      --marker='♡' \
      --color=bg:-1,bg:-1,spinner:#f5e0dc,hl:#7AA89F \
      --color=fg:-1,bg:-1,header:#DCD7BA,info:#7AA89F,pointer:#f5e0dc \
      --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#7AA89F,hl+:#7AA89F \
      --header='CTRL-c or ESC to quit' \
      --preview 'bat --style=numbers --color=always --line-range :500 {}' \
      --height 70% --layout reverse --border top"
      export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

      # Node and package managers
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"

       # Homebrew
       export HOMEBREW_NO_AUTO_UPDATE=1

       # Docker BuildKit
       export DOCKER_BUILDKIT=1

      # Bat theme
      export BAT_THEME="Kanagawa"

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
        "$HOME/.dotfiles/config"
        "$HOME/.dotfiles"
      )
      # Max depth for config traversal (1 = immediate children only)
      C_DEPTH=1

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

      # Search config directory and open nvim
      c() {
        local dirs=()

        for base in "''${C_BASE_DIRS[@]}"; do
          if [ -d "$base" ]; then
            dirs+=("$base")
            while IFS= read -r dir; do
              dirs+=("$dir")
            done < <(find "$base" -mindepth 1 -maxdepth "$C_DEPTH" -type d ! -name ".git" ! -path "*/.git/*" 2>/dev/null)
          fi
        done

        local selected
        selected=$(printf '%s\n' "''${dirs[@]}" | fzf)
        [ -n "$selected" ] && nvim "$selected"
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
        local ssh_alias=$(awk '/^Host / {print $2}' ~/.ssh/config | fzf)
        if [ -z "$ssh_alias" ]; then
          echo "No alias selected!"
          return 1
        fi
        local remote_base_path="/"
        local remote_dir=$(ssh $ssh_alias "find $remote_base_path -maxdepth 1 -type d" | fzf)
        if [ -z "$remote_dir" ]; then
          echo "No directory selected!"
          return 1
        fi
        local mount_point="$HOME/remote-repos/$ssh_alias"
        mkdir -p $mount_point
        echo "Mounting $remote_dir..."
        sshfs -F ~/.ssh/config $ssh_alias:$remote_dir $mount_point
        echo "Attaching to Docker container..."
        ssh $ssh_alias "cd $remote_dir && docker-compose exec app bash"
        nvim $mount_point
        echo "Unmounting $remote_dir..."
        fusermount -u $mount_point
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
          open "''${COMPANY_WEBSITES[$selected_key]}"
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

      # macOS clipboard copy
      macos_copy_to_clipboard() {
        pbcopy < $1
      }

      # macOS key repeat settings
      macos_set_proper_key_repeat() {
        defaults write -g KeyRepeat -int 1 && defaults write -g InitialKeyRepeat -int 10
      }

      # Source external files if they exist
      [ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"
      [ -f "$HOME/.dotfiles/config/scripts/fzf-git.sh" ] && source "$HOME/.dotfiles/config/scripts/fzf-git.sh"

      # Enable colors and prompt substitution
      autoload -U colors && colors
      setopt PROMPT_SUBST

      # Set up fzf key bindings and fuzzy completion
      eval "$(fzf --zsh)"

      # Optional machine-local overrides (not tracked in git)
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
    '';
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file = {
    ".config/starship.toml".source = link "starship/starship.toml";
    ".config/superfile".source = link "config/superfile";
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Kamil Ksen";
      user.email = "mccom_kks@mccom.pl";
      core.editor = "nvim";
      init.defaultBranch = "main";
    };
  };

  # Common packages shared between macOS and NixOS
  home.packages = with pkgs; [
    # Terminal tools
    ripgrep btop yazi tmux

    # Shell and CLI utilities
    gh railway curl wget tree fd
    eza difftastic just jq yq lazygit lazydocker

    # Text processing and search
    gnugrep gnused coreutils bat delta fzf

    # System monitoring
    htop fastfetch pfetch neofetch

    # File and archive tools
    unzip p7zip

    # Network tools
    nmap socat wireguard-tools wireguard-go

    # Database tools
    sqlite

    # Version control
    git-extras tig

    # System utilities
    stow

    # Programming tools
    zig stylua tree-sitter

    # File sync
    rsync openssh

    # Other
    tldr watchexec

	qutebrowser
  ];

  programs.home-manager.enable = true;
}
