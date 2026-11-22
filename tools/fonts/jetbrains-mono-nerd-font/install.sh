#!/usr/bin/env bash
#
# Installs JetBrains Mono Nerd Font via Homebrew. Prompts like Starship
# need a Nerd Font to render their icons.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

require_brew

echo "Installing JetBrains Mono Nerd Font..."
brew install --cask font-jetbrains-mono-nerd-font
echo "Select \"JetBrainsMono Nerd Font\" in your terminal's font settings."
