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

-- ===========================================================================
--  SKROTY PODSTAWOWE — z kickstart.nvim
-- ===========================================================================
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "zgas podswietlenie wyszukiwania" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "wyjdz z trybu terminala" })
-- Ctrl+h/j/k/l = okno w lewo/dol/gore/prawo — patrz vim-tmux-navigator w BAZIE

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
--  BAZA
--  UWAGA: vim.pack to NIE lazy.nvim. Spec przyjmuje TYLKO src / name /
--  version / data — klucze 'lazy', 'dependencies', 'opts', 'config' sa
--  po cichu wyrzucane (normalize_spec w runtime/lua/vim/pack.lua).
--  Zaleznosci wpisujesz recznie PRZED pluginem, setup() wolasz sam.
-- ===========================================================================
vim.pack.add({
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  gh("nvim-tree/nvim-web-devicons"),
  gh("neovim/nvim-lspconfig"),
  gh("folke/tokyonight.nvim"),
  gh("srcery-colors/srcery-vim"),

  -- nauka vima
  gh("MunifTanjim/nui.nvim"),        -- zaleznosc hardtime; wczesniej sie NIE instalowala
  gh("m4xshen/hardtime.nvim"),
  gh("tris203/precognition.nvim"),
  gh("ThePrimeagen/vim-be-good"),
  gh("stevearc/aerial.nvim"),
  gh("christoomey/vim-tmux-navigator"),
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 2  -- na starcie wszystko (nie)rozwinięte

require("hardtime").setup({ disable_mouse = false })   -- domyslnie hardtime wylacza mysz
-- Bylo: opts = { highlightFullVirtLine = true } w specu (ignorowane przez
-- vim.pack) + toggle() bez setup(). startVisible domyslnie = true.
require("precognition").setup({ highlightFullVirtLine = true })
-- aerial WYMAGA setup() — bez tego :AerialToggle nie istnieje.
require("aerial").setup()
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<cr>", { desc = "aerial: spis symboli" })

vim.cmd.colorscheme("srcery")

-- vim-tmux-navigator — 6.3k★. Ctrl+h/j/k/l przechodzi miedzy oknami nvima,
-- a na krawedzi przeskakuje do sasiedniego panelu tmuxa (druga polowa siedzi
-- w .tmux.conf jako plugin tpm). Poza tmuxem dziala jak zwykle Ctrl+w h/j/k/l.
-- Skroty ustawiamy sami, bez domyslnego Ctrl+\ (poprzedni panel).
vim.g.tmux_navigator_no_mappings = 1
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  { desc = "okno/panel tmux w lewo" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>",  { desc = "okno/panel tmux w dol" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>",    { desc = "okno/panel tmux w gore" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "okno/panel tmux w prawo" })

-- ===========================================================================
--  [P] PODPOWIEDZI SKOKOW W KOLUMNIE ZNAKOW — dopelnienie precognition
--  precognition ma na sztywno tylko 4 podpowiedzi w kolumnie: gg G { }
--  (hint_plan.lua, bez API do dodawania nowych). Ten blok dorysowuje obok
--  nich: ]] [[ (naglowki markdown) oraz ]f [f ]c [c (funkcje, klasy).
--  Liczone treesitterem tylko w widocznym fragmencie — nie zmienia stanu
--  ; , ani pozycji kursora. Wlacza/wylacza sie razem z :Precognition toggle.
-- ===========================================================================
local jh_ns = vim.api.nvim_create_namespace("pk-jump-hints")
local jh_md = vim.treesitter.query.parse("markdown", "(atx_heading) @h (setext_heading) @h")

local function jh_rows(query, capture, buf, root, top, bot)
  local rows = {}
  for id, node in query:iter_captures(root, buf, top, bot) do
    if query.captures[id] == capture then rows[#rows + 1] = (node:range()) end
  end
  table.sort(rows)
  return rows
end

local function jh_render()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, jh_ns, 0, -1)
  if vim.bo[buf].buftype ~= "" or not require("precognition").is_visible() then return end
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return end
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local top, bot = vim.fn.line("w0") - 1, vim.fn.line("w$")
  local root = parser:parse({ top, bot })[1]:root()
  local lang = parser:lang()
  local marks = {}
  local function nearest(rows, nxt_txt, prv_txt)
    local prv, nxt
    for _, r in ipairs(rows) do
      if r < row then prv = r elseif r > row and not nxt then nxt = r end
    end
    if nxt then marks[nxt] = marks[nxt] or nxt_txt end
    if prv then marks[prv] = marks[prv] or prv_txt end
  end
  if lang == "markdown" then nearest(jh_rows(jh_md, "h", buf, root, top, bot), "]]", "[[") end
  local tq = vim.treesitter.query.get(lang, "textobjects")
  if tq then
    nearest(jh_rows(tq, "function.outer", buf, root, top, bot), "]f", "[f")
    nearest(jh_rows(tq, "class.outer", buf, root, top, bot), "]c", "[c")
  end
  for r, txt in pairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, jh_ns, r, 0, { sign_text = txt, sign_hl_group = "Comment", priority = 5 })
  end
end

vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "WinScrolled", "TextChanged", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("pk-jump-hints", { clear = true }),
  callback = function() pcall(jh_render) end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
  group = "pk-jump-hints",
  callback = function(ev) vim.api.nvim_buf_clear_namespace(ev.buf, jh_ns, 0, -1) end,
})

