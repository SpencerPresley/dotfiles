-- rustaceanvim
-- https://github.com/mrcjkb/rustaceanvim

local on_attach = require("utils.lsp").on_attach

local config = function()
	local settings = {
		tools = {
			hover_actions = {
				auto_focus = true,
			},
		},
		server = {
			on_attach = on_attach,
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
					},
				},
			},
		},
	}
	vim.g.rustaceanvim = settings
end

return {
	"mrcjkb/rustaceanvim",
	version = "^6",
	lazy = false,
	config = config,
}
