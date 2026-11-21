#!/usr/bin/env bash
#
# Installs Codex via Homebrew.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/../../core/homebrew/verify.sh"

echo "Installing Codex..."
brew install --cask codex
