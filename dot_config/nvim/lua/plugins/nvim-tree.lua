-- https://github.com/nvim-tree/nvim-tree.lua

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  config = function()
    require("nvim-tree").setup({
      filters = {
        dotfiles = false, -- Show hidden files
      },
      view = {
        adaptive_size = true,
      }
    })
  end,
}
