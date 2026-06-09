#!/usr/bin/env bash
# homebrew.sh - Install and configure Homebrew

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Homebrew"

if command_exists brew; then
  log_ok "Homebrew already installed"
else
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would install Homebrew"
  else
    log_warn "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Ensure shellenv is available for this session
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Add shellenv to ~/.zprofile if missing
if command_exists brew; then
  local_shellenv_line='eval "$(/opt/homebrew/bin/brew shellenv)"'
  append_if_missing "$HOME/.zprofile" "$local_shellenv_line"
fi

if [[ "${DRY_RUN:-false}" != "true" ]]; then
  log_section "Updating Homebrew..."
  brew update || log_warn "brew update had issues, continuing..."
fi

log_ok "Homebrew ready"
