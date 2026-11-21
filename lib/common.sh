#!/usr/bin/env bash
#
# Shared helpers. Meant to be sourced, not executed.

# Returns an error if Homebrew is not installed.
require_brew() {
  if ! command -v brew > /dev/null; then
    echo "Error: Homebrew is not installed. Run tools/core/homebrew/install.sh first." >&2
    return 1
  fi
}

# Ask a [Y/n] question. Returns 0 for yes (default), 1 for no.
confirm() {
  local answer
  read -r -p "$1 [Y/n] " answer
  case "$answer" in
    [nN] | [nN][oO]) return 1 ;;
    *) return 0 ;;
  esac
}
