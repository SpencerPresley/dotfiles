-- https://github.com/akinsho/bufferline.nvim
-- Buffers-as-tabs. NOTE: these are *buffers*, not tabpages -- opening N files =
-- N buffers in ONE window, so `:q` closes the window (not per-buffer) and `:qa`
-- quits everything at once. You never need N+1 `:q`.

local keys = {
  -- Navigate (respects the visible tab order, unlike raw :bnext).
  -- [b/]b follows vim's bracket-pair "prev/next item" grammar and clobbers
  -- nothing (unlike <S-h>/<S-l> which shadow native H/L viewport motions).
  { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
  { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
  { "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
  { "<leader>bn", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },

  -- Reorder the current buffer within the tabline
  { "<leader>b,", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
  { "<leader>b.", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },

  -- Jump around / pick
  { "<leader>b$", "<cmd>BufferLineGoToBuffer -1<cr>", desc = "Go to last buffer" },
  { "<leader>bb", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
  { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
  { "<leader>bP", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle pin" },

  -- Close (mini.bufremove deletes the buffer WITHOUT closing the window/split)
  { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete buffer (keep window)" },
  { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
  { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to the right" },
  {
    "<leader>bD",
    function()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].buflisted then
          pcall(require("mini.bufremove").delete, b, false)
        end
      end
    end,
    desc = "Delete all buffers",
  },
}

-- Jump straight to buffer N by its ordinal (matches the numbers shown on tabs)
for i = 1, 9 do
  table.insert(keys, {
    "<leader>b" .. i,
    "<cmd>BufferLineGoToBuffer " .. i .. "<cr>",
    desc = "Go to buffer " .. i,
  })
end

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  cond = function()
    return not vim.g.vscode -- pointless inside vscode-neovim
  end,
  -- mini.nvim provides BOTH the icons (via the web-devicons mock) and
  -- mini.bufremove, used above to close buffers without wrecking the layout.
  dependencies = { "nvim-mini/mini.nvim" },
  keys = keys,
  opts = {
    options = {
      mode = "buffers",
      numbers = "ordinal", -- show each tab's ordinal = the N in <leader>bN (muscle memory)
      diagnostics = "nvim_lsp",
      diagnostics_update_on_event = true,
      always_show_bufferline = false, -- hide the strip when only one buffer is open
      separator_style = "slant", -- opaque theme gives the slant real bg colors
      show_buffer_close_icons = false,
      show_close_icon = false,
      truncate_names = false, -- full names, no `symlink_AGENTS.md…`
      max_name_length = 40,
      -- Reserve the sidebar column so the tabline never draws over nvim-tree.
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "left",
          separator = true,
        },
      },
    },
    -- No custom highlights: the colorscheme (monokai-pro) themes bufferline.
    -- Because monokai-pro is opaque, tabs get real backgrounds automatically --
    -- this is what finally makes the tabs read like the mockup.
  },
}
