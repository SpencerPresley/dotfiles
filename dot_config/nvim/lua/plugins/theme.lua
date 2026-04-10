return {
  "catppuccin/nvim",
  lazy = false,
  name = "catppuccin",
  config = function()
    require("catppuccin").setup({
      transparent_background = true,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },
    })
    vim.cmd("colorscheme catppuccin")
  end,
} 
