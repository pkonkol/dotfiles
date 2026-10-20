-- ===========================================================================
--  LEADER — musi byc ustawiony PRZED jakimkolwiek mapowaniem, inaczej
--  mapowania z <leader> zlapia stara wartosc ('\').
-- ===========================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Skrot jak w kickstart.nvim: gh("folke/which-key.nvim") -> pelny URL
local function gh(repo) return "https://github.com/" .. repo end

-- ===========================================================================
--  OPCJE — z kickstart.nvim. Nic nowego do nauki, tylko lepsze domyslne.
-- ===========================================================================
vim.loader.enable()                 -- cache bajtkodu Lua, szybszy start
vim.o.number = true
vim.o.mouse = "a"                   -- mysz: klik, zaznaczanie, scroll
vim.o.breakindent = true            -- zawinieta linia zachowuje wciecie
vim.o.undofile = true               -- historia undo przetrwa zamkniecie pliku
vim.o.ignorecase = true             -- /foo znajdzie Foo...
vim.o.smartcase = true              -- ...ale /Foo juz tylko Foo
vim.o.signcolumn = "yes"            -- stala kolumna na znaczniki (diagnostyka, git) — tekst nie skacze
vim.o.updatetime = 250              -- szybsze CursorHold (podswietlenia, zapis swap)
vim.o.timeoutlen = 300              -- ile czekac na kolejny klawisz sekwencji
vim.o.splitright = true             -- :vsplit otwiera po prawej
vim.o.splitbelow = true             -- :split otwiera pod spodem
vim.o.list = true                   -- pokaz niewidoczne znaki:
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"          -- :%s/a/b/ pokazuje podglad zmian na zywo
vim.o.cursorline = true             -- podswietl linie z kursorem
vim.o.scrolloff = 10                -- trzymaj 10 linii marginesu nad/pod kursorem
vim.o.confirm = true                -- :q z niezapisanymi zmianami pyta, zamiast rzucac bledem
-- Schowek systemowy: y/p dziala z macOS (Cmd+C/V) bez "+y. Minus: kazde
-- dd/x tez nadpisuje schowek systemowy. vim.schedule = nie spowalnia startu.
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 2  -- na starcie wszystko (nie)rozwinięte

-- ===========================================================================
--  SKROTY PODSTAWOWE — z kickstart.nvim
-- ===========================================================================
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "zgas podswietlenie wyszukiwania" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "wyjdz z trybu terminala" })
-- Ctrl+h/j/k/l = okno w lewo/dol/gore/prawo — patrz lua/pk/tmux_navigator.lua

-- Mignij skopiowanym tekstem — widac, CO dokladnie poszlo do rejestru
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("pk-highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Diagnostyka (bledy z LSP: ty, ruff, terraformls)
vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  -- ]d / [d od razu pokazuje pelny komunikat w okienku
  jump = { on_jump = function(_, bufnr)
    vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
  end },
})
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "wszystkie bledy pliku na liste" })


-- ===========================================================================
--  PLUGINY — tu te z konfiguracja do 3 linii: jeden vim.pack.add + setup.
--  Wieksze maja wlasny plik lua/pk/<nazwa>.lua z vim.pack.add w srodku;
--  wlaczasz je jednym require ponizej.
--  Zasada: bez fiszek nie wlaczamy — plugin, ktorego skrotow nie znasz,
--  to martwy kod. Gwiazdki GitHub z 2026-10-12.
--
--  UWAGA: vim.pack to NIE lazy.nvim. Spec przyjmuje TYLKO src / name /
--  version / data — klucze 'lazy', 'dependencies', 'opts', 'config' sa
--  po cichu wyrzucane (normalize_spec w runtime/lua/vim/pack.lua).
--  Zaleznosci wpisujesz recznie PRZED pluginem.
--  Ten sam plugin w dwoch vim.pack.add musi miec ten sam spec (version),
--  inaczej inity przepisuja sobie nvim-pack-lock.json. Drugi add to no-op.
--
--  Wbudowane w Neovim, BEZ pluginu (nie instaluj zamiennikow):
--    gc / gcc     komentowanie (od 0.10; odpowiednik vim-commentary)
--    ]d [d        nastepna/poprzednia diagnostyka
--    ]q [q        quickfix;  ]<space> [<space>  pusta linia pod/nad
--    gO           spis naglowkow (markdown, help)
-- ===========================================================================
vim.pack.add({
  gh("nvim-tree/nvim-web-devicons"),
  gh("folke/tokyonight.nvim"),
  gh("srcery-colors/srcery-vim"),
  gh("ThePrimeagen/vim-be-good"),    -- :VimBeGood w pustym buforze, bez configu
  gh("MunifTanjim/nui.nvim"),        -- zaleznosc hardtime
  gh("m4xshen/hardtime.nvim"),
  gh("stevearc/aerial.nvim"),
  -- [2] nvim-surround — kylechui, 4.3k★, bez configu (setup() opcjonalne od v4).
  --     Te same klawisze co tpope/vim-surround (14.1k★, oryginal w VimScript,
  --     ostatni commit 2024) i co surround wbudowany w VSCodeVim.
  --     mini.surround uzywa sa/sd/sr — pamiec miesniowa by sie rozjechala.
  { src = gh("kylechui/nvim-surround"), version = vim.version.range("4.x") },
  -- [7] oil — stevearc, 6.9k★: katalog jako zwykly bufor; zmieniasz nazwy
  --     edytujac tekst, kasujesz dd, zapis :w wykonuje operacje na dysku.
  -- gh("stevearc/oil.nvim"),
})

vim.cmd.colorscheme("srcery")
-- hardtime — nauka vima: blokuje powtarzanie hjkl, podpowiada lepszy ruch
require("hardtime").setup({ disable_mouse = false })   -- domyslnie hardtime wylacza mysz
-- aerial WYMAGA setup() — bez tego :AerialToggle nie istnieje.
require("aerial").setup()
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<cr>", { desc = "aerial: spis symboli" })
-- require("oil").setup({})
-- vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "katalog nadrzedny (oil)" })

-- Moduly ponizej same instaluja swoje pluginy (vim.pack.add w pliku).
require("pk.precognition")     -- + podpowiedzi ]] [[ ]f [f ]c [c w kolumnie znakow
require("pk.tmux_navigator")
require("pk.treesitter")       -- parsery, terraform, helm
require("pk.lsp")
require("pk.which_key")        -- [1]
require("pk.fzf")              -- [3]
-- require("pk.gitsigns")      -- [4]
require("pk.textobjects")      -- [5] af/if ac/ic aa/ia, ]f [f ]c [c, ; ,
require("pk.flash")            -- [6] s skok, S wezel treesittera, r remote
require("pk.yanky")            -- [Y] p, potem <C-p>/<C-n>
require("pk.dial")             -- [D] <C-a>/<C-x> tez na datach, true/false, [ ]/[x]
require("pk.neo_tree")         -- [E]
-- require("pk.lsp_attach")    -- [L]
-- require("pk.blink")         -- [8]
-- require("pk.conform")       -- [9]
