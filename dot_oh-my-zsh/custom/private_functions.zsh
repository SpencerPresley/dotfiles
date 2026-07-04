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
    bat --style=plain --paging=never --wrap=never "$f"
  else
    cat "$f"
  fi
}

# relpath - Print real path(s) relative to the current directory
# Usage: relpath <path> [path ...]
relpath() {
  if (( $# == 0 )); then
    echo "Usage: relpath <path> [path ...]" >&2
    return 1
  fi

  python3 - "$@" <<'PY'
import os
import sys

for path in sys.argv[1:]:
    print(os.path.relpath(os.path.realpath(path)))
PY
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

# prompt-use - Switch the active shell prompt engine (p10k | starship | omp)
# Usage: prompt-use <engine>     e.g. prompt-use starship
# Writes ~/.config/prompt-engine (machine-local, not tracked by chezmoi) and
# reloads the shell so the new prompt takes effect. No args = show current +
# choices. Switching back is the same command; the other configs stay put.
prompt-use() {
  local -a engines=(p10k starship omp)
  local file="${XDG_CONFIG_HOME:-$HOME/.config}/prompt-engine"
  local current
  current=$(command cat "$file" 2>/dev/null || echo p10k)

  if (( $# == 0 )); then
    print -P "Current prompt engine: %F{cyan}$current%f"
    print    "Available:            ${engines[*]}"
    print -P "Usage: %F{green}prompt-use%f <${(j:|:)engines}>"
    return 0
  fi

  if [[ " ${engines[*]} " != *" $1 "* ]]; then
    print -P "%F{red}Unknown engine '$1'.%f Choose one of: ${engines[*]}" >&2
    return 1
  fi

  mkdir -p "${file:h}"
  print -r -- "$1" > "$file"
  print -P "Prompt engine → %F{green}$1%f  (reloading shell…)"
  exec zsh
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

# install-codex-skills - Install a skills repo into a project's .agents/skills for Codex (default: obra/superpowers)
# Usage: install-codex-skills [--path <dir>] [--local] [--force] [--repo <url>]
#   -p|-P|--path <dir>  Install into <dir> instead of the current directory.
#   -l|-L|--local       Gitignore the installed skills git isn't already
#                       tracking (leaves committed skills / lockfile alone).
#   -f|-F|--force       Override the $HOME refusal (only meaningful with --path).
#   -r|-R|--repo <url>  Install a different skills repo (default: obra/superpowers).
# Thin wrapper around `npx skills add` (scoped to Codex — the reason this exists
# is that the Codex superpowers plugin installs globally with no project scoping).
# That command already clones the repo and creates .agents/skills, so this only
# adds what it won't: a $HOME safety guard, an optional install path, and
# .gitignore management for --local.
install-codex-skills() {
  local repo="https://github.com/obra/superpowers"
  local target="$PWD"
  local path_given=0 local_ignore=0 force=0

  while (( $# )); do
    case "$1" in
      -p|-P|--path)
        [[ -n "$2" ]] || { print -P "%F{red}--path requires a directory argument.%f" >&2; return 1; }
        target="$2"; path_given=1; shift 2 ;;
      -r|-R|--repo)
        [[ -n "$2" ]] || { print -P "%F{red}--repo requires a URL argument.%f" >&2; return 1; }
        repo="$2"; shift 2 ;;
      -l|-L|--local)  local_ignore=1; shift ;;
      -f|-F|--force)  force=1; shift ;;
      -h|--help)
        print -P -- "%F{green}install-codex-skills%f — project-scoped skills for Codex (wraps 'npx skills add')

Installs a skills repo into ./.agents/skills for %F{cyan}Codex only%f, so superpowers-style
skills stay scoped to one project instead of active everywhere like the global Codex plugin.

%F{cyan}Usage%f
  install-codex-skills [--path <dir>] [--local] [--force] [--repo <url>]
  ics …                          (alias)

%F{cyan}Options%f
  -p -P --path <dir>   Install into <dir> instead of the current directory.
  -l -L --local        Gitignore the installed skills git isn't already tracking.
  -f -F --force        Override the \$HOME refusal (only meaningful with --path).
  -r -R --repo <url>   Install a different skills repo (default: obra/superpowers).
  -h    --help         Show this help.

%F{cyan}--local%f
  Ignores only skill dirs under .agents/skills that git isn't already tracking,
  plus skills-lock.json if untracked. Committed skills (and a shared lockfile)
  are left alone — a .gitignore can't ignore a tracked path, and un-committing
  isn't --local's job. To make an already-committed skill local, 'git rm --cached
  -r <path>' it yourself. Never creates a ~/.gitignore; at \$HOME it's a no-op.

%F{cyan}Guards%f
  • Refuses \$HOME unless you pass BOTH --path and --force; a bare cwd of \$HOME
    is always refused (treated as an accident).
  • In a non-repo with no .gitignore, --local warns instead of creating one.

%F{cyan}Examples%f
  ics                                  # superpowers → ./ for Codex
  ics --local                          # …and gitignore it
  ics -p ~/work/proj -l                # install into another project + gitignore
  ics --repo https://github.com/vercel-labs/agent-skills"
        return 0 ;;
      *)
        print -P "%F{red}Unknown option '$1'.%f" >&2
        print "Usage: install-codex-skills [--path <dir>] [--local] [--force] [--repo <url>]" >&2
        return 1 ;;
    esac
  done

  if [[ ! -d "$target" ]]; then
    print -P "%F{red}Not a directory: $target%f" >&2
    return 1
  fi
  local abs="${target:A}"

  # Guard: never blindly install into $HOME. Only an explicit `--path ~ --force`
  # may override — a bare cwd of $HOME is treated as an accident and refused.
  if [[ "$abs" == "${HOME:A}" ]]; then
    if (( path_given && force )); then
      print -P "%F{214}Warning: installing skills directly into \$HOME ($abs) [--force].%f"
      print -P "%F{214}  \$HOME is the top of every path — agents that walk up the tree may load these%f"
      print -P "%F{214}  skills from many/all directories (the un-scoped, active-everywhere behavior%f"
      print -P "%F{214}  this tool exists to avoid), and they can duplicate/conflict with any%f"
      print -P "%F{214}  per-project .agents/skills. Proceeding because --force was given.%f"
    else
      print -P "%F{red}Refusing to install skills into \$HOME ($abs).%f" >&2
      (( path_given )) && print -P "%F{red}Re-run with --force to install into \$HOME anyway (unscoped, active-everywhere risk).%f" >&2
      return 1
    fi
  fi

  ( cd "$abs" && npx skills add "$repo" --skill '*' --agent 'codex' --project --yes ) || return 1

  # Never write a ~/.gitignore. $HOME isn't a git repo (chezmoi lives elsewhere),
  # so an ignore file there does nothing — and you never want one. Turn --local
  # into a no-op here rather than creating it.
  if (( local_ignore )) && [[ "$abs" == "${HOME:A}" ]]; then
    print -P "%F{214}Warning: --local ignored at \$HOME — refusing to create ~/.gitignore.%f"
    print -P "%F{214}  To ignore .agents/ everywhere, add it to your global git excludes instead%f"
    print -P "%F{214}  (chezmoi: dot_config/private_git/private_ignore), not a ~/.gitignore.%f"
    local_ignore=0
  fi

  if (( local_ignore )); then
    local gi="$abs/.gitignore"
    local has_git=0; [[ -e "$abs/.git" ]] && has_git=1

    # Ignore only the skills git ISN'T already tracking (the ones this install
    # left uncommitted), plus skills-lock.json if untracked. Anything git tracks
    # — a committed skill or a shared lockfile — is left alone: a .gitignore
    # entry can't ignore a tracked path anyway, and un-committing files isn't
    # --local's job. git is the source of truth for "is this committed", so
    # there's no need to diff the installer's output to know what to ignore.
    local -a entries=() kept=()
    local d p
    for d in "$abs/.agents/skills"/*(N/); do
      p=".agents/skills/${d:t}/"
      if (( has_git )) && [[ -n "$(git -C "$abs" ls-files -- ".agents/skills/${d:t}" 2>/dev/null)" ]]; then
        kept+=( "$p" )
      else
        entries+=( "$p" )
      fi
    done
    if [[ -e "$abs/skills-lock.json" ]]; then
      if (( has_git )) && [[ -n "$(git -C "$abs" ls-files -- skills-lock.json 2>/dev/null)" ]]; then
        kept+=( "skills-lock.json" )
      else
        entries+=( "skills-lock.json" )
      fi
    fi

    if (( ${#entries} )); then
      # Honor the original contract: in a non-repo with no .gitignore, warn
      # rather than create one. Otherwise append (creating the file if needed).
      if (( ! has_git )) && [[ ! -f "$gi" ]]; then
        print -P "%F{214}Warning: no .git or .gitignore in $abs — skills installed but not gitignored.%f"
      else
        local created=0; [[ -f "$gi" ]] || created=1
        for p in $entries; do
          grep -qxF -- "$p" "$gi" 2>/dev/null || print -r -- "$p" >> "$gi"
        done
        (( created )) \
          && print -P "Created %F{cyan}.gitignore%f and ignored ${#entries} skill path(s)." \
          || print -P "Ignored ${#entries} skill path(s) in %F{cyan}.gitignore%f."
        (( has_git )) || print -P "%F{214}Warning: no .git in $abs — .gitignore updated, but nothing is tracked here.%f"
      fi
    else
      print -P "%F{214}--local: nothing to ignore — installed skills are already tracked (or none present).%f"
    fi

    if (( ${#kept} )); then
      print -P "%F{214}Left already-tracked path(s) committed: ${(j:, :)kept}.%f"
      print -P "%F{214}  --local won't un-commit them — run 'git rm --cached -r <path>' yourself to make them local.%f"
    fi
  fi

  return 0
}
