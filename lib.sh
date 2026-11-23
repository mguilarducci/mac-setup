#!/usr/bin/env bash
#
# Logging and install helpers used by install.sh. Meant to be sourced.

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
# Plain ANSI output is used until gum is installed (right after Homebrew).
# From then on, section headers, spinners and banners render through gum.
if [ -t 1 ]; then
  BOLD=$'\033[1m' DIM=$'\033[2m' BLUE=$'\033[34m' GREEN=$'\033[32m' YELLOW=$'\033[33m' RESET=$'\033[0m'
else
  BOLD="" DIM="" BLUE="" GREEN="" YELLOW="" RESET=""
fi

USE_GUM=false
ACCENT=212 # pink

# Switches logging to gum when it is available and we are on a terminal.
enable_gum() {
  if [ -t 1 ] && command -v gum > /dev/null; then
    USE_GUM=true
  fi
}

section() {
  if $USE_GUM; then
    echo
    gum style --bold --foreground "$ACCENT" --border rounded \
      --border-foreground "$ACCENT" --padding "0 2" "$1"
  else
    printf '\n%s==> %s%s\n' "$BOLD$BLUE" "$1" "$RESET"
  fi
}

step() { printf '  %s→%s %s\n' "$BLUE" "$RESET" "$1"; }
ok() { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
skip() { printf '  %s•%s %s%s%s\n' "$DIM" "$RESET" "$DIM" "$1" "$RESET"; }
note() { printf '  %s!%s %s%s%s\n' "$YELLOW" "$RESET" "$YELLOW" "$1" "$RESET"; }

# spin <title> <command...> shows a spinner while the command runs. Its output
# is hidden unless it fails. Without gum, the command runs with normal output.
spin() {
  local title="$1"
  shift
  if $USE_GUM; then
    gum spin --spinner dot --spinner.foreground "$ACCENT" --show-error \
      --title " $title" -- "$@"
  else
    step "$title"
    "$@"
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
  spin "Installing $name..." brew install "$formula"
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
  # No spinner here: some casks ask for the sudo password while installing.
  step "Installing $name..."
  brew install --cask "$cask"
  ok "$name installed"
}

# ---------------------------------------------------------------------------
# Banners (gum only; nothing is printed without it)
# ---------------------------------------------------------------------------
banner() {
  $USE_GUM || return 0
  echo
  gum style --bold --foreground "$ACCENT" --border double \
    --border-foreground "$ACCENT" --align center --width 50 --padding "1 2" \
    "mac-setup" "Setting up this Mac"
}

finish() {
  if $USE_GUM; then
    echo
    gum style --bold --foreground 2 --border rounded --border-foreground 2 \
      --padding "0 2" "Done!" "Open a new terminal to load the changes."
  else
    printf '\n%sDone.%s Open a new terminal to load the changes.\n' "$BOLD$GREEN" "$RESET"
  fi
}
