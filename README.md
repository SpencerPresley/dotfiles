# Dotfiles

Personal dotfiles managed with chezmoi + 1Password.

## New Machine Setup

**Automated:**

```bash
curl -fsSL https://raw.githubusercontent.com/SpencerPresley/dotfiles/main/bootstrap.sh | bash
```

**What bootstrap does:**

1. Installs Xcode CLT, Homebrew
2. Installs essentials (`chezmoi`, `git`, `gh`, `1password`, `1password-cli`)
3. Prompts for 1Password setup (CLI integration + SSH Agent)
4. Authenticates with GitHub via `gh auth login`
5. Installs Oh My Zsh
6. Runs `chezmoi init` (clones dotfiles repo)
7. Runs `brew bundle` (installs all packages from Brewfile)
8. Runs `chezmoi apply` (lays down dotfiles, runs setup scripts)

After bootstrap: open a new terminal, then run `tmux` and press `prefix + I` to install plugins.

**Manual post-setup:**

- **Work GitHub SSH**: The `github-work` SSH alias is managed by chezmoi, but the key and auth are not. Generate or copy `~/.ssh/id_work`, add the public key to the work GitHub account, then `gh auth login` for that account.

## What's Included

**Managed by chezmoi:**

- Shell: `.zshrc`, `.zshenv`, `.zprofile`, `.p10k.zsh`
- Git: `.gitconfig`, `.config/git/ignore`
- Editors: `.vimrc`
- Terminal: `.config/tmux/`, `.config/ghostty/config`
- Tools: `.config/gh/`, `.config/ssh/`, `.config/aria2/`

**Auto-installed by `.chezmoiscripts/`:**

- Neovim config (cloned from [NeovimSetup](https://github.com/SpencerPresley/NeovimSetup))
- Powerlevel10k, zsh-autosuggestions, fast-syntax-highlighting
- TPM (tmux plugin manager)
- Bun, Rust, uv
- Docker Compose CLI plugin (macOS)
- Ollama (native install, migrates from Homebrew if needed)
- Ollama environment LaunchAgent (env vars from `.chezmoidata/ollama.yaml`)
