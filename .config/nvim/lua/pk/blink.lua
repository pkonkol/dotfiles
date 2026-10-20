-- [8] blink.cmp — saghen, 6.6k★
--     Okienko z podpowiedziami podczas pisania (LSP, sciezki, slowa z bufora).
--     Zastepca nvim-cmp (9.5k★) w LazyVim i kickstarcie.
--     fuzzy = "lua": bez sciagania prekompilowanej binarki w Rust.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
require("blink.cmp").setup({
  keymap = { preset = "default" },   -- <C-y> przyjmij, <C-n>/<C-p> wybor, <C-e> zamknij, <C-space> dokumentacja
  completion = { documentation = { auto_show = false } },
  sources = { default = { "lsp", "path", "buffer" } },
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
})
