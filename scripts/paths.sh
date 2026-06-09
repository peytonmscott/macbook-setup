#!/usr/bin/env bash
# paths.sh - Verify and fix PATH for tools installed outside Homebrew
# This script manages ~/.zshenv as a fallback for non-Homebrew tool paths.
# Most paths should already live in the canonical dotfiles/zsh/zshrc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "PATH Configuration"

# ~/.zshenv is machine-local (not symlinked) so it is safe to append to.
ZSHENV="$HOME/.zshenv"

ensure_in_path() {
  local name="$1"
  local dir="$2"
  local export_line="$3"

  if [[ ! -d "$dir" ]]; then
    log_skip "$name directory not found: $dir"
    return 0
  fi

  if command_exists "$name"; then
    log_ok "$name already in PATH ($(command -v "$name"))"
    return 0
  fi

  # Check if dir is already in PATH via current shell
  if [[ ":$PATH:" == *":$dir:"* ]]; then
    log_ok "$name dir already in PATH: $dir"
    return 0
  fi

  # Fallback: append to ~/.zshenv so it persists
  log_warn "$name found at $dir but not in PATH"
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would append to $ZSHENV: $export_line"
  else
    append_if_missing "$ZSHENV" "$export_line"
    export PATH="$dir:$PATH"
    log_ok "$name added to PATH via $ZSHENV"
  fi
}

# Kotlin
ensure_in_path "kotlin" "$HOME/.local/share/kotlin/bin" 'export PATH="$HOME/.local/share/kotlin/bin:$PATH"'

# Android adb
ensure_in_path "adb" "$HOME/Library/Android/sdk/platform-tools" 'export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"'

# Android sdkmanager
ensure_in_path "sdkmanager" "$HOME/Library/Android/sdk/cmdline-tools/latest/bin" 'export PATH="$HOME/Library/Android/sdk/cmdline-tools/latest/bin:$PATH"'

log_ok "PATH configuration complete"
