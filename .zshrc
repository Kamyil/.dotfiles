# Starship is now managed by Nix Home Manager
# eval "$(starship init zsh)"
DISABLE_AUTO_UPDATE=true
export MANPAGER="nvim -c 'Man!' -"

export DISABLE_AUTO_TITLE=true


# export ZSH=$HOME/.oh-my-zsh export WEZTERM_CONFIG_FILE=$HOME/.config/wezterm/init.lua

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# Preferred editor for local and remote sessions
#
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Set config directory for macOS
export XDG_CONFIG_HOME="$HOME/.config"



# set the Catppuccin theme for `fzf` command
#
# --color=bg:-1,bg:-1,spinner:#f5e0dc,hl:#f5c2e7 \
# --color=fg:-1,bg:-1,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
# --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f5c2e7 \
#
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
# display hidden files, and exclude the '.git' directory.
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

# Use powerline
USE_POWERLINE="true"
# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration


# COWPATH="$COWPATH:$HOME/.cowsay/cowfiles"
# COWPATH="$COWPATH:$HOME/.cowsay/cowfiles"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#
# History related changes
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line
bindkey -M viins '^x^e' edit-command-line

weather() {
  curl "wttr.in/$1?lang=pl"
}

# (fuzzly) Search directory (and `cd` into it)
# Base directories to auto-discover projects from
SD_BASE_DIRS=(
  "$HOME/Work/Projects"
  "$HOME/Personal/Projects"
)
# Max depth for subdirectory traversal (1 = immediate children only)
SD_DEPTH=1

# (fuzzly) Config search base dirs
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
  for base in "${SD_BASE_DIRS[@]}"; do
    if [ -d "$base" ]; then
      while IFS= read -r dir; do
        dirs+=("$dir")
      done < <(find "$base" -mindepth 1 -maxdepth "$SD_DEPTH" -type d 2>/dev/null)
    fi
  done
  
  # Also include manually specified dirs if the files exist
  if [ -f "$HOME/.zsh_company_dirs" ]; then
    source "$HOME/.zsh_company_dirs"
    dirs+=("${COMPANY_DIRS[@]}")
  fi
  if [ -f "$HOME/.zsh_personal_dirs" ]; then
    source "$HOME/.zsh_personal_dirs"
    dirs+=("${PERSONAL_DIRS[@]}")
  fi
  
  local selected
  selected=$(printf '%s\n' "${dirs[@]}" | fzf)
  [ -n "$selected" ] && cd "$selected"
}

# (fuzzly) Search config directory and open nvim
c() {
  local dirs=()

  for base in "${C_BASE_DIRS[@]}"; do
    if [ -d "$base" ]; then
      dirs+=("$base")
      while IFS= read -r dir; do
        dirs+=("$dir")
      done < <(find "$base" -mindepth 1 -maxdepth "$C_DEPTH" -type d ! -name ".git" ! -path "*/.git/*" 2>/dev/null)
    fi
  done

  local selected
  selected=$(printf '%s\n' "${dirs[@]}" | fzf)
  [ -n "$selected" ] && nvim "$selected"
}

# (fuzzly) search ssh alias and ssh into
sshf() {
  # Parse ~/.ssh/config to get the hostnames defined in 'Host' lines
  local ssh_hosts=$(grep "^Host " ~/.ssh/config | awk '{print $2}')

  # Use fzf to select a host
  local selected_host=$(printf '%s\n' "${ssh_hosts[@]}" | fzf)

  # If a host is selected, run the ssh command
  if [[ -n $selected_host ]]; then
    ssh "$selected_host"
  fi
}

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

  # Open the mounted repo in Neovim
  nvim $mount_point

  # Unmount after Neovim is closed
  echo "Unmounting $remote_dir..."
  fusermount -u $mount_point
}

# (fuzzly) Search directory (and `cd` into it and run neovim on that directory)
sdn() {
  sd && nvim .
}

db() {
  # Load the db urls and their picker aliases from the file
  source "$HOME/.zsh_db_configs"

  # Get the key names from the array (only keys for selection)
  local config_keys=("${(k)DB_CONFIGS[@]}")

  # Use fzf to select a config alias key
  local selected_key=$(printf '%s\n' "${config_keys[@]}" | fzf)

  # If a key is selected, evaluate and run the associated command (the value from the key-value pair)
  if [[ -n $selected_key ]]; then
    eval "${DB_CONFIGS[$selected_key]}"
  fi
}

