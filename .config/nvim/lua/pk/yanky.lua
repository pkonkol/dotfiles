-- yanky — gbprod, 1.3k★
--     Historia kopiowania (yank ring). Wspolny dla init.lua i init-vscode.lua;
--     Obsidian dostaje to samo z vim_motions.lua (te same klawisze).
--     p / P wklejaja jak zwykle; zaraz po wklejeniu <C-p> / <C-n> podmienia
--     wklejony tekst na starszy / nowszy wpis z historii.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("gbprod/yanky.nvim") })
require("yanky").setup({})
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)",      { desc = "wklej za (yanky)" })
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)",     { desc = "wklej przed (yanky)" })
vim.keymap.set("n",          "<C-p>", "<Plug>(YankyPreviousEntry)", { desc = "wklejone -> starszy wpis z historii" })
vim.keymap.set("n",          "<C-n>", "<Plug>(YankyNextEntry)",     { desc = "wklejone -> nowszy wpis z historii" })
