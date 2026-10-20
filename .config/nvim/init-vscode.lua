-- ===========================================================================
--  init-vscode.lua — Neovim jako silnik edycji w VS Code (vscode-neovim)
--  Wlaczany w settings.json: "vscode-neovim.neovimInitVimPaths.darwin".
--
--  VS Code rysuje tekst i caly interfejs, nvim tylko edytuje bufor. Okna,
--  popupy i virtual text nvima nie sa wyswietlane, wiec which-key, fzf-lua,
--  aerial, neo-tree, precognition i colorscheme tu nie dzialaja. Zamiast nich
--  te same klawisze co w init.lua wolaja odpowiednik z VS Code.
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

-- [3] fzf-lua -> Quick Open / Quick Search
map("<leader><leader>", "workbench.action.quickOpen",            "szukaj wszystkiego (Cmd+P)")
map("<leader>ff",       "workbench.action.quickOpen",            "pliki")
map("<leader>fg",       "workbench.action.quickTextSearch",      "grep na zywo")
map("<leader>fG",       "workbench.action.findInFiles",          "grep w panelu Search")
map("<leader>fb",       "workbench.action.showAllEditors",       "otwarte edytory")
map("<leader>fo",       "workbench.action.openRecent",           "ostatnie pliki i foldery")
map("<leader>fk",       "workbench.action.openGlobalKeybindings", "wszystkie skroty")
map("<leader>fs",       "workbench.action.showAllSymbols",       "symbole w projekcie")

-- [1] which-key -> Command Palette (przy kazdej komendzie widac jej skrot)
map("<leader>?", "workbench.action.showCommands", "lista komend")

-- aerial -> Outline;  neo-tree -> Explorer
map("<leader>a", "outline.focus",                                 "spis symboli (Outline)")
map("<leader>e", "workbench.files.action.showActiveFileInExplorer", "plik w drzewie")
map("<leader>E", "workbench.action.toggleSidebarVisibility",       "pokaz/ukryj panel boczny")

-- Diagnostyka: nvim w VS Code nie ma LSP, wiec ]d [d ida do Problems
map("]d",        "editor.action.marker.next",        "nastepny blad")
map("[d",        "editor.action.marker.prev",        "poprzedni blad")
map("<leader>q", "workbench.actions.view.problems",  "wszystkie bledy (Problems)")

-- vim-tmux-navigator -> grupy edytorow i panele VS Code
map("<C-h>", "workbench.action.navigateLeft",  "panel w lewo")
map("<C-j>", "workbench.action.navigateDown",  "panel w dol")
map("<C-k>", "workbench.action.navigateUp",    "panel w gore")
map("<C-l>", "workbench.action.navigateRight", "panel w prawo")
