-- [3] fzf-lua — ibhagwan, 4.5k★
--     telescope.nvim ma 19.8k★, ale LazyVim w v14 wymienil go na fzf-lua.
--     Uzywa tego samego fzf co shell: ta sama skladnia zapytan ('exact ^pre !neg).
--     Wymaga: fzf, rg, fd (masz z brew).
--     Bez skrotow tez dziala: :FzfLua files, :FzfLua live_grep, :FzfLua <Tab>
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("ibhagwan/fzf-lua") })
require("fzf-lua").setup({})
require("which-key").add({ { "<leader>f", group = "find" } })
local function fzf(fn) return function() require("fzf-lua")[fn]() end end
vim.keymap.set("n", "<leader>ff", fzf("files"),     { desc = "pliki" })
vim.keymap.set("n", "<leader>fg", fzf("live_grep"), { desc = "grep na zywo" })
vim.keymap.set("n", "<leader>fb", fzf("buffers"),   { desc = "bufory" })
vim.keymap.set("n", "<leader>fo", fzf("oldfiles"),  { desc = "ostatnie pliki" })
vim.keymap.set("n", "<leader>fk", fzf("keymaps"),   { desc = "wszystkie skroty" })
vim.keymap.set("n", "<leader>fh", fzf("helptags"),  { desc = "help" })
vim.keymap.set("n", "<leader>fr", fzf("resume"),    { desc = "wznow ostatnie szukanie" })
-- Jak Cmd+P w VS Code: bez prefiksu pliki, '$' bufory, '@' symbole w pliku, '#' w projekcie
vim.keymap.set("n", "<leader><leader>", fzf("global"), { desc = "szukaj wszystkiego (Cmd+P)" })