# Fuzzly search websites via alias and open them in default browser
work_sites() {
  # Load the aliases from the file
  source "$HOME/.zsh_company_websites"

  # Get the key names from the array (only keys for selection)
  local company_website_keys=("${(k)COMPANY_WEBSITES[@]}")

  # Use fzf to select an alias key
  local selected_key=$(printf '%s\n' "${company_website_keys[@]}" | fzf)

  # If a key is selected, evaluate and run the associated command (the value from the key-value pair)
  if [[ -n $selected_key ]]; then
    # on linux there is either xdg-open or sensible-browser
    open "${COMPANY_WEBSITES[$selected_key]}"
  fi
}

# (fuzzly) Find git branch and switch into it
switch_branch() {
  # Fetch them first
  git fetch -a
  # Use fzf to select a host
  local selected_branch=$(git branch --list | fzf)

  if [[ -n $selected_branch ]]; then
    git checkout "$selected_branch"
  fi
}

hisf() {
  local commands_history_entries=$(history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq)
  local selected_command_from_history=$(printf '%s\n' "${commands_history_entries[@]}" | fzf)

  # If a host is selected, run the ssh command
  if [[ -n $selected_command_from_history ]]; then
    eval "$selected_command_from_history"
  fi
}






killf() {
  ps aux | fzf --preview="" --prompt="Select process to kill: " | awk '{print $2}' | xargs -r kill -9
}






color_palette() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

sb() {
  cd ~/second-brain/ && nvim .
}

macos_copy_to_clipboard() {
  # $1 meaning path to the file
 pbcopy < $1
}

macos_set_proper_key_repeat() {
   defaults write -g KeyRepeat -int 1 && defaults write -g InitialKeyRepeat -int 10
}

# Other aliases
alias n="nvim ."
alias y="yazi ."
alias b="browser"
alias hf="his"
alias x="exit"
alias q="exit"
alias lg="lazygit"
alias ldk="lazydocker"
# alias lsql="~/lazysql_Darwin_arm64/lazysql"
alias ls="lsd"
alias finder="open"
alias grep="grep --color=auto"
alias reset_zsh="source ~/.zshrc"
alias clear_nvim_cache="rm -rf ~/.local/share/nvim"
alias cat='bat' 
alias jira="~/bin/jira"
alias serpl="~/bin/serpl"
alias json="fx"
alias doom="~/.config/emacs/bin/doom"
alias chsh="~/.local/scripts/tmux-cht/tmux-cht.sh"
alias private_gitignore="nvim .git/info/exclude"
alias git_log="serie"


# git aliases
alias gpom="git pull origin master"
alias gpod="git pull origin development"
alias gc="git checkout"
alias gcb="git checkout -b"
alias gags="git add . && git stash"
alias gsp="git stash pop"

# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# disable Brew auto updates
export HOMEBREW_NO_AUTO_UPDATE=1

# Only source if files exist (cross-platform compatibility)
[ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"
# turn fzf git on
[ -f "$HOME/.dotfiles/config/scripts/fzf-git.sh" ] && source "$HOME/.dotfiles/config/scripts/fzf-git.sh"
export BAT_THEME="Kanagawa"


# Maybe we can switch to it later
# eval "$(starship init zsh)"
#
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

ZVM_VI_HIGHLIGHT_BACKGROUND=#A33FC4         # Hex value
ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL

# Define colors
autoload -U colors && colors

# Enable vim mode
bindkey -v
export KEYTIMEOUT=1

function custom_keymap_select() {
	case $KEYMAP in
		vicmd) echo -ne '\e[1 q';; # block
		viins|main) echo -ne '\e[5 q';; # beam
	esac
}
zle -N zle-keymap-select custom_keymap_select

function zle-line-init() {
	zle -K viins
	echo -ne "\e[5 q"
}
zle -N zle-line-init

echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

## Init
setopt PROMPT_SUBST

# bun completions
# [ -s "/Users/kamil/.bun/_bun" ] && source "/Users/kamil/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PNPM_HOME="/Users/kamil/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
