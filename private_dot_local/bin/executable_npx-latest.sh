#!/bin/bash
# Wrapper script to run npx using the latest nvm node version
# Used for MCP servers in Claude Desktop which can't resolve dynamic paths

NVM_DIR="$HOME/.nvm/versions/node"
LATEST=$(ls -v "$NVM_DIR" 2>/dev/null | tail -1)

if [[ -z "$LATEST" ]]; then
    echo "Error: No node versions found in $NVM_DIR" >&2
    exit 1
fi

exec "$NVM_DIR/$LATEST/bin/npx" "$@"
