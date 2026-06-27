#!/bin/bash
# Parses aliases.zsh and functions.zsh to display custom aliases and functions
# Called by the `aliases` function in functions.zsh

ALIASES_FILE=~/.oh-my-zsh/custom/aliases.zsh
FUNCTIONS_FILE=~/.oh-my-zsh/custom/functions.zsh

# Bold headers when attached to a terminal; plain when piped/redirected.
if [ -t 1 ]; then BOLD=$'\033[1m'; RESET=$'\033[0m'; else BOLD=""; RESET=""; fi

# --- Pass 1: find the widest alias name so every description lines up in one
#     uniform column across all sections (functions don't stretch it). ---
maxw=0
while IFS= read -r line; do
  if [[ "$line" =~ ^alias\ ([^=]+)=.*\#\ (.+)$ ]]; then
    n=${#BASH_REMATCH[1]}
    (( n > maxw )) && maxw=$n
  fi
done < "$ALIASES_FILE"
(( maxw < 4 )) && maxw=4
descindent=$((maxw + 4))   # 2 leading spaces + name column + 2 spaces

# print_row NAME DESC — inline if NAME fits the column, else wrap DESC underneath
print_row() {
  if (( ${#1} <= maxw )); then
    printf "  %-${maxw}s  %s\n" "$1" "$2"
  else
    printf "  %s\n" "$1"
    printf "%*s%s\n" "$descindent" "" "$2"
  fi
}

# ---- Aliases ----
echo "${BOLD}=== Custom Aliases ===${RESET}"
echo

first_section=1
while IFS= read -r line; do
  # Section headers: lines like "# Git" (single word, no alias)
  if [[ "$line" =~ ^#\ ([A-Za-z][A-Za-z0-9/]+)$ ]]; then
    [[ $first_section -eq 0 ]] && echo   # blank line between sections
    first_section=0
    printf "%s%s%s\n" "$BOLD" "${BASH_REMATCH[1]}" "$RESET"
  # Aliases with descriptions: alias name="..."  # description
  elif [[ "$line" =~ ^alias\ ([^=]+)=.*\#\ (.+)$ ]]; then
    print_row "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
  fi
done < "$ALIASES_FILE"

# ---- Functions ----
echo
echo "${BOLD}=== Custom Functions ===${RESET}"
echo

# Format: # func-name - description, then # Usage: ..., then func-name() {
# Skips internal functions (starting with _) and aliases() itself.
current_name=""
current_desc=""
current_usage=""
first_func=1
while IFS= read -r line; do
  if [[ "$line" =~ ^#\ ([a-zA-Z0-9][a-zA-Z0-9_-]*)\ -\ (.+)$ ]]; then
    name="${BASH_REMATCH[1]}"
    if [[ "$name" != _* ]] && [[ "$name" != "aliases" ]]; then
      current_name="$name"
      current_desc="${BASH_REMATCH[2]}"
      current_usage=""
    else
      current_name=""
      current_desc=""
    fi
  elif [[ "$line" =~ ^#\ Usage:\ (.+)$ ]] && [[ -n "$current_name" ]]; then
    current_usage="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ \(\)\ *\{$ ]] && [[ -n "$current_name" ]]; then
    [[ $first_func -eq 0 ]] && echo      # blank line between functions
    first_func=0
    print_row "${current_usage:-$current_name}" "$current_desc"
    current_name=""
    current_desc=""
    current_usage=""
  fi
done < "$FUNCTIONS_FILE"
