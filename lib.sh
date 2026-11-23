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

USE_GUM=false
ACCENT=212 # pink

# Switches logging to gum when it is available and we are on a terminal.
# Commands still print straight to the terminal: gum only styles our messages.
enable_gum() {
  if [ -t 1 ] && command -v gum > /dev/null; then
    USE_GUM=true
  fi
}

section() {
  if $USE_GUM; then
    echo
    gum style --bold --foreground "$ACCENT" "==> $1"
  else
    printf '\n%s==> %s%s\n' "$BOLD$BLUE" "$1" "$RESET"
  fi
}

step() {
  if $USE_GUM; then
    echo "  $(gum style --foreground 4 '→') $1"
  else
    printf '  %s→%s %s\n' "$BLUE" "$RESET" "$1"
  fi
}

ok() {
  if $USE_GUM; then
    echo "  $(gum style --foreground 2 '✓') $1"
  else
    printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"
  fi
}

skip() {
  if $USE_GUM; then
    gum style --faint "  • $1"
  else
    printf '  %s•%s %s%s%s\n' "$DIM" "$RESET" "$DIM" "$1" "$RESET"
  fi
}

note() {
  if $USE_GUM; then
    gum style --foreground 3 "  ! $1"
  else
    printf '  %s!%s %s%s%s\n' "$YELLOW" "$RESET" "$YELLOW" "$1" "$RESET"
  fi
}

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
  if $USE_GUM; then
    echo
    gum style --bold --foreground 2 "Done. Open a new terminal to load the changes."
    return
  fi
  printf '\n%sDone.%s Open a new terminal to load the changes.\n' "$BOLD$GREEN" "$RESET"
}
