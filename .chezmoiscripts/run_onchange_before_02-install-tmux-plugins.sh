#!/bin/bash
set -euo pipefail

echo "==> Installing tmux plugins..."

TMUX_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
TMUX_PLUGIN_DIR="$TMUX_CONFIG_DIR/plugins"

install_pinned_plugin() {
    local name="$1"
    local url="$2"
    local sha="$3"
    local dest="$4"
    local current=""

    if [ -d "$dest/.git" ]; then
        git -C "$dest" remote set-url origin "$url"
        current="$(git -C "$dest" rev-parse HEAD)"
        if [ -n "$(git -C "$dest" status --porcelain)" ]; then
            local backup="${dest}.pre-pin.$(date +%Y%m%d-%H%M%S).$$"
            echo "    Moving dirty $name directory to $backup."
            mv "$dest" "$backup"
        else
            if [ "$current" = "$sha" ]; then
                if git -C "$dest" symbolic-ref -q HEAD >/dev/null; then
                    echo "    Detaching $name at pinned commit $sha..."
                    git -C "$dest" checkout --detach "$sha"
                fi
                echo "    $name already pinned at $sha."
                return
            fi

            echo "    Pinning $name to $sha..."
            GIT_TERMINAL_PROMPT=0 git -C "$dest" fetch --depth=1 origin "$sha"
            git -C "$dest" checkout --detach "$sha"
            git -C "$dest" submodule update --init --recursive --depth=1
            return
        fi
    fi

    if [ -e "$dest" ]; then
        local backup="${dest}.pre-pin.$(date +%Y%m%d-%H%M%S).$$"
        echo "    Moving non-git $name directory to $backup."
        mv "$dest" "$backup"
    fi

    echo "    Cloning $name at $sha..."
    mkdir -p "$(dirname "$dest")"
    git init -q "$dest"
    git -C "$dest" remote add origin "$url"
    GIT_TERMINAL_PROMPT=0 git -C "$dest" fetch --depth=1 origin "$sha"
    git -C "$dest" checkout -q --detach FETCH_HEAD
    git -C "$dest" submodule update --init --recursive --depth=1

    current="$(git -C "$dest" rev-parse HEAD)"
    if [ "$current" != "$sha" ]; then
        echo "    $name expected $sha but checked out $current." >&2
        return 1
    fi
}

mkdir -p "$TMUX_PLUGIN_DIR"

install_pinned_plugin tpm https://github.com/tmux-plugins/tpm.git \
    99469c4a9b1ccf77fade25842dc7bafbc8ce9946 "$TMUX_PLUGIN_DIR/tpm"
install_pinned_plugin tmux-sensible https://github.com/tmux-plugins/tmux-sensible.git \
    25cb91f42d020f675bb0a2ce3fbd3a5d96119efa "$TMUX_PLUGIN_DIR/tmux-sensible"
install_pinned_plugin vim-tmux-navigator https://github.com/christoomey/vim-tmux-navigator.git \
    c45243dc1f32ac6bcf6068e5300f3b2b237e576a "$TMUX_PLUGIN_DIR/vim-tmux-navigator"
install_pinned_plugin tmux-resurrect https://github.com/tmux-plugins/tmux-resurrect.git \
    cff343cf9e81983d3da0c8562b01616f12e8d548 "$TMUX_PLUGIN_DIR/tmux-resurrect"
install_pinned_plugin tmux-continuum https://github.com/tmux-plugins/tmux-continuum.git \
    0698e8f4b17d6454c71bf5212895ec055c578da0 "$TMUX_PLUGIN_DIR/tmux-continuum"
install_pinned_plugin tmux-yank https://github.com/tmux-plugins/tmux-yank.git \
    acfd36e4fcba99f8310a7dfb432111c242fe7392 "$TMUX_PLUGIN_DIR/tmux-yank"
install_pinned_plugin tmux-menus https://github.com/jaclu/tmux-menus.git \
    879f56df1b9703ac277fa16b9bbaf8705f2e6a1c "$TMUX_PLUGIN_DIR/tmux-menus"

# Catppuccin's tmux repo is named "tmux", so keep it under a namespaced
# directory instead of TPM's flat plugin path to avoid ambiguity.
install_pinned_plugin catppuccin-tmux https://github.com/catppuccin/tmux.git \
    b2f219c00609ea1772bcfbdae0697807184743e4 "$TMUX_PLUGIN_DIR/catppuccin/tmux"

echo "==> Tmux plugins complete."
