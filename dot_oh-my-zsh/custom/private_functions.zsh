# aliases - Show custom aliases and functions
# Usage: aliases
# Parses aliases.zsh and functions.zsh to display all custom commands
# with their descriptions. Uses show-custom.sh for the actual parsing.
aliases() {
  bash ~/.oh-my-zsh/custom/show-custom.sh
}

# tips - Quick reference for shell tools & keybindings (fzf, zoxide, eza, delta...)
# Usage: tips [--no-footer]
# Prints the curated tool guide (tips.txt) — colorized (bold-cyan section titles,
# dim rules) when writing to a terminal — then the auto-generated keybinding
# sections (show-keys.sh parses keybindings.zsh, so they can't drift from what's
# actually bound), then a pointer to `als`. `--no-footer` drops that pointer; it's
# used by `help`, which already prints your aliases itself.
tips() {
  local f=~/.oh-my-zsh/custom/tips.txt
  local keys=~/.oh-my-zsh/custom/show-keys.sh
  local footer=1
  [[ "$1" == "--no-footer" ]] && footer=0
  if [[ -t 1 ]]; then
    _tips_colorize < "$f"
  else
    command cat "$f"
  fi
  [[ -x $keys ]] && { print; "$keys"; }
  if (( footer )); then
    print -r  -- "=============================================================================="
    print -rP -- "  your own aliases & functions:  %F{green}als%f"
    print -r  -- "=============================================================================="
  fi
}

# help - Everything at a glance: your custom aliases/functions + the tooling tips
# Usage: help
# Runs `aliases` (your `als` output) then `tips` (the tooling/keybinding guide).
# `help` isn't a zsh builtin (only run-help→man exists), so this claims it cleanly.
help() {
  aliases
  print
  tips --no-footer
}

