-- https://github.com/loctvl842/monokai-pro.nvim
return {
  "loctvl842/monokai-pro.nvim",
  name = "monokai-pro",
  lazy = false,
  priority = 1000,
  config = function()
    require("monokai-pro").setup({
      -- Opaque: gives bufferline/nvim-tree real backgrounds so tabs read as
      -- tabs. Flip to true if you want the terminal to show through (but then
      -- the tabline goes subtle again -- that whole tradeoff).
      transparent_background = false,
      terminal_colors = true,
      devicons = true,
      filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
      styles = {
        comment = { italic = true },
        keyword = { italic = true },
      },
    })
    vim.cmd.colorscheme("monokai-pro")
  end,
}
