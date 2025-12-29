#!/bin/bash
# run_once_install.sh - Runs once on new machines

set -e

echo "=== Installing dependencies ==="

# Oh My Zsh (check for oh-my-zsh.sh, not just directory - chezmoi may create custom/ first)
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# fast-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" ]; then
    echo "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
fi

# TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Bun
if [ ! -d "$HOME/.bun" ]; then
    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# Rust/Cargo
if [ ! -d "$HOME/.cargo" ]; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# uv (Python)
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Docker compose CLI plugin (for 'docker compose' command)
if [ ! -L "$HOME/.docker/cli-plugins/docker-compose" ]; then
    echo "Setting up docker compose CLI plugin..."
    mkdir -p "$HOME/.docker/cli-plugins"
    ln -sfn /opt/homebrew/bin/docker-compose "$HOME/.docker/cli-plugins/docker-compose"
fi

echo "=== Done! ==="
echo "Run 'source \$HOME/.zshrc' to reload shell"
echo "Run 'tmux' then 'prefix + I' to install tmux plugins"
