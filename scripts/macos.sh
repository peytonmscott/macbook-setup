#!/usr/bin/env bash
# macos.sh - Broad macOS system settings orchestrator

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "macOS System Settings"

# Disable automatic space rearranging
run_or_dry defaults write com.apple.dock mru-spaces -bool false
log_ok "Disabled automatic Spaces rearranging"

# Disable hot corners
run_or_dry defaults write com.apple.dock wvous-tl-corner -int 0
run_or_dry defaults write com.apple.dock wvous-tr-corner -int 0
run_or_dry defaults write com.apple.dock wvous-bl-corner -int 0
run_or_dry defaults write com.apple.dock wvous-br-corner -int 0
run_or_dry defaults write com.apple.dock wvous-tl-modifier -int 0
run_or_dry defaults write com.apple.dock wvous-tr-modifier -int 0
run_or_dry defaults write com.apple.dock wvous-bl-modifier -int 0
run_or_dry defaults write com.apple.dock wvous-br-modifier -int 0
log_ok "Disabled hot corners"

# Restart affected services
if [[ "${DRY_RUN:-false}" != "true" ]]; then
  killall Dock >/dev/null 2>&1 || true
  killall Finder >/dev/null 2>&1 || true
  killall SystemUIServer >/dev/null 2>&1 || true
  killall cfprefsd >/dev/null 2>&1 || true
fi

log_ok "macOS system settings applied"
