vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/srcery-colors/srcery-vim",
})

vim.cmd.colorscheme("srcery")

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
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})
vim.treesitter.language.register("gotmpl", "helm")
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "python", "toml", "lua" },
--   callback = function() pcall(vim.treesitter.start) end,
-- })
vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.start) end,
})

-- ---------------------------------------------------------------------------
--  LSP
--    terraformls — oficjalny od HashiCorp: brew install hashicorp/tap/terraform-ls
--    helm_ls     — mrjosh/helm-ls; w brew jako "helm-ls" (sprawdz: brew search helm-ls)
--                  Daje podpowiedzi do .Values.* czytane z values.yaml.
-- ---------------------------------------------------------------------------
vim.lsp.enable({ "ty", "ruff", "terraformls" })
--vim.lsp.enable({ "helm_ls" })
