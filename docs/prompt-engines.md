# Prompt Engines — Handoff & Config Reference

_Last updated: 2026-07-04. Restore anchor: git tag `prompt-baseline` (commit `9aa72e5`)._

This repo can run **three** shell prompts interchangeably: **powerlevel10k (p10k)**,
**starship**, and **oh-my-posh (omp)**. This doc is a handoff for a future session
to help tune/build out their configs — plus a safety net for getting back to the
current setup if you break something.

---

## TL;DR — current state

- **Active prompt:** p10k (the default). Nothing is broken or half-migrated.
- **Switch engines:** `prompt-use p10k | starship | omp` (writes `~/.config/prompt-engine`, `exec zsh`).
- **Vi mode:** ON (added 2026-07-04). Insert mode types normally; `Esc` → vim normal mode.
- **Restore point:** everything is in git; tag `prompt-baseline` marks today's known-good state.

---

## "Am I even using p10k?" — yes. Here's the nuance.

You **are** using p10k as your prompt. The thing that's *off* is p10k's **instant-prompt
feature**, not p10k itself.

- **Instant prompt** = p10k renders a *cached copy* of your prompt the instant zsh
  starts, before `~/.zshrc` finishes sourcing (nvm, direnv, completions, etc.). It's
  p10k's headline perf trick and no other prompt has it.
- **It's currently `off`:** `dot_zshrc.tmpl:13` → `POWERLEVEL9K_INSTANT_PROMPT=off`,
  even though the p10k wizard header (`dot_p10k.zsh:4`) says `instant_prompt=verbose`.
  So it was deliberately disabled at some point.
- **To re-enable:** change `off` → `verbose` (warns if anything prints to the console
  during init) or `quiet` (suppresses those warnings). Tradeoff: instant prompt can
  hide/delay output from commands that print during zshrc init, and misbehaves with
  anything that needs console *input* during startup — which is the usual reason people
  turn it off. Flip it, open a new shell, and see if anything looks wrong.

Net: p10k is fully in use; you're just leaving one optimization on the table.

---

## Safety net — get back to exactly today's setup

Everything is version-controlled. If you mess with p10k (or anything else):

```sh
cd ~/.local/share/chezmoi

# See what you changed vs the known-good baseline
git diff prompt-baseline -- dot_p10k.zsh

# Restore a single file from the baseline, then push it live
git checkout prompt-baseline -- dot_p10k.zsh
chezmoi apply ~/.p10k.zsh

# Or restore the whole prompt setup at once
git checkout prompt-baseline -- dot_p10k.zsh dot_config/starship.toml \
  dot_config/ohmyposh/theme.json dot_zshrc.tmpl \
  dot_oh-my-zsh/custom/private_keybindings.zsh
chezmoi apply
```

And always: `prompt-use p10k` puts you back on p10k regardless of config edits.

> The `prompt-baseline` tag is movable — after you settle on a new setup you're happy
> with, re-anchor it: `git tag -f prompt-baseline <new-commit>`.

---

## Architecture — how the switcher works

A single selector variable picks the engine; each engine initializes in its own branch.

| Piece | Source (in this repo) | Deployed to | Role |
|---|---|---|---|
| Selector read | `dot_zshrc.tmpl` (top) | `~/.zshrc` | `PROMPT_ENGINE=$(cat ~/.config/prompt-engine \|\| echo p10k)` |
| Instant-prompt + `ZSH_THEME` gate | `dot_zshrc.tmpl` | `~/.zshrc` | only active when `PROMPT_ENGINE == p10k` |
| Engine init | `dot_zshrc.tmpl` (end) | `~/.zshrc` | `case` block: sources p10k **or** `eval "$(starship/omp init)"` |
| `prompt-use` fn | `dot_oh-my-zsh/custom/private_functions.zsh` | `~/.oh-my-zsh/custom/functions.zsh` | writes selector + `exec zsh` |
| Selector file | _(not tracked)_ | `~/.config/prompt-engine` | machine-local; absent ⇒ p10k |
| Keybindings / vi mode | `dot_oh-my-zsh/custom/private_keybindings.zsh` | `~/.oh-my-zsh/custom/keybindings.zsh` | `bindkey -v`, fzf re-binds, Option-F/B reclaim |

