source "$HOME/.zsh_config_aliases"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

plugins=(git golang symfony node docker git-prompt history kitty macos npm nvm postgres rust ssh tmux vi-mode alias-finder git-extras safe-paste zsh-interactive-cd)
# Path to your Oh My Zsh installation.
#
export ZSH=$HOME/.oh-my-zsh
export WEZTERM_CONFIG_FILE=$HOME/.config/wezterm/init.lua

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH



# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Cool ones so far
# ZSH_THEME="dst"
# ZSH_THEME="muse"
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme 
ZSH_THEME=”powerlevel10k.powerlevel10k”

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

#ln -s ~/.dotfiles/nvim  Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.


zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Set config directory for macOS
export XDG_CONFIG_HOME="$HOME/.config"



# set the Catppuccin theme for `fzf` command
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
--header='CTRL-c or ESC to quit' \
--preview 'bat --style=numbers --color=always --line-range :500 {}' \
--color=bg:-1,bg:-1,spinner:#f5e0dc,hl:#f5c2e7 \
--color=fg:-1,bg:-1,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f5c2e7 \
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
COWPATH="$COWPATH:$HOME/.cowsay/cowfiles"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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

# (fuzzly) Search directory (and `cd` into it)
sd() {
  local dirs=()

  if [ -f "$HOME/.zsh_company_dirs" ]; then
    source "$HOME/.zsh_company_dirs"
    dirs+=("${COMPANY_DIRS[@]}") 
  fi

  if [ -f "$HOME/.zsh_personal_dirs" ]; then
    source "$HOME/.zsh_personal_dirs"
    dirs+=("${PERSONAL_DIRS[@]}")
  fi

  # Use process substitution to feed directory strings into fzf
  cd "$(printf '%s\n' "${dirs[@]}" | fzf)"
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

# (fuzzly) Search directory (and `cd` into it and run neovim on that directory)
sdn() {
  sd && nvim .
}

# Config search and run alias
config() {
  # Load the config aliases from the file
  source "$HOME/.zsh_config_aliases"

  # Get the key names from the array (only keys for selection)
  local config_keys=("${(k)CONFIG_ALIASES[@]}")

  # Use fzf to select a config alias key
  local selected_key=$(printf '%s\n' "${config_keys[@]}" | fzf)

  # If a key is selected, evaluate and run the associated command (the value from the key-value pair)
  if [[ -n $selected_key ]]; then
    eval "${CONFIG_ALIASES[$selected_key]}"
  fi
}

# Fuzzly search websites via alias and open them in default browser
browser() {
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

his() {
  local commands_history_entries=$(history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq)
  local selected_command_from_history=$(printf '%s\n' "${commands_history_entries[@]}" | fzf)

  # If a host is selected, run the ssh command
  if [[ -n $selected_command_from_history ]]; then
    eval "$selected_command_from_history"
  fi
}

gs() {
  git stash list | fzf
}

killf() {
  ps aux | fzf --preview 'echo {}' | awk '{print $2}' | xargs kill -9
}

color_palette() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

sb() {
  cd ~/second-brain/ && nvim .
}

# Other aliases
alias n="nvim ."
alias y="yazi ."
alias b="browser"
alias c="config"
alias hf="his"
alias x="exit"
alias q="exit"
alias lg="lazygit"
alias ldk="lazydocker"
alias lsql="~/lazysql_Darwin_arm64/lazysql"
alias ls="lsd"
alias finder="open"
alias grep="grep --color=auto"
alias reset_zsh="source ~/.zshrc"
alias cat='bat' 
alias jira="~/bin/jira"
alias serpl="~/bin/serpl"
alias json="fx"
alias doom="~/.config/emacs/bin/doom"
alias chsh="~/.local/scripts/tmux-cht/tmux-cht.sh"


export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# disable Brew auto updates
export HOMEBREW_NO_AUTO_UPDATE=1

source /Users/kamil/.config/broot/launcher/bash/br
export BAT_THEME="Catppuccin Mocha"


# Maybe we can switch to it later
# eval "$(starship init zsh)"
#
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# Setup "fuck" alias
eval $(thefuck --alias)

# Some python stuff
PATH=$(pyenv root)/shims:$PATH
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

ZVM_VI_HIGHLIGHT_BACKGROUND=#A33FC4         # Hex value
ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL

# Define colors
autoload -U colors && colors

# Enable vim mode
bindkey -v
export KEYTIMEOUT=1
export VI_MODE_SET_CURSOR=true
## Init
setopt PROMPT_SUBST

source $ZSH/oh-my-zsh.sh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
