#!/usr/bin/env bash
# git.sh - Configure global Git settings

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

log_section "Git Configuration"

if [[ -z "${GIT_NAME:-}" || -z "${GIT_EMAIL:-}" ]]; then
  log_fail "GIT_NAME and GIT_EMAIL must be set before running git.sh"
  exit 1
fi

run_or_dry git config --global user.name "$GIT_NAME"
run_or_dry git config --global user.email "$GIT_EMAIL"
run_or_dry git config --global init.defaultBranch main
run_or_dry git config --global core.excludesfile "$HOME/.gitignore_global"
run_or_dry git config --global rerere.enabled true
run_or_dry git config --global push.autoSetupRemote true
run_or_dry git config --global pull.rebase false

log_ok "Git configured"
