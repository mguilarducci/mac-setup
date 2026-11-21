#!/usr/bin/env bash
#
# Installs Claude Code via Homebrew.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

require_brew

echo "Installing Claude Code..."
brew install --cask claude-code
