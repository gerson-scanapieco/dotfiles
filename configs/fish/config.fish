# Disable greeting
set -g fish_greeting

# Asdf shims (asdf v0.16+ is Go-based; just needs shims on PATH)
if test -d $HOME/.asdf/shims
    fish_add_path -p $HOME/.asdf/shims
end

# Autojump
if test -f /opt/homebrew/share/autojump/autojump.fish
    source /opt/homebrew/share/autojump/autojump.fish
else if test -f /usr/local/share/autojump/autojump.fish
    source /usr/local/share/autojump/autojump.fish
end
