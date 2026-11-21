#!/usr/bin/env bash
#
# Installs the 1Password CLI (op) via Homebrew.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

require_brew

echo "Installing 1Password CLI..."
brew install --cask 1password-cli
