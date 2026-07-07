-- https://github.com/rachartier/tiny-inline-diagnostic.nvim
-- Prettier inline diagnostics: the current line's message rendered as a distinct
-- boxed element with an arrow, offset from the code -- instead of the dim
-- built-in virtual_text. REPLACES virtual_text only (signs/underline/floats in
-- utils/diagnostics.lua stay). That file sets `virtual_text = false` so there's
-- no double render.
return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      -- presets: modern | classic | minimal | powerline | ghost | simple | nonerdfont | amongus
      preset = "modern",
      options = {
        show_source = { enabled = false }, -- matches your `source = "if_many"` intent
        multilines = { enabled = true, always_show = false }, -- expand long messages
        show_all_diags_on_cursorline = false, -- just the cursor line's diagnostic
      },
    })
  end,
}
