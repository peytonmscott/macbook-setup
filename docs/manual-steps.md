# Manual Steps

After running `./bootstrap.sh`, some items still require manual intervention.

## Apple Account / iCloud

- Sign into your Apple Account / iCloud.
- Verify **Desktop and Documents** sync if applicable.
- Enable **Find My Mac** if desired.

## App Permissions

- **Aerospace**: Grant Accessibility permissions in  
  `System Settings > Privacy & Security > Accessibility`.
- **Terminal / Ghostty**: Grant **Full Disk Access** if desired.
- **Developer Tools**: Approve any system prompts for developer tool access.

## GitHub

- Run `gh auth login` to authenticate the GitHub CLI.
- Add an SSH key to your GitHub account if you haven't already:
  ```bash
  ssh-keygen -t ed25519 -C "your_email@example.com"
  cat ~/.ssh/id_ed25519.pub
  ```

## Android

- Open Android Studio or verify the SDK installation.
- Confirm emulator images are downloaded if needed.
- Run `sdkmanager --list` to review available packages.

## Maestro Studio

- Maestro CLI is installed via Homebrew.
- **Maestro Studio Desktop App**: If an official cask or stable download is not available, install manually from the official source.

## Restart

- **Restart your Mac** or log out and back in for all system settings to take full effect.
- Some Dock and Finder changes may need a restart to stick reliably.

## Optional / Nice to Have

- Set your default browser in `System Settings > Desktop & Dock`.
- Configure Time Machine backup.
- Sign into JetBrains Toolbox and install your preferred IDE.
- Customize Ghostty theme if the default isn't to your liking.
