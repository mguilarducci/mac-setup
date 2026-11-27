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

# detail <key> <value>: an indented key/value line (bold key) under the
# previous message.
detail() {
  if $USE_GUM; then
    echo "      $(gum style --bold "$1:") $(gum style --faint "$2")"
  else
    printf '      %s%s:%s %s%s%s\n' "$BOLD" "$1" "$RESET" "$DIM" "$2" "$RESET"
  fi
}

# confirm <question>: asks yes/no on the terminal (also when piped from curl).
# Says no when there is no terminal to ask on.
confirm() {
  if ! { : < /dev/tty; } 2> /dev/null; then
    return 1
  fi
  if $USE_GUM; then
    gum confirm --default=false "  $1" < /dev/tty
  else
    local answer
    read -r -p "  ? $1 [y/N] " answer < /dev/tty
    [[ "$answer" =~ ^[Yy] ]]
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

# Removes a line from a file if it is there (exact match).
remove_line() {
  local file="$1" line="$2" tmp
  grep -qxF "$line" "$file" 2> /dev/null || return 0
  tmp="$(mktemp)"
  grep -vxF "$line" "$file" > "$tmp" || true
  cat "$tmp" > "$file"
  rm -f "$tmp"
  ok "Removed from $file: $line"
}

# remove_block <file> <start marker> <end marker>
# Removes the lines from the start marker to the end marker, inclusive.
remove_block() {
  local file="$1" start="$2" end="$3" tmp
  grep -qxF "$start" "$file" 2> /dev/null || return 0
  tmp="$(mktemp)"
  awk -v s="$start" -v e="$end" '$0 == s { skip = 1 } !skip { print } $0 == e { skip = 0 }' "$file" > "$tmp"
  cat "$tmp" > "$file"
  rm -f "$tmp"
  ok "Removed the block \"$start\" from $file"
}

# source_config <rc file> <config dir> <path under config dir>
# Makes <rc file> source <config dir>/<path>. Lines that source the same file
# from another copy of the repo (e.g. an old clone) are removed.
source_config() {
  local file="$1" dir="$2" rel="$3" want old olds
  want="source \"$dir/$rel\""
  olds="$(grep -F "/config/$rel\"" "$file" 2> /dev/null | grep -E '^source "' || true)"
  while IFS= read -r old; do
    if [ -n "$old" ] && [ "$old" != "$want" ]; then
      remove_line "$file" "$old"
    fi
  done <<< "$olds"
  add_line "$file" "$want"
}

# read_config <notes file> <config dir> <path under config dir>
# Makes an agent notes file (like AGENTS.local.md) say "Also read
# <config dir>/<path>.". Lines that point at the same file in another copy of
# the repo (e.g. an old clone) are removed.
read_config() {
  local file="$1" dir="$2" rel="$3" want old olds
  want="Also read $dir/$rel."
  olds="$(grep -F "/config/$rel." "$file" 2> /dev/null | grep -E '^Also read ' || true)"
  while IFS= read -r old; do
    if [ -n "$old" ] && [ "$old" != "$want" ]; then
      remove_line "$file" "$old"
    fi
  done <<< "$olds"
  mkdir -p "$(dirname "$file")"
  add_line "$file" "$want"
}

# link <source> <target>
# Points <target> at <source> with a symlink. A symlink already at <target>
# is replaced; a real file or directory is moved to <target>.bak.<timestamp>.
link() {
  local src="$1" dst="$2" backup
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    skip "$dst already links to $src"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"
    ln -s "$src" "$dst"
    ok "Relinked $dst -> $src"
    return
  fi
  if [ -e "$dst" ]; then
    backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    note "Moved the old $dst to $backup"
  fi
  ln -s "$src" "$dst"
  ok "Linked $dst -> $src"
}

# repo_details <repo dir>
# Prints where the repo comes from and the commit in use, e.g.
#   url: https://github.com/<owner>/<repo>.git
#   source: github:<owner>/<repo>
#   commit: 1a2b3c4
repo_details() {
  local url path host
  url="$(git -C "$1" remote get-url origin 2> /dev/null || true)"
  if [ -n "$url" ]; then
    path="${url#*://}" # drop https://, ssh://
    path="${path#*@}"  # drop git@
    host="${path%%[:/]*}"
    path="${path#*[:/]}"
    detail url "$url"
    detail source "${host%%.*}:${path%.git}"
  fi
  detail commit "$(git -C "$1" rev-parse --short HEAD)"
}

# install_formula <formula> <name>
install_formula() {
  local formula="$1" name="$2"
  if brew list --formula "$formula" &> /dev/null; then
    skip "$name is already installed"
    detail type formula
    return
  fi
  step "Installing $name..."
  detail type formula
  brew install "$formula"
  ok "$name installed"
}

# install_crate <crate> <name>
# Builds a crate from crates.io with cargo. brew upgrade doesn't cover crates,
# so if it is already installed this asks whether to update it.
install_crate() {
  local crate="$1" name="$2"
  if cargo install --list | grep -q "^$crate v"; then
    if confirm "$name is already installed. Update it?"; then
      step "Updating $name..."
      detail type crate
      # cargo install rebuilds only when crates.io has a newer version.
      cargo install "$crate"
      ok "$name is up to date"
    else
      skip "$name is already installed"
      detail type crate
    fi
    return
  fi
  step "Installing $name..."
  detail type crate
  cargo install "$crate"
  ok "$name installed"
}

# use_tap_cask <user/tap/cask>
# Taps a third-party tap and trusts only the given cask (not the whole tap);
# Homebrew refuses to load casks from untrusted taps.
use_tap_cask() {
  local cask="$1" tap="${1%/*}"
  if brew tap | grep -qxF "$tap"; then
    skip "Tap $tap is already added"
  else
    step "Tapping $tap..."
    brew tap "$tap"
    ok "Tapped $tap"
  fi
  if brew trust --json v1 | grep -qF "\"$cask\""; then
    skip "Cask $cask is already trusted"
  else
    step "Trusting cask $cask..."
    brew trust --cask "$cask"
    ok "Trusted $cask"
  fi
}

# install_cask <cask> <name> [App.app]
# <cask> can be a third-party cask (user/tap/cask); see use_tap_cask.
# When an app name is given and that app is already in /Applications but was
# not installed by Homebrew (e.g. downloaded from the website), the cask is
# skipped; otherwise brew would fail because the app already exists.
install_cask() {
  local cask="$1" name="$2" app="${3:-}" tap=""
  case "$cask" in */*/*)
    tap="${cask%/*}"
    use_tap_cask "$cask"
    ;;
  esac
  if brew list --cask "$cask" &> /dev/null; then
    skip "$name is already installed"
    cask_details "$app" "$tap"
    return
  fi
  if [ -n "$app" ] && [ -d "/Applications/$app" ]; then
    skip "$name is already in /Applications/$app (installed outside Homebrew)"
    cask_details "$app" "$tap"
    return
  fi
  step "Installing $name..."
  cask_details "$app" "$tap"
  brew install --cask "$cask"
  ok "$name installed"
}

# cask_details <App.app or ""> <tap or "">
cask_details() {
  detail type cask
  if [ -n "$1" ]; then detail app "$1"; fi
  if [ -n "$2" ]; then detail tap "$2"; fi
}

finish() {
  if $USE_GUM; then
    echo
    gum style --bold --foreground 2 "Done. Open a new terminal to load the changes."
    return
  fi
  printf '\n%sDone.%s Open a new terminal to load the changes.\n' "$BOLD$GREEN" "$RESET"
}
