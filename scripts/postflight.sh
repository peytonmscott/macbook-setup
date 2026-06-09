#!/usr/bin/env bash
# postflight.sh - Verify installation and print summary

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Postflight Checks"

check_command() {
  local cmd="$1"
  if command_exists "$cmd"; then
    log_ok "$cmd installed"
  else
    log_warn "$cmd NOT found"
  fi
}

check_symlink() {
  local path="$1"
  if [[ -L "$path" ]]; then
    log_ok "Symlink OK: $path -> $(readlink "$path")"
  else
    log_warn "Missing symlink: $path"
  fi
}

# Core tools
check_command brew
check_command git
check_command nvim
check_command ghostty
check_command aerospace
check_command starship
check_command zoxide
check_command fzf
check_command yazi
check_command gh
check_command jj
check_command maestro

# Role-specific
if [[ "${MACHINE_ROLE:-}" == "work" ]]; then
  check_command az
fi

# Android
if command_exists adb; then
  log_ok "adb installed"
else
  log_warn "adb NOT found"
fi

if command_exists sdkmanager; then
  log_ok "sdkmanager installed"
else
  log_warn "sdkmanager NOT found"
fi

# Kotlin
if command_exists kotlin; then
  log_ok "kotlin installed"
else
  log_warn "kotlin NOT found"
fi

# Symlinks (from dotfiles repo)
if [[ -n "${DOTFILES_REPO:-}" ]]; then
  check_symlink "$HOME/.zshrc"
  check_symlink "$HOME/.config/nvim"
  check_symlink "$HOME/.config/ghostty"
  check_symlink "$HOME/.config/aerospace/aerospace.toml"
  check_symlink "$HOME/.config/starship.toml"
  check_symlink "$HOME/.config/yazi"
fi

log_section "Summary"
echo "  Role:      ${MACHINE_ROLE}"
echo "  Git Name:  ${GIT_NAME}"
echo "  Git Email: ${GIT_EMAIL}"
echo ""
echo "  Next steps:"
echo "    1. Review docs/manual-steps.md for manual steps."
echo "    2. Restart your Mac or log out/in for some settings to take effect."
echo "    3. Run 'gh auth login' to authenticate with GitHub."
echo ""
log_ok "Bootstrap complete!"
