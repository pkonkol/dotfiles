-- [6] flash — folke, 4.3k★
--     Wspolny dla init.lua (terminal) i init-vscode.lua (VS Code rysuje etykiety
--     jako dekoracje). Obsidian: wbudowany flash wtyczki Vim Motions.
--     Skok w dowolne widoczne miejsce: s + znaki + etykieta. Nastepca
--     easymotion/sneak; leap.nvim (5.0k★) to alternatywa, flash = konwencja LazyVim.
--     f/F/t/T: etykiety na celach + powtarzanie tym samym klawiszem (f x, potem
--     f f f; F wstecz). ; i , zostaja dla pk/textobjects.lua (powtarzaja ]f [f ]c [c),
--     dlatego nie ma ich w keys.
--     Nadpisuje wbudowane 's' (= 'cl'). S tylko w n/o — w visual S nalezy do nvim-surround.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("folke/flash.nvim") })
require("flash").setup({
  modes = { char = { jump_labels = true, keys = { "f", "F", "t", "T" } } },
})
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end,       { desc = "flash" })
vim.keymap.set({ "n", "o" },      "S", function() require("flash").treesitter() end, { desc = "flash: wezel treesittera" })
vim.keymap.set("o",               "r", function() require("flash").remote() end,     { desc = "flash: remote" })
