#!/bin/bash

# Define the URL for the app and its destination directory
APP_URL="https://betterdictation.com/macos/BetterDictation-5b5e6965d6825a50bda0eae3ecb56da2.zip?vsn=d"
TEMP_DIR="/tmp/betterdictation"
DEST_DIR="/Applications"

# Create a temporary directory
mkdir -p "$TEMP_DIR"

# Download the app
echo "Downloading BetterDictation..."
curl -L -o "$TEMP_DIR/BetterDictation.zip" "$APP_URL"

# Extract the app
echo "Extracting BetterDictation..."
unzip -q "$TEMP_DIR/BetterDictation.zip" -d "$TEMP_DIR"

# Move the app to the Applications folder
echo "Installing BetterDictation..."
mv "$TEMP_DIR/BetterDictation.app" "$DEST_DIR"

# Clean up the temporary directory
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "BetterDictation installed successfully!"
