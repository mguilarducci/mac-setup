#!/usr/bin/env bash
#
# Installs Codex via Homebrew.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

require_brew

echo "Installing Codex..."
brew install --cask codex
