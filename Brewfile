# Taps / external commands
tap "domt4/autoupdate", trusted: { command: "autoupdate" }

# Core tools
brew "bat"
brew "eza"
brew "chezmoi"
brew "coreutils"
brew "findutils"
brew "git"
brew "gnu-sed"
brew "gawk"
brew "moreutils"
brew "fd"
brew "fzf"
brew "zoxide"
brew "direnv"        # hooked in .zshrc (`eval "$(direnv hook zsh)"`)
brew "gh"
brew "gitleaks"
brew "htop"
brew "ncdu"          # interactive disk-usage browser (pairs with `dux`)
brew "jq"
brew "ripgrep"
brew "tree"
brew "wget"
brew "aria2"

# Dev
brew "bison"
brew "cmake"
brew "act"          # run GitHub Actions locally; configured by dot_actrc
brew "gopls"
brew "llvm"
brew "neovim"
brew "nvm"
brew "pnpm"
brew "luarocks"
brew "taplo"
brew "shellcheck"   # nvim-lint runs it for sh (nvim/lua/plugins/nvim-lint.lua)

# Containers
brew "colima"
brew "ctop"
brew "docker"
brew "docker-compose"
brew "lazydocker"

# Git
brew "git-delta"
brew "git-filter-repo"
brew "lazygit"

# AI/ML
brew "llama.cpp"
brew "opencode"
brew "hf"           # Hugging Face CLI

# Cloud
brew "awscli"

# Data/DB
brew "postgresql@18"
brew "redis"

# atlascyber-main local-dev host prereqs
# (.claude/skills/worktree-dev/SKILL.md "One-time setup", plus postgresql/redis
# above). WeasyPrint (apps/server/pyproject.toml) dlopens the cairo/pango stack
# at runtime. These are declared rather than left implicit because today they
# only reach a fresh machine as transitive deps of graphviz/poppler — and libffi
# via nothing declared at all — so `brew autoremove`, or dropping graphviz, would
# silently break the work setup.
brew "pango"
brew "cairo"
brew "glib"
brew "gdk-pixbuf"
brew "libffi"

# Terminal
brew "tmux"
brew "sesh"
brew "viu"

# Yazi file manager + preview dependencies
# (also uses fd, ripgrep, fzf, zoxide, jq, sevenzip from above)
brew "yazi"
brew "ffmpeg"       # video thumbnails
brew "imagemagick"  # HEIC/JXL/font previews
brew "poppler"      # PDF previews
brew "resvg"        # SVG previews

# Prompt engines (switch between them with `prompt-use`)
brew "starship"
brew "oh-my-posh"

# Misc
brew "graphviz"
brew "sevenzip"
brew "tlrc"
brew "wireshark"    # the formula = tshark CLI; the GUI cask is deliberately not here

# Security / recon
brew "nmap"
brew "semgrep"
brew "ffuf"         # web fuzzer (content/param discovery)

# Casks
cask "1password"
cask "1password-cli"
cask "betterdisplay"
cask "chatgpt"
cask "claude"
cask "dropbox"
cask "firefox"
cask "ghostty"
cask "gitkraken"
cask "google-chrome"
cask "obsidian"
cask "karabiner-elements"
cask "orbstack"           # dot_zprofile sources its shell init; script 14 sets the docker context
cask "rectangle"
cask "slack"
cask "session-manager-plugin"
cask "soundsource"
cask "spotify"
cask "stats"
cask "tailscale-app"
cask "visual-studio-code"

# Fonts
cask "font-fira-code-nerd-font"
cask "font-hack-nerd-font"
cask "font-jetbrains-mono-nerd-font"
cask "font-maple-mono-nf"
cask "font-meslo-for-powerlevel10k"
cask "font-monaspace"     # unpatched, kept: VS Code editor.fontFamily uses "Monaspace Neon"
cask "font-monaspace-nf"
cask "font-sauce-code-pro-nerd-font"
cask "font-symbols-only-nerd-font"
cask "font-victor-mono-nerd-font"
