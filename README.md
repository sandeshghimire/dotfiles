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
| `foot`, `alacritty`, `kitty`, `ghostty` | terminal configs |
| `starship`| `~/.config/starship.toml` |
| `btop`    | `~/.config/btop/` |

## Deploy on a new machine

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