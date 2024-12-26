#!/bin/bash

# Check if Atuin is already registered by attempting to retrieve the encryption key
if atuin key &>/dev/null; then
    echo "Atuin is already registered. Skipping registration."
    exit 0
fi

# Prompt for registration details
echo "Atuin requires registration."
read -s -p "Password: " password
echo
read -s -p "Confirm Password: " confirm_password
echo

# Verify that the passwords match
if [[ "$password" != "$confirm_password" ]]; then
    echo "Passwords do not match. Exiting registration."
    exit 1
fi

# Register with Atuin
echo "Registering Atuin..."
atuin register -u "nehiljain" -e "jain.nehil@gmail.com" -p "$password"
if [ $? -eq 0 ]; then
    echo "Atuin registration successful."
else
    echo "Atuin registration failed."
    exit 1
fi

# Retrieve and display the encryption key
encryption_key=$(atuin key)
if [ $? -eq 0 ]; then
    echo "Your Atuin encryption key is: $encryption_key"
    echo "Please store this key securely; it is required for logging in on other machines."
else
    echo "Failed to retrieve Atuin encryption key."
    exit 1
fi
