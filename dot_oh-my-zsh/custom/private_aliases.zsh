# Custom Aliases
# ==============
# Format: alias name="command"  # description
#
# The `aliases` function parses this file to display all aliases with their
# descriptions. Add an inline comment (# description) after any alias to
# have it appear in the output.
#
# Section headers (lines starting with # followed by a word and no alias)
# are also displayed to group related aliases.

# Git
alias gs="git status"  # show git status
alias gb="git branch --sort=-committerdate"  # list branches by recent commit
alias gc="git checkout"  # checkout branch/file
alias gl="git log --oneline -20"  # show last 20 commits (oneline)
alias gd="git diff"  # show unstaged changes
alias gds="git diff --staged"  # show staged changes
alias force="git push --force-with-lease"  # safe force push

# Node/Bun
alias nfresh="rm -rf node_modules package-lock.json && npm i"  # clean reinstall (npm)
alias nremove="rm -rf node_modules package-lock.json"  # remove node_modules + lockfile
alias bfresh="rm -rf node_modules bun.lockb && bun i"  # clean reinstall (bun)

# Navigation
alias dotfiles="chezmoi cd"  # cd to chezmoi dotfiles dir

# Editor
alias vim="nvim"  # use neovim

# SSH
alias ssh="ssh -F ~/.config/ssh/config"  # use custom ssh config
alias ssh-config="nvim ~/.config/ssh/config"  # edit ssh config

# Tools
alias 7z='7zz'  # 7-Zip
alias aria='aria2c'  # aria2 download manager
alias aria2='aria2c'  # aria2 download manager
alias aria-start='aria2c --conf-path=~/.config/aria2/aria2.conf'  # start aria2 RPC daemon (with secret)

# Serena
alias serena='uvx --from git+https://github.com/oraios/serena serena'  # run serena
alias serena-init='serena-init-project'  # init serena project (see functions)
alias serena-i='serena-init-project'  # init serena project (short)
alias si='serena-init-project'  # init serena project (shortest)

# Add 'dangerously-skip-permissions' as a mode i can switch to
# without auto-activating it
alias claude='claude --allow-dangerously-skip-permissions'
