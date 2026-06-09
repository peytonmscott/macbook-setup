#!/usr/bin/env bash
# dock.sh - Configure Dock appearance and contents

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Dock Settings"

# Position left
run_or_dry defaults write com.apple.dock orientation -string "left"
log_ok "Dock position: left"

# Auto hide
run_or_dry defaults write com.apple.dock autohide -bool true
log_ok "Dock autohide: on"

# Hide recent apps
run_or_dry defaults write com.apple.dock show-recents -bool false
log_ok "Dock recent apps: hidden"

# Mission Control / dragging to top
run_or_dry defaults write com.apple.dock expose-group-apps -bool false || true
log_ok "Mission Control settings applied"

if [[ "${DRY_RUN:-false}" != "true" ]]; then
  killall Dock >/dev/null 2>&1 || true
fi

log_ok "Dock settings applied"

# Only clean up dock items if dockutil is installed (installed via brew)
if command_exists dockutil; then
  log_section "Dock Items"

  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would clean Dock items with dockutil"
  else
    # Remove everything first
    dockutil --remove all --no-restart || true
    log_ok "Removed all Dock items"

    # Add common apps
    dockutil --add "/System/Applications/Launchpad.app" --no-restart || true
    dockutil --add "/Applications/Safari.app" --no-restart || true

    # Personal-only apps
    if [[ "${MACHINE_ROLE:-}" == "personal" ]]; then
      dockutil --add "/System/Applications/Messages.app" --no-restart || true
      dockutil --add "/System/Applications/Notes.app" --no-restart || true
      dockutil --add "/System/Applications/App Store.app" --no-restart || true
    fi

    dockutil --add "/System/Applications/System Settings.app" --no-restart || true

    log_ok "Dock items configured"
  fi
else
  log_skip "dockutil not found, skipping Dock item cleanup (will be available after brew install)"
fi

# Restart Dock to apply
if [[ "${DRY_RUN:-false}" != "true" ]]; then
  killall Dock >/dev/null 2>&1 || true
fi