-- ---------------------------------------------------------------------------
--  TREESITTER
--  Parsery to skompilowane biblioteki C, po jednej na jezyk (wymaga
--  tree-sitter-cli + kompilatora C). Lista nizej to tylko BAZA instalowana
--  z gory — pozostale doinstaluja sie same przy pierwszym otwarciu pliku
--  (autocmd FileType nizej, wzor z kickstart.nvim).
--  install("all") istnieje, ale dokumentacja go odradza: 323 parsery,
--  z czego tylko 10 "stable", 304 "unstable", 9 "unmaintained" — minuty
--  kompilacji, setki MB i wywrotki na porzuconych gramatykach.
-- ---------------------------------------------------------------------------
require("nvim-treesitter").install({ "python", "toml", "lua",
  "bash", "fish",
  "rust",
  "javascript", "typescript", "tsx",
  "json", "yaml", "markdown", "markdown_inline",
  "html", "css", "dockerfile", "sql", "gitcommit", "diff",
  -- IaC
  "terraform", "hcl",   -- .tf/.tfvars oraz .hcl (packer, nomad, .terraform.lock.hcl)
  "gotmpl",             -- Go templates = to, co siedzi w {{ }} w szablonach Helma
})

-- ---------------------------------------------------------------------------
--  TERRAFORM
--  Neovim sam wykrywa: *.tf -> "terraform", *.tfvars -> "terraform-vars".
--  Parser nazywa sie "terraform", wiec dla tfvars trzeba go zarejestrowac
--  recznie, inaczej pliki .tfvars zostaja bez kolorow.
-- ---------------------------------------------------------------------------
vim.treesitter.language.register("terraform", "terraform-vars")

-- ---------------------------------------------------------------------------
--  HELM
--  Problem: szablon Helma to YAML z wstrzyknietym Go template. Parser "yaml"
--  wywraca sie na {{ ... }}, wiec caly plik traci kolorowanie.
--  Rozwiazanie: traktuj plik jako Go template (parser "gotmpl"), a tekst
--  POMIEDZY dyrektywami wstrzyknij z powrotem jako YAML — to robi plik
--  after/queries/gotmpl/injections.scm.
--
--  Wzorzec lapie tylko katalog templates/, zeby Chart.yaml i values.yaml
--  (ktore sa zwyklym YAML-em) zostaly przy parserze yaml.
-- ---------------------------------------------------------------------------
--  WYMAGANE przy wlaczonym yamlls: bez tego szablony maja filetype "yaml"
--  i yamlls zglasza blad na kazdym {{ }}. Z tym dostaja "helm" -> helm_ls.
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})
vim.treesitter.language.register("gotmpl", "helm")
-- Przy KAZDYM otwarciu pliku: jest parser -> wlacz; nie ma, ale da sie
-- pobrac -> zainstaluj w tle i wlacz po instalacji; nie ma -> nic.
local ts_available = require("nvim-treesitter").get_available()
local function ts_attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if not vim.treesitter.language.add(lang) then return end
  vim.treesitter.start(buf, lang)
