# Login shell setup. Sourced from ~/.zprofile by mac-setup's install.sh.

# Some tools install into ~/.local/bin, which is not on the PATH by default.
export PATH="$HOME/.local/bin:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
