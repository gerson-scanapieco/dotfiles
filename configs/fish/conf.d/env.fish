# Editor
set -gx BUNDLER_EDITOR code
set -gx GEM_EDITOR code
set -gx EDITOR "code -w"
set -gx VISUAL "code -w"

# Erlang/Elixir shell history
set -gx ERL_AFLAGS "-kernel shell_history enabled"

# Path additions
fish_add_path /usr/local/sbin
