-- https://github.com/nvim-mini/mini.nvim
-- Library of 40+ independent Lua modules improving Neovim experience
-- Using single package instead of individual nvim-mini/* packages (recommended)

return {
  "nvim-mini/mini.nvim",
  version = "*",
  config = function()
    -- Extend and create a/i textobjects
    require("mini.ai").setup()

    -- Comment lines
    require("mini.comment").setup()

    -- Move any selection in any direction
    require("mini.move").setup()

    -- Fast and feature-rich surround actions
    require("mini.surround").setup()

    -- Autohighlight word under cursor
    require("mini.cursorword").setup()

    -- Visualize and work with indent scope
    require("mini.indentscope").setup()

    -- Autopairs
    require("mini.pairs").setup()

    -- Trailspace (highlight and remove)
    require("mini.trailspace").setup()

    -- Remove buffers
    require("mini.bufremove").setup()

    -- Notifications
    require("mini.notify").setup()

    -- Icons
    require("mini.icons").setup()

    -- Split and join arguments
    require("mini.splitjoin").setup()
  end,
}
