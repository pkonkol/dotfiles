local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({
  gh("L3MON4D3/LuaSnip"),
  gh("echasnovski/mini.operators"),
  gh("folke/flash.nvim"),
  gh("gbprod/yanky.nvim"),
  gh("kylechui/nvim-surround"),
  -- { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  -- gh("nvim-tree/nvim-web-devicons"),
  -- gh("neovim/nvim-lspconfig"),
  -- gh("folke/tokyonight.nvim"),
  -- gh("srcery-colors/srcery-vim"),

  -- nauka vima
  -- gh("MunifTanjim/nui.nvim"),        -- zaleznosc hardtime; wczesniej sie NIE instalowala
  gh("m4xshen/hardtime.nvim"),
  -- gh("tris203/precognition.nvim"),
  -- gh("ThePrimeagen/vim-be-good"),
  -- gh("stevearc/aerial.nvim"),
  -- gh("christoomey/vim-tmux-navigator"),
})

require('vim_motions')
require("hardtime").setup({ disable_mouse = false })   -- domyslnie hardtime wylacza mysz
--
-- vim.pack.add({ gh("folke/which-key.nvim") })
-- require("which-key").setup({})
-- vim.keymap.set("n", "<leader>?", function()
--   require("which-key").show({ global = false })
-- end, { desc = "skroty tego bufora" })

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
