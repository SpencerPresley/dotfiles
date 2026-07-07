-- Docker language server configuration

vim.lsp.config.dockerls = {
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  root_markers = {
    "Dockerfile",
    ".git",
  },
}

-- Docker Compose language server
vim.lsp.config.docker_compose_language_service = {
  cmd = { "docker-compose-langserver", "--stdio" },
  filetypes = { "yaml.docker-compose" },
  root_markers = {
    "docker-compose.yaml",
    "docker-compose.yml",
    "compose.yaml",
    "compose.yml",
    ".git",
  },
}
