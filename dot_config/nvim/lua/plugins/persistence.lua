-- https://github.com/folke/persistence.nvim
-- Saves the session (buffers, layout, cwd) on exit; restore it on demand.
-- Opt-in restore only -- it never auto-restores, so a plain `nvim` stays clean.

return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore session (this dir)" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Stop saving this session" },
  },
}
