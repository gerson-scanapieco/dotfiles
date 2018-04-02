# Sublime as default editor.
export BUNDLER_EDITOR="subl"
export GEM_EDITOR="subl"
export EDITOR="subl -w"
export VISUAL="$EDITOR"

export HISTFILE="$HOME/.zsh_history"
export HISTCONTROL="ignoreboth:erasedups" # Erase duplicates in history
export HISTSIZE=10000 # Store 10k history entries

export PG_HOME="/usr/local/opt/postgresql@9.6"

export PATH="$PG_HOME/bin:$PATH"

if [ $ITERM_SESSION_ID ]; then
  export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";
fi
