#!/usr/bin/env bash
#
# Sets up a new Mac. Safe to run more than once.

set -euo pipefail

ZPROFILE="$HOME/.zprofile"
ZSHRC="$HOME/.zshrc"
BREW_BIN="/opt/homebrew/bin/brew"

# ---------------------------------------------------------------------------
# Load helpers from lib.sh: next to this file when run from a clone, or
# downloaded from GitHub when run through curl.
# ---------------------------------------------------------------------------
LIB_URL="https://raw.githubusercontent.com/mguilarducci/mac-setup/HEAD/lib.sh"
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/lib.sh" ]; then
  # shellcheck source=lib.sh
  source "$SCRIPT_DIR/lib.sh"
else
  LIB="$(curl -fsSL "$LIB_URL")"
  eval "$LIB"
fi

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

# gum makes the rest of this script look nicer: https://github.com/charmbracelet/gum
install_formula gum "gum"
enable_gum

banner

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

finish
