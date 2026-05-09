# Disable greeting
set -g fish_greeting

# Asdf integration (legacy shell-based versions)
if test -f $HOME/.asdf/asdf.fish
    source $HOME/.asdf/asdf.fish
end

# Autojump
if test -f /opt/homebrew/share/autojump/autojump.fish
    source /opt/homebrew/share/autojump/autojump.fish
else if test -f /usr/local/share/autojump/autojump.fish
    source /usr/local/share/autojump/autojump.fish
end
