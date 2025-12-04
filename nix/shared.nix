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

    shellAliases = {
      n = "nvim .";
      y = "yazi .";
      b = "browser";
      c = "config";
      hf = "his";
      x = "exit";
      q = "exit";
      lg = "lazygit";
      ldk = "lazydocker";
      ls = "lsd";
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
      private_gitignore = "nvim .git/info/exclude";
      git_log = "serie";

      # Git aliases
      gpom = "git pull origin master";
      gpod = "git pull origin development";
      gc = "git checkout";
      gcb = "git checkout -b";
      gags = "git add . && git stash";
      gsp = "git stash pop";
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

      # Bat theme
      export BAT_THEME="gruvbox-dark"

      # Vi mode and key bindings
      bindkey -v
      export KEYTIMEOUT=1
      export VI_MODE_SET_CURSOR=true
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward

      # ZVM configuration
      ZVM_VI_HIGHLIGHT_BACKGROUND=#A33FC4
      ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL

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

      # Directory search and navigation
      # Base directories to auto-discover projects from
      SD_BASE_DIRS=(
        "$HOME/Work/Projects"
        "$HOME/Personal/Projects"
      )
      # Max depth for subdirectory traversal (1 = immediate children only)
      SD_DEPTH=1

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

      # Config search
      config() {
        source "$HOME/.zsh_config_aliases"
        local config_keys=("''${(k)CONFIG_ALIASES[@]}")
        local selected_key=$(printf '%s\n' "''${config_keys[@]}" | fzf)
        if [[ -n $selected_key ]]; then
          eval "''${CONFIG_ALIASES[$selected_key]}"
        fi
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
    '';
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$character";
      directory = {
        style = "#7B958E";  # muted teal-green
        format = "[$path]($style) ";
      };
      git_branch = {
        style = "#958294";  # muted purple-grey
        format = "on [$symbol$branch]($style) ";
      };
      character = {
        success_symbol = "[➜](#7B9A5B)";  # muted green with similar saturation
        error_symbol = "[➜](#A95B58)";    # muted red-brown
      };
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Kamil Ksen";
    userEmail = "mccom_kks@mccom.pl";
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
    };
  };

  # Core packages available on both systems
  home.packages = with pkgs; [
    # Terminal tools
    fzf bat delta lazygit lazydocker
  ];

  programs.home-manager.enable = true;
}