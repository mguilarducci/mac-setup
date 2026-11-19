#!/usr/bin/env bash
#
# Installs hc using the official install script and adds its install
# directory (~/.local/bin) to the PATH in ~/.zprofile.

set -euo pipefail

ZPROFILE="$HOME/.zprofile"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

echo "Installing hc..."
curl -fsSL https://releases.herdr.dev/core/install.sh | sh

if ! grep -qxF "$PATH_LINE" "$ZPROFILE" 2> /dev/null; then
  echo >> "$ZPROFILE"
  echo "$PATH_LINE" >> "$ZPROFILE"
  echo "Added ~/.local/bin to PATH in $ZPROFILE."
fi
