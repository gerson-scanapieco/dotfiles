# Docker
alias dockerkillall='docker kill (docker ps -q)'
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n"; and docker rm (docker ps -a -q)'
alias dockercleani='printf "\n>>> Deleting untagged images\n\n"; and docker rmi (docker images -q -f dangling=true)'
alias dockerclean='dockercleanc; or true; and dockercleani'

# Git
abbr -a g git

# Git worktrees: wt new [--no-hooks] <branch> | wt rm [--no-hooks] <name> | wt ls
# Per-project hooks live in the worktree's tracked .wt/ dir: post-new, pre-rm, post-rm
function __wt_hook --argument-names hook script cwd root branch dir
    test -x $script; or return 0
    WT_HOOK=$hook WT_ROOT=$root WT_BRANCH=$branch WT_DIR=$dir \
        command sh -c 'cd "$1" && exec "$2"' sh $cwd $script
    or begin
        echo "wt: $hook hook failed" >&2
        return 1
    end
end

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
            argparse no-hooks -- $argv; or return 1
            if test (count $argv) -ne 1
                echo "usage: wt new [--no-hooks] <branch>" >&2
                return 1
            end
            set -l branch $argv[1]
            set -l dir $root/(string replace -a / - $branch)
            git worktree add -b $branch $dir; or return 1
            cd $dir
            set -q _flag_no_hooks
            or __wt_hook post-new $dir/.wt/post-new $dir $root $branch $dir
        case rm
            argparse no-hooks -- $argv; or return 1
            if test (count $argv) -ne 1
                echo "usage: wt rm [--no-hooks] <name>" >&2
                return 1
            end
            set -l dir $root/$argv[1]
            set -l branch (git -C $dir branch --show-current 2>/dev/null)
            set -l post

            if not set -q _flag_no_hooks
                __wt_hook pre-rm $dir/.wt/pre-rm $dir $root $branch $dir; or return 1
                if test -x $dir/.wt/post-rm
                    set post (mktemp)
                    cp $dir/.wt/post-rm $post; and chmod +x $post
                end
            end

            git -C $common worktree remove $dir
            or begin
                test -n "$post"; and rm -f $post
                return 1
            end
            if string match -q "$dir*" $PWD
                cd $root
            end

            if test -n "$post"
                __wt_hook post-rm $post $root $root $branch $dir
                rm -f $post
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
