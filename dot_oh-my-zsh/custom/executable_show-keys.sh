#!/usr/bin/env zsh
# Generates the keybinding sections of the cheatsheet from keybindings.zsh, so
# they can't drift from what's actually bound. Called by the `cheatsheet`
# function (functions.zsh).
#
# Convention in keybindings.zsh:
#   #:: Title                          opens a cheatsheet section
#   bindkey ... 'SEQ' widget  #: desc  becomes a row (SEQ auto-rendered to a key
#                                      name; deduped; untagged binds are skipped)

emulate -L zsh
setopt extended_glob

local KEYS_FILE=${KEYS_FILE:-~/.oh-my-zsh/custom/keybindings.zsh}
[[ -r $KEYS_FILE ]] || return 0

# Render a zsh bindkey caret-sequence into a human key name.
#   ^[[A/^[OA -> ↑   ^[f -> Alt-F   ^A -> Ctrl-A   ^X^E -> Ctrl-X Ctrl-E
#   ^Xc -> Ctrl-X c
prettify() {
  local seq=$1
  case $seq in
    ('^[[A'|'^[OA') print -rn -- '↑'; return ;;
    ('^[[B'|'^[OB') print -rn -- '↓'; return ;;
    ('^[[C'|'^[OC') print -rn -- '→'; return ;;
    ('^[[D'|'^[OD') print -rn -- '←'; return ;;
  esac
  local out='' i=1 n=${#seq} c nx
  while (( i <= n )); do
    c=${seq[i]}
    if [[ $c == '^' ]]; then
      nx=${seq[i+1]}
      if [[ $nx == '[' ]]; then                 # ESC/Meta -> Alt-<char>
        out+="Alt-${(U)seq[i+2]} "
        (( i += 3 ))
      else                                       # control -> Ctrl-<char>
        out+="Ctrl-${(U)nx} "
        (( i += 2 ))
      fi
    else                                         # literal char (e.g. the c in ^Xc)
      out+="$c "
      (( i++ ))
    fi
  done
  print -rn -- "${out% }"
}

# Pass 1: collect (section, key, desc) rows, dedup by sequence, find key width.
local -a secs keys descs
local -A seen
local cur='' line seq desc key
integer maxw=0
while IFS= read -r line; do
  if [[ $line == '#::'* ]]; then
    cur=${line#'#::'}
    cur=${cur##[[:space:]]#}; cur=${cur%%[[:space:]]#}
  elif [[ $line == *bindkey*\'*\'*'#:'* ]]; then
    seq=${${line#*\'}%%\'*}                       # first single-quoted token
    (( ${+seen[$seq]} )) && continue
    seen[$seq]=1
    desc=${line#*'#:'}; desc=${desc##[[:space:]]#}
    key=$(prettify $seq)
    secs+=$cur; keys+=$key; descs+=$desc
    (( ${#key} > maxw )) && maxw=${#key}
  fi
done < $KEYS_FILE

(( ${#keys} )) || return 0

# Pass 2: emit sections in first-seen order, aligned like the curated guide.
local -a order
local s
for s in $secs; do (( ${order[(Ie)$s]} )) || order+=$s; done

local sec; integer idx
for sec in $order; do
  print -r -- "$sec"
  print -r -- "${(l:78::-:):-}"
  for idx in {1..${#keys}}; do
    [[ $secs[idx] == $sec ]] || continue
    printf "  %-${maxw}s  %s\n" "$keys[idx]" "$descs[idx]"
  done
  print
done
