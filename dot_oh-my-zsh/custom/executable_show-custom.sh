#!/bin/bash
# Parses aliases.zsh and functions.zsh to display custom aliases and functions
# Called by the `aliases` function in functions.zsh

ALIASES_FILE=~/.oh-my-zsh/custom/aliases.zsh
FUNCTIONS_FILE=~/.oh-my-zsh/custom/functions.zsh

echo "=== Custom Aliases ==="
echo

# Parse aliases.zsh
# Looks for section headers (# Word) and aliases with inline comments
while IFS= read -r line; do
  # Section headers: lines like "# Git" but not documentation lines
  if [[ "$line" =~ ^#\ ([A-Za-z][A-Za-z0-9/]+)$ ]]; then
    echo "${BASH_REMATCH[1]}"
  # Aliases with descriptions: alias name="..."  # description
  elif [[ "$line" =~ ^alias\ ([^=]+)=.*\#\ (.+)$ ]]; then
    printf "  %-14s %s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
  fi
done < "$ALIASES_FILE"

echo
echo "=== Custom Functions ==="
echo

# Parse functions.zsh
# Format: # func-name - description, then # Usage: ..., then func-name() {
# Skips internal functions (starting with _) and aliases()
current_name=""
current_desc=""
current_usage=""

while IFS= read -r line; do
  # Match "# function-name - description"
  if [[ "$line" =~ ^#\ ([a-zA-Z0-9][a-zA-Z0-9_-]*)\ -\ (.+)$ ]]; then
    name="${BASH_REMATCH[1]}"
    # Skip internal functions and aliases() itself
    if [[ "$name" != _* ]] && [[ "$name" != "aliases" ]]; then
      current_name="$name"
      current_desc="${BASH_REMATCH[2]}"
      current_usage=""
    else
      current_name=""
      current_desc=""
    fi
  # Match "# Usage: ..."
  elif [[ "$line" =~ ^#\ Usage:\ (.+)$ ]] && [[ -n "$current_name" ]]; then
    current_usage="${BASH_REMATCH[1]}"
  # When we hit a function definition and have pending info, print it
  elif [[ "$line" =~ \(\)\ *\{$ ]] && [[ -n "$current_name" ]]; then
    if [[ -n "$current_usage" ]]; then
      printf "  %s\n" "$current_usage"
    else
      printf "  %s\n" "$current_name"
    fi
    printf "                %s\n" "$current_desc"
    current_name=""
    current_desc=""
    current_usage=""
  fi
done < "$FUNCTIONS_FILE"
