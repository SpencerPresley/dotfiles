# tail.lua tests

Tests for `lua/utils/tail.lua` (the `:Tail` live-follow feature). They run
headless nvim against the **real installed module** via `require("utils.tail")`.

```sh
tests/tail/run.sh              # suite + recovery + fuzz seeds 1-3 (~1 min)
tests/tail/run.sh fuzz 8 800   # heavier: 8 fuzz seeds x 800 ops
```

`run.sh` exits non-zero on any failure.

## What's here

- **suite.lua** — adversarial suite (~29 assertions). Live append, follow-at-bottom
  vs preserve-cursor-when-scrolled-up, burst debounce, atomic-rename re-arm,
  truncate, unsaved-edit safety (no clobber), stop-mid-debounce, double-start,
  leak-free teardown, no fast-context errors. Uses condition-polling with measured
  latency, not fixed sleeps; a watchdog prevents hangs.
- **recovery.lua** — the two nasty failure modes (~14 assertions): delete→recreate
  rotation (buffer not corrupted, session healthy, auto-recovers via poll + re-arm),
  and the size ceiling (refuses huge files, auto-disables + warns when a followed
  file grows past the cap).
- **fuzz.lua** — property-based stress test. Applies a random op sequence
  (append/truncate/rename/delete/recreate/edit/save/discard/cursor/tail-toggle) to a
  live tailed buffer and, after each op, asserts invariants that must always hold:
  no crash/error, `watcher-present == tailing`, buffer converges to disk when
  observable, editor responsive. Seeded + op-logged, so a failure is reproducible
  (`SEED=<n> NOPS=<n>`). The fuzzer was validated by injecting known bugs and
  confirming it catches them.

## Known limitations (by design, not bugs)

- Delete-then-recreate rotation recovers within one `poll_ms` (2s) rather than
  instantly. Rename-based rotation recovers immediately.
- Files past `max_bytes` (10 MB) are refused / auto-disabled — use `tail -f` for
  genuinely huge firehose logs. The module never re-reads past the cap.
- Tests run headless, so they can't exercise interaction with live plugins
  (LSP/treesitter/gitsigns) on reload. Drive it in a real session for that.
