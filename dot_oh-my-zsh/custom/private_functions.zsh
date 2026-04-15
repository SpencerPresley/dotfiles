# aliases - Show custom aliases and functions
# Usage: aliases
# Parses aliases.zsh and functions.zsh to display all custom commands
# with their descriptions. Uses show-custom.sh for the actual parsing.
aliases() {
  bash ~/.oh-my-zsh/custom/show-custom.sh
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