# _tips_colorize - internal: colorize tips.txt for a terminal. Bold-cyan section
# titles + the CHEATSHEET banner, dim ==== / ---- rules, everything else verbatim.
# One-line lookahead: a line is a section title when the NEXT line is a --- rule,
# so titles need no markup in the source file. `have` guards against double-print.
_tips_colorize() {
  awk '
    function emit(s){
      if(!have) return
      if(s ~ /^={3,}/)          printf "%s%s%s\n", B, s, R
      else if(s ~ /CHEATSHEET/)  printf "%s%s%s%s\n", B, C, s, R
      else                       printf "%s\n", s
    }
    BEGIN{ B="\033[1m"; C="\033[36m"; D="\033[2m"; R="\033[0m"; have=0 }
    {
      if ($0 ~ /^-{5,}$/ && have) {          # current line is a rule => buf was a title
        printf "%s%s%s%s\n", B, C, buf, R
        printf "%s%s%s\n",   D, $0,  R
        have=0; next
      }
      emit(buf)
      buf=$0; have=1
    }
    END{ emit(buf) }
  '
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

# serena-init-project - Print the steps to install/enable Serena for Claude Code
# Usage: serena-init-project
# Single-quoted on purpose: the commands contain backticks, and in double quotes
# those are command substitution — the previous version actually RAN uv install /
# serena setup / uv upgrade / uv uninstall instead of printing them.
serena-init-project() {
  print 'To setup Serena now follow these steps:'
  print '1. Run `uv tool install -p 3.13 serena-agent@latest --prerelease=allow`'
  print '2. Run `serena setup claude-code`  (sets serena up globally, user-level, for Claude Code).'
  print 'To update:    uv tool upgrade serena-agent --prerelease=allow'
  print 'To uninstall: uv tool uninstall serena-agent'
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
#   -l|-L|--local       Gitignore only the skills THIS run installs (diffed
#                       against a pre-install snapshot); leaves pre-existing
#                       and committed skills alone.
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
        print -P -- "%B%F{green}install-codex-skills%f%b — project-scoped skills for Codex (wraps 'npx skills add')

Installs a skills repo into ./.agents/skills for %F{cyan}Codex only%f, so superpowers-style
skills stay scoped to one project instead of active everywhere like the global Codex plugin.

%B%F{cyan}Usage%f%b
  install-codex-skills [--path <dir>] [--local] [--force] [--repo <url>]
  ics …                          (alias)

%B%F{cyan}Options%f%b
  -p -P --path <dir>   Install into <dir> instead of the current directory.
  -l -L --local        Gitignore the installed skills git isn't already tracking.
  -f -F --force        Override the \$HOME refusal (only meaningful with --path).
  -r -R --repo <url>   Install a different skills repo (default: obra/superpowers).
  -h    --help         Show this help.

%B%F{cyan}--local%f%b
  Gitignores only the skill dirs THIS run installs — diffed against a snapshot
  taken just before the install — plus skills-lock.json if this run created it.
  Skills already present (yours, another tool's, or committed) are left untouched.
  It only ever appends to .gitignore; it never deletes or un-tracks anything. To
  make an already-committed skill local, 'git rm --cached -r <path>' it yourself.
  Never creates a ~/.gitignore; at \$HOME it's a no-op.

%B%F{cyan}Guards%f%b
  • Refuses \$HOME unless you pass BOTH --path and --force; a bare cwd of \$HOME
    is always refused (treated as an accident).
  • In a non-repo with no .gitignore, --local warns instead of creating one.

%B%F{cyan}Examples%f%b
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

  # For --local we gitignore ONLY what this run installs. Snapshot the skill
  # dirs (and whether the lockfile exists) BEFORE the install so we can diff
  # afterward — this way pre-existing skills (hand-made, from another tool, or
  # already committed) are left completely alone. "untracked" is the wrong test:
  # a skill you made but haven't committed yet is untracked too, and shouldn't
  # be ignored. Provenance ("did this command create it") is the right axis.
  local -a pre_skills=()
  local lock_pre=0
  if (( local_ignore )); then
    local d
    for d in "$abs/.agents/skills"/*(N/); do pre_skills+=( "${d:t}" ); done
    [[ -e "$abs/skills-lock.json" ]] && lock_pre=1
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

    # Diff against the pre-install snapshot: ignore only skill dirs that this
    # run created, plus skills-lock.json only if this run created it. A dir that
    # already existed (yours, another tool's, or committed) is skipped — not our
    # business. As a final guard, if a "new" path is somehow already git-tracked
    # (committed then working-copy deleted, then recreated), leave it: a
    # .gitignore can't ignore a tracked path, and un-committing isn't our job.
    local -a entries=() kept=()
    local sdir name p
    for sdir in "$abs/.agents/skills"/*(N/); do
      name="${sdir:t}"
      (( ${pre_skills[(Ie)$name]} )) && continue      # pre-existed → not from this run
      p=".agents/skills/$name/"
      if (( has_git )) && [[ -n "$(git -C "$abs" ls-files -- ".agents/skills/$name" 2>/dev/null)" ]]; then
        kept+=( "$p" )
      else
        entries+=( "$p" )
      fi
    done
    if (( ! lock_pre )) && [[ -e "$abs/skills-lock.json" ]]; then   # lockfile created this run
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
          && print -P "Created %F{cyan}.gitignore%f and ignored ${#entries} newly-installed skill path(s)." \
          || print -P "Ignored ${#entries} newly-installed skill path(s) in %F{cyan}.gitignore%f."
        (( has_git )) || print -P "%F{214}Warning: no .git in $abs — .gitignore updated, but nothing is tracked here.%f"
      fi
    else
      print -P "%F{214}--local: nothing new to ignore — this run added no skills (all were already present).%f"
    fi

    if (( ${#kept} )); then
      print -P "%F{214}Left already-tracked path(s) alone: ${(j:, :)kept}.%f"
      print -P "%F{214}  --local won't un-commit them — run 'git rm --cached -r <path>' yourself to make them local.%f"
    fi
  fi

  return 0
}

# _tcopy_killtree - internal: kill a pid and its whole descendant tree.
# Deepest-first so children die before parents can reparent them to init. Uses
# pgrep -P, so it works regardless of job-control/process-group state (a plain
# `kill -$pid` group-kill silently no-ops when monitor mode is off).
_tcopy_killtree() {
  local p=$1 sig=${2:-TERM} c
  for c in ${(f)"$(pgrep -P $p 2>/dev/null)"}; do
    _tcopy_killtree $c $sig
  done
  kill -$sig $p 2>/dev/null
}

# tcopy - Run a command/pipeline and copy the command + its output to clipboard
# Usage: tcopy <command ...>   |   tcopy '<cmd | with | pipes>'
# Runs the command, captures its output (stdout+stderr), strips ANSI color, and
# copies a clean "$ <command>\n<output>" block to the clipboard via pbcopy — for
# handing a command and its result to someone (e.g. Claude) with full context
# and no terminal prompt glyph. Output is copied, NOT re-printed; only a
# one-line confirmation is shown. Exit status of the command is propagated.
#
# The line is eval'd, so aliases and functions (rlp, gs, es, …) resolve exactly
# as if you typed them. Pipes/redirects/globs are shell syntax that the shell
# splits BEFORE tcopy runs, so quote the whole line to keep them intact:
#     tcopy 'brew list | grep font'    # pipeline captured
#     tcopy brew list | grep font      # pipes tcopy's OWN output into grep
# A single unpiped command needs no quotes: tcopy rlp a b c
#
# Blocking-command guard: a long-running/interactive command (npm run dev,
# tail -f, top, vim) would capture forever, and there's no way to tell that
# apart from a slow-but-finite command. So tcopy bounds it: if the command
# hasn't finished in TCOPY_TIMEOUT seconds (default 30) it's killed — process
# tree and all — and nothing is copied. Tune or disable per-call:
#     TCOPY_TIMEOUT=120 tcopy 'cargo build'     # allow a slow build
#     TCOPY_TIMEOUT=0   tcopy '<command>'        # no limit at all
tcopy() {
  if (( $# == 0 )); then
    print -u2 "Usage: tcopy <command ...>   |   tcopy '<cmd | with | pipes>'"
    return 1
  fi
  if ! command -v pbcopy >/dev/null 2>&1; then
    print -u2 "tcopy: pbcopy not found (needs the macOS clipboard tool)."
    return 1
  fi

  setopt localoptions extended_glob no_notify

  # 1 arg  → a full shell command line, used verbatim (pipes/redirects/globs OK).
  # 2+ args → joined with only the quoting each needs, so literal args with
  #           spaces or glob chars survive the round-trip.
  local cmdline
  if (( $# == 1 )); then
    cmdline="$1"
  else
    cmdline="${(j: :)${(q-)@}}"
  fi

  local timeout=${TCOPY_TIMEOUT:-30}
  local output ret

  if (( timeout <= 0 )); then
    # No guard: run inline, simplest path.
    output="$(eval "$cmdline" 2>&1)"
    ret=$?
  else
    # Guarded: run detached, writing output to a temp file and its exit code to
    # a sentinel file. Poll for the sentinel (robust — unlike `kill -0`, it can't
    # be fooled by an unreaped zombie); on timeout, kill the whole tree and bail.
    local tmp done
    tmp=$(mktemp "${TMPDIR:-/tmp}/tcopy.XXXXXX") || return 1
    done="${tmp}.done"
    { eval "$cmdline" >| "$tmp" 2>&1; print -rn -- $? >| "$done" } &!
    local pid=$!
    local -F elapsed=0
    while [[ ! -e "$done" ]] && (( elapsed < timeout )); do
      sleep 0.05
      (( elapsed += 0.05 ))
    done
    if [[ -e "$done" ]]; then
      ret="$(<$done)"
      [[ "$ret" == <-> ]] || ret=1
      output="$(<$tmp)"
      command rm -f "$tmp" "$done"
    else
      _tcopy_killtree $pid TERM
      sleep 0.2
      _tcopy_killtree $pid KILL
      command rm -f "$tmp" "$done"
      print -u2 -P "%F{red}✗%f tcopy: didn't finish in ${timeout}s — looks long-running or interactive, so nothing was copied."
      print -u2 -P "   %F{242}rerun with a longer/disabled limit, e.g. TCOPY_TIMEOUT=0 tcopy …%f"
      return 124
    fi
  fi

  output="${output//$'\x1b'\[[0-9;]#[a-zA-Z]/}"   # strip ANSI SGR/CSI escapes

  {
    printf '$ %s\n' "$cmdline"
    [[ -n "$output" ]] && print -r -- "$output"
  } | pbcopy

  print -u2 -P "%F{green}✔%f copied command + output to clipboard"
  return $ret
}

# ghst - Ghostty helper actions (list fonts/keybinds/themes/colors) + custom help
# Usage: ghst [command] [extra ghostty args]   (bare `ghst` = `ghst help`)
#   fonts          ghostty +list-fonts     — font faces Ghostty can see
#   keys|binds|kbs ghostty +list-keybinds  — active keybindings
#   themes         ghostty +list-themes    — available color themes
#   colors         ghostty +list-colors    — named colors + their hex values
#   help           this help (the default)
# A thin dispatcher over `ghostty +<action>` for the handful of read-only actions
# worth quick access — the leader is `ghst` (not `g*`, which the oh-my-zsh git
# plugin owns). Editing/showing config is deliberately absent: this repo manages
# Ghostty config (dot_config/ghostty/config.tmpl + a gitignored .ghostty.local),
# so +edit-config/+show-config would bypass that source of truth. macOS can't
# launch the emulator from the CLI, but these actions run fine there. Synonyms are
# accepted (keys/binds/kbs, theme/themes, …) so there's nothing to misremember;
# trailing args pass through, e.g. `ghst fonts --help`.
ghst() {
  command -v ghostty >/dev/null 2>&1 || {
    print -u2 -P "%F{red}ghst: ghostty not found on PATH.%f"; return 1
  }

  local cmd=${1:-help}
  (( $# )) && shift

  case "$cmd" in
    help|-h|--help)
      print -P "%F{green}ghst%f — Ghostty helper actions  (%F{242}bare ghst = help%f)"
      print
      print -P "  %F{green}ghst fonts%f          list font faces         (+list-fonts)"
      print -P "  %F{green}ghst keys%f  │ binds  list keybindings        (+list-keybinds)"
      print -P "  %F{green}ghst themes%f         list color themes       (+list-themes)"
      print -P "  %F{green}ghst colors%f         list named colors + hex (+list-colors)"
      print -P "  %F{green}ghst help%f           this help"
      ;;
    fonts|font)                   ghostty +list-fonts "$@" ;;
    keys|key|binds|bind|kbs|kb)   ghostty +list-keybinds "$@" ;;
    themes|theme)                 ghostty +list-themes "$@" ;;
    colors|color)                 ghostty +list-colors "$@" ;;
    *)
      print -u2 -P "%F{red}ghst: unknown command '$cmd'.%f  Try %F{green}ghst help%f."
      return 1
      ;;
  esac
}

# _opa_annotate - internal: print one plugin's name + what enabling it would add
# (alias/function counts, and whether it runs init/completion at load rather than
# just defining aliases). Reads $VERBOSE (dynamic scope) to also dump the alias
# definitions. Used by omz-plugin-audit.
_opa_annotate() {
  emulate -L zsh
  local n=$1 file=~/.oh-my-zsh/plugins/$1/$1.plugin.zsh
  if [[ ! -r $file ]]; then
    print -P "  %F{green}${(r:18:)n}%f %F{242}(no built-in plugin file found)%f"
    return
  fi
  local a f
  a=$(grep -cE '^[[:space:]]*alias '                                   "$file")
  f=$(grep -cE '^[[:space:]]*(function |[A-Za-z0-9_:.-]+[[:space:]]*\(\))' "$file")
  local -a bits
  (( a )) && bits+=("$a $( (( a==1 )) && print alias    || print aliases )")
  (( f )) && bits+=("$f $( (( f==1 )) && print function || print functions )")
  grep -qE '^[[:space:]]*(eval|source|\.[[:space:]]|compdef|autoload)\b' "$file" \
    && bits+=("init/completion")
  (( ${#bits} )) || bits=("no aliases/functions")
  print -P "  %F{green}${(r:18:)n}%f %F{242}${(j: · :)bits}%f"
  [[ -n $VERBOSE ]] && grep -E '^[[:space:]]*alias ' "$file" | sed 's/^[[:space:]]*/        /'
}

# omz-plugin-audit - Suggest omz plugins for tools you've installed, or inspect any plugin
# Usage: omz-plugin-audit [-v|--verbose] [plugin ...]
#   (no args)     List built-in omz plugins that are NOT enabled but whose name
#                 matches a Homebrew formula/cask you have installed, each with
#                 what enabling it would add (alias/function counts, init/completion).
#   plugin ...    Inspect the named plugin(s) directly instead (any plugin, whether
#                 or not it's installed/enabled) — same annotation.
#   -v|--verbose  Also print the actual alias definitions each plugin provides.
# Answers not just "which plugins match my tools" but "what would each give me,"
# so the pure alias-dumps are easy to skip. Set math mirrors the one-liner:
#   (omz plugin list  −  omz plugin list --enabled)  ∩  (brew formula ∪ cask)
omz-plugin-audit() {
  emulate -L zsh
  setopt localoptions

  local -a names
  local VERBOSE=
  while (( $# )); do
    case "$1" in
      -v|--verbose) VERBOSE=1; shift ;;
      -h|--help)
        print "Usage: omz-plugin-audit [-v|--verbose] [plugin ...]"
        print "  no args → suggest plugins for your installed tools; args → inspect those plugins."
        return 0 ;;
      -*) print -u2 -P "%F{red}omz-plugin-audit: unknown option '$1'%f"; return 1 ;;
      *)  names+=("$1"); shift ;;
    esac
  done

  # Explicit inspect mode.
  if (( ${#names} )); then
    print -P "%B%F{cyan}Plugin details%f%b"
    local n; for n in $names; do _opa_annotate "$n"; done
    return 0
  fi

  command -v omz  >/dev/null 2>&1 || { print -u2 -P "%F{red}omz not available in this shell.%f"; return 1 }
  command -v brew >/dev/null 2>&1 || { print -u2 -P "%F{red}brew not found.%f"; return 1 }

  local strip='s/\x1b\[[0-9;]*m//g'
  local -a all enabled installed candidates
  all=(${(f)"$(omz plugin list 2>/dev/null | sed $strip | sort -u)"})
  enabled=(${(f)"$(omz plugin list --enabled 2>/dev/null | sed $strip | sort -u)"})
  installed=(${(f)"$({ brew list --formula; brew list --cask; } 2>/dev/null | sort -u)"})

  local -A en inst
  local x
  for x in $enabled;   do en[$x]=1;   done
  for x in $installed; do inst[$x]=1; done
  for x in $all; do
    (( ${+en[$x]} ))   && continue     # already enabled
    (( ${+inst[$x]} )) || continue     # not an installed tool
    candidates+=$x
  done

  if (( ! ${#candidates} )); then
    print -P "%F{242}No disabled built-in plugins match a Homebrew-installed tool — nothing to suggest.%f"
    return 0
  fi

  print -P "%B%F{cyan}omz plugins for tools you have installed (not currently enabled)%f%b"
  print -P "%F{242}enable via plugins=(…) in dot_zshrc.tmpl · prefer learning your own aliases over dumping these%f"
  print
  local n; for n in ${(o)candidates}; do _opa_annotate "$n"; done
  print
  print -P "%F{242}inspect one in depth:  omz-plugin-audit -v <name>%f"
}

# y — yazi with directory-follow: browse around, and quitting with `q` cd's the
# shell to wherever you ended up (`Q` quits without moving). Mechanism: yazi
# writes its final cwd into the file passed via --cwd-file on `quit`, and we cd
# there. From https://yazi-rs.github.io/docs/quick-start
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}
