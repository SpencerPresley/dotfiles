-- Center screen when jumping (works in both)
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Better indenting in visual mode (works in both)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior (works in both)
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- jj to escape (terminal Neovim only - VS Code uses compositeKeys)
if not vim.g.vscode then
    vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape insert mode" })
end

if vim.g.vscode then
    -- VS Code specific keymaps
    local vscode = require("vscode")

    -- Buffer navigation -> VS Code tabs
    vim.keymap.set("n", "<leader>bn", function()
        vscode.action("workbench.action.nextEditor")
    end, { desc = "Next tab" })
    vim.keymap.set("n", "<leader>bp", function()
        vscode.action("workbench.action.previousEditor")
    end, { desc = "Previous tab" })

    -- Window navigation -> VS Code editor groups
    vim.keymap.set("n", "<C-h>", function()
        vscode.action("workbench.action.focusLeftGroup")
    end, { desc = "Move to left group" })
    vim.keymap.set("n", "<C-j>", function()
        vscode.action("workbench.action.focusBelowGroup")
    end, { desc = "Move to bottom group" })
    vim.keymap.set("n", "<C-k>", function()
        vscode.action("workbench.action.focusAboveGroup")
    end, { desc = "Move to top group" })
    vim.keymap.set("n", "<C-l>", function()
        vscode.action("workbench.action.focusRightGroup")
    end, { desc = "Move to right group" })

    -- Splitting -> VS Code split editor
    vim.keymap.set("n", "<leader>sv", function()
        vscode.action("workbench.action.splitEditorRight")
    end, { desc = "Split editor right" })
    vim.keymap.set("n", "<leader>sh", function()
        vscode.action("workbench.action.splitEditorDown")
    end, { desc = "Split editor down" })

    -- Resizing -> VS Code increase/decrease view size
    vim.keymap.set("n", "<C-Up>", function()
        vscode.action("workbench.action.increaseViewHeight")
    end, { desc = "Increase view height" })
    vim.keymap.set("n", "<C-Down>", function()
        vscode.action("workbench.action.decreaseViewHeight")
    end, { desc = "Decrease view height" })
    vim.keymap.set("n", "<C-Left>", function()
        vscode.action("workbench.action.decreaseViewWidth")
    end, { desc = "Decrease view width" })
    vim.keymap.set("n", "<C-Right>", function()
        vscode.action("workbench.action.increaseViewWidth")
    end, { desc = "Increase view width" })

    -- Config editing -> VS Code settings
    vim.keymap.set("n", "<leader>rc", function()
        vscode.action("workbench.action.openSettingsJson")
    end, { desc = "Open settings JSON" })

    -- File Explorer -> VS Code explorer
    vim.keymap.set("n", "<leader>m", function()
        vscode.action("workbench.view.explorer")
    end, { desc = "Focus explorer" })
    vim.keymap.set("n", "<leader>e", function()
        vscode.action("workbench.action.toggleSidebarVisibility")
    end, { desc = "Toggle sidebar" })

else
    -- Full Neovim keymaps

    -- Buffer navigation
    vim.keymap.set("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
    vim.keymap.set("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })

    -- Window navigation
    vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
    vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
    vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
    vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

    -- Splitting & Resizing
    vim.keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split window vertically" })
    vim.keymap.set("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Split window horizontally" })
    vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
    vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
    vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
    vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })

    -- Quick config editing
    vim.keymap.set("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

    -- File Explorer
    vim.keymap.set("n", "<leader>m", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus on file explorer" })
    vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
end
