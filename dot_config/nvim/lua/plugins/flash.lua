-- https://github.com/folke/flash.nvim
-- Label-based motion: jump anywhere on screen in a few keystrokes.
-- Configured to be PURELY opt-in via `s`/`S` -- native `f/F/t/T` and `/`
-- search are left completely untouched.

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      search = { enabled = false }, -- don't hook `/` and `?` -- keep search native
      char = { enabled = false }, -- don't touch f/F/t/T -- keep them native
    },
  },
  keys = {
    -- `s`/`S` shadow native s (=cl) and S (=cc), which are trivially replaced.
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    -- Operator-pending only -> does NOT shadow normal-mode r/R.
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
