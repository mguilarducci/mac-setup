#!/usr/bin/env bash
#
# Installs Homebrew using the official install script and optionally
# configures the shell (zsh) to use it.

set -euo pipefail

INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
BREW_BIN="/opt/homebrew/bin/brew"
ZPROFILE="$HOME/.zprofile"

# Ask a [Y/n] question. Returns 0 for yes (default), 1 for no.
confirm() {
  local answer
  read -r -p "$1 [Y/n] " answer
  case "$answer" in
    [nN] | [nN][oO]) return 1 ;;
    *) return 0 ;;
  esac
}

echo "Checking Homebrew install script at $INSTALL_URL..."
if ! curl -fsSLI "$INSTALL_URL" > /dev/null; then
  echo "Error: Homebrew install script not found at $INSTALL_URL." >&2
  echo "Check https://brew.sh for the current install command." >&2
  exit 1
fi
echo "Install script found."

if confirm "Proceed with the Homebrew installation?"; then
  /bin/bash -c "$(curl -fsSL "$INSTALL_URL")"
else
  echo "Installation skipped."
  exit 0
fi

if confirm "Add Homebrew to your shell environment ($ZPROFILE)?"; then
  echo >> "$ZPROFILE"
  echo 'eval "$('"$BREW_BIN"' shellenv zsh)"' >> "$ZPROFILE"
  eval "$("$BREW_BIN" shellenv zsh)"
  # shellcheck disable=SC1090
  source "$ZPROFILE"
  echo "Homebrew enabled. Open a new terminal or run: source $ZPROFILE"
else
  echo "Skipped shell configuration."
fi