end
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("pk-treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then return end
    if vim.tbl_contains(require("nvim-treesitter").get_installed("parsers"), lang) then
      ts_attach(ev.buf, lang)
    elseif vim.tbl_contains(ts_available, lang) then
      require("nvim-treesitter").install(lang):await(function() ts_attach(ev.buf, lang) end)
    else
      ts_attach(ev.buf, lang)   -- parser spoza nvim-treesitter (np. wbudowany w Neovim)
    end
  end,
})

-- ---------------------------------------------------------------------------
--  LSP
--  Serwer to OSOBNY program (instalujesz go brew/rustup), nvim-lspconfig
--  daje tylko gotowe przepisy: jak go odpalic, dla jakich plikow, gdzie
--  jest root projektu (420 przepisow). vim.lsp.enable() wlacza przepis.
--  Wlaczony serwer bez zainstalowanej binarki NIE robi bledu — po prostu
--  sie nie uruchamia (sprawdzone). Diagnoza: :checkhealth vim.lsp
--  Kilka serwerow na jezyk = normalne, byle w roznych rolach (ty = typy,
--  ruff = lint+format). Dwa od typow naraz = zdublowane bledy.
-- ---------------------------------------------------------------------------
-- Instalacja binarek: ./setup-mac.sh -b  (lista BREW_LSP w setup-mac.sh)

-- lua_ls musi wiedziec, ze 'vim' to API Neovima, inaczej kazde vim.* to blad
vim.lsp.config("lua_ls", { settings = { Lua = {
  runtime = { version = "LuaJIT" },
  workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
} } })

vim.lsp.enable({
  "ty", "ruff",          -- python: typy + lint/format (rozne role, nie dubluja sie)
  "terraformls",         -- terraform
  "lua_ls",              -- lua: ten plik
  "bashls",              -- bash/sh: bledy z shellcheck
  "fish_lsp",            -- fish: config.fish
  "yamlls",              -- yaml: schematy GitHub Actions, compose, Chart.yaml (SchemaStore);
                         --   manifesty k8s wymagaja wskazania schematu (settings.yaml.schemas)
  "helm_ls",             -- helm: .Values.* z values.yaml (filetype "helm" — blok HELM wyzej)
  "markdown_oxide",      -- markdown pod Obsidiana: [[wikilinki]], tagi, backlinki,
                         --   :LspToday / :LspYesterday — notatki dzienne
  "jsonls",              -- json
  "taplo",               -- toml: pyproject.toml, Cargo.toml
  "dockerls",            -- Dockerfile
  "ts_ls",               -- typescript / tsx
})

-- [markdown] alternatywa dla markdown_oxide — tylko JEDEN z dwoch naraz:
-- vim.lsp.enable("marksman")      -- brew install marksman

-- [rust] CELOWO wylaczony. rustup (setup-mac.sh -d) instaluje atrape
-- ~/.cargo/bin/rust-analyzer nawet bez komponentu — nvim widzi plik
-- wykonywalny, probuje startowac serwer i sypie bledem przy kazdym .rs.
-- Wlaczaj razem z: rustup component add rust-analyzer
-- vim.lsp.enable("rust_analyzer")
--


-- ===========================================================================
--  PLUGINY — kazdy blok samodzielny: vim.pack.add + setup + skroty.
--  Wlaczasz, odkomentowujac CALY blok. Fiszki: srs-nvim.md, sekcja o tym
--  samym numerze. Zasada: bez fiszek nie wlaczamy — plugin, ktorego
--  skrotow nie znasz, to martwy kod.
--  Gwiazdki GitHub z 2026-10-12.
--
--  Wbudowane w Neovim, BEZ pluginu (nie instaluj zamiennikow):
--    gc / gcc     komentowanie (od 0.10; odpowiednik vim-commentary)
--    ]d [d        nastepna/poprzednia diagnostyka
--    ]q [q        quickfix;  ]<space> [<space>  pusta linia pod/nad
--    gO           spis naglowkow (markdown, help)
-- ===========================================================================

-- [1] which-key — folke, 7.3k★ ------------------------------------- AKTYWNY
--     Po wcisnieciu prefiksu (<leader>, g, z, ], [, ", ') pokazuje, co dalej.
--     Sam robi za sciage do wszystkich pozostalych pluginow.
vim.pack.add({ gh("folke/which-key.nvim") })
require("which-key").setup({})
vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "skroty tego bufora" })

