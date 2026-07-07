-- https://github.com/akinsho/toggleterm.nvim
-- Persistent terminals with custom terminal support (lazygit, lazydocker)

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle floating terminal" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle horizontal terminal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Toggle vertical terminal" },
    { "<leader>gg", desc = "Lazygit" },
    { "<leader>ld", desc = "Lazydocker" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = false, -- Using custom keymaps instead
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = false,
    terminal_mappings = true,
    persist_size = true,
    persist_mode = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,
    auto_scroll = true,
    float_opts = {
      border = "rounded",
      width = function()
        return math.floor(vim.o.columns * 0.85)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.85)
      end,
      winblend = 0,
    },
    winbar = {
      enabled = false,
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    -- Lazygit terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      hidden = true,
      float_opts = {
        border = "rounded",
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        -- Close with q in normal mode
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = term.bufnr, silent = true })
      end,
      on_close = function()
        vim.cmd("startinsert!")
      end,
    })

    -- Lazydocker terminal
    local lazydocker = Terminal:new({
      cmd = "lazydocker",
      direction = "float",
      hidden = true,
      float_opts = {
        border = "rounded",
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = term.bufnr, silent = true })
      end,
      on_close = function()
        vim.cmd("startinsert!")
      end,
    })

    -- Global toggle functions
    vim.keymap.set("n", "<leader>gg", function()
      lazygit:toggle()
    end, { desc = "Lazygit" })

    vim.keymap.set("n", "<leader>ld", function()
      lazydocker:toggle()
    end, { desc = "Lazydocker" })

    -- Terminal window navigation keymaps
    function _G.set_terminal_keymaps()
      local map_opts = { buffer = 0, silent = true }
      -- Escape to normal mode
      vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], map_opts)
      -- Window navigation (matches your tmux navigator in normal mode)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], map_opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], map_opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], map_opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], map_opts)
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = function()
        set_terminal_keymaps()
      end,
    })
  end,
}
