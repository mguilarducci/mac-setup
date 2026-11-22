#!/usr/bin/env bash
#
# Installs the Starship prompt via Homebrew and optionally enables it
# in zsh (~/.zshrc). Requires a Nerd Font, so it installs JetBrains Mono
# Nerd Font first if missing.

set -euo pipefail

ZSHRC="$HOME/.zshrc"
INIT_LINE='eval "$(starship init zsh)"'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

require_brew

if ! brew list --cask font-jetbrains-mono-nerd-font > /dev/null 2>&1; then
  bash "$SCRIPT_DIR/../../fonts/jetbrains-mono-nerd-font/install.sh"
fi

echo "Installing Starship..."
brew install starship

if grep -qxF "$INIT_LINE" "$ZSHRC" 2> /dev/null; then
  echo "Starship is already enabled in $ZSHRC."
elif confirm "Enable Starship in your shell ($ZSHRC)?"; then
  echo >> "$ZSHRC"
  echo "$INIT_LINE" >> "$ZSHRC"
  echo "Starship enabled. Open a new terminal to see it."
else
  echo "Skipped shell configuration."
fi
