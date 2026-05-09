# Docker
alias dockerkillall='docker kill (docker ps -q)'
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n"; and docker rm (docker ps -a -q)'
alias dockercleani='printf "\n>>> Deleting untagged images\n\n"; and docker rmi (docker images -q -f dangling=true)'
alias dockerclean='dockercleanc; or true; and dockercleani'

# Git
abbr -a g git

# Bundler
alias b="bundle"
alias bi="b install --jobs=2"
alias be="b exec"
alias bo="b open"
alias bu="b update"

# Elixir / Phoenix
alias ixs="iex -S mix phx.server"

# Unix
alias ll="ls -al"
alias ln="ln -v"
alias mkdir="mkdir -p"
alias e="code -w"
alias v="code -w"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=auto"

# Pretty print the PATH
function path
    for p in $PATH
        echo $p
    end
end
