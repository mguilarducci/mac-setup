#!/usr/bin/env bash
#
# Installs the GitHub CLI (gh) via Homebrew.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/../homebrew/verify.sh"

echo "Installing GitHub CLI (gh)..."
brew install gh
