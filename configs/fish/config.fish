# Disable greeting
set -g fish_greeting

# Asdf shims (asdf v0.16+ is Go-based; just needs shims on PATH)
if test -d $HOME/.asdf/shims
    fish_add_path -p $HOME/.asdf/shims
end

# Zoxide
if command -q zoxide
    zoxide init fish | source
end

# Fzf keybindings and fuzzy completion
if command -q fzf
    fzf --fish | source
end
