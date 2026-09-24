vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/srcery-colors/srcery-vim",
})

vim.cmd.colorscheme("srcery")

require("nvim-treesitter").install({ "python", "toml", "lua",
  "bash", "fish",
  "rust",
  "javascript", "typescript", "tsx",
  "json", "yaml", "markdown", "markdown_inline",
  "html", "css", "dockerfile", "sql", "gitcommit", "diff",
})
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "python", "toml", "lua" },
--   callback = function() pcall(vim.treesitter.start) end,
-- })
vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.start) end,
})

vim.lsp.enable({ "ty", "ruff" })
