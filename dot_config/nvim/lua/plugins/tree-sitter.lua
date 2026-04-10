-- https://github.com/nvim-treesitter/nvim-treesitterir

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  lazy = false,
  config = function()
    require("nvim-treesitter.configs").setup({
      -- language parsers that MUST be installed
      ensure_installed = {
        "lua",
        "python",
        "bash",
        "typescript",
        "javascript",
        "html",
        "css",
        "json",
        "yaml",
        "go",
        "markdown",
        "dockerfile",
        "markdown_inline",
        "c",
        "cpp",
        "csv",
        "diff",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "goctl",
        "gomod",
        "gosum",
        "htmldjango",
        "jinja",
        "jinja_inline",
        "jsdoc",
        "nginx",
        "ssh_config",
        "toml",
        "tsx",
        "xml",
      },
      auto_install = true, -- auto-install any other parsers on opening new files
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<TAB>",
          node_decremental = "<S-TAB>",
        },
      },
    })
  end,
}
