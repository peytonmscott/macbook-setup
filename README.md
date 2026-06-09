# macbook-setup

A boring, rerunnable, inspectable macOS provisioning system for Apple Silicon Macs.

## Quick Start

```bash
git clone <repo-url> ~/Developer/macbook-setup
cd ~/Developer/macbook-setup
./bootstrap.sh
```

## Features

- **One command** to provision a new Mac.
- **Role-based** setup: `personal` or `work`.
- **Idempotent** — safe to rerun.
- **Dry-run mode** for testing changes.
- **Boring Bash** — no magic, easy to audit.

## Structure

```
macbook-setup/
├── bootstrap.sh          # Main entrypoint
├── config/               # Environment presets
├── scripts/              # Modular setup scripts
├── brew/                 # Brewfiles for packages
└── docs/                 # Documentation
```

## Usage

### Interactive (default)

```bash
./bootstrap.sh
```

### Non-interactive

```bash
./bootstrap.sh --role personal --git-name "Peyton" --git-email "peyton@example.com"
```

With a dotfiles repo:

```bash
./bootstrap.sh --role personal --git-name "Peyton" --git-email "peyton@example.com" \
  --dotfiles-repo "https://github.com/yourusername/dotfiles.git"
```

### Flags

| Flag | Description |
|------|-------------|
| `--role personal\|work` | Machine role |
| `--git-name <name>` | Git user name |
| `--git-email <email>` | Git user email |
| `--dotfiles-repo <url>` | Clone dotfiles from this Git repo |
| `--skip-brew` | Skip Homebrew installation |
| `--skip-macos` | Skip macOS settings |
| `--skip-dotfiles` | Skip dotfiles linking |
| `--skip-packages` | Skip package installation |
| `--dry-run` | Show what would be done |
| `--help` | Show usage |

## What It Does

1. Validates macOS
2. Asks for role, Git name, and email (if not provided)
3. Optionally clones your real dotfiles repo (via `--dotfiles-repo` or interactive prompt)
4. Installs Xcode Command Line Tools
5. Installs Homebrew
6. Installs packages via `brew bundle`
7. Configures Git
8. Creates `~/Developer`
9. Symlinks dotfiles from your repo (with backups for conflicts)
10. Applies macOS settings (Dock, Finder, Keyboard, Menu Bar)
11. Installs Kotlin and Android CLI tools
12. Runs postflight checks and prints summary

## Dotfiles

This repo does **not** ship fake dotfiles. Instead, it can optionally clone your real dotfiles repository:

- **Flag**: `--dotfiles-repo https://github.com/yourusername/dotfiles.git`
- **Interactive**: You'll be prompted for a repo URL during bootstrap (leave blank to skip)
- **Auto-link**: If your dotfiles repo follows the structure below, `bootstrap.sh` will symlink them automatically. If the repo has an `install.sh`, that will be run instead.

Expected dotfiles repo structure:

```
dotfiles/
├── zsh/zshrc              -> ~/.zshrc
├── git/gitignore_global   -> ~/.gitignore_global
├── ghostty/               -> ~/.config/ghostty
├── aerospace/aerospace.toml -> ~/.config/aerospace/aerospace.toml
├── nvim/                  -> ~/.config/nvim
├── starship/starship.toml -> ~/.config/starship.toml
└── yazi/                  -> ~/.config/yazi
```

If no dotfiles repo is provided, apps will use their default configs.

## Safety

- Existing files are backed up with a timestamp before being replaced.
- Scripts use `set -euo pipefail`.
- Steps are skipped if already applied.

## Manual Steps

See [docs/manual-steps.md](docs/manual-steps.md) for remaining items.

## License

MIT
