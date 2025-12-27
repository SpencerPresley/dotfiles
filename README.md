# Dotfiles

Personal dotfiles managed with chezmoi + 1Password.

## New Machine Setup

### Option 1: One-liner (after pushing to GitHub)
```bash
curl -fsSL https://raw.githubusercontent.com/spencerpresley/dotfiles/main/bootstrap.sh | bash
```

### Option 2: Step by step

#### 1. Xcode CLI tools
```bash
xcode-select --install
```

#### 2. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### 3. Essentials
```bash
brew install chezmoi git gh
brew install --cask 1password 1password-cli
```

#### 4. 1Password setup
- Open 1Password and sign in
- Settings → Developer → Enable **Integrate with 1Password CLI**
- Settings → Developer → Enable **SSH Agent**

#### 5. GitHub auth
```bash
gh auth login
```

#### 6. Apply dotfiles
```bash
chezmoi init --apply spencerpresley/dotfiles
```

#### 7. Brew packages
```bash
brew bundle --file=~/.local/share/chezmoi/Brewfile
```

#### 8. Shell tools
```bash
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

# TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### 9. Dev tools
```bash
# Bun
curl -fsSL https://bun.sh/install | bash

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Manual setup

#### Cursor
```bash
# Copy settings
cp ~/.local/share/chezmoi/reference/cursor-settings.json ~/Library/Application\ Support/Cursor/User/settings.json

# Install extensions
cat ~/.local/share/chezmoi/reference/cursor-extensions.txt | xargs -I {} cursor --install-extension {}
```

#### Claude Desktop
```bash
cp ~/.local/share/chezmoi/reference/claude-desktop-config.json ~/Library/Application\ Support/Claude/claude_desktop_config.json
# Edit the file and replace ~ with /Users/yourusername
```

#### Tmux plugins
```bash
tmux
# Press: prefix + I
```

#### Work projects
Copy `.env` files from `reference/work-envs/` to respective projects.

---

## What's included

### Managed dotfiles
- `.zshrc`, `.zshenv`, `.zprofile`, `.p10k.zsh`
- `.gitconfig`, `.config/git/ignore`
- `.config/nvim`, `.config/tmux/tmux.conf`
- `.config/ghostty/config`, `.config/karabiner/karabiner.json`
- `.config/gh/config.yml`, `.config/ssh/config`
- `.claude/settings.json`, `.claude/commands/`
- `.local/bin/npx-latest.sh`

### Reference files (manual copy)
- `reference/cursor-settings.json` - Cursor editor settings
- `reference/cursor-extensions.txt` - Cursor extension list
- `reference/claude-desktop-config.json` - Claude Desktop MCP config
- `reference/work-envs/` - Work project .env templates
- `reference/prompts/` - Claude system prompts
- `reference/CLAUDE.md` - Claude Code project instructions template
- `reference/opencode.json.example`, `reference/oh-my-opencode.json` - OpenCode config

### Secrets (in 1Password)
- GitHub PAT
- API keys: OpenAI, Anthropic, Gemini, OpenRouter, LangSmith, Context7, OpenCode, Ollama
- AWS CLI credentials
- AWS Console login (SpencerP)
- SSH keys (atlasconnect-key)
- Firefox recovery key
- Raycast token
