# Dotfiles

Personal dotfiles managed with chezmoi + 1Password.

## New Machine Setup

**Quick Overview:**

1. Install Homebrew
2. Install essentials (chezmoi, git, 1password, 1password-cli)
3. Setup SSH for GitHub
4. Setup 1password (Integrate with 1Password CLI and SSH Agent)
5. Apply dot files (this also runs run_once_install.sh automatically)
6. Install brew packages (then check for any post-install caveats)
7. Restart terminal, then install tmux plugins
8. App setups (Cursor, Claude Desktop, etc.)

**Detailed Steps:**

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Install essentials
brew install chezmoi git
brew install --cask 1password 1password-cli

# 3. Setup SSH for GitHub (first time only)
ssh-keygen -t ed25519 -C "spencerpresley96@gmail.com"
cat "$HOME/.ssh/id_ed25519.pub"  # Add to GitHub → Settings → SSH Keys
ssh -T git@github.com  # Verify it works

# 4. Open 1Password, sign in, then:
#    Settings → Developer → Enable "Integrate with 1Password CLI"
#    Settings → Developer → Enable "SSH Agent"
#    (Optional: Add your SSH key to 1Password for future machines)

# 5. Apply dotfiles (this also runs run_once_install.sh automatically)
chezmoi init --apply git@github.com:spencerpresley/dotfiles.git

# 6. Install brew packages
brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"

# 7. Check for any post-install caveats
brew info $(brew leaves) 2>/dev/null | grep -B 2 -A 5 "Caveats"

# 8. Restart terminal, then install tmux plugins
tmux
# Press: Ctrl+a then Shift+i to install plugins

# 9. Cursor setup
cp "$HOME/.local/share/chezmoi/reference/cursor-settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
cat "$HOME/.local/share/chezmoi/reference/cursor-extensions.txt" | xargs -I {} cursor --install-extension {}

# 10. Claude Desktop setup
cp "$HOME/.local/share/chezmoi/reference/claude-desktop-config.json" "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
```

## What's Included

**Managed by chezmoi:**

- Shell: `.zshrc`, `.zshenv`, `.zprofile`, `.p10k.zsh`
- Git: `.gitconfig`, `.config/git/ignore`
- Editors: `.config/nvim/`, `.vimrc`
- Terminal: `.config/tmux/tmux.conf`, `.config/ghostty/config`
- Tools: `.config/gh/`, `.config/ssh/`, `.config/karabiner/`
- Claude: `.claude/settings.json`, `.claude/commands/`

**Auto-installed by `run_once_install.sh`:**

- Oh My Zsh + Powerlevel10k
- zsh-autosuggestions, fast-syntax-highlighting
- TPM (tmux plugin manager)
- Bun, Rust, uv

**Reference files (manual copy):**

- `reference/cursor-settings.json`
- `reference/cursor-extensions.txt`
- `reference/claude-desktop-config.json`
- `reference/work-envs/` - Work project .env templates
