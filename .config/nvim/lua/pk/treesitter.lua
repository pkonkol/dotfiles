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
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })
-- Bez tree-sitter CLI (np. Termux bez `setup-termux.sh -t`) install() sypie
-- bledem przy kazdym starcie. Wtedy zostaja parsery wbudowane w Neovim:
-- lua, vim, vimdoc, query, markdown, c.
local ts_can_build = vim.fn.executable("tree-sitter") == 1
if ts_can_build then require("nvim-treesitter").install({ "python", "toml", "lua",
  "bash", "fish",
  "rust",
  "javascript", "typescript", "tsx",
  "json", "yaml", "markdown", "markdown_inline",
  "html", "css", "dockerfile", "sql", "gitcommit", "diff",
  -- IaC
  "terraform", "hcl",   -- .tf/.tfvars oraz .hcl (packer, nomad, .terraform.lock.hcl)
  "gotmpl",             -- Go templates = to, co siedzi w {{ }} w szablonach Helma
}) end

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
    elseif ts_can_build and vim.tbl_contains(ts_available, lang) then
      require("nvim-treesitter").install(lang):await(function() ts_attach(ev.buf, lang) end)
    else
      ts_attach(ev.buf, lang)   -- parser spoza nvim-treesitter (np. wbudowany w Neovim)
    end
  end,
})
