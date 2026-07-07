local M = {}

local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

M.setup = function()
  vim.diagnostic.config({
    -- Inline messages are handled by tiny-inline-diagnostic.nvim (prettier,
    -- current-line, offset). Built-in virtual_text OFF so they don't double up.
    virtual_text = false,
    underline = true,
    severity_sort = true, -- errors rank above warnings in signs / virtual text
    update_in_insert = false, -- don't recompute diagnostics on every keystroke
    float = {
      style = "minimal",
      source = true,
      header = "",
      prefix = "",
      border = "rounded",
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
        [vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
        [vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
        [vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
      },
    },
  })
end

return M
