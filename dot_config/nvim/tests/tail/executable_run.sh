#!/usr/bin/env bash
# Regression + property tests for lua/utils/tail.lua. Runs headless nvim against
# the REAL installed module (require("utils.tail")), not a copy.
#
#   ./run.sh                # suite + recovery + fuzz seeds 1-3 x 300 ops
#   ./run.sh fuzz 8 800     # just the fuzzer: 8 seeds x 800 ops
#
# Exits non-zero if anything fails, so it's CI-able.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$(cd "$HERE/../.." && pwd)"   # nvim config root: has lua/utils/tail.lua
FAIL=0

nvim_run() { # $1=script  (env: TAILTEST_TMP + any script vars already exported)
  nvim --headless --clean --cmd "set rtp+=$CFG" \
    -c "lua vim.defer_fn(function() dofile('$HERE/$1') end, 120)" 2>&1
}

script_case() { # $1=script $2=label
  local tmp out; tmp="$(mktemp -d)"
  out="$(TAILTEST_TMP="$tmp" nvim_run "$1")"
  echo "$out" | grep -E "passed,|> FAIL|FAILED|E5560|note " || true
  echo "$out" | grep -qE "> FAIL|E5560|[1-9][0-9]* FAILED" && FAIL=1
  rm -rf "$tmp"
}

fuzz_case() { # $1=seed $2=nops
  local tmp out; tmp="$(mktemp -d)"
  out="$(TAILTEST_TMP="$tmp" SEED="$1" NOPS="$2" nvim_run fuzz.lua)"
  echo "$out" | grep -E "SEED=|SURVIVED|> FAILED|E5560" || true
  echo "$out" | grep -qE "FAILED|E5560" && FAIL=1
  rm -rf "$tmp"
}

if [ "${1:-}" = "fuzz" ]; then
  seeds="${2:-6}"; nops="${3:-500}"
  echo "== property fuzzer: seeds 1-$seeds x $nops ops =="
  for s in $(seq 1 "$seeds"); do fuzz_case "$s" "$nops"; done
else
  echo "== adversarial suite =="        ; script_case suite.lua    suite
  echo "== recovery + size guard =="     ; script_case recovery.lua recovery
  echo "== property fuzzer (seeds 1-3 x 300 ops) ==" ; for s in 1 2 3; do fuzz_case "$s" 300; done
fi

echo
[ "$FAIL" -eq 0 ] && echo "ALL GREEN" || echo "FAILURES DETECTED"
exit "$FAIL"
