
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

[ -z "$PS1" ] && return

autoload -Uz compinit
compinit
source ~/.zplugin.zsh

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile
fi
