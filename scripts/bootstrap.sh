#!/usr/bin/env bash
# Reproduce this machine on a fresh install:
#   1. Install all packages (pacman + AUR) from scripts/packages/
#   2. Install root-owned system-sleep hooks
#   3. Deploy dotfiles with stow (via install.sh)
# Assumes a fresh Omarchy (or Arch) base. Run from a terminal with sudo available.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing pacman packages (explicit list)"
sudo pacman -S --needed - < "$REPO_DIR/scripts/packages/explicit.txt"

aur_list="$REPO_DIR/scripts/packages/aur.txt"
if [[ -s "$aur_list" ]]; then
    helper="$(command -v paru || command -v yay || true)"
    if [[ -z "$helper" ]]; then
        echo "!! No AUR helper found (paru/yay). Install one and re-run this script." >&2
        exit 1
    fi
    echo "==> Installing AUR packages via ${helper##*/}"
    "$helper" -S --needed - < "$aur_list"
fi

echo "==> Installing system sleep hooks (root)"
for hook in "$REPO_DIR"/scripts/system-sleep/*; do
    [[ -e "$hook" ]] || continue
    echo "  /usr/lib/systemd/system-sleep/$(basename "$hook")"
    sudo install -Dm755 "$hook" "/usr/lib/systemd/system-sleep/$(basename "$hook")"
done

echo "==> Deploying dotfiles"
"$REPO_DIR/install.sh"

# Pick up user units restored by stow (enable-state comes via .wants symlinks)
systemctl --user daemon-reload 2>/dev/null || true

echo "==> Bootstrap complete. Reboot or log out/in for a clean session."