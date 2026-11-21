#!/usr/bin/env bash
#
# Installs Homebrew using the official install script and optionally
# configures the shell (zsh) to use it.

set -euo pipefail

INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
BREW_BIN="/opt/homebrew/bin/brew"
ZPROFILE="$HOME/.zprofile"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

if require_brew > /dev/null 2>&1; then
  read -r -p "Homebrew is already installed. Reinstall? [y/N] " answer
  case "$answer" in
    [yY] | [yY][eE][sS]) ;;
    *)
      echo "Skipping Homebrew installation."
      exit 0
      ;;
  esac
fi

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
  echo "Homebrew enabled."
else
  echo "Skipped shell configuration."
fi
