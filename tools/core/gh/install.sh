#!/usr/bin/env bash
#
# Installs the GitHub CLI (gh) via Homebrew.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

require_brew

echo "Installing GitHub CLI (gh)..."
brew install gh
