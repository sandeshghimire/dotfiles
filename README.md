# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a **package** holding files at their real paths
relative to `$HOME`. Stowing a package symlinks it into place:

| Package   | Link target |
|-----------|-------------|
| `bash`    | `~/.bashrc`, `~/.bash_profile`, `~/.profile` |
| `git`     | `~/.config/git/` |
| `hypr`    | `~/.config/hypr/` (Hyprland) |
| `omarchy` | `~/.config/omarchy/` (shell config, themes, hooks, extensions) |
| `systemd` | `~/.config/systemd/user/` (custom units + enable state) |
| `foot`, `alacritty`, `kitty`, `ghostty` | terminal configs |
| `starship`| `~/.config/starship.toml` |
| `btop`    | `~/.config/btop/` |

## Reproduce a machine (fresh install)

```bash
git clone <remote-url> ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap.sh
```

### What `bootstrap.sh` restores

1. **Packages** — pacman explicit list + AUR list (idempotent via `--needed`)
2. **Root sleep hooks** — `scripts/system-sleep/*` → `/usr/lib/systemd/system-sleep/`
   (bluetooth resume fix, keyboard-backlight hibernate fix)
3. **Dotfiles** — every stow package, including user systemd units in `systemd/`
   (custom services like `voxtype` and their enable-state via `.wants` symlinks)

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/bootstrap.sh` | Install all packages from `scripts/packages/` (pacman + AUR via yay/paru), then deploy dotfiles. Assumes an Omarchy/Arch base. |
| `scripts/sync-packages.sh` | Refresh package lists from the current machine — run after adding/removing software. |
| `install.sh` | Deploy/re-link all stow packages only. |

Existing configs on the target (e.g. stock Omarchy files) are backed up to
`~/.dotfiles-backup/<timestamp>/` before stowing, so nothing is lost.

## Deploy dotfiles only

```bash
git clone <remote-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Daily use

Edit files through their normal paths (`~/.config/hypr/...`) — they are
symlinks into this repo. Commit changes from `~/dotfiles` like any git repo:

```bash
cd ~/dotfiles
git add -A && git commit -m "tweak hypr bindings"
git push
```

## Add a new config to track

```bash
mkdir -p ~/dotfiles/<app>/.config/<app>
mv ~/.config/<app> ~/dotfiles/<app>/.config/<app>
stow -d ~/dotfiles -t ~ <app>
```

## Unlink a package

```bash
stow -D -d ~/dotfiles -t ~ <app>   # removes symlinks, files stay in repo
```

## Notes

- `omarchy/.config/omarchy/plugins/` is gitignored — plugin clones have their
  own git repos and are managed by `omarchy plugin`.
- If an `omarchy refresh`/`reinstall` ever replaces a symlinked directory with
  real files, just re-run `./install.sh` to re-link.
- Never commit secrets (`.ssh/`, tokens, `.bash_history`).