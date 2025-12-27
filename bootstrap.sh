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

# Apply dotfiles with chezmoi
echo "Applying dotfiles..."
chezmoi init --apply spencerpresley/dotfiles

# Install all brew packages
echo "Installing brew packages..."
brew bundle --file=~/.local/share/chezmoi/Brewfile

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# zsh plugins
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" ]; then
    echo "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
fi

# TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Bun
if [ ! -d "$HOME/.bun" ]; then
    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# Rust
if [ ! -d "$HOME/.cargo" ]; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# uv
if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

echo ""
echo "=== DONE! ==="
echo ""
echo "Manual steps remaining:"
echo "  1. Restart terminal or run: source ~/.zshrc"
echo "  2. Run tmux, then prefix + I to install plugins"
echo "  3. Copy Cursor settings from reference/cursor-settings.json"
echo "  4. Copy Claude Desktop config from reference/claude-desktop-config.json"
echo "  5. Copy work .env files from reference/work-envs/"
echo ""
