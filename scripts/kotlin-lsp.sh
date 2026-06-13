#!/usr/bin/env bash
# kotlin-lsp.sh - Install Kotlin Language Server from JetBrains CDN
# Because the Homebrew tap often lags behind releases, we install directly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Kotlin Language Server"

KOTLIN_LSP_DIR="/opt/homebrew/opt/kotlin-lsp/libexec"
KOTLIN_LSP_VERSION="262.7569.0"
KOTLIN_LSP_URL="https://download-cdn.jetbrains.com/kotlin-lsp/${KOTLIN_LSP_VERSION}/kotlin-server-${KOTLIN_LSP_VERSION}-aarch64.sit"

# Check if already installed and not expired
if [[ -f "$KOTLIN_LSP_DIR/build.txt" ]]; then
  current_version=$(cat "$KOTLIN_LSP_DIR/build.txt")
  log_ok "Kotlin LSP already installed: $current_version"
  
  # Test if expired
  if "$KOTLIN_LSP_DIR/bin/intellij-server" --version >/dev/null 2>&1; then
    log_ok "Kotlin LSP is working"
    exit 0
  fi
  
  log_warn "Kotlin LSP may be expired, reinstalling..."
fi

if [[ "${DRY_RUN:-false}" == "true" ]]; then
  log_skip "(dry-run) Would download Kotlin LSP ${KOTLIN_LSP_VERSION}"
  exit 0
fi

# Download and install
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

log_warn "Downloading Kotlin LSP ${KOTLIN_LSP_VERSION}..."
curl -fsSL "$KOTLIN_LSP_URL" -o "$TMP_DIR/kotlin-lsp.sit"

log_warn "Extracting..."
cd "$TMP_DIR"
unzip -q kotlin-lsp.sit

log_warn "Installing to ${KOTLIN_LSP_DIR}..."
mkdir -p "$(dirname "$KOTLIN_LSP_DIR")"
rm -rf "$KOTLIN_LSP_DIR"
cp -R "kotlin-server-${KOTLIN_LSP_VERSION}" "$KOTLIN_LSP_DIR"

# Fix permissions
chmod +x "$KOTLIN_LSP_DIR/bin/intellij-server"
# Remove macOS quarantine
xattr -c "$KOTLIN_LSP_DIR/bin/intellij-server" 2>/dev/null || true

log_ok "Kotlin LSP ${KOTLIN_LSP_VERSION} installed"
