#!/usr/bin/env bash
# Deploy all dotfiles packages with GNU Stow.
# Safe to re-run: uses --restow to refresh existing links.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for pkg_path in "$DOTFILES_DIR"/*/; do
    pkg="$(basename "$pkg_path")"
    echo "Stowing: $pkg"
    stow --restow --dir="$DOTFILES_DIR" --target="$HOME" "$pkg"
done

echo "Done. All packages linked into \$HOME."