#!/usr/bin/env bash
#
# Logging and install helpers used by install.sh. Meant to be sourced.

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  BOLD=$'\033[1m' DIM=$'\033[2m' BLUE=$'\033[34m' GREEN=$'\033[32m' YELLOW=$'\033[33m' RESET=$'\033[0m'
else
  BOLD="" DIM="" BLUE="" GREEN="" YELLOW="" RESET=""
fi

section() { printf '\n%s==> %s%s\n' "$BOLD$BLUE" "$1" "$RESET"; }
step() { printf '  %s→%s %s\n' "$BLUE" "$RESET" "$1"; }
ok() { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
skip() { printf '  %s•%s %s%s%s\n' "$DIM" "$RESET" "$DIM" "$1" "$RESET"; }
note() { printf '  %s!%s %s%s%s\n' "$YELLOW" "$RESET" "$YELLOW" "$1" "$RESET"; }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
# Appends a line to a file unless it is already there.
add_line() {
  if grep -qxF "$2" "$1" 2> /dev/null; then
    skip "Already in $1: $2"
  else
    echo "$2" >> "$1"
    ok "Added to $1: $2"
  fi
}

# install_formula <formula> <name>
install_formula() {
  local formula="$1" name="$2"
  if brew list --formula "$formula" &> /dev/null; then
    skip "$name is already installed"
    return
  fi
  step "Installing $name..."
  brew install "$formula"
  ok "$name installed"
}

# install_cask <cask> <name> [App.app]
# When an app name is given and that app is already in /Applications but was
# not installed by Homebrew (e.g. downloaded from the website), the cask is
# skipped; otherwise brew would fail because the app already exists.
install_cask() {
  local cask="$1" name="$2" app="${3:-}"
  if brew list --cask "$cask" &> /dev/null; then
    skip "$name is already installed"
    return
  fi
  if [ -n "$app" ] && [ -d "/Applications/$app" ]; then
    skip "$name is already in /Applications/$app (installed outside Homebrew)"
    return
  fi
  step "Installing $name..."
  brew install --cask "$cask"
  ok "$name installed"
}

finish() {
  printf '\n%sDone.%s Open a new terminal to load the changes.\n' "$BOLD$GREEN" "$RESET"
}
