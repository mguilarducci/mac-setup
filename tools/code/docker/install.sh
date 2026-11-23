#!/usr/bin/env bash
#
# Installs Docker Desktop via Homebrew. On Apple silicon, optionally installs
# Rosetta 2, which Docker recommends for running amd64 tooling.
#
# See https://docs.docker.com/desktop/setup/install/mac-install/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

require_brew

if [ "$(uname -m)" = "arm64" ] && ! /usr/bin/pgrep -q oahd; then
  if confirm "Rosetta 2 is recommended for Docker on Apple silicon. Install it?"; then
    softwareupdate --install-rosetta --agree-to-license
  fi
fi

echo "Installing Docker Desktop..."
brew install --cask docker-desktop
echo "Open Docker Desktop once to accept the license and finish setup:"
echo "  open -a Docker"
