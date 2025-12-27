# Git
alias gs="git status"
alias gb="git branch --sort=-committerdate"
alias gc="git checkout"
alias gl="git log --oneline -20"
alias gd="git diff"
alias gds="git diff --staged"
alias force="git push --force-with-lease"

# Node/Bun
alias nfresh="rm -rf node_modules package-lock.json && npm i"
alias nremove="rm -rf node_modules package-lock.json"
alias bfresh="rm -rf node_modules bun.lockb && bun i"

# Navigation
alias dotfiles="chezmoi cd"

# Editor
alias vim="nvim"

# SSH
alias ssh="ssh -F ~/.config/ssh/config"
alias ssh-config="nvim ~/.config/ssh/config"

# Tools
alias ollama='OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 ollama'
alias 7z='7zz'

# Serena
alias serena='uvx --from git+https://github.com/oraios/serena serena'
alias serena-init='serena-init-project'
alias serena-i='serena-init-project'
alias si='serena-init-project'
