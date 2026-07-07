-- Emmet language server for HTML/CSS abbreviation expansion

vim.lsp.config.emmet_ls = {
  cmd = { "emmet-ls", "--stdio" },
  filetypes = {
    "html",
    "css",
    "scss",
    "less",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
  },
  root_markers = {
    ".git",
  },
}
