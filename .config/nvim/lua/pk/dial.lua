-- dial — monaqa, 1.1k★
--     Rozszerza <C-a> / <C-x> (+1 / -1 pod kursorem albo dalej w linii).
--     Wspolny dla init.lua i init-vscode.lua. Lista obiektow jak w bloku, ktory
--     generuje Vim Motions do vim_motions.lua — w Obsidianie dziala tak samo.
--     Obiekty: liczby, hex, daty 2026-10-20 i 2026/10/20, true/false,
--     kolory #a1b2c3, checkbox [ ] <-> [x].
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("monaqa/dial.nvim") })
local augend = require("dial.augend")
require("dial.config").augends:register_group({
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.date.new({ pattern = "%Y-%m-%d", default_kind = "day" }),
    augend.date.new({ pattern = "%Y/%m/%d", default_kind = "day" }),
    augend.constant.alias.bool,
    augend.hexcolor.new({ case = "lower" }),
    augend.constant.new({ elements = { "[ ]", "[x]" }, word = false, cyclic = true }),
  },
})
vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal(), { desc = "+1 (dial)" })
vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal(), { desc = "-1 (dial)" })
vim.keymap.set("v", "<C-a>", require("dial.map").inc_visual(), { desc = "+1 w zaznaczeniu (dial)" })
vim.keymap.set("v", "<C-x>", require("dial.map").dec_visual(), { desc = "-1 w zaznaczeniu (dial)" })
