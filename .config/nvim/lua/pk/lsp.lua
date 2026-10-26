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
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("neovim/nvim-lspconfig") })
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
  "tsc",                 -- typescript / tsx: natywny TS 7 (tsc --lsp); starszy tsc z node_modules pomija
})

-- [markdown] alternatywa dla markdown_oxide — tylko JEDEN z dwoch naraz:
-- vim.lsp.enable("marksman")      -- brew install marksman

-- [rust] CELOWO wylaczony. rustup (setup-mac.sh -d) instaluje atrape
-- ~/.cargo/bin/rust-analyzer nawet bez komponentu — nvim widzi plik
-- wykonywalny, probuje startowac serwer i sypie bledem przy kazdym .rs.
-- Wlaczaj razem z: rustup component add rust-analyzer
-- vim.lsp.enable("rust_analyzer")
