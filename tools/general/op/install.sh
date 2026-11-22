#!/usr/bin/env bash
#
# Installs the 1Password CLI (op) via Homebrew and adds an `op-sa`
# shell function to ~/.zshrc that injects a service account token read from
# a macOS Keychain item whose name is passed as a parameter.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../lib/common.sh"

ZSHRC="$HOME/.zshrc"
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
  echo "# Runs op with a service account token read from the Keychain item given as"
  echo "# the first argument: op-sa <keychain-item> <op args...>. The plain \`op\`"
  echo "# command is left untouched."
  echo "op-sa() {"
  echo "  if [ \$# -lt 1 ]; then"
  echo "    echo \"Usage: op-sa <keychain-item> [op args...]\" >&2"
  echo "    return 1"
  echo "  fi"
  echo "  local item=\"\$1\" token"
  echo "  shift"
  echo "  token=\"\$(security find-generic-password -a \"\$USER\" -s \"\$item\" -w)\" || return"
  echo "  OP_SERVICE_ACCOUNT_TOKEN=\"\$token\" command op \"\$@\""
  echo "}"
  echo "$END_MARKER"
} >> "$ZSHRC"

echo "Added op-sa() to $ZSHRC. Store a token with:"
echo "  security add-generic-password -U -a \"\$USER\" -s <keychain-item> -w"
echo "Then use it: op-sa <keychain-item> vault list"
