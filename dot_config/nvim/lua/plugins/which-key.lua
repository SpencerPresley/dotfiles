-- https://github.com/folke/which-key.nvim

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- Group labels for leader key prefixes
    spec = {
      { "<leader>c", group = "Code" },
      { "<leader>f", group = "Find (FZF)" },
      { "<leader>g", group = "Go to / Git" },
      { "<leader>l", group = "Lint" },
      { "<leader>x", group = "Trouble / Diagnostics" },
      { "<leader>d", group = "Diagnostics" },
      { "<leader>w", group = "Workspace" },
      { "<leader>r", group = "Rename" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
