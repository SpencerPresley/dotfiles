-- https://github.com/nvim-tree/nvim-tree.lua

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  config = function()
    require("nvim-tree").setup({
      hijack_cursor = true, -- keep the cursor on the filename, not column 0
      filters = {
        dotfiles = false, -- show hidden files
      },
      view = {
        -- Dynamic width (replaces the deprecated `adaptive_size`): grows to the
        -- longest name but capped so a deep path can't eat half the screen.
        width = { min = 30, max = 55 },
        preserve_window_proportions = true, -- don't reflow your other splits on open
        number = true, -- absolute number on the cursor line ...
        relativenumber = true, -- ... relative elsewhere -> `20j` targeting
        signcolumn = "yes",
      },
      update_focused_file = {
        enable = true, -- reveal/sync the file you're editing
        update_root = false,
      },
      diagnostics = {
        enable = true, -- LSP diagnostics in the tree (off by default)
        show_on_dirs = true, -- bubble counts up to the parent folder
      },
      modified = {
        enable = true, -- mark files with unsaved changes
      },
      actions = {
        open_file = {
          quit_on_open = false, -- keep the tree open after opening a file (sidebar workflow)
        },
      },
      renderer = {
        group_empty = true, -- collapse single-child dir chains (a/b/c)
        root_folder_label = ":~:s?$?/..?",
        highlight_git = "name", -- color the filename by git status
        highlight_diagnostics = "name",
        highlight_modified = "none",
        indent_markers = {
          enable = true, -- the faint │ indent guides
        },
        icons = {
          show = {
            folder_arrow = false, -- drop the >/v arrows; the folder glyph shows open state
          },
          glyphs = {
            folder = {
              default = "󰉖", -- nf-md-folder_outline        (U+F0256)
              open = "󰷏", -- nf-md-folder_open_outline   (U+F0DCF)
              empty = "󰉖",
              empty_open = "󰷏",
            },
          },
        },
      },
    })
  end,
}
