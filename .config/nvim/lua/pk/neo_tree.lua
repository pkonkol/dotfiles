-- [E] neo-tree — 5.6k★
--     Drzewo plikow jak w VS Code: panel po lewej, na zadanie caly ekran. Wybor kickstart.nvim.
--     Alternatywy: nvim-tree.lua 8.7k★ (mniej zaleznosci, samo drzewo),
--     NERDTree 20k★ (VimScript, klasyk z vima). Bez pluginu: :Lexplore
--     <leader>e panel / <leader>E caly ekran jak :Ex; w drzewie ? = wszystkie skroty.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({
  { src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("*") },
  gh("nvim-lua/plenary.nvim"),
  gh("MunifTanjim/nui.nvim"),
  gh("nvim-tree/nvim-web-devicons"),
})
require("neo-tree").setup({
  window = {
    -- w = "otworz w wybranym oknie", wymaga pluginu nvim-window-picker; bez niego blad
    mappings = { ["w"] = "noop" },
  },
  filesystem = {
    follow_current_file = { enabled = true },   -- drzewo podswietla otwarty plik
    hijack_netrw_behavior = "open_current",     -- :Ex, :e ., nvim . -> neo-tree na caly ekran
  },
})
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>",          { desc = "drzewo plikow (panel)" })
vim.keymap.set("n", "<leader>E", "<cmd>Neotree position=current reveal<cr>", { desc = "drzewo plikow (caly ekran)" })
