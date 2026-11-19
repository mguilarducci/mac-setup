#!/usr/bin/env bash
#
# Installs the core tools in order: Homebrew, the GitHub CLI, then hc.
#
# Works from a local clone or piped from curl. When piped, it downloads
# the repository to a temporary directory first.

set -euo pipefail

REPO_TARBALL="https://github.com/mguilarducci/mac-setup/archive/HEAD.tar.gz"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")/.." 2> /dev/null && pwd || true)"

if [ ! -f "$ROOT_DIR/tools/core/homebrew/install.sh" ]; then
  ROOT_DIR="$(mktemp -d)"
  trap 'rm -rf "$ROOT_DIR"' EXIT
  echo "Downloading mac-setup..."
  curl -fsSL "$REPO_TARBALL" | tar -xz -C "$ROOT_DIR" --strip-components=1
fi

bash "$ROOT_DIR/tools/core/homebrew/install.sh"

# Make brew available to the next steps in this process.
if ! command -v brew > /dev/null && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv bash)"
fi

bash "$ROOT_DIR/tools/core/gh/install.sh"

bash "$ROOT_DIR/tools/core/hc/install.sh"
