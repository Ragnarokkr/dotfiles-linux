#!/usr/bin/env sh

# This script downloads the dotfiles repository and runs the setup script.

set -euo pipefail

typeset REPO_URL="https://github.com/ragnarokkr/dotfiles-linux.git"
typeset INSTALL_DIR="${XDG_LOCAL_SHARE:=$HOME/.local/share/dotfiles}"

echo "Cloning dotfiles repository from $REPO_URL to $INSTALL_DIR..."
if git clone "$REPO_URL" "$INSTALL_DIR"; then
    echo "Repository cloned successfully."
else
    echo "Error: Failed to clone repository. Please check your internet connection and try again."
    exit 1
fi

echo "Running setup script..."
if [ -f "$INSTALL_DIR/setup.sh" ]; then
    cd "$INSTALL_DIR" || exit
    ./setup.sh
else
    echo "Error: setup.sh not found in $INSTALL_DIR."
    exit 1
fi

echo "Dotfiles installation complete."
