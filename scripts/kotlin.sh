#!/usr/bin/env bash
# kotlin.sh - Install Kotlin toolchain

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Kotlin Toolchain"

if command_exists kotlin && command_exists kotlinc; then
  log_ok "Kotlin already installed"
  exit 0
fi

if [[ "${DRY_RUN:-false}" == "true" ]]; then
  log_skip "(dry-run) Would install Kotlin via official installer"
  exit 0
fi

log_warn "Installing Kotlin..."
curl -fsSL https://kotl.in/install.sh | sh

# Add to PATH if needed
KOTLIN_HOME="$HOME/.local/share/kotlin"
if [[ -d "$KOTLIN_HOME/bin" ]]; then
  export PATH="$KOTLIN_HOME/bin:$PATH"
fi

if command_exists kotlin; then
  log_ok "Kotlin installed: $(kotlin -version 2>&1 | head -n1)"
else
  log_warn "Kotlin installed but not in PATH. You may need to restart your shell."
fi
