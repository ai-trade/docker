source ~/.zplugin/bin/zplugin.zsh

if [[ -r "~/.cache/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "~/.cache/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zinit ice depth=1
zinit light romkatv/powerlevel10k

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

zinit ice wait lucid
zinit light skywind3000/z.lua

export FZ_HISTORY_CD_CMD=_zlua
zinit ice wait lucid
zinit light changyuheng/fz

zinit ice wait lucid
zinit light changyuheng/zsh-interactive-cd

zinit ice wait lucid
zinit light zdharma/fast-syntax-highlighting

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light zdharma/history-search-multi-word

zinit ice wait lucid as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras

bindkey "^A" vi-beginning-of-line
bindkey "^E" vi-end-of-line



