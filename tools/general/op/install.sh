#!/usr/bin/env bash
#
# Installs the 1Password CLI (op) via Homebrew and adds an `op`
# shell function to ~/.zshrc that injects a service account token stored in
# the macOS Keychain.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

ZSHRC="$HOME/.zshrc"
KEYCHAIN_ITEM="macmini-op-cli"
MARKER="# >>> op service account >>>"
END_MARKER="# <<< op service account <<<"

require_brew

echo "Installing 1Password CLI..."
brew install --cask 1password-cli

if grep -qF "$MARKER" "$ZSHRC" 2> /dev/null; then
  echo "Service account function already in $ZSHRC; skipping."
  exit 0
fi

{
  echo
  echo "$MARKER"
  echo "# Runs op with the service account token from the Keychain. If the item is"
  echo "# missing, falls back to a plain op. Use \`command op\` to bypass it."
  echo "op() {"
  echo "  local token"
  echo "  if token=\"\$(security find-generic-password -a \"\$USER\" -s '$KEYCHAIN_ITEM' -w 2> /dev/null)\"; then"
  echo "    OP_SERVICE_ACCOUNT_TOKEN=\"\$token\" command op \"\$@\""
  echo "  else"
  echo "    command op \"\$@\""
  echo "  fi"
  echo "}"
  echo "$END_MARKER"
} >> "$ZSHRC"

echo "Added op() to $ZSHRC. Store the token with:"
echo "  security add-generic-password -U -a \"\$USER\" -s '$KEYCHAIN_ITEM' -w"
