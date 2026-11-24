-- [S] statuscol — luukvbaal, 612★
--     Lewa kolumna jak w VS Code: strzalki foldow bez cyfr poziomow, wszystko klikalne.
--     Klik: strzalka = zwin/rozwin (Ctrl+klik = z zagniezdzonymi),
--           znaczek bledu = okienko z trescia (srodkowy = code action),
--           znaczek gita = podglad hunka (gdy wlaczone gitsigns),
--           numer linii: srodkowy = yank linii.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("luukvbaal/statuscol.nvim") })
local builtin = require("statuscol.builtin")
require("statuscol").setup({
  segments = {
    { sign = { namespace = { "diagnostic" }, maxwidth = 1 }, click = "v:lua.ScSa" },  -- bledy LSP
    { sign = { name = { ".*" }, namespace = { ".*" }, maxwidth = 1, colwidth = 2 }, click = "v:lua.ScSa" }, -- reszta (git, jump-hints)
    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
    { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },                       -- strzalki przy tekscie
  },
})
