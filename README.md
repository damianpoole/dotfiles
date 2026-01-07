# Dotfiles

My personal collection of configuration files (dotfiles) for macOS, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## 🛠️ Configurations

This repository includes configurations for the following tools:

- **[Aerospace](https://github.com/nikitabobko/AeroSpace):** Tiling window manager for macOS.
- **[JankyBorders](https://github.com/FelixKratz/JankyBorders):** Highlight active window borders.
- **[Ghostty](https://github.com/ghostty-org/ghostty):** GPU-accelerated terminal emulator.
- **[Neovim](https://neovim.io/):** Text editor configuration based on [LazyVim](https://www.lazyvim.org/).
- **[Sketchybar](https://github.com/FelixKratz/Sketchybar):** Highly customizable macOS status bar.
- **[Tmux](https://github.com/tmux/tmux):** Terminal multiplexer managed with [TPM](https://github.com/tmux-plugins/tpm).
- **[Yazi](https://github.com/sxyazi/yazi):** Blazing fast terminal file manager.
- **Zsh:** Shell configuration.

## 🚀 Installation

### Prerequisites

Ensure you have [Homebrew](https://brew.sh/) installed, then install Stow:

```sh
brew install stow
```

### Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/yourusername/dotfiles.git ~/Git/dotfiles
   cd ~/Git/dotfiles
   ```

2. **Symlink configurations:**

   This repository uses a `.stowrc` file to set the default target directory to `~/.config`. To stow all packages at once:

   ```sh
   stow .
   ```

   **Note on specific packages:**

   If you need to stow a package to a different location (like `zshrc` to `~` instead of `~/.config`), you can override the target:

   ```sh
   stow --target=$HOME zshrc
   ```

   To unstow (remove links):

   ```sh
   stow -D package_name
   ```
