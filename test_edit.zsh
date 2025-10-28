#!/bin/zsh
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^o' edit-command-line
bindkey -M viins '^o' edit-command-line

echo "Testing edit-command-line widget..."
bindkey -M viins | grep edit
bindkey -M vicmd | grep edit
