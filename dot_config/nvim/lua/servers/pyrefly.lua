-- pyrefly language server configuration
-- Repo-wide Python type checker (replaces basedpyright). Reads [tool.pyrefly]
-- from each package's pyproject.toml, so editor diagnostics match `make typecheck`.
--
-- Install (once, on PATH):  uv tool install pyrefly
--   Prefer pinning to whatever your projects gate on, e.g.
--     uv tool install pyrefly==1.1.1
--   so the LSP's config schema matches the repo's [tool.pyrefly].
--
-- Interpreter resolution: pyrefly's `auto` mode honors an activated VIRTUAL_ENV
-- and searches ancestor .venv dirs, so a single uv-workspace venv at the repo
-- root resolves correctly even though the LSP root is a member package dir.
-- Note: blink.cmp handles capabilities automatically.

vim.lsp.config.pyrefly = {
  cmd = { "pyrefly", "lsp" },
  filetypes = { "python" },
  -- Closest marker wins, so in a uv workspace the LSP attaches at the MEMBER
  -- package (apps/server, packages/ac-agents) and reads that member's
  -- [tool.pyrefly] — the same cwd `make typecheck` uses.
  root_markers = {
    "pyrefly.toml",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
}