Init order matters: p10k's instant-prompt block must stay at the **top** of `~/.zshrc`;
the engine `case` block runs **last** so nothing overrides the prompt. `keybindings.zsh`
loads after all oh-my-zsh plugins (that's why its overrides beat dirhistory/fzf).

---

## Per-engine config reference

### powerlevel10k
- **Config file:** `~/.p10k.zsh` (source `dot_p10k.zsh`) — a ~1700-line zsh script, heavily commented and self-documenting.
- **Regenerate from scratch:** `p10k configure` (interactive wizard).
- **Current style:** Pure, snazzy palette, 2-line, sparse, transient **on**, instant **off**.
- **Key knobs:**
  - Segments: `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` / `..._RIGHT_PROMPT_ELEMENTS`
  - `POWERLEVEL9K_INSTANT_PROMPT` (off/quiet/verbose — currently set in zshrc, not here)
  - `POWERLEVEL9K_TRANSIENT_PROMPT` (always/same-dir/off)
  - `POWERLEVEL9K_PROMPT_ADD_NEWLINE` (blank line before each prompt — currently true)
  - Per-segment: `POWERLEVEL9K_<SEG>_FOREGROUND`, `..._CONTENT_EXPANSION`, `..._VISUAL_IDENTIFIER_EXPANSION`
- **Vi mode:** native — `..._PROMPT_CHAR_*_VIINS/VICMD_*` already flip `❯`→`❮`.
- **Docs:** https://github.com/romkatv/powerlevel10k (maintenance-mode; bugfixes only, no new features).

### starship
- **Config file:** `~/.config/starship.toml` (source `dot_config/starship.toml`).
- **Docs:** https://starship.rs/config/ — full module list + options.
- **Structure:** top-level `format` string, `right_format`, `add_newline`, `command_timeout`
  (default 500ms), `scan_timeout`, `palette` + `[palettes.<name>]`, and one `[<module>]` table each.
- **Module format strings:** e.g. `format = "[$branch]($style)"`, and the top-level `format`
  references modules with `$directory$git_branch$character` etc. `$character` is the prompt symbol.
- **Presets (great starting points):** `starship preset -l` to list; `starship preset <name> -o ~/.config/starship.toml` to install.
- **Preview without reloading:** `STARSHIP_CONFIG=~/.config/starship.toml starship prompt`
- **Current seed:** mirrors the p10k Pure/snazzy look (blue dir, grey `branch*`, magenta/red `❯`, yellow cmd-duration ≥5s).
- **Vi mode:** works — `starship init zsh` installs keymap hooks; `character.vicmd_symbol = "❮"` is set.
- **Transient prompt:** ⚠️ NOT native for zsh (only Fish/pwsh/cmd). Would need a `zle` shim like
  `zsh-transient-prompt` — finicky next to fast-syntax-highlighting + autosuggestions. Left unwired on purpose.

### oh-my-posh
- **Config file:** `~/.config/ohmyposh/theme.json` (source `dot_config/ohmyposh/theme.json`). Also supports YAML/TOML.
- **Docs:** https://ohmyposh.dev/docs — config + segment reference.
- **Structure:** `blocks[]` → `segments[]`; plus `transient_prompt`, `secondary_prompt`, `tooltips[]`, `console_title_template`.
- **Segment fields:** `type` (path/git/python/text/os/time/…), `style` (plain/powerline/diamond/accordion),
  `foreground`/`background`, `foreground_templates[]` (conditional colors), `template` (Go text/template + sprig),
  `properties{}`.
- **Preview without reloading:** `oh-my-posh print primary --config ~/.config/ohmyposh/theme.json --shell zsh`
  (also `print transient`, `print secondary`).
- **Themes gallery (100+):** https://ohmyposh.dev/docs/themes — steal segments/looks from these.
- **Migrate old configs:** `oh-my-posh config migrate` (v2 → v3).
- **Current seed:** mirrors the p10k look; **transient prompt ON** (collapses finished prompts to `❯`).
- **Tooltips:** omp-only feature — type a command + space and a segment appears on the right (not wired yet).
- **Vi mode:** ⚠️ NOT wired in the current theme. omp doesn't track zsh's keymap the way starship does,
  so the char stays `❯` in normal mode. Wiring it up is an open thread (below).

---

## Feature scorecard (for reference)

| | p10k | starship | omp |
|---|---|---|---|
| Transient (zsh) | ✅ native | ⚠️ DIY only | ✅ native |
| Instant prompt | ✅ (currently off) | ❌ | ❌ |
| Async git status | ✅ gitstatusd | ❌ sync | ❌ sync |
| Vi-mode indicator | ✅ | ✅ | ⚠️ needs wiring |
| Tooltips | ❌ | ❌ | ✅ |
| Config format | zsh vars | one TOML | JSON/YAML/TOML + templates |
| Maintenance | bugfix-only | very active | very active |

---

## Open threads / ideas to explore next session

1. **Flesh out starship & omp** to fully match — or improve on — the p10k look. The seeds
   are deliberately minimal (dir + `branch*` + `❯`); consider adding exec-time, python venv
   styling, git ahead/behind counts, or context segments (k8s/aws/node) if wanted.
2. **omp vi-mode indicator** — the one gap. Needs omp to know the zsh keymap; explore
   exporting mode state and a `foreground_templates`/segment that reacts to it.
3. **p10k instant prompt** — decide whether to flip `off` → `verbose` and re-gain the perf trick.
4. **starship transient** — decide if it's worth a `zle` shim, or accept it as the reason
   starship stays third for transient-lovers.
5. **omp tooltips** — a genuinely unique feature; wire up e.g. a `git` tooltip if it appeals.

---

## Quick commands

```sh
prompt-use                # show current engine + choices
prompt-use starship       # switch (reloads shell)
prompt-use p10k           # back to default

p10k configure            # p10k wizard
starship preset -l        # list starship presets
oh-my-posh print primary --config ~/.config/ohmyposh/theme.json --shell zsh   # preview omp

# preview starship / omp without switching:
STARSHIP_CONFIG=~/.config/starship.toml starship prompt
```
