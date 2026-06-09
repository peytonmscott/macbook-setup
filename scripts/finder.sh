#!/usr/bin/env bash
# finder.sh - Configure Finder preferences

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Finder Settings"

# New window target: Documents
run_or_dry defaults write com.apple.finder NewWindowTarget -string "PfDo"
run_or_dry defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Documents/"
log_ok "Finder new window target: Documents"

# Default list view
run_or_dry defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
log_ok "Finder default view: list"

# Calculate all sizes
run_or_dry defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true
log_ok "Finder info panes expanded"

# Default search scope: current folder
run_or_dry defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
log_ok "Finder default search scope: current folder"

# Show path bar
run_or_dry defaults write com.apple.finder ShowPathbar -bool true
log_ok "Finder path bar: visible"

# Show status bar
run_or_dry defaults write com.apple.finder ShowStatusBar -bool true
log_ok "Finder status bar: visible"

# Show Library folder
run_or_dry chflags nohidden "$HOME/Library" || true
log_ok "Library folder: visible"

# Hide recent tags
run_or_dry defaults write com.apple.finder ShowRecentTags -bool false || true
log_ok "Finder recent tags: hidden"

# Create Developer dir and add to favorites
ensure_dir "$HOME/Developer"

# Finder sidebar configuration
log_section "Finder Sidebar"

# Use sfltool if available to add favorites
if command_exists sfltool; then
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would configure Finder sidebar favorites"
  else
    # Remove existing user favorites if possible
    # Note: com.apple.sidebarlists.plist is complex; best-effort approach
    # Adding Developer to favorites
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems file://"$HOME/Developer" || true
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems file://"$HOME/Documents" || true
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems file://"$HOME/Downloads" || true
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems file://"$HOME/Desktop" || true
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems file://"$HOME/Pictures" || true
    log_ok "Finder favorites updated via sfltool"
  fi
else
  log_skip "sfltool not found, skipping Finder sidebar manipulation"
fi

if [[ "${DRY_RUN:-false}" != "true" ]]; then
  killall Finder >/dev/null 2>&1 || true
  killall sharedfilelistd >/dev/null 2>&1 || true
fi

log_ok "Finder settings applied"
