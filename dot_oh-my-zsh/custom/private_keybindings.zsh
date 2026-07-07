# Keybindings — sourced by oh-my-zsh AFTER all plugins, so these overrides win
# over plugin bindings (notably dirhistory + fzf). To disable vi mode, comment
# out the `bindkey -v` + KEYTIMEOUT lines below; everything else is harmless.
#
# Tips tags: a `#:: Title` line opens a section in `tips`, and a
# bindkey carrying a trailing `#: description` becomes a row under it (the key
# name is auto-derived from the sequence, so it can't be mislabeled). Untagged
# binds don't appear. show-keys.sh does the parsing; see functions.zsh's
# tips(). Tag one binding per key (the viins/insert one); the vicmd/emacs
# duplicates stay untagged so each key shows once.

# ── Reclaim Option-F / Option-B for word motion ──────────────────────────────
# The dirhistory plugin's Ghostty special-case grabs the ^[f / ^[b *letter*
# sequences, which collides with emacs word-motion and zsh-autosuggestions'
# partial-accept (accept one word of a suggestion). dirhistory's Option-ARROW
# navigation uses different sequences (^[[1;3C etc.) and is left fully intact.
bindkey -M emacs '^[f' forward-word
bindkey -M emacs '^[b' backward-word

# ── Vi mode ──────────────────────────────────────────────────────────────────
# Modal line editing. Insert mode types normally; Esc → normal mode for
# hjkl / ciw / dd / f<char> / % / . repeat, etc. p10k and starship show the
# mode automatically (❯ insert → ❮ normal).
bindkey -v
KEYTIMEOUT=1          # 10ms Esc lag instead of the default 400ms (KEYTIMEOUT=40)

# Word motion + partial-accept in insert mode too.
#:: word motion
bindkey -M viins '^[f' forward-word   #: move forward one word
bindkey -M viins '^[b' backward-word  #: move back one word

# Keep the emacs insert-mode keys you rely on — `bindkey -v` unlinks the emacs
# keymap from `main`, so without these you'd lose them while typing.
#:: line editing (insert mode)
bindkey -M viins '^A' beginning-of-line   #: jump to start of line
bindkey -M viins '^E' end-of-line         #: jump to end of line
bindkey -M viins '^K' kill-line           #: delete to end of line
bindkey -M viins '^U' backward-kill-line  #: delete to start of line
bindkey -M viins '^W' backward-kill-word  #: delete the previous word

# Re-bind fzf widgets in insert mode. They were bound in the emacs keymap, which
# `bindkey -v` detaches from `main`; without this you'd lose fzf Ctrl-R/T + Alt-C.
bindkey -M viins '^R' fzf-history-widget
bindkey -M viins '^T' fzf-file-widget
bindkey -M viins '^[c' fzf-cd-widget

# Prefix history search on Up/Down in insert mode (parity with your emacs setup:
# type a prefix, press Up, walk only matching history).
#:: history search
bindkey -M viins '^[[A' up-line-or-beginning-search    #: prefix-search history backward
bindkey -M viins '^[[B' down-line-or-beginning-search  #: prefix-search history forward
bindkey -M viins '^[OA' up-line-or-beginning-search
bindkey -M viins '^[OB' down-line-or-beginning-search

# Edit the current command line in $EDITOR (nvim). Ctrl-X Ctrl-E in either mode;
# vim's `v` visual-mode in normal mode is deliberately left untouched.
#:: command line & clipboard
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^X^E' edit-command-line  #: edit the command line in $EDITOR (nvim)
bindkey -M vicmd '^X^E' edit-command-line

# ── Copy the current command line + its output to the clipboard ───────────────
# tcopy (see functions.zsh) copies a "$ <cmd>\n<output>" block to the clipboard,
# handy for handing a command and its result to someone with full context. The
# catch: a pipeline must be quoted — typing `tcopy brew list | grep font` pipes
# tcopy's OWN output into grep, because the shell splits `|` before tcopy runs.
#
# This widget removes that chore. It grabs the whole typed line as text (BUFFER
# — pipes, redirects, quotes and all), single-quotes it with ${(qq)…} so it
# survives as one word, and prepends `tcopy `. The shell then only ever sees one
# simple `tcopy '…'` command: no pipe to fight, and the line runs exactly once
# (the reason to wrap *before* the parse rather than re-run it after — that would
# execute a trailing `| tee`/`| xargs` twice). Type the command normally, then
# press Ctrl-X then c *instead of* Enter (mnemonic: Ctrl-X for widgets, c = copy;
# sibling of ^X^E above). Don't pre-type `tcopy` — it wraps the raw line; history
# records the rewritten `tcopy '…'` form.
#
# Chord is ^X c (Ctrl-X, then a plain c), NOT ^X^C: Ctrl-C is the terminal's
# interrupt char, so it raises SIGINT and aborts the line before the chord can
# complete — it never reaches the widget. Same trap for ^C/^Z/^\/^S/^Q, and ^Y
# (DSUSP on macOS); the second key must be an ordinary character.
tcopy-line() {
  [[ -n $BUFFER ]] && BUFFER="tcopy ${(qq)BUFFER}"
  zle accept-line
}
zle -N tcopy-line
bindkey -M viins '^Xc' tcopy-line   #: run the line AND copy the command + its output (tcopy)
bindkey -M vicmd '^Xc' tcopy-line   # normal mode

# ── Copy the current command line to the clipboard, WITHOUT running it ────────
# The plain-text sibling of ^X c above. ^O copies whatever is on the line right
# now (BUFFER) to the clipboard and leaves everything as-is — nothing runs, the
# line stays put to keep editing or to Enter. Use it to grab a command to paste
# elsewhere when you DON'T want to run it (or don't want its output, just the
# command). print -rn keeps the text exact, no trailing newline; zle -M flashes a
# confirmation under the prompt. ^O is safe to bind (not a tty signal char) —
# verified it reaches the widget rather than being eaten like ^C would be.
pbcopy-line() {
  print -rn -- "$BUFFER" | pbcopy
  zle -M 'copied command line to clipboard (not run)'
}
zle -N pbcopy-line
bindkey -M viins '^O' pbcopy-line   #: copy the command line (does NOT run it)
bindkey -M vicmd '^O' pbcopy-line   # normal mode
