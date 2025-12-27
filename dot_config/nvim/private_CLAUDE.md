# Neovim Configuration

This is a modern, modular Neovim configuration with dual-mode support for both terminal Neovim and VS Code/Cursor.

## Directory Structure

```tree
lua/
├── config/           # Core configuration
│   ├── lazy.lua      # lazy.nvim bootstrap
│   ├── options.lua   # Editor options
│   ├── keymaps.lua   # Key bindings
│   ├── globals.lua   # Global variables (leader = space)
│   └── autocmds.lua  # Autocommand groups
├── plugins/          # Plugin specifications (one file per plugin)
├── servers/          # LSP server configurations (one file per server)
│   └── init.lua      # Server registration
└── utils/            # Shared utilities
    ├── lsp.lua       # LSP on_attach handler and keybindings
    └── diagnostics.lua
```

## Key Technologies

- **Plugin Manager**: lazy.nvim
- **Theme**: Catppuccin (transparent background)
- **Completion**: nvim-cmp + LuaSnip + Supermaven (AI)
- **Fuzzy Finder**: fzf-lua
- **File Explorer**: nvim-tree
- **Statusline**: lualine
- **Utilities**: mini.nvim collection

## Active Language Servers

| Server | Languages | Key Features |
|--------|-----------|--------------|
| lua_ls | Lua | Neovim runtime awareness |
| ts_ls | TypeScript/JavaScript | Inlay hints, auto-imports |
| basedpyright | Python | Type checking, auto-imports |
| efm-langserver | Multi-language | Formatting (prettier, stylua, ruff) and linting |

## Key Bindings

Leader key is `<Space>`.

### Navigation

- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Buffers
- `<leader>e` - Toggle file explorer
- `<leader>m` - Focus file explorer

### LSP

- `<leader>gD` - Go to definition
- `<leader>gd` - Find references (FZF)
- `<leader>gr` - All references
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>d` - Hover/diagnostics
- `K` - Hover information

### Completion

- `<C-Space>` - Trigger completion
- `<C-k>/<C-j>` - Navigate items
- `<CR>` - Confirm selection
- `<Tab>` - Accept Supermaven suggestion

## Coding Conventions

- **Indentation**: 2 spaces
- **Module pattern**: `local M = {}` with `return M`
- **Plugin specs**: lazy.nvim format with `opts` tables
- **Keybindings**: Always include `desc` for which-key

## Dual-Mode Support

Configuration detects VS Code via `vim.g.vscode` flag:

- Terminal Neovim: Full plugin suite loads
- VS Code/Cursor: Core keymaps only, uses VS Code native features

## Autocommands

1. **LastCursorGroup** - Restore cursor position on file reopen
2. **HighlightYank** - Flash yanked text (200ms)
3. **FormatOnSaveGroup** - Async formatting via EFM
4. **LspAttachGroup** - Attach LSP keybindings

## Adding New Plugins

Create a new file in `lua/plugins/` returning a lazy.nvim spec:

```lua
return {
  "owner/plugin-name",
  event = "VeryLazy",  -- or other lazy-loading trigger
  opts = {
    -- plugin options
  },
}
```

## Adding New Language Servers

1. Create `lua/servers/<server_name>.lua`:

```lua
vim.lsp.config.<server_name> = {
  cmd = { "server-binary" },
  filetypes = { "filetype" },
  root_markers = { ".git" },
}
```

2. Add to `lua/servers/init.lua`:

```lua
local servers = {
  -- existing servers...
  "<server_name>",
}
```

## Important Files

- `init.lua` - Entry point, loads config modules
- `lazy-lock.json` - Plugin version lock file
- `vscode-neovim-setup.md` - VS Code integration guide
