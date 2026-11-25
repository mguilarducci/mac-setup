#!/usr/bin/env bash
#
# Sets up a new Mac. Safe to run more than once.

set -euo pipefail

ZPROFILE="$HOME/.zprofile"
ZSHRC="$HOME/.zshrc"
BREW_BIN="/opt/homebrew/bin/brew"
REPO_URL="https://github.com/mguilarducci/mac-setup.git"
# Where the repo is cloned when this script runs through curl.
REPO_CLONE="$HOME/.mac-setup"

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

# Some tools install into ~/.local/bin. config/zsh/zprofile.zsh adds it to the
# PATH for new shells; this does it for the rest of this run.
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# Requirements: Homebrew, git, gum, and this repo (for the files in config/).
# ---------------------------------------------------------------------------
section "Requirements"
if ! command -v brew > /dev/null && [ ! -x "$BREW_BIN" ]; then
  step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Homebrew installed"
else
  skip "Homebrew is already installed"
fi
eval "$("$BREW_BIN" shellenv bash)"
install_formula git "Git"

# gum styles the rest of this script's messages: https://github.com/charmbracelet/gum
install_formula gum "gum"
enable_gum

# Update Homebrew and its package lists, then upgrade anything outdated.
step "Updating Homebrew..."
brew update
ok "Homebrew is up to date"
if [ -n "$(brew outdated --quiet)" ]; then
  step "Upgrading outdated packages..."
  brew outdated
  brew upgrade
  ok "Packages upgraded"
else
  skip "No outdated packages"
fi

# This repo. Uses the git installed above.
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/config" ]; then
  REPO_DIR="$SCRIPT_DIR"
  skip "Running from a local clone"
elif [ -d "$REPO_CLONE/.git" ]; then
  REPO_DIR="$REPO_CLONE"
  step "Updating $REPO_DIR..."
  if git -C "$REPO_DIR" pull --ff-only --quiet; then
    ok "$REPO_DIR is up to date"
  else
    note "Could not update $REPO_DIR; using it as it is"
  fi
else
  REPO_DIR="$REPO_CLONE"
  step "Cloning mac-setup into $REPO_DIR..."
  git clone --quiet "$REPO_URL" "$REPO_DIR"
  ok "Cloned into $REPO_DIR"
fi
CONFIG_DIR="$REPO_DIR/config"
detail "clone destination" "$REPO_DIR"
repo_details "$REPO_DIR"

# ---------------------------------------------------------------------------
# Terminal, prompts & shell tools. Ghostty and Starship use the Nerd Font.
# ---------------------------------------------------------------------------
section "Terminal, prompts & shell tools"
install_cask ghostty "Ghostty" "Ghostty.app"
install_cask herdr-app "Herdr" "Herdr.app"
install_cask font-jetbrains-mono-nerd-font "JetBrains Mono Nerd Font"
note "Ghostty uses it through config/ghostty. In other terminals, select \"JetBrainsMono Nerd Font\" in the font settings."
install_formula starship "Starship"
install_formula zoxide "zoxide"
install_formula atuin "Atuin"
install_formula ripgrep "ripgrep"
install_formula fd "fd"

# ---------------------------------------------------------------------------
# Dev tools. Neovim + LazyVim (https://www.lazyvim.org) also uses ripgrep and
# fd from above (fd is needed to search in the file explorer) and the Nerd
# Font. The LazyVim config lives in config/nvim.
# ---------------------------------------------------------------------------
section "Dev tools"
install_formula neovim "Neovim"
install_formula tree-sitter-cli "tree-sitter CLI"
install_formula gh "GitHub CLI"
# mise manages per-project runtimes (Node, Python, ...): https://mise.jdx.dev
install_formula mise "mise"
install_formula shellcheck "ShellCheck"
install_cask docker-desktop "Docker Desktop" "Docker.app"
note "Open Docker Desktop once to accept the license: open -a Docker"
install_formula mosquitto "Mosquitto (mosquitto_sub, mosquitto_pub)"

# ---------------------------------------------------------------------------
# AI
# ---------------------------------------------------------------------------
section "AI"
install_cask claude-code "Claude Code"
install_cask codex "Codex"
install_formula skillshare "Skillshare CLI"
install_cask runkids/tap/skillshare-app "Skillshare" "skillshare.app"

# ---------------------------------------------------------------------------
# Productivity
# ---------------------------------------------------------------------------
section "Productivity"
install_cask obsidian "Obsidian" "Obsidian.app"
install_cask linear "Linear" "Linear.app"
install_cask superwhisper "Superwhisper" "superwhisper.app"

# ---------------------------------------------------------------------------
# Social networking
# ---------------------------------------------------------------------------
section "Social networking"
install_cask slack "Slack" "Slack.app"

# ---------------------------------------------------------------------------
# Secrets managers (op-sa() for the 1Password CLI lives in config/zsh/op-sa.zsh)
# ---------------------------------------------------------------------------
section "Secrets managers"
install_cask 1password-cli "1Password CLI"
install_formula openbao "OpenBao"

# ---------------------------------------------------------------------------
# Shell config: ~/.zprofile and ~/.zshrc only load the files in config/zsh,
# so other installers can still add their own lines to them.
# ---------------------------------------------------------------------------
section "Shell config"
source_config "$ZPROFILE" "$CONFIG_DIR" zsh/zprofile.zsh
source_config "$ZSHRC" "$CONFIG_DIR" zsh/zshrc.zsh

# Older versions of this script wrote these straight into the files.
remove_line "$ZPROFILE" 'export PATH="$HOME/.local/bin:$PATH"'
remove_line "$ZPROFILE" "eval \"\$($BREW_BIN shellenv zsh)\""
remove_line "$ZSHRC" 'eval "$(starship init zsh)"'
remove_block "$ZSHRC" "# >>> op service account >>>" "# <<< op service account <<<"

# ---------------------------------------------------------------------------
# App config: only the config files are symlinks into config/. Whatever the
# apps write next to them (lock files, state) stays out of the repo.
# ---------------------------------------------------------------------------
section "App config"
link "$CONFIG_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
link "$CONFIG_DIR/atuin/config.toml" "$HOME/.atuin/config.toml"
link "$CONFIG_DIR/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
for file in init.lua lua .neoconf.json stylua.toml; do
  link "$CONFIG_DIR/nvim/$file" "$HOME/.config/nvim/$file"
done
note "Run nvim once to install the plugins, then :LazyHealth to check the setup."

# Herdr's agents read AGENTS.local.md; this points them at the rules that keep
# config/herdr-app/personal-mods.json (the installed community mods) in sync.
read_config "$HOME/.config/herdr-app/AGENTS.local.md" "$CONFIG_DIR" herdr-app/sync.md
note "To get the Herdr mods back, ask an agent in Herdr to restore them."

finish
