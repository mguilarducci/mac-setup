#!/usr/bin/env bash
#
# Exits with an error if Homebrew is not installed.

set -euo pipefail

if ! command -v brew > /dev/null; then
  echo "Error: Homebrew is not installed. Run tools/core/homebrew/install.sh first." >&2
  exit 1
fi
