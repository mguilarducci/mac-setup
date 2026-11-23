#!/usr/bin/env bash
#
# Sets up a new Mac. Safe to run more than once.

set -euo pipefail

ZPROFILE="$HOME/.zprofile"
ZSHRC="$HOME/.zshrc"
BREW_BIN="/opt/homebrew/bin/brew"

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  BOLD=$'\033[1m' BLUE=$'\033[34m' GREEN=$'\033[32m' YELLOW=$'\033[33m' RESET=$'\033[0m'
else
  BOLD="" BLUE="" GREEN="" YELLOW="" RESET=""
fi

section() { printf '\n%s==> %s%s\n' "$BOLD$BLUE" "$1" "$RESET"; }
step() { printf '  %s->%s %s\n' "$BLUE" "$RESET" "$1"; }
ok() { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
skip() { printf '  %s-%s %s\n' "$YELLOW" "$RESET" "$1"; }
note() { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$1"; }

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

# ---------------------------------------------------------------------------
# Shell PATH
# ---------------------------------------------------------------------------
section "Shell PATH"
# Some tools install into ~/.local/bin, which is not on the PATH by default.
add_line "$ZPROFILE" 'export PATH="$HOME/.local/bin:$PATH"'
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
section "Homebrew"
if ! command -v brew > /dev/null && [ ! -x "$BREW_BIN" ]; then
  step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Homebrew installed"
else
  skip "Homebrew is already installed"
fi
add_line "$ZPROFILE" "eval \"\$($BREW_BIN shellenv zsh)\""
eval "$("$BREW_BIN" shellenv bash)"

# ---------------------------------------------------------------------------
# Command-line tools
# ---------------------------------------------------------------------------
section "Command-line tools"
install_formula gh "GitHub CLI"
install_formula shellcheck "ShellCheck"

# ---------------------------------------------------------------------------
# Coding tools
# ---------------------------------------------------------------------------
section "Coding tools"
install_cask claude-code "Claude Code"
install_cask codex "Codex"
install_cask docker-desktop "Docker Desktop" "Docker.app"
note "Open Docker Desktop once to accept the license: open -a Docker"
install_cask herdr-app "Herdr" "Herdr.app"
install_cask ghostty "Ghostty" "Ghostty.app"

# ---------------------------------------------------------------------------
# Apps
# ---------------------------------------------------------------------------
section "Apps"
install_cask slack "Slack" "Slack.app"

# ---------------------------------------------------------------------------
# 1Password CLI
# ---------------------------------------------------------------------------
section "1Password CLI"
install_cask 1password-cli "1Password CLI"

# op-sa <keychain-item> <op args...> runs op with a service account token read
# from the Keychain. The plain `op` command is left untouched.
if grep -qF "# >>> op service account >>>" "$ZSHRC" 2> /dev/null; then
  skip "op-sa() is already in $ZSHRC"
else
  cat >> "$ZSHRC" << 'EOF'

# >>> op service account >>>
op-sa() {
  if [ $# -lt 1 ]; then
    echo "Usage: op-sa <keychain-item> [op args...]" >&2
    return 1
  fi
  local item="$1" token
  shift
  token="$(security find-generic-password -a "$USER" -s "$item" -w)" || return
  OP_SERVICE_ACCOUNT_TOKEN="$token" command op "$@"
}
# <<< op service account <<<
EOF
  ok "Added op-sa() to $ZSHRC"
  note "Store a token with: security add-generic-password -U -a \"\$USER\" -s <keychain-item> -w"
fi

# ---------------------------------------------------------------------------
# Fonts
# ---------------------------------------------------------------------------
section "Fonts"
install_cask font-jetbrains-mono-nerd-font "JetBrains Mono Nerd Font"
note "Select \"JetBrainsMono Nerd Font\" in your terminal's font settings (Ghostty: font-family = \"JetBrainsMono Nerd Font\")."

# ---------------------------------------------------------------------------
# Starship prompt (needs the Nerd Font above)
# ---------------------------------------------------------------------------
section "Starship prompt"
install_formula starship "Starship"
add_line "$ZSHRC" 'eval "$(starship init zsh)"'

printf '\n%sDone.%s Open a new terminal to load the changes.\n' "$BOLD$GREEN" "$RESET"
