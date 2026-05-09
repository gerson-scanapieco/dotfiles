# Add Homebrew to PATH (must come first)
fish_add_path /opt/homebrew/bin

# Disable greeting
set -g fish_greeting

# Asdf shims (asdf v0.16+ is Go-based; just needs shims on PATH)
if test -d $HOME/.asdf/shims
    fish_add_path -p $HOME/.asdf/shims
end

if status is-interactive
    # Zoxide
    if command -q zoxide
        zoxide init fish | source
    end

    # Fzf keybindings and fuzzy completion
    if command -q fzf
        fzf --fish | source
    end

    # Direnv
    if command -q direnv
        direnv hook fish | source
    end

    # Starship prompt
    if command -q starship
        starship init fish | source
    end
end
