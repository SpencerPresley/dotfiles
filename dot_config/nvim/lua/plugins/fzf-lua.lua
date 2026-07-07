-- https://github.com/ibhagwan/fzf-lua

return {
  "ibhagwan/fzf-lua",
  lazy = false,
  config = function()
    local fzf_lua = require("fzf-lua")

    fzf_lua.setup({
      actions = {
        files = {
          true, -- inherit fzf-lua's default file actions (<CR>=open, ctrl-s/v splits, ...)
          ["ctrl-t"] = require("trouble.sources.fzf").actions.open, -- also: open selection in Trouble
        },
      },
    })
  end,
  keys = {
    {
      "<leader>ff",
      function()
        require("fzf-lua").files()
      end,
      desc = "FZF Files",
    },
    {
      "<leader>fg",
      function()
        require("fzf-lua").live_grep()
      end,
      desc = "FZF Live Grep",
    },
    {
      "<leader>fb",
      function()
        require("fzf-lua").buffers()
      end,
      desc = "FZF Buffers",
    },
    {
      "<leader>fh",
      function()
        require("fzf-lua").help_tags()
      end,
      desc = "FZF Help Tags",
    },
    {
      "<leader>fx",
      function()
        require("fzf-lua").diagnostics_document()
      end,
      desc = "FZF Diagnostics Document",
    },
    {
      "<leader>fX",
      function()
        require("fzf-lua").diagnostics_workspace()
      end,
      desc = "FZF Diagnostics Workspace",
    },
    {
      "<leader>fs",
      function()
        require("fzf-lua").lsp_document_symbols()
      end,
      desc = "FZF Document Symbols",
    },
    {
      "<leader>fl",
      function()
        require("fzf-lua").blines()
      end,
      desc = "FZF Buffer Lines (search THIS file)",
    },
    {
      "<leader>fL",
      function()
        require("fzf-lua").lines()
      end,
      desc = "FZF Lines (all open buffers)",
    },
    {
      "<leader>fr",
      function()
        require("fzf-lua").resume()
      end,
      desc = "FZF Resume last search",
    },
    {
      "<leader>fk",
      function()
        require("fzf-lua").keymaps()
      end,
      desc = "FZF Keymaps (searchable cheatsheet)",
    },
  },
}
