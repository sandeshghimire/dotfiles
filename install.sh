#!/usr/bin/env bash
# Deploy all dotfiles packages with GNU Stow.
# Safe to re-run: uses --restow to refresh existing links.
# Existing real files/dirs at target paths (e.g. stock configs on a fresh
# Omarchy install) are backed up to ~/.dotfiles-backup/<timestamp>/ first.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup_target() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        local rel="${target#"$HOME"/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        echo "  Backing up existing: $target"
        mv "$target" "$BACKUP_DIR/$rel"
    fi
}

for pkg_path in "$DOTFILES_DIR"/*/; do
    pkg="$(basename "$pkg_path")"
    echo "Stowing: $pkg"

    # Back up existing targets before stowing (handles fresh installs with stock configs)
    for top in "$pkg_path"/* "$pkg_path"/.[!.]*; do
        [[ -e "$top" ]] || continue
        name="$(basename "$top")"
        if [[ "$name" == ".config" ]]; then
            for child in "$top"/* "$top"/.[!.]*; do
                [[ -e "$child" ]] || continue
                backup_target "$HOME/.config/$(basename "$child")"
            done
        else
            backup_target "$HOME/$name"
        fi
    done

    stow --restow --dir="$DOTFILES_DIR" --target="$HOME" "$pkg"
done

echo "Done. All packages linked into \$HOME."