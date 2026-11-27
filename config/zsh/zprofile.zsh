# Login shell setup. Sourced from ~/.zprofile by mac-setup's install.sh.

# Some tools install into ~/.local/bin, and cargo into ~/.cargo/bin. Neither
# is on the PATH by default.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
