#!/usr/bin/env bash
#
# Runs every tools/core/*/install.sh, then tools/code, tools/fonts and
# tools/terminal, in that order.
# Homebrew goes first, since other tools depend on it; the rest run in
# alphabetical order. A failing tool does not stop the others; failures
# are listed at the end.
#
# Works from a local clone or piped from curl. When piped, it downloads
# the repository to a temporary directory first.

set -euo pipefail

# Some tools install into ~/.local/bin, which is not on the PATH by default.
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.zprofile 2> /dev/null ||
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
export PATH="$HOME/.local/bin:$PATH"

REPO_TARBALL="https://github.com/mguilarducci/mac-setup/archive/HEAD.tar.gz"
BREW_BIN="/opt/homebrew/bin/brew"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")/.." 2> /dev/null && pwd || true)"

if [ ! -d "$ROOT_DIR/tools/core" ]; then
  ROOT_DIR="$(mktemp -d)"
  trap 'rm -rf "$ROOT_DIR"' EXIT
  echo "Downloading mac-setup..."
  curl -fsSL "$REPO_TARBALL" | tar -xz -C "$ROOT_DIR" --strip-components=1
fi

TOOLS_DIR="$ROOT_DIR/tools"
failed=()

run_tool() {
  local group="$1" name="$2"
  echo "==> $group/$name"
  if ! bash "$TOOLS_DIR/$group/$name/install.sh"; then
    failed+=("$group/$name")
  fi
}

# Runs every tool in a group, in alphabetical order, skipping the given names.
run_group() {
  local group="$1"
  shift
  local script name skip
  for script in "$TOOLS_DIR/$group"/*/install.sh; do
    name="$(basename "$(dirname "$script")")"
    for skip in "$@"; do
      [ "$name" = "$skip" ] && continue 2
    done
    run_tool "$group" "$name"
  done
}

run_tool core homebrew

# Make brew available to the next tools in this process.
if ! command -v brew > /dev/null && [ -x "$BREW_BIN" ]; then
  eval "$("$BREW_BIN" shellenv bash)"
fi

run_group core homebrew

echo
echo "Starting installation of coding tools..."
run_group code

echo
echo "Starting installation of fonts..."
run_group fonts

echo
echo "Starting installation of terminal tools..."
run_group terminal

if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed: ${failed[*]}" >&2
  exit 1
fi

echo "All tools installed."