-- [2] nvim-surround — kylechui, 4.3k★ ------------------------------ AKTYWNY
--     Te same klawisze co tpope/vim-surround (14.1k★, oryginal w VimScript,
--     ostatni commit 2024) i co surround wbudowany w VSCodeVim.
--     mini.surround uzywa sa/sd/sr — pamiec miesniowa by sie rozjechala.
--     setup() opcjonalne od v4.
vim.pack.add({ { src = gh("kylechui/nvim-surround"), version = vim.version.range("4.x") } })

-- [3] fzf-lua — ibhagwan, 4.5k★ ---------------------------------- AKTYWNY
--     telescope.nvim ma 19.8k★, ale LazyVim w v14 wymienil go na fzf-lua.
--     Uzywa tego samego fzf co shell: ta sama skladnia zapytan ('exact ^pre !neg).
--     Wymaga: fzf, rg, fd (masz z brew).
--     Bez skrotow tez dziala: :FzfLua files, :FzfLua live_grep, :FzfLua <Tab>
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

-- [4] gitsigns — lewis6991, 7.1k★ -------------------------------- wylaczony
--     Zmiany gita przy numerach linii + operacje na hunkach.
--     ]h/[h jak w LazyVim (README gitsigns proponuje ]c, ale ten koliduje z diffem).
-- vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
-- require("gitsigns").setup({
--   on_attach = function(buf)
--     local gs = require("gitsigns")
--     local function map(l, r, d) vim.keymap.set("n", l, r, { buffer = buf, desc = d }) end
--     map("]h", function() gs.nav_hunk("next") end, "nastepny hunk")
--     map("[h", function() gs.nav_hunk("prev") end, "poprzedni hunk")
--     map("<leader>hs", gs.stage_hunk,          "stage hunk")
--     map("<leader>hr", gs.reset_hunk,          "cofnij hunk")
--     map("<leader>hp", gs.preview_hunk_inline, "podglad hunka")
--     map("<leader>hb", gs.blame_line,          "blame linii")
--   end,
-- })
-- require("which-key").add({ { "<leader>h", group = "git hunk" } })

-- [5] nvim-treesitter-textobjects — 2.8k★, branch MAIN ------------ AKTYWNY
--     af/if ac/ic aa/ia, ]f [f ]c [c, ; , — wspolne z init-vscode.lua
require("pk.textobjects")

-- [6] flash — folke, 4.3k★ ----------------------------------------- AKTYWNY
--     s skok, S wezel treesittera, r remote (w operatorze) — wspolne z init-vscode.lua
require("pk.flash")

-- [Y] yanky — gbprod, 1.3k★ ------------------------------------------ AKTYWNY
--     p, potem <C-p>/<C-n> = starszy/nowszy wpis historii — wspolne z init-vscode.lua
require("pk.yanky")

-- [D] dial — monaqa, 1.1k★ ------------------------------------------- AKTYWNY
--     <C-a>/<C-x> tez na datach, true/false, [ ]/[x] — wspolne z init-vscode.lua
require("pk.dial")

-- [7] oil — stevearc, 6.9k★ -------------------------------------- wylaczony
--     Katalog jako zwykly bufor: zmieniasz nazwy edytujac tekst, kasujesz dd,
--     zapis :w wykonuje operacje na dysku.
-- vim.pack.add({ gh("stevearc/oil.nvim") })
-- require("oil").setup({})
-- vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "katalog nadrzedny (oil)" })

