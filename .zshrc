source "$HOME/.slimzsh/slim.zsh"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# Set config directory for macOS
export XDG_CONFIG_HOME="$HOME/.config"
# Use powerline
USE_POWERLINE="true"
# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration

export OPENAI_API_KEY='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'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Aliases
alias sd="cd ~/Work/ && cd \$(find * -type d | fzf)"
alias n="nvim ."
alias lg="lazygit"
alias ls="exa"
# Colorful grep output
alias grep="grep --color=auto"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# It's a bad idea really... terminal can autocrash on init with this 
# when such thing happens, then good luck with fast disabling it
# if [[ ! $TERM =~ screen ]]; then
#     exec tmux
# fi
##

source /Users/kamil/.config/broot/launcher/bash/br

BAT_THEME="Catppuccin-mocha"
# BAT_THEME="ansi"
# Catpuccin fzf (fuzzy-finder)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
