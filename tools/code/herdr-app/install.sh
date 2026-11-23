#!/usr/bin/env bash
#
# Installs the Herdr desktop app via Homebrew. The cask only supports Apple
# silicon.
#
# See https://herdr.dev/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

require_brew

if [ "$(uname -m)" != "arm64" ]; then
  echo "Error: Herdr requires Apple silicon." >&2
  exit 1
fi

echo "Installing Herdr..."
brew install --cask herdr-app
