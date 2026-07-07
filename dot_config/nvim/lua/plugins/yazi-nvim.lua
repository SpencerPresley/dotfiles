-- https://github.com/mikavilpas/yazi.nvim
-- Real yazi in a floating window, synced to the current buffer's directory.
-- Companion to nvim-tree, NOT a replacement: yazi has no vim count prefixes
-- (`20j` won't work inside it) -- reach for it for previews, bulk rename,
-- plugins and multi-select ops, and use nvim-tree for motion-heavy navigation.

return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  cond = function()
    return not vim.g.vscode
  end,
  keys = {
    { "<leader>-", "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
    { "<leader>=", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false, -- keep nvim-tree as the default directory explorer
    keymaps = {
      show_help = "<f1>",
    },
  },
}
