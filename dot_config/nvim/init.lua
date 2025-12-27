if vim.g.vscode then
	-- VS Code/Cursor - minimal config (no plugins)
	require("config.globals") -- Leader key for vscode
	require("config.options")
	require("config.keymaps")
	return
end

-- Full Neovim - load everything
require("config.lazy")
