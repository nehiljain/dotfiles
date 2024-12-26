# My macOS Dotfiles

This repository contains my personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/). It includes configurations for the Fish shell, various CLI tools, and macOS applications, all tailored to enhance productivity and streamline workflows.

## 🚀 Quick Start

1. **Install Homebrew**: If you haven't already, install Homebrew by following the instructions at [brew.sh](https://brew.sh/).

2. **Install chezmoi and initialize with this repo**:
   ```bash
   brew install chezmoi
   chezmoi init --apply https://github.com/nehiljain/dotfiles.git
   ```

3. **Run the setup script**: This script ensures that Fish shell and its plugins are installed and configured correctly.
   ```bash
   ./run_once_setup.sh
   ```

## ✨ What's Included

### 🛠 Core Tools
- **Shell**: Fish shell with custom aliases and functions.
- **Package Manager**: Homebrew for managing macOS packages.
- **Terminal Multiplexer**: tmux, configured via Brewfile.
- **Git**: Custom git configurations and aliases.
- **SSH**: 1Password SSH agent configuration.

### 📦 Key Applications (via Brewfile)
- **Development**: neovim, git, node, go, python (via pyenv).
- **CLI Tools**: fzf, ripgrep, bat, eza, jq.
- **Applications**: 
  - 1Password
  - Alacritty
  - Docker
  - Rectangle (window management)
  - And more...

### 🐟 Fish Shell Configuration
- Custom aliases and functions.
- Integration with:
  - z (directory jumping)
  - Fisher (plugin manager)
  - Done (notification on long-running commands)

### ⌨️ Karabiner Elements
- Caps Lock mapped to Hyperkey (Ctrl + Cmd + Shift + Opt).
- Custom terminal shortcuts.

### 🖥️ Rectangle
- Manage window layouts efficiently with Rectangle. For custom shortcuts, refer to the [Rectangle documentation](https://github.com/rxhanson/Rectangle?tab=readme-ov-file#import--export-json-config).

## 🔄 Update Process

1. **Update packages**:
   ```bash
   brew update && brew upgrade
   ```

2. **Update chezmoi**:
   ```bash
   chezmoi update
   ```

## FAQ

### Rectangle shortcuts can be tricky:

Read the [Rectangle documentation](https://github.com/rxhanson/Rectangle?tab=readme-ov-file#import--export-json-config) for more details. You may need to run:
```bash
mkdir -p ~/Library/Application\ Support/Rectangle/
```
Then, chezmoi can create the file `~/Library/Application\ Support/Rectangle/RectangleConfig.json`, which is read by Rectangle by default. If all else fails, use the import button for the JSON file directly.

## Contributing

Feel free to fork this repository and make your own customizations. Pull requests are welcome if you have improvements or additional features to suggest.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

