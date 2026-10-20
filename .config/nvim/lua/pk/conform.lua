-- [9] conform — stevearc, 5.4k★
--     Formatowanie zewnetrznymi narzedziami (ruff, stylua, terraform fmt).
--     gq z LSP formatuje tylko tam, gdzie serwer to umie; conform dziala
--     z kazdym formaterem CLI. Skrot <leader>cf, bo <leader>f to fzf.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("stevearc/conform.nvim") })
require("conform").setup({
  formatters_by_ft = {
    python    = { "ruff_organize_imports", "ruff_format" },
    lua       = { "stylua" },
    terraform = { "terraform_fmt" },
    fish      = { "fish_indent" },
    sh        = { "shfmt" },
  },
  format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
})
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "formatuj" })
