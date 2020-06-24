source  /etc/profile
export PATH="$HOME/.bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
. $HOME/.asdf/asdf.sh
if [ -f ~/.py3/bin/activate ]; then
export VIRTUAL_ENV_DISABLE_PROMPT=yes
source ~/.py3/bin/activate
fi
export TERM=xterm-256color
