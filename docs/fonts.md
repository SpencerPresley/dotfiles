# Fonts & Nerd Font glyph coverage

Measured 2026-07 by reading each font's character map (`fontTools`) against the
Nerd Fonts v3 codepoint ranges — not from docs or cask descriptions.

## Inventory

| Glyph set | Complete-NF group¹ | MesloLGS NF (p10k) | Monaspace NF | Monaspace (plain) |
|---|---|---|---|---|
| Powerline core | 100% | 100% | 100% | 100% |
| Powerline extra | 100%² | 88% | 88% | 88% |
| Font Awesome (v3 loc) | 100% | 44% | 44% | — |
| Font Awesome ext | 100% | 100% | 99% | — |
| Material Design | 100% | 99% | 99% | — |
| Weather | 100% | 96% | 96% | — |
| Devicons | 100% | 39% | 38% | — |
| Octicons | 100% | 72% | 100% | — |
| Codicons | 100% | 86% | 86% | — |
| Font Logos | 100% | 36% | 88% | — |
| Pomicons | 100% | 100% | 100% | — |
| Power Symbols | 100% | 100% | 100% | — |
| Seti-UI | 100% | 93% | 97% | — |

¹ FiraCode NF, Hack NF, JetBrainsMono NF (+NL), Maple Mono NF, VictorMono NF,
SauceCodePro NF, and Symbols Nerd Font. Every Nerd Fonts ≥v3 release is patched
`--complete`, so all official `-nerd-font` / `-nf` casks from the ryanoasis
project are identical in coverage.
² Reported 94% by the scan; the missing codepoints are unassigned in NF v3.

## What this means

- **Terminal-facing fonts**: use anything in the complete-NF group. Ghostty's
  primary is Hack Nerd Font with `Symbols Nerd Font Mono` as fallback — the
  fallback is only consulted for codepoints the primary lacks, so it is inert
  until a font swap makes it matter.
- **MesloLGS NF** is the powerlevel10k author's v2-era patch: fine for the p10k
  prompt (built for exactly those glyphs), shows tofu in modern tools (yazi,
  eza) that use v3 codepoints. Keep it for p10k; don't use it as a terminal
  font elsewhere.
- **Monaspace NF** is GitHub's own NF build, *not* a complete v3 patch
  (Devicons 38%, Font Awesome 44%). If Monaspace ever becomes the Ghostty
  font, the Symbols fallback covers the gaps. Plain `font-monaspace` stays
  installed because VS Code's `editor.fontFamily` is `"Monaspace Neon"`.
- **Don't patch fonts locally** (`font-patcher`): every gap has an official
  pre-patched cask, and local patching means re-patching on every upstream
  release with artifacts a Brewfile can't express.

## Reproducing the scan

```bash
uv run --with fonttools python - <<'EOF'
import os
from fontTools.ttLib import TTFont

SETS = {
    "Powerline core":   [(0xE0A0, 0xE0A2), (0xE0B0, 0xE0B3)],
    "Powerline extra":  [(0xE0A3, 0xE0A3), (0xE0B4, 0xE0C8), (0xE0CA, 0xE0CA), (0xE0CC, 0xE0D7)],
    "Font Awesome":     [(0xED00, 0xF2FF)],
    "FA Extension":     [(0xE200, 0xE2A9)],
    "Material":         [(0xF0001, 0xF1AF0)],
    "Weather":          [(0xE300, 0xE3EB)],
    "Devicons":         [(0xE700, 0xE8EF)],
    "Octicons":         [(0xF400, 0xF533), (0x2665, 0x2665), (0x26A1, 0x26A1)],
    "Codicons":         [(0xEA60, 0xEC1E)],
    "Font Logos":       [(0xF300, 0xF381)],
    "Pomicons":         [(0xE000, 0xE00A)],
    "Power Symbols":    [(0x23FB, 0x23FE), (0x2B58, 0x2B58)],
    "Seti-UI":          [(0xE5FA, 0xE6B7)],
}

fam_seen = {}
d = os.path.expanduser("~/Library/Fonts")
for fn in sorted(os.listdir(d)):
    if not fn.lower().endswith((".ttf", ".otf")):
        continue
    f = TTFont(os.path.join(d, fn), lazy=True, fontNumber=0)
    fam = f["name"].getDebugName(16) or f["name"].getDebugName(1)
    if fam in fam_seen:
        f.close(); continue
    fam_seen[fam] = True
    cmap = set(f.getBestCmap())
    f.close()
    print(f"\n{fam}")
    for name, ranges in SETS.items():
        total = sum(e - s + 1 for s, e in ranges)
        have = sum(1 for s, e in ranges for cp in range(s, e + 1) if cp in cmap)
        print(f"  {name:16s} {100 * have // total:3d}%")
EOF
```
