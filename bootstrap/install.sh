#!/usr/bin/env bash
#
# Runs every tools/core/*/install.sh. Homebrew goes first, since other
# tools depend on it; the rest run in alphabetical order. A failing tool
# does not stop the others; failures are listed at the end.
#
# Works from a local clone or piped from curl. When piped, it downloads
# the repository to a temporary directory first.

set -euo pipefail

REPO_TARBALL="https://github.com/mguilarducci/mac-setup/archive/HEAD.tar.gz"
BREW_BIN="/opt/homebrew/bin/brew"
ZPROFILE="$HOME/.zprofile"
LOCAL_BIN_LINE='export PATH="$HOME/.local/bin:$PATH"'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")/.." 2> /dev/null && pwd || true)"

if [ ! -d "$ROOT_DIR/tools/core" ]; then
  ROOT_DIR="$(mktemp -d)"
  trap 'rm -rf "$ROOT_DIR"' EXIT
  echo "Downloading mac-setup..."
  curl -fsSL "$REPO_TARBALL" | tar -xz -C "$ROOT_DIR" --strip-components=1
fi

# Some tools install into ~/.local/bin, which is not on the PATH by default.
if ! grep -qxF "$LOCAL_BIN_LINE" "$ZPROFILE" 2> /dev/null; then
  echo >> "$ZPROFILE"
  echo "$LOCAL_BIN_LINE" >> "$ZPROFILE"
  echo "Added ~/.local/bin to PATH in $ZPROFILE."
fi
export PATH="$HOME/.local/bin:$PATH"

CORE_DIR="$ROOT_DIR/tools/core"
failed=()

run_tool() {
  local name="$1"
  echo "==> $name"
  if ! bash "$CORE_DIR/$name/install.sh"; then
    failed+=("$name")
  fi
}

run_tool homebrew

# Make brew available to the next tools in this process.
if ! command -v brew > /dev/null && [ -x "$BREW_BIN" ]; then
  eval "$("$BREW_BIN" shellenv bash)"
fi

for script in "$CORE_DIR"/*/install.sh; do
  name="$(basename "$(dirname "$script")")"
  [ "$name" = "homebrew" ] && continue
  run_tool "$name"
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed: ${failed[*]}" >&2
  exit 1
fi

echo "All core tools installed."
