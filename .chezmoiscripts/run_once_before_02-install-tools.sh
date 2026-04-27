#!/bin/bash
set -euo pipefail

echo "==> Installing development tools..."

# Bun
if [ ! -d "$HOME/.bun" ]; then
    echo "    Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
else
    echo "    Bun already installed."
fi

# Rust/Cargo
if [ ! -d "$HOME/.cargo" ]; then
    echo "    Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    echo "    Rust already installed."
fi

# uv (Python)
if ! command -v uv &> /dev/null; then
    echo "    Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "    uv already installed."
fi

echo "==> Development tools complete."
