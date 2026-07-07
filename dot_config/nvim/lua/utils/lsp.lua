local M = {}

-- NOTE: Neovim 0.11+ provides default LSP keymaps that you may want to use instead:
--   grn -> vim.lsp.buf.rename()
--   gra -> vim.lsp.buf.code_action()
--   grr -> vim.lsp.buf.references()
--   gri -> vim.lsp.buf.implementation()
--   gO  -> vim.lsp.buf.document_symbol()
--   [d  -> vim.diagnostic.goto_prev() (with float)
--   ]d  -> vim.diagnostic.goto_next() (with float)
--   <C-S> (insert mode) -> vim.lsp.buf.signature_help()
--
-- The keymaps below override some of these defaults with custom behavior.
-- If you prefer the defaults, you can remove the corresponding mappings below.

M.on_attach = function(client, bufnr)
	local keymap = vim.keymap.set
	local opts = {
		noremap = true,
		silent = true,
		buffer = bufnr,
	}
	-- native neovim keymaps
	keymap("n", "<leader>gD", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	keymap("n", "<leader>gS", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
	keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	keymap("n", "<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	keymap("n", "<leader>D", "<cmd>lua vim.diagnostic.open_float({ scope = 'line' })<CR>", opts)
	keymap("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	keymap("n", "<leader>pd", "<cmd>lua vim.diagnostic.jump({ count = -1 })<CR>", opts)
	keymap("n", "<leader>nd", "<cmd>lua vim.diagnostic.jump({ count = 1 })<CR>", opts)
	keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	-- fzf-lua keymaps
	keymap("n", "<leader>gd", "<cmd>FzfLua lsp_finder<CR>", opts)
	keymap("n", "<leader>gr", "<cmd>FzfLua lsp_references<CR>", opts)
	keymap("n", "<leader>gt", "<cmd>FzfLua lsp_typedefs<CR>", opts)
	keymap("n", "<leader>ds", "<cmd>FzfLua lsp_document_symbols<CR>", opts)
	keymap("n", "<leader>ws", "<cmd>FzfLua lsp_workspace_symbols<CR>", opts)
	keymap("n", "<leader>gi", "<cmd>FzfLua lsp_implementations<CR>", opts)

	-- === DAP keymaps ===
	if client.name == "rust_analyzer" then
		local dap = require("dap")
		keymap("n", "<leader>dc", dap.continue, opts) -- Continue / Start
		keymap("n", "<leader>do", dap.step_over, opts) -- Step over
		keymap("n", "<leader>di", dap.step_into, opts) -- Step into
		keymap("n", "<leader>du", dap.step_out, opts) -- Step out
		keymap("n", "<leader>db", dap.toggle_breakpoint, opts) -- Toggle breakpoint
		keymap("n", "<leader>dr", dap.repl.open, opts) -- Open REPL
	end
end

return M
