#!/usr/bin/env bash
# lib.sh - Shared helpers for macbook-setup

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_section() {
  echo
  echo -e "${CYAN}==>${NC} $1"
}

log_ok() {
  echo -e "${GREEN}[ok]${NC} $1"
}

log_skip() {
  echo -e "${YELLOW}[skip]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[warn]${NC} $1"
}

log_fail() {
  echo -e "${RED}[fail]${NC} $1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
      log_skip "(dry-run) Would create directory: $dir"
      return 0
    fi
    mkdir -p "$dir"
    log_ok "Created directory: $dir"
  fi
}

backup_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
      log_skip "(dry-run) Would backup: $path"
      return 0
    fi
    local timestamp
    timestamp=$(date +%Y-%m-%d-%H%M%S)
    local backup="${path}.backup-${timestamp}"
    mv "$path" "$backup"
    log_warn "Existing $path backed up to $backup"
  fi
}

link_file() {
  local source="$1"
  local target="$2"

  # If target is already the correct symlink, skip
  if [[ -L "$target" ]]; then
    local current
    current=$(readlink "$target")
    if [[ "$current" == "$source" ]]; then
      log_skip "Symlink already correct: $target"
      return 0
    fi
  fi

  # If target exists (file, dir, or wrong symlink), back it up
  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
  fi

  # Ensure parent directory exists
  ensure_dir "$(dirname "$target")"

  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would link $target -> $source"
    return 0
  fi

  # Create symlink
  ln -s "$source" "$target"
  log_ok "Linked $target -> $source"
}

append_if_missing() {
  local file="$1"
  local line="$2"

  if [[ ! -f "$file" ]]; then
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
      log_skip "(dry-run) Would create file: $file"
    else
      touch "$file"
    fi
  fi

  if ! grep -qxF "$line" "$file" 2>/dev/null; then
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
      log_skip "(dry-run) Would append to $file: $line"
      return 0
    fi
    echo "$line" >> "$file"
    log_ok "Appended to $file"
  fi
}

run_or_dry() {
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would run: $*"
    return 0
  fi
  "$@"
}

require_macos() {
  if [[ "$OSTYPE" != darwin* ]]; then
    log_fail "This script is designed for macOS only."
    exit 1
  fi
}
