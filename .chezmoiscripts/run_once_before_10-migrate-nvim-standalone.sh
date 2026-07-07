#!/bin/bash
# One-time migration: ~/.config/nvim used to be a standalone clone of
# NeovimSetup (cloned by run_once_before_00-clone-nvim-config.sh, now gone).
# chezmoi manages those files directly now, so the leftover git clone must go.
#
# This is a *before* script on purpose: it runs before chezmoi overwrites any
# files, so if this machine has un-saved local work we abort with everything
# still intact. run_once + non-zero exit isn't recorded as done, so it re-runs
# on the next `chezmoi apply` after you've dealt with it.
set -euo pipefail

NVIM="$HOME/.config/nvim"
GITDIR="$NVIM/.git"

# Fresh machine, or already migrated: nothing to do.
[ -d "$GITDIR" ] || exit 0

# Only ever touch the old NeovimSetup clone — never some other repo.
remote="$(git -C "$NVIM" remote get-url origin 2>/dev/null || true)"
case "$remote" in
  *NeovimSetup*) ;;
  *) exit 0 ;;
esac

dirty="$(git -C "$NVIM" status --porcelain 2>/dev/null || true)"
if unpushed="$(git -C "$NVIM" log --oneline '@{u}..HEAD' 2>/dev/null)"; then :; else
  unpushed="__UNKNOWN__"   # no upstream configured — can't verify, treat as unsafe
fi

if [ -n "$dirty" ] || [ -n "$unpushed" ]; then
  [ -n "$dirty" ]    && dirty_out="$dirty"       || dirty_out="  (none)"
  if   [ "$unpushed" = "__UNKNOWN__" ]; then unpushed_out="  (no upstream — couldn't compare)"
  elif [ -n "$unpushed" ];             then unpushed_out="$unpushed"
  else                                       unpushed_out="  (none)"
  fi
  cat >&2 <<EOF

========================================================================
  nvim migration halted: ~/.config/nvim has local work not in the repo
========================================================================

Your Neovim config used to be a standalone clone of NeovimSetup. It's now
managed by chezmoi, so this leftover .git clone needs to go -- but this
machine has changes that were never pushed, and NeovimSetup is archived
(read-only), so they can't be pushed anymore. Deal with them first.

Uncommitted changes:
${dirty_out}

Unpushed commits:
${unpushed_out}

Then re-run 'chezmoi apply'.

  * Don't care / it's junk  (recommended):
        rm -rf ~/.config/nvim/.git
    chezmoi holds the canonical config; this just drops the stale clone and
    its drift. The next 'chezmoi apply' restores the managed files.

  * Want to keep it:
        cd ~/.config/nvim && git bundle create ~/nvim-old.bundle --all
    stash that bundle somewhere safe, then 'rm -rf ~/.config/nvim/.git' and
    re-integrate by hand later.
========================================================================
EOF
  exit 1
fi

# Clean and fully pushed: safe to drop the orphaned clone.
rm -rf "$GITDIR"
echo "chezmoi: removed orphaned ~/.config/nvim/.git (now chezmoi-managed)"
