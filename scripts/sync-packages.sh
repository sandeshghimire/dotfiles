#!/usr/bin/env bash
# Refresh package lists from the current machine.
# Run after adding/removing software, then commit the change.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pacman -Qqe > "$REPO_DIR/scripts/packages/explicit.txt"
pacman -Qqm > "$REPO_DIR/scripts/packages/aur.txt"

echo "Updated package lists:"
echo "  pacman: $(wc -l < "$REPO_DIR/scripts/packages/explicit.txt") packages"
echo "  AUR:    $(wc -l < "$REPO_DIR/scripts/packages/aur.txt") packages"