#!/usr/bin/env bash
# menu-bar.sh - Configure menu bar items

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Menu Bar Settings"

# Hide Spotlight from menu bar
# Attempt known defaults keys
hide_spotlight_menu_bar() {
  # Modern macOS (Ventura+)
  run_or_dry defaults write com.apple.Spotlight MenuItemHidden -bool true || true

  # Control Center
  run_or_dry defaults write com.apple.controlcenter "NSStatusItem Visible com.apple.Spotlight" -bool false || true

  # SystemUIServer
  run_or_dry defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/Volume.menu" \
    "/System/Library/CoreServices/Menu Extras/Battery.menu" \
    "/System/Library/CoreServices/Menu Extras/Clock.menu" \
    "/System/Library/CoreServices/Menu Extras/AirPort.menu" || true
}

if [[ "${DRY_RUN:-false}" == "true" ]]; then
  log_skip "(dry-run) Would hide Spotlight from menu bar"
else
  hide_spotlight_menu_bar
  log_ok "Spotlight menu bar: hidden (best effort)"
fi

# Show Weather in menu bar
show_weather_menu_bar() {
  # Try Control Center setting
  run_or_dry defaults write com.apple.controlcenter "NSStatusItem Visible com.apple.WeatherWidget" -bool true || true
  run_or_dry defaults write com.apple.controlcenter "NSStatusItem Preferred Position com.apple.WeatherWidget" -int 100 || true
}

if [[ "${DRY_RUN:-false}" == "true" ]]; then
  log_skip "(dry-run) Would show Weather in menu bar"
else
  show_weather_menu_bar
  log_ok "Weather menu bar: enabled (best effort)"
fi

if [[ "${DRY_RUN:-false}" != "true" ]]; then
  killall SystemUIServer >/dev/null 2>&1 || true
fi

log_ok "Menu bar settings applied"
