-- https://github.com/coder/claudecode.nvim
-- Real Neovim<->Claude Code integration over the same MCP/WebSocket protocol as
-- the official VS Code/JetBrains extensions: in-editor diffs, selection & file
-- context, @-mentions. Uses the NATIVE terminal provider so it needs no snacks.
return {
  "coder/claudecode.nvim",
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeSelectModel",
  },
  opts = {
    terminal = {
      provider = "native", -- built-in nvim terminal -> no snacks dependency
      split_side = "right",
      split_width_percentage = 0.38, -- set once so you rarely need to resize
    },
  },
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: focus" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
    { "<leader>ab", function() vim.cmd("ClaudeCodeAdd " .. vim.fn.expand("%:p")) end, desc = "Claude: add current file" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
    -- Diff review (you can also just :w to accept / :q to reject in the diff)
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: deny diff" },
  },
}
