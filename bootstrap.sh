#!/usr/bin/env bash
# bootstrap.sh - Main entrypoint for macbook-setup
# Usage: ./bootstrap.sh [--role personal|work] [--git-name NAME] [--git-email EMAIL]
#                       [--skip-brew] [--skip-macos] [--skip-dotfiles] [--skip-packages]
#                       [--dry-run] [--help]

set -euo pipefail

# Determine repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

# shellcheck source=scripts/lib.sh
source "$REPO_ROOT/scripts/lib.sh"

# Default flags
MACHINE_ROLE=""
GIT_NAME=""
GIT_EMAIL=""
SKIP_BREW=false
SKIP_MACOS=false
SKIP_DOTFILES=false
SKIP_PACKAGES=false
DRY_RUN=false
DOTFILES_REPO=""

# Print usage
usage() {
  cat <<EOF
Usage: ./bootstrap.sh [OPTIONS]

Options:
  --role personal|work    Machine role
  --git-name NAME         Git user name
  --git-email EMAIL       Git user email
  --dotfiles-repo URL     Clone dotfiles from this Git repo (optional)
  --skip-brew             Skip Homebrew installation
  --skip-macos            Skip macOS settings
  --skip-dotfiles         Skip dotfiles linking
  --skip-packages         Skip package installation
  --dry-run               Show what would be done
  --help                  Show this help message
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --role)
      MACHINE_ROLE="$2"
      shift 2
      ;;
    --git-name)
      GIT_NAME="$2"
      shift 2
      ;;
    --git-email)
      GIT_EMAIL="$2"
      shift 2
      ;;
    --dotfiles-repo)
      DOTFILES_REPO="$2"
      shift 2
      ;;
    --skip-brew)
      SKIP_BREW=true
      shift
      ;;
    --skip-macos)
      SKIP_MACOS=true
      shift
      ;;
    --skip-dotfiles)
      SKIP_DOTFILES=true
      shift
      ;;
    --skip-packages)
      SKIP_PACKAGES=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      log_fail "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Export flags so sub-scripts can see them
export MACHINE_ROLE GIT_NAME GIT_EMAIL SKIP_BREW SKIP_MACOS SKIP_DOTFILES SKIP_PACKAGES DRY_RUN DOTFILES_REPO

# Banner
echo "================================"
echo "  macbook-setup"
echo "  macOS Provisioning"
echo "================================"
echo

# Validate macOS
require_macos

# Interactive prompts for missing values
if [[ -z "$MACHINE_ROLE" ]]; then
  # shellcheck source=scripts/ask.sh
  source "$REPO_ROOT/scripts/ask.sh"
  ask_role
fi

if [[ -z "$GIT_NAME" ]]; then
  # shellcheck source=scripts/ask.sh
  source "$REPO_ROOT/scripts/ask.sh"
  ask_git_name
fi

if [[ -z "$GIT_EMAIL" ]]; then
  # shellcheck source=scripts/ask.sh
  source "$REPO_ROOT/scripts/ask.sh"
  ask_git_email
fi

# Re-source ask.sh if it hasn't been loaded, for confirm_choices
if ! type confirm_choices &>/dev/null; then
  # shellcheck source=scripts/ask.sh
  source "$REPO_ROOT/scripts/ask.sh"
fi
confirm_choices

# Source role config
if [[ "$MACHINE_ROLE" == "personal" ]]; then
  # shellcheck source=config/personal.env
  source "$REPO_ROOT/config/personal.env"
elif [[ "$MACHINE_ROLE" == "work" ]]; then
  # shellcheck source=config/work.env
  source "$REPO_ROOT/config/work.env"
else
  log_fail "Invalid role: $MACHINE_ROLE"
  exit 1
fi

# Source common config
# shellcheck source=config/common.env
source "$REPO_ROOT/config/common.env"

# 1. Xcode Command Line Tools
bash "$REPO_ROOT/scripts/xcode.sh"

# 2. Homebrew
if [[ "$SKIP_BREW" != "true" ]]; then
  bash "$REPO_ROOT/scripts/homebrew.sh"
else
  log_skip "Homebrew installation skipped"
fi

# 3. Packages (before some macOS tools that need them)
if [[ "$SKIP_PACKAGES" != "true" ]]; then
  bash "$REPO_ROOT/scripts/packages.sh"
else
  log_skip "Package installation skipped"
fi

# 4. Git config
bash "$REPO_ROOT/scripts/git.sh"

# 5. Developer directory
log_section "Developer Directory"
ensure_dir "$HOME/Developer"
log_ok "~/Developer ready"

# 6. Dotfiles
bash "$REPO_ROOT/scripts/dotfiles.sh"

# 7. macOS settings
if [[ "$SKIP_MACOS" != "true" ]]; then
  bash "$REPO_ROOT/scripts/keyboard.sh"
  bash "$REPO_ROOT/scripts/finder.sh"
  bash "$REPO_ROOT/scripts/dock.sh"
  bash "$REPO_ROOT/scripts/menu-bar.sh"
  bash "$REPO_ROOT/scripts/macos.sh"
else
  log_skip "macOS settings skipped"
fi

# 8. Kotlin
bash "$REPO_ROOT/scripts/kotlin.sh"

# 9. Android
bash "$REPO_ROOT/scripts/android.sh"

# 10. PATH verification / fixup for non-Homebrew tools
bash "$REPO_ROOT/scripts/paths.sh"

# 11. Postflight
bash "$REPO_ROOT/scripts/postflight.sh"

# Manual steps reminder
echo
echo "================================"
echo "  Remaining Manual Steps"
echo "================================"
echo "  See: docs/manual-steps.md"
echo "================================"
echo

log_ok "All done!"
