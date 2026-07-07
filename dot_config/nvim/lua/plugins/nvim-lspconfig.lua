-- https://github.com/neovim/nvim-lspconfig
-- Quickstart configs for Neovim's built-in LSP client
-- Note: nvim-lspconfig provides server configs, vim.lsp.config/enable is used for setup

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
  },
  config = function()
    require("utils.diagnostics").setup()
    require("servers")
  end,
}
