# aliases - Show custom aliases and functions
# Usage: aliases
# Parses aliases.zsh and functions.zsh to display all custom commands
# with their descriptions. Uses show-custom.sh for the actual parsing.
aliases() {
  bash ~/.oh-my-zsh/custom/show-custom.sh
}

# cheatsheet - Quick reference for shell tools & keybindings (fzf, zoxide, eza, delta...)
# Usage: cheatsheet
# Prints the curated shell guide. Uses bat for color if available, else cat.
cheatsheet() {
  local f=~/.oh-my-zsh/custom/cheatsheet.txt
  if command -v bat >/dev/null 2>&1; then
    bat --style=plain --paging=never "$f"
  else
    cat "$f"
  fi
}

serena-init-project() {
  echo "To setup Serena now follow these steps:"
  echo "1. Run `uv tool install -p 3.13 serena-agent@latest --prerelease=allow`"
  echo "2. Run `serena setup claude-code`. This will setup serena globally e.g., user level for claude code."
  echo "To update run `uv tool upgrade serena-agent --prerelease=allow`"
  echo "To uninstall run `uv tool uninstall serena-agent`"
}

# 7zip - create max-compressed zip files (compatible with standard unzip)
# Usage: 7zip <input_file> [output_file]
7zip() {
    if [[ -z "$1" ]]; then
        echo "Usage: 7zip <input_file> [output_file]"
        return 1
    fi
    local output="${2:-$1.zip}"
    7zz a -tzip -mx=9 -mfb=258 -mpass=15 "$output" "$1"
}

# fe - Fuzzy-find file(s) with a bat preview and open them in nvim
# Usage: fe [query]
# Tab/Shift-Tab to multi-select; Enter opens all picks in nvim. (Plain Ctrl-T
# still just inserts a path into the current command line.)
fe() {
    local -a files
    files=("${(@f)$(fd --type f --hidden --follow --exclude .git 2>/dev/null \
        | fzf --multi --query="${1:-}" \
              --preview 'bat --style=numbers --color=always --line-range=:200 {}')}")
    (( ${#files} )) && [[ -n "${files[1]}" ]] && nvim "${files[@]}"
}
