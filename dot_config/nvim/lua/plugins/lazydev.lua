-- https://github.com/folke/lazydev.nvim
-- Faster LuaLS setup for Neovim - lazily loads plugin type definitions

return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
