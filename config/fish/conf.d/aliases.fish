# Docker
alias dockerkillall='docker kill (docker ps -q)'
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n"; and docker rm (docker ps -a -q)'
alias dockercleani='printf "\n>>> Deleting untagged images\n\n"; and docker rmi (docker images -q -f dangling=true)'
alias dockerclean='dockercleanc; or true; and dockercleani'

# Git
abbr -a g git

# Git worktrees: wt new <branch> | wt rm <name> | wt ls
function wt
    set -l cmd $argv[1]
    set -e argv[1]

    set -l common (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or begin
        echo "wt: not in a git repository" >&2
        return 1
    end

    set -l root
    if test (basename $common) = .bare
        set root (dirname $common)
    else
        set root (dirname (git rev-parse --show-toplevel))
    end

    switch "$cmd"
        case new
            if test (count $argv) -ne 1
                echo "usage: wt new <branch>" >&2
                return 1
            end
            set -l dir $root/(string replace -a / - $argv[1])
            git worktree add -b $argv[1] $dir; and cd $dir
        case rm
            if test (count $argv) -ne 1
                echo "usage: wt rm <name>" >&2
                return 1
            end
            set -l dir $root/$argv[1]
            git -C $common worktree remove $dir
            and if string match -q "$dir*" $PWD
                cd $root
            end
        case ls
            git worktree list
        case '*'
            echo "usage: wt new <branch> | wt rm <name> | wt ls" >&2
            return 1
    end
end

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

# yazi: cd to the directory yazi was in on exit
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end
