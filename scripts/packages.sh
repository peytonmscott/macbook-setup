#!/usr/bin/env bash
# packages.sh - Install packages via Homebrew bundle

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Package Installation"

if [[ "${SKIP_PACKAGES:-false}" == "true" ]]; then
  log_skip "Package installation skipped via flag"
  exit 0
fi

if ! command_exists brew; then
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Homebrew not installed yet, skipping brew bundle steps"
    exit 0
  fi
  log_fail "Homebrew not found. Run homebrew.sh first."
  exit 1
fi

# Update Homebrew to ensure taps are available
log_section "Updating Homebrew..."
if [[ "${DRY_RUN:-false}" == "true" ]]; then
  log_skip "(dry-run) Would run: brew update"
else
  brew update
fi

# Common packages
log_section "Installing common packages..."
if [[ "${DRY_RUN:-false}" == "true" ]]; then
  log_skip "(dry-run) Would run: brew bundle --file $REPO_ROOT/brew/Brewfile.common"
else
  brew bundle --file "$REPO_ROOT/brew/Brewfile.common"
fi

# Role-specific packages
if [[ "${MACHINE_ROLE:-}" == "personal" ]]; then
  log_section "Installing personal packages..."
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would run: brew bundle --file $REPO_ROOT/brew/Brewfile.personal"
  else
    brew bundle --file "$REPO_ROOT/brew/Brewfile.personal"
  fi
elif [[ "${MACHINE_ROLE:-}" == "work" ]]; then
  log_section "Installing work packages..."
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would run: brew bundle --file $REPO_ROOT/brew/Brewfile.work"
  else
    brew bundle --file "$REPO_ROOT/brew/Brewfile.work"
  fi
fi

log_ok "Packages installed"
