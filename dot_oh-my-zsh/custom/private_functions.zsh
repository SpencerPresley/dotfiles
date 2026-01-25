# aliases - Show custom aliases and functions
# Usage: aliases
# Parses aliases.zsh and functions.zsh to display all custom commands
# with their descriptions. Uses show-custom.sh for the actual parsing.
aliases() {
  bash ~/.oh-my-zsh/custom/show-custom.sh
}

# serena-init-project - Initialize a Serena project and add it as an MCP to Claude Code
# Usage: serena-init-project [--language <lang>] [other serena args...]
# Aliases: serena-init, serena-i, si
# - Creates a Serena project named after the current directory
# - Indexes the project and sets log level to INFO
# - Defaults to --language python if not specified
# - Adds the Serena MCP server to Claude Code for this project
serena-init-project() {
  local args=("$@")
  [[ ! " ${args[*]} " =~ " --language " ]] && args+=(--language python)
  uvx --from git+https://github.com/oraios/serena serena project create --name "${PWD##*/}" --index --log-level INFO "${args[@]}" && \
  claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code --project "$(pwd)"
}

# 7zip - create max-compressed zip files (compatible with standard unzip)
# Usage: 7zip <input_file> [output_file]
7zip() {
    if [[ -z "$1" ]]; then
        echo "Usage: 7zip <input_file> [output_file]"
        return 1
    fi
    local output="${2:-$1.zip}"
    7zz a -tzip -mx=9 "$output" "$1"
}

# Directory-specific claude alias for ac-agents project
autoload -Uz add-zsh-hook

_ac_agents_claude_alias() {
    if [[ "$PWD" == "$HOME/work/ac-agents"* ]]; then
        alias claude='claude --append-system-prompt "$(cat $HOME/work/ac-agents/research/prompts/.claude-system-prompt.txt)"'
    else
        unalias claude 2>/dev/null
    fi
}

add-zsh-hook chpwd _ac_agents_claude_alias
_ac_agents_claude_alias  # Run on shell startup

# claude-ctx - start Colima + Milvus for semantic code search
# Usage: claude-ctx
claude-ctx() {
  if ! colima status &>/dev/null; then
    echo "Starting Colima..."
    colima start
  fi
  if ! docker ps 2>/dev/null | grep -q milvus; then
    echo "Starting Milvus..."
    (cd ~/milvus && bash standalone_embed.sh start)
  fi
  echo "Claude Context ready (Milvus + Ollama)"
}

# claude-ctx-stop - stop Colima + Milvus services
# Usage: claude-ctx-stop
claude-ctx-stop() {
  echo "Stopping Milvus..."
  (cd ~/milvus && bash standalone_embed.sh stop)
  echo "Stopping Colima..."
  colima stop
  echo "Claude Context services stopped"
}
