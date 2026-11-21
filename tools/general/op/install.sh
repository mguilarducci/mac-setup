#!/usr/bin/env bash
#
# Installs the 1Password CLI (op) via Homebrew and, optionally, adds an `op`
# shell function to ~/.zshrc that injects a service account token stored in
# the macOS Keychain.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

ZSHRC="$HOME/.zshrc"
MARKER="# >>> op service account >>>"
END_MARKER="# <<< op service account <<<"

require_brew

echo "Installing 1Password CLI..."
brew install --cask 1password-cli

# Prompts need a terminal; skip the optional step when there is none
# (e.g. the bootstrap was piped from curl without a TTY).
if ! { exec 3< /dev/tty; } 2> /dev/null; then
  echo "No terminal available; skipping service account setup."
  exit 0
fi

if grep -qF "$MARKER" "$ZSHRC" 2> /dev/null; then
  echo "Service account function already in $ZSHRC; skipping."
  exit 0
fi

read -r -u 3 -p "Keychain item name of the service account token (empty to skip): " service
if [ -z "$service" ]; then
  echo "Skipping service account setup."
  exit 0
fi

{
  echo
  echo "$MARKER"
  echo "# Runs op with the service account token from the Keychain. If the item is"
  echo "# missing, falls back to a plain op. Use \`command op\` to bypass it."
  echo "op() {"
  echo "  local token"
  echo "  if token=\"\$(security find-generic-password -a \"\$USER\" -s '$service' -w 2> /dev/null)\"; then"
  echo "    OP_SERVICE_ACCOUNT_TOKEN=\"\$token\" command op \"\$@\""
  echo "  else"
  echo "    command op \"\$@\""
  echo "  fi"
  echo "}"
  echo "$END_MARKER"
} >> "$ZSHRC"

echo "Added op() to $ZSHRC. Store the token with:"
echo "  security add-generic-password -U -a \"\$USER\" -s '$service' -w"
