# Dotfiles

Personal configs, managed with [GNU Stow](https://www.gnu.org/software/stow/).

```
shared/     # portable: nvim extras, yazi, herdr overlay
macos/      # Aerospace, Sketchybar, Ghostty, zsh, tmux, LazyVim bootstrap
omarchy/    # bash extras sourced into ~/.bashrc
```

## Install

### macOS

```sh
brew install stow
./install-macos.sh
```

That stows `shared/` and `macos/` into `~/.config`, and `macos/zshrc` into `$HOME`.

If you previously used a flat `stow .` layout, unstow once from the old tree (or remove the old symlinks), pull this layout, then run `./install-macos.sh`.

### Omarchy (Linux)

Omarchy already owns Hyprland, Ghostty, Herdr, bash, and a LazyVim tree. Fold extras on top:

```sh
./install-omarchy.sh
```

That command:

- Symlinks unique Neovim plugins, `user-options.lua`, `lazyvim.json`, spell files, and Yazi from `shared/`
- Leaves Omarchy’s `init.lua`, `lazy.lua`, theme plugins, and empty keymap/autocmd stubs alone
- Patches Omarchy’s `herdr/config.toml` with `shared/herdr/config.toml` (prefix, onboarding, plugin keys)
- Appends a `source` of `omarchy/bashrc` to `~/.bashrc` once
- Re-runs cleanly after `git pull`

Do not run `install-macos.sh` on Omarchy, or `stow .` from the repo root.

## Neovim layout

| Tree | Contents |
|------|----------|
| `shared/nvim/` | Plugins and `lua/config/user-options.lua` that fold into any LazyVim install |
| `macos/nvim/` | Full LazyVim bootstrap (`init.lua`, `lazy.lua`, Catppuccin `core.lua`, stubs) |

Omarchy uses stock LazyVim + `theme.lua`; Mac uses `macos/nvim` + the same shared plugins.
