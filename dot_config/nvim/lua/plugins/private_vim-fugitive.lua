-- https://github.com/tpope/vim-fugitive
-- A Git wrapper so awesome, it should be illegal

return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Ghdiffsplit", "Gread", "Gwrite", "GMove", "GDelete", "GBrowse" },
  keys = {
    -- Git status (the main fugitive window)
    { "<leader>Gs", "<cmd>Git<cr>", desc = "Git status" },
    -- Staging/unstaging
    { "<leader>Gw", "<cmd>Gwrite<cr>", desc = "Git add (stage) current file" },
    { "<leader>Gr", "<cmd>Gread<cr>", desc = "Git checkout (revert) current file" },
    -- Commit
    { "<leader>Gc", "<cmd>Git commit<cr>", desc = "Git commit" },
    { "<leader>Ga", "<cmd>Git commit --amend<cr>", desc = "Git commit --amend" },
    -- Push/pull
    { "<leader>Gp", "<cmd>Git push<cr>", desc = "Git push" },
    { "<leader>GP", "<cmd>Git pull<cr>", desc = "Git pull" },
    -- Diff
    { "<leader>Gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff split" },
    { "<leader>Gv", "<cmd>Gvdiffsplit<cr>", desc = "Git diff vertical split" },
    -- Log
    { "<leader>Gl", "<cmd>Git log --oneline<cr>", desc = "Git log (oneline)" },
    { "<leader>GL", "<cmd>Git log<cr>", desc = "Git log (full)" },
    -- Blame
    { "<leader>Gb", "<cmd>Git blame<cr>", desc = "Git blame" },
    -- Branch
    { "<leader>GB", "<cmd>Git branch<cr>", desc = "Git branch" },
    -- Misc
    { "<leader>Gf", "<cmd>Git fetch<cr>", desc = "Git fetch" },
    { "<leader>Gm", "<cmd>Git merge<cr>", desc = "Git merge" },
  },
}
