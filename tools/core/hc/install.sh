#!/usr/bin/env bash
#
# Installs hc using the official install script.

set -euo pipefail

echo "Installing hc..."
curl -fsSL https://releases.herdr.dev/core/install.sh | sh
