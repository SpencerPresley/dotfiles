#!/bin/bash
set -euo pipefail

echo "==> Setting up Neovim config..."

NVIM_DIR="$HOME/.config/nvim"

if [ -d "$NVIM_DIR" ]; then
    echo "    Neovim config already exists."
else
    echo "    Cloning NeovimSetup..."
    git clone git@github.com:SpencerPresley/NeovimSetup.git "$NVIM_DIR"
fi

echo "==> Neovim config complete."
