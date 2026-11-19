#!/usr/bin/env bash
#
# Installs the GitHub CLI (gh) via Homebrew.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/../helpers/verify-homebrew.sh"

brew install gh
