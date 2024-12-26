#!/bin/bash

# Ensure Fish shell is installed
if ! command -v fish &> /dev/null; then
    echo "Fish shell not found. Installing..."
    brew install fish
fi

# Dynamically find the path to the Fish shell
FISH_PATH=$(which fish)

# Ensure Fish is added to the list of login shells
if ! grep -Fxq "$FISH_PATH" /etc/shells; then
    echo "Adding $FISH_PATH to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

# Set Fish as the default shell for the user
if [ "$(dscl . -read ~/ UserShell | awk '{print $2}')" != "$FISH_PATH" ]; then
    echo "Setting $FISH_PATH as the default shell for user $(whoami)..."
    chsh -s "$FISH_PATH"
else
    echo "Fish shell is already the default shell."
fi

# Ensure Fisher is installed
if ! fish -c "type -q fisher"; then
    echo "Fisher not found. Installing..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fisher install jethrokuan/z
    fisher install PatrickF1/fzf.fish
    fisher install franciscolourenco/done
else
    echo "Fisher is already installed."
fi

if [ ! -f ~/.config/alacritty/catppuccin-frappe.toml ]; then
    echo "Downloading catppuccin-frappe.toml..."
    curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-frappe.toml
else
    echo "catppuccin-frappe.toml already exists."
fi


