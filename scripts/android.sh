#!/usr/bin/env bash
# android.sh - Install Android CLI tools using the official Google installer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Android CLI Tools"

ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ANDROID_SDK_ROOT="$ANDROID_HOME"

if command_exists adb && command_exists sdkmanager; then
  log_ok "Android CLI tools already available"
else
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_skip "(dry-run) Would run official Android installer"
  else
    log_warn "Running official Android CLI installer..."
    # Official Google installer for Apple Silicon macOS
    curl -fsSL "https://dl.google.com/android/cli/latest/darwin_arm64/install.sh" | bash || {
      log_fail "Official Android installer failed."
      log_warn "You may need to install Android Studio or the command line tools manually."
      exit 1
    }
  fi
fi

# Ensure env vars are set for this session and future shells
if [[ "${DRY_RUN:-false}" != "true" ]]; then
  export ANDROID_HOME
  export ANDROID_SDK_ROOT
  if [[ -d "$ANDROID_HOME/platform-tools" ]]; then
    export PATH="$ANDROID_HOME/platform-tools:$PATH"
  fi
  if [[ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]]; then
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
  elif [[ -d "$ANDROID_HOME/cmdline-tools/bin" ]]; then
    export PATH="$ANDROID_HOME/cmdline-tools/bin:$PATH"
  fi
fi

# Install common SDK packages
if [[ "${DRY_RUN:-false}" != "true" ]]; then
  if command_exists sdkmanager; then
    log_section "Installing Android SDK packages..."
    yes | sdkmanager --licenses || true
    sdkmanager --install "platform-tools" "platforms;android-35" "build-tools;35.0.0" "emulator" "cmdline-tools;latest" || true
    log_ok "Android SDK packages installed"
  else
    log_warn "sdkmanager not found. Skipping SDK package installation."
  fi
fi

log_ok "Android CLI setup complete"
