-- bash-language-server configuration for Bash/Shell scripts

vim.lsp.config.bashls = {
  cmd = { "bash-language-server", "start" },
  -- `.zshrc`/`.zsh` are filetype `zsh`, not `sh` -- add it so bashls attaches.
  -- NB: it's a *bash* server; you get completion/hover/basic diagnostics, but it
  -- doesn't grok zsh-only syntax and shellcheck won't lint zsh.
  filetypes = { "sh", "bash", "zsh" },
  root_markers = {
    ".git",
  },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
    },
  },
}
