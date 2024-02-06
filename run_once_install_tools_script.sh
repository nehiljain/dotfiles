#!/bin/bash

# Check if chezmoi is installed
if command -v chezmoi >/dev/null 2>&1; then
    echo "chezmoi is installed."
else
    echo "chezmoi is not installed."
    exit 1
fi

# Change directory to chezmoi
chezmoi cd || exit 1

# Update chezmoi
chezmoi update || exit 1

# Function to install and set fish as the default shell
function install_and_set_fish {
    # Install oh-my-fish
    curl -L https://get.oh-my.fish | fish || exit 1

    # Get the path to the fish binary
    fish_path=$(which fish)

    # Check if fish path already exists in /etc/shells
    if ! grep -q "^$fish_path$" /etc/shells; then
        echo "here adding fish"
        # If it doesn't exist, add it
        sudo bash -c "echo $fish_path >> /etc/shells"
    fi

    # Set fish as the default shell
    chsh -s "$fish_path"
}

# # Call the install_and_set_fish function
# install_and_set_fish || exit 1

# # Kill terminal app
# exit 0