-- [E] neo-tree — 5.6k★ ----------------------------------------------- AKTYWNY
--     Drzewo plikow jak w VS Code: panel po lewej, na zadanie caly ekran. Wybor kickstart.nvim.
--     Alternatywy: nvim-tree.lua 8.7k★ (mniej zaleznosci, samo drzewo),
--     NERDTree 20k★ (VimScript, klasyk z vima). Bez pluginu: :Lexplore
--     <leader>e panel / <leader>E caly ekran jak :Ex; w drzewie ? = wszystkie skroty.
vim.pack.add({
  { src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("*") },
  gh("nvim-lua/plenary.nvim"),     -- zaleznosc; nui i web-devicons sa juz wyzej
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


-- ===========================================================================
--  NA POZNIEJ — LSP, uzupelnianie, formatowanie (z kickstart.nvim)
-- ===========================================================================

-- [L] LSP ---------------------------------------------------------------------
--     Podstawowe skroty LSP SA JUZ WBUDOWANE w Neovim 0.11+ i dzialaja
--     teraz (masz wlaczone ty, ruff, terraformls) — bez zadnego kodu:
--       K       dokumentacja pod kursorem     CTRL-]  idz do definicji
--       grr     referencje                    grn     zmien nazwe wszedzie
--       gra     akcje / szybkie poprawki      gri     implementacja
--       grt     definicja typu                gO      symbole w pliku
--       gq{ruch} formatuj przez LSP           CTRL-S  (insert) sygnatura funkcji
--     Ponizej tylko dodatki z kickstarta.
-- vim.api.nvim_create_autocmd("LspAttach", {
--   group = vim.api.nvim_create_augroup("pk-lsp-attach", { clear = true }),
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     local function map(l, r, d) vim.keymap.set("n", l, r, { buffer = ev.buf, desc = "LSP: " .. d }) end
--     map("grD", vim.lsp.buf.declaration, "deklaracja")
--     -- podswietl wszystkie wystapienia symbolu pod kursorem, gdy kursor stoi
--     if client and client:supports_method("textDocument/documentHighlight", ev.buf) then
--       local g = vim.api.nvim_create_augroup("pk-lsp-highlight", { clear = false })
--       vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, { buffer = ev.buf, group = g, callback = vim.lsp.buf.document_highlight })
--       vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { buffer = ev.buf, group = g, callback = vim.lsp.buf.clear_references })
--     end
--     -- podpowiedzi typow wstawione w tekst (wlacz/wylacz)
--     if client and client:supports_method("textDocument/inlayHint", ev.buf) then
--       map("<leader>th", function()
--         vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
--       end, "przelacz podpowiedzi typow")
--     end
--   end,
-- })

-- [8] blink.cmp — saghen, 6.6k★ ---------------------------------- wylaczony
--     Okienko z podpowiedziami podczas pisania (LSP, sciezki, slowa z bufora).
--     Zastepca nvim-cmp (9.5k★) w LazyVim i kickstarcie.
--     fuzzy = "lua": bez sciagania prekompilowanej binarki w Rust.
-- vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
-- require("blink.cmp").setup({
--   keymap = { preset = "default" },   -- <C-y> przyjmij, <C-n>/<C-p> wybor, <C-e> zamknij, <C-space> dokumentacja
--   completion = { documentation = { auto_show = false } },
--   sources = { default = { "lsp", "path", "buffer" } },
--   fuzzy = { implementation = "lua" },
--   signature = { enabled = true },
-- })

-- [9] conform — stevearc, 5.4k★ --------------------------------- wylaczony
--     Formatowanie zewnetrznymi narzedziami (ruff, stylua, terraform fmt).
--     gq z LSP formatuje tylko tam, gdzie serwer to umie; conform dziala
--     z kazdym formaterem CLI. Skrot <leader>cf, bo <leader>f to fzf.
-- vim.pack.add({ gh("stevearc/conform.nvim") })
-- require("conform").setup({
--   formatters_by_ft = {
--     python    = { "ruff_organize_imports", "ruff_format" },
--     lua       = { "stylua" },
--     terraform = { "terraform_fmt" },
--     fish      = { "fish_indent" },
--     sh        = { "shfmt" },
--   },
--   format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
-- })
-- vim.keymap.set({ "n", "v" }, "<leader>cf", function()
--   require("conform").format({ async = true, lsp_format = "fallback" })
-- end, { desc = "formatuj" })
