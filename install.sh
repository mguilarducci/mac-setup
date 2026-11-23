#!/usr/bin/env bash
#
# Sets up a new Mac. Safe to run more than once.

set -euo pipefail

ZPROFILE="$HOME/.zprofile"
ZSHRC="$HOME/.zshrc"
BREW_BIN="/opt/homebrew/bin/brew"

# Appends a line to a file unless it is already there.
add_line() {
  grep -qxF "$2" "$1" 2> /dev/null || echo "$2" >> "$1"
}

# ---------------------------------------------------------------------------
# Shell PATH
# ---------------------------------------------------------------------------
# Some tools install into ~/.local/bin, which is not on the PATH by default.
add_line "$ZPROFILE" 'export PATH="$HOME/.local/bin:$PATH"'
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
if ! command -v brew > /dev/null && [ ! -x "$BREW_BIN" ]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
add_line "$ZPROFILE" "eval \"\$($BREW_BIN shellenv zsh)\""
eval "$("$BREW_BIN" shellenv bash)"

# ---------------------------------------------------------------------------
# GitHub CLI
# ---------------------------------------------------------------------------
echo "Installing GitHub CLI..."
brew install gh

# ---------------------------------------------------------------------------
# Coding tools
# ---------------------------------------------------------------------------
echo "Installing Claude Code..."
brew install --cask claude-code

echo "Installing Codex..."
brew install --cask codex

echo "Installing Docker Desktop..."
brew install --cask docker-desktop
echo "Open Docker Desktop once to accept the license: open -a Docker"

echo "Installing Herdr..."
brew install --cask herdr-app

# ---------------------------------------------------------------------------
# 1Password CLI
# ---------------------------------------------------------------------------
echo "Installing 1Password CLI..."
brew install --cask 1password-cli

# op-sa <keychain-item> <op args...> runs op with a service account token read
# from the Keychain. The plain `op` command is left untouched.
if ! grep -qF "# >>> op service account >>>" "$ZSHRC" 2> /dev/null; then
  cat >> "$ZSHRC" << 'EOF'

# >>> op service account >>>
op-sa() {
  if [ $# -lt 1 ]; then
    echo "Usage: op-sa <keychain-item> [op args...]" >&2
    return 1
  fi
  local item="$1" token
  shift
  token="$(security find-generic-password -a "$USER" -s "$item" -w)" || return
  OP_SERVICE_ACCOUNT_TOKEN="$token" command op "$@"
}
# <<< op service account <<<
EOF
  echo "Added op-sa() to $ZSHRC. Store a token with:"
  echo "  security add-generic-password -U -a \"\$USER\" -s <keychain-item> -w"
fi

# ---------------------------------------------------------------------------
# Fonts
# ---------------------------------------------------------------------------
echo "Installing JetBrains Mono Nerd Font..."
brew install --cask font-jetbrains-mono-nerd-font
echo "Select \"JetBrainsMono Nerd Font\" in your terminal's font settings."

# ---------------------------------------------------------------------------
# Starship prompt (needs the Nerd Font above)
# ---------------------------------------------------------------------------
echo "Installing Starship..."
brew install starship
add_line "$ZSHRC" 'eval "$(starship init zsh)"'

echo
echo "Done. Open a new terminal to load the changes."
