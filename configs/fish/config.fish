# Add Homebrew to PATH (must come first)
fish_add_path /opt/homebrew/bin

# Disable greeting
set -g fish_greeting

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

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
