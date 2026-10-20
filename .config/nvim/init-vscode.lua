-- ===========================================================================
--  init-vscode.lua — Neovim jako silnik edycji w VS Code (vscode-neovim)
--  Wlaczany w settings.json: "vscode-neovim.neovimInitVimPaths.darwin".
--
--  VS Code rysuje tekst i caly interfejs, nvim tylko edytuje bufor. Okna,
--  popupy i virtual text nvima nie sa wyswietlane, wiec which-key, fzf-lua,
--  aerial, neo-tree, precognition i colorscheme tu nie dzialaja. Zamiast nich
--  te same klawisze co w init.lua wolaja odpowiednik z VS Code, a <leader>
--  otwiera menu VSpaceCode.whichkey.
--
--  Bez kodu, z vscode-neovim: K gd gD gO gh, wbudowane grr grn gra gri
--  (vim.lsp.buf przekierowany do VS Code), Ctrl+w s/v/q/o (edytory VS Code).
-- ===========================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local function gh(repo) return "https://github.com/" .. repo end
local vscode = require("vscode")

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.o.clipboard = "unnamedplus"     -- vscode-neovim podpina pod to schowek VS Code

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "zgas podswietlenie wyszukiwania" })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("pk-highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- ===========================================================================
--  EDYCJA — to samo co w terminalu
-- ===========================================================================
vim.pack.add({
  gh("MunifTanjim/nui.nvim"),
  gh("m4xshen/hardtime.nvim"),
  { src = gh("kylechui/nvim-surround"), version = vim.version.range("4.x") },
})
require("hardtime").setup({ disable_mouse = false })
require("pk.textobjects")

-- ===========================================================================
--  UI — klawisze z init.lua, akcja z VS Code
-- ===========================================================================
local function code(command) return function() vscode.action(command) end end
local function map(lhs, command, desc) vim.keymap.set("n", lhs, code(command), { desc = desc }) end

-- [1] which-key + [3] fzf-lua -> menu VSpaceCode.whichkey. Cala zawartosc
--     menu (<leader>ff, fg, a, e, q...) siedzi w .config/vscode/settings/20-neovim.jsonc.
map("<leader>", "whichkey.show", "menu which-key")

-- Foldy rysuje VS Code; vscode-neovim wylacza foldy nvima i nie mapuje z*
map("zc", "editor.fold",       "zwin")
map("zo", "editor.unfold",     "rozwin")
map("za", "editor.toggleFold", "przelacz zwiniecie")
map("zM", "editor.foldAll",    "zwin wszystko")
map("zR", "editor.unfoldAll",  "rozwin wszystko")

-- Diagnostyka: nvim w VS Code nie ma LSP, wiec ]d [d ida do Problems
map("]d",        "editor.action.marker.next",        "nastepny blad")
map("[d",        "editor.action.marker.prev",        "poprzedni blad")

-- vim-tmux-navigator -> grupy edytorow i panele VS Code
map("<C-h>", "workbench.action.navigateLeft",  "panel w lewo")
map("<C-j>", "workbench.action.navigateDown",  "panel w dol")
map("<C-k>", "workbench.action.navigateUp",    "panel w gore")
map("<C-l>", "workbench.action.navigateRight", "panel w prawo")
