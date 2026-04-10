#!/bin/bash
# Bootstrap script for new Mac setup
# Run with: curl -fsSL https://raw.githubusercontent.com/spencerpresley/dotfiles/main/bootstrap.sh | bash

set -e

echo "=== Setting up your Mac ==="

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key after Xcode tools are installed..."
    read -n 1
fi

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update Homebrew
brew update

# Install essentials first
echo "Installing essentials..."
brew install chezmoi git gh
brew install --cask 1password 1password-cli

echo ""
echo "=== MANUAL STEPS REQUIRED ==="
echo "1. Open 1Password and sign in"
echo "2. Settings → Developer → Enable 'Integrate with 1Password CLI'"
echo "3. Settings → Developer → Enable 'SSH Agent'"
echo ""
echo "Press any key when done..."
read -n 1

# GitHub auth
echo "Authenticating with GitHub..."
gh auth login

# Oh My Zsh (must be before chezmoi — shell plugins clone into its custom dir)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Apply dotfiles with chezmoi
# .chezmoiscripts handle: shell plugins, dev tools, docker compose, ollama
echo "Applying dotfiles..."
chezmoi init --apply spencerpresley/dotfiles

# Install all brew packages
echo "Installing brew packages..."
brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"

echo ""
echo "=== DONE! ==="
echo ""
echo "Open a new terminal, then run tmux and press prefix + I to install plugins."
echo ""
