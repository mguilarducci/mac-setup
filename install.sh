#!/usr/bin/env bash
#
# Sets up a new Mac. Asks before installing each item. Safe to run more than
# once.

set -euo pipefail

ZPROFILE="$HOME/.zprofile"
ZSHRC="$HOME/.zshrc"
BREW_BIN="/opt/homebrew/bin/brew"

# Appends a line to a file unless it is already there.
add_line() {
  grep -qxF "$2" "$1" 2> /dev/null || echo "$2" >> "$1"
}

# Asks a [Y/n] question. Returns 0 for yes (default), 1 for no.
confirm() {
  local answer
  read -r -p "$1 [Y/n] " answer < /dev/tty
  case "$answer" in
    [nN] | [nN][oO]) return 1 ;;
    *) return 0 ;;
  esac
}

# ---------------------------------------------------------------------------
# Shell PATH
# ---------------------------------------------------------------------------
# Some tools install into ~/.local/bin, which is not on the PATH by default.
add_line "$ZPROFILE" 'export PATH="$HOME/.local/bin:$PATH"'
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# Homebrew (required by everything below)
# ---------------------------------------------------------------------------
if ! command -v brew > /dev/null && [ ! -x "$BREW_BIN" ]; then
  if ! confirm "Install Homebrew? Everything else needs it."; then
    echo "Homebrew is required. Stopping."
    exit 1
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
add_line "$ZPROFILE" "eval \"\$($BREW_BIN shellenv zsh)\""
eval "$("$BREW_BIN" shellenv bash)"

# ---------------------------------------------------------------------------
# GitHub CLI
# ---------------------------------------------------------------------------
if confirm "Install GitHub CLI?"; then
  brew install gh
fi

# ---------------------------------------------------------------------------
# Coding tools
# ---------------------------------------------------------------------------
if confirm "Install Claude Code?"; then
  brew install --cask claude-code
fi

if confirm "Install Codex?"; then
  brew install --cask codex
fi

if confirm "Install Docker Desktop?"; then
  brew install --cask docker-desktop
  echo "Open Docker Desktop once to accept the license: open -a Docker"
fi

if confirm "Install Herdr?"; then
  brew install --cask herdr-app
fi

# ---------------------------------------------------------------------------
# 1Password CLI
# ---------------------------------------------------------------------------
if confirm "Install 1Password CLI?"; then
  brew install --cask 1password-cli

  # op-sa <keychain-item> <op args...> runs op with a service account token
  # read from the Keychain. The plain `op` command is left untouched.
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
fi

# ---------------------------------------------------------------------------
# Fonts
# ---------------------------------------------------------------------------
if confirm "Install JetBrains Mono Nerd Font?"; then
  brew install --cask font-jetbrains-mono-nerd-font
  echo "Select \"JetBrainsMono Nerd Font\" in your terminal's font settings."
fi

# ---------------------------------------------------------------------------
# Starship prompt (looks best with the Nerd Font above)
# ---------------------------------------------------------------------------
if confirm "Install Starship?"; then
  brew install starship
  add_line "$ZSHRC" 'eval "$(starship init zsh)"'
fi

echo
echo "Done. Open a new terminal to load the changes."
