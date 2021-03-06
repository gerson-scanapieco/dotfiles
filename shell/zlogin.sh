eval "$(rbenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Keep shell history for erlang/elixir
export ERL_AFLAGS="-kernel shell_history enabled"

PATH=$PATH:/usr/local/sbin