# Keybindings — sourced by oh-my-zsh AFTER all plugins, so these overrides win
# over plugin bindings (notably dirhistory + fzf). To disable vi mode, comment
# out the `bindkey -v` + KEYTIMEOUT lines below; everything else is harmless.

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
bindkey -M viins '^[f' forward-word
bindkey -M viins '^[b' backward-word

# Keep the emacs insert-mode keys you rely on — `bindkey -v` unlinks the emacs
# keymap from `main`, so without these you'd lose them while typing.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word

# Re-bind fzf widgets in insert mode. They were bound in the emacs keymap, which
# `bindkey -v` detaches from `main`; without this you'd lose fzf Ctrl-R/T + Alt-C.
bindkey -M viins '^R' fzf-history-widget
bindkey -M viins '^T' fzf-file-widget
bindkey -M viins '^[c' fzf-cd-widget

# Prefix history search on Up/Down in insert mode (parity with your emacs setup:
# type a prefix, press Up, walk only matching history).
bindkey -M viins '^[[A' up-line-or-beginning-search
bindkey -M viins '^[[B' down-line-or-beginning-search
bindkey -M viins '^[OA' up-line-or-beginning-search
bindkey -M viins '^[OB' down-line-or-beginning-search

# Edit the current command line in $EDITOR (nvim). Ctrl-X Ctrl-E in either mode;
# vim's `v` visual-mode in normal mode is deliberately left untouched.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^X^E' edit-command-line
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
# press Ctrl-X Ctrl-C *instead of* Enter (mnemonic: Ctrl-X for widgets, C = copy;
# sibling of ^X^E above). Don't pre-type `tcopy` — it wraps the raw line; history
# records the rewritten `tcopy '…'` form.
tcopy-line() {
  [[ -n $BUFFER ]] && BUFFER="tcopy ${(qq)BUFFER}"
  zle accept-line
}
zle -N tcopy-line
bindkey -M viins '^X^C' tcopy-line   # insert mode
bindkey -M vicmd '^X^C' tcopy-line   # normal mode
