#!/usr/bin/env bash
#
# Installs Claude Code via Homebrew.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/../../core/homebrew/verify.sh"

echo "Installing Claude Code..."
brew install --cask claude-code
