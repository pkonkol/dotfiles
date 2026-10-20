-- ===========================================================================
--  init-obsidian.lua — nvim jako silnik edycji w Obsidianie (wtyczka Vim Motions,
--  backend Neovim). Settings -> Vim Motions -> Neovim configuration path.
--
--  Klawisze trzyma nvim; wbudowany silnik vima wtyczki wtedy sie wylacza.
--  Obsidian rysuje floaty i extmarki nvima, wiec which-key.nvim dziala.
--  Po stronie Obsidiana zostaja: picker (<leader>f*, zamiast fzf-lua), harpoon,
--  oil, hint mode, pasek statusu. Text objects Markdowna i ]h [h daje wtyczka.
--
--  lua/vim_motions.lua generuje wtyczka z wlasnych ustawien (surround, yanky,
--  flash, LuaSnip, mini.operators na gr, dial) i nadpisuje go sama — nie edytuj,
--  zmiany wpisuj PO require. Leader ustawia motions-plugin.lua.
-- ===========================================================================
local function gh(repo) return "https://github.com/" .. repo end

-- Pluginy, ktore konfiguruje vim_motions.lua. Spec taki jak w init.lua —
-- inny 'version' przepisuje wspolny nvim-pack-lock.json przy kazdym starcie.
vim.pack.add({
  { src = gh("kylechui/nvim-surround"), version = vim.version.range("4.x") },
  gh("folke/flash.nvim"),
  gh("gbprod/yanky.nvim"),
  gh("L3MON4D3/LuaSnip"),
  gh("echasnovski/mini.operators"),
  gh("monaqa/dial.nvim"),          -- blok tylko przy wlaczonym "Enhanced increment/decrement"
})
require("vim_motions")

-- nauka vima
vim.pack.add({ gh("MunifTanjim/nui.nvim"), gh("m4xshen/hardtime.nvim") })
require("hardtime").setup({ disable_mouse = false })   -- domyslnie hardtime wylacza mysz

-- [1] which-key — jak w init.lua. Grupe +find dla pickera dopisuje tez wtyczka.
vim.pack.add({ gh("folke/which-key.nvim") })
require("which-key").setup({})
vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "skroty tego bufora" })
